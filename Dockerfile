FROM        centos-base
RUN         yum install -y httpd 
RUN         yum install -y openssh-server
RUN         yum install -y http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN         yum install -y supervisor 
RUN         yum install -y mercurial 
RUN         sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN         sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
ADD         supervisord.conf /etc/supervisord.conf
ADD         start.sh    /opt/start.sh
EXPOSE      80 22
USER	    root 
