#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

echo "[INFO] Generating Nagios Admin Username/Password ..."
: ${NAGIOSADMIN_USER:="nagiosadmin"}
: ${NAGIOSADMIN_PASS:="nagios"}
/usr/bin/htpasswd -Bbn ${NAGIOSADMIN_USER} ${NAGIOSADMIN_PASS} > /usr/local/nagios/etc/htpasswd.users
echo "[INFO] Done."

echo "[INFO] Configurating Slack ..."
sed -i "/^my \$opt_domain =/c my \$opt_domain = \"${SLACK_DOMAIN}\";" ${SLACK_NAGIOS}
sed -i "/^my \$opt_token =/c my \$opt_token = \"${SLACK_TOKEN}\";" ${SLACK_NAGIOS}
echo "[INFO] Done."

echo "[INFO] Fix permissions ..."
chown -R nagios:nagios /usr/local/nagios
chown -R nagios:www-data /usr/local/nagios/var/rw
echo "[INFO] Done."

echo "[INfO] Launching Supervisord ..."
cat > /etc/supervisor/conf.d/supervisord.conf <<EOF
[program:nagios]
command=/usr/local/nagios/bin/nagios /usr/local/nagios/etc/nagios.cfg

[program:apache2]
command=/bin/bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"
EOF

# Launch supervisord
exec /usr/bin/supervisord --nodaemon --loglevel debug

