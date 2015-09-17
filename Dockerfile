FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
	&& apt-get -y install \
	    wget \
	    build-essential \
	    apache2 \
	    apache2-utils \
	    php5-gd \
	    libgd2-xpm-dev \
	    libapache2-mod-php5 \
	    postfix \
	    unzip \
	    heirloom-mailx \
	    libssl-dev \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

RUN useradd --system --home /usr/local/nagios -M nagios \
	&& groupadd --system nagcmd \
	&& usermod -a -G nagcmd nagios \ 
	&& usermod -a -G nagcmd www-data

RUN cd /tmp  \
	&& wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.1.1.tar.gz \
	&& tar -zxvf nagios-4.1.1.tar.gz \
	&& cd /tmp/nagios-4.1.1  \
	&& ./configure \
		--with-nagios-group=nagios \
		--with-command-group=nagcmd \
		--with-mail=/usr/sbin/sendmail \
		--with-httpd_conf=/etc/apache2/conf-available \
	&& make all \
	&& make install \
	&& make install-init \
	&& make install-config \
	&& make install-commandmode \
	&& make install-webconf \
	&& cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/ \
	&& chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers \
	&& ln -s /etc/init.d/nagios /etc/rcS.d/S99nagios \
	&& rm -rf /tmp/nagios-4.1.1*
	

RUN cd /tmp \
	&& wget http://www.nagios-plugins.org/download/nagios-plugins-2.1.1.tar.gz \
	&& tar -zxvf nagios-plugins-2.1.1.tar.gz \
	&& cd /tmp/nagios-plugins-2.1.1 \
	&& ./configure \
		--with-nagios-user=nagios \
		--with-nagios-group=nagios \
		--enable-perl-modules \
		--enable-extra-opts \
	&& make \
	&& make install \
	&& rm -rf /tmp/nagios-plugins-2.1.1*
RUN cd /tmp \
	&& wget http://sourceforge.net/projects/nagios/files/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz \
	&& tar -zxvf nrpe-2.15.tar.gz \
	&& cd nrpe-2.15 \
	&& ./configure \
		--with-ssl=/usr/bin/openssl \
		--with-ssl-lib=/usr/lib/x86_64-linux-gnu \
	&& make all \
	&& make install-plugin \
	&& rm -rf /tmp/nrpe-2.15*

 
RUN a2enmod cgi

ADD htpasswd.users /usr/local/nagios/etc/htpasswd.users
ADD 000-default.conf /etc/apache2/sites-enabled/000-default.conf
ADD entrypoint.sh /entrypoint.sh

EXPOSE 80
VOLUME /usr/local/nagios/etc/

ENTRYPOINT ["/entrypoint.sh"]
