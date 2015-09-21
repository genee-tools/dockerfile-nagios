# dockerfile-nagios

nagios dockerfile

## Usage

docker run -d --name=nagios -p 80:80 -v /home/nagios/:/usr/local/nagios -v /home/nagios/nail.rc:/etc/nail.rc genee/nagios
