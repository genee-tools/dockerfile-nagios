FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

RUN apt-get -y install \
    wget \
    build-essential \
    apache2 \
    apache2-utils \
    php5-gd \
    libgd2-xpm-dev \
    libapache2-mod-php5 \
    postfix \
    unzip

RUN useradd --system --home /usr/local/nagios -M nagios
RUN groupadd --system nagcmd
RUN usermod -a -G nagcmd nagios
RUN usermod -a -G nagcmd www-data

RUN cd /tmp && \
	wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.1.1.tar.gz && \
	wget http://www.nagios-plugins.org/download/nagios-plugins-2.1.1.tar.gz && \
	tar -zxvf nagios-4.1.1.tar.gz && \
	tar -zxvf nagios-plugins-2.1.1.tar.gz

RUN cd /tmp/nagios-4.1.1 && ./configure \
	--with-nagios-group=nagios \
	--with-command-group=nagcmd \
	--with-mail=/usr/sbin/sendmail \
	--with-httpd_conf=/etc/apache2/conf-available

RUN cd /tmp/nagios-4.1.1 && make all
RUN cd /tmp/nagios-4.1.1 && make install
RUN cd /tmp/nagios-4.1.1 && make install-init
RUN cd /tmp/nagios-4.1.1 && make install-config
RUN cd /tmp/nagios-4.1.1 && make install-commandmode
RUN cd /tmp/nagios-4.1.1 && make install-webconf
RUN cd /tmp/nagios-4.1.1 && cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/
RUN cd /tmp/nagios-4.1.1 && chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers
RUN /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
RUN ln -s /etc/init.d/nagios /etc/rcS.d/S99nagios

RUN cd /tmp/nagios-plugins-2.1.1 && ./configure \
	--with-nagios-user=nagios \
	--with-nagios-group=nagios \
	--enable-perl-modules \
	--enable-extra-opts 
RUN cd /tmp/nagios-plugins-2.1.1 && make
RUN cd /tmp/nagios-plugins-2.1.1 && make install

RUN a2enmod cgi

ADD htpasswd.users /usr/local/nagios/etc/htpasswd.users
ADD 000-default.conf /etc/apache2/sites-enabled/000-default.conf
ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
