
FROM centos:centos6

# epel
RUN yum -y install wget yum-utils && \
  wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm -O /root/epel-release-6-8.noarch.rpm && \
  rpm -Uvh /root/epel-release-6-8.noarch.rpm

# fish
RUN yum-config-manager --add-repo http://fishshell.com/files/linux/RedHat_RHEL-6/fish.release:2.repo

# install postgresql repo
RUN sed -i "s/\\[base\\]/[base]\\nexclude=postgresql*/" /etc/yum.repos.d/CentOS-Base.repo && \
  sed -i "s/\\[updates\\]/[updates]\\nexclude=postgresql*/" /etc/yum.repos.d/CentOS-Base.repo && \
  yum -y localinstall https://download.postgresql.org/pub/repos/yum/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-3.noarch.rpm

# packages
RUN yum -y update && \
  yum groupinstall -y 'development tools' && \
  yum -y install git fish htop gcc pychart postgresql93-devel byobu bzr openssh-server \
  vim pwgen xz-libs zlib-devel bzip2-devel openssl-devel xz-libs ncurses-devel curl \
  curl-devel libxslt-devel openldap-devel tar libjpeg-devel wget sqlite-devel readline-devel \
  tk-devel gdbm-devel db4-devel libffi-devel libxslt libxml2 libxml2-devel libjpeg-turbo-devel \
  openjpeg-devel libtiff-devel libpng libXext libz.so.1 xorg-x11-fonts-Type1 cabextract nodejs \
  npm

# Install additional fonts
RUN rpm -ivh https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# Install python 2.7
RUN wget http://www.python.org/ftp/python/2.7.9/Python-2.7.9.tar.xz && \
  xz -d Python-2.7.9.tar.xz && \
  tar -xvf Python-2.7.9.tar && \
  cd Python-2.7.9 && \
  ./configure --prefix=/usr/local && \
  make && \
  make altinstall && \
  export PATH="/usr/local/bin:$PATH" && \
  cd ..

# Install pip
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
  python2.7 get-pip.py

# Install python dependencies
RUN pip2.7 install "babel>=1.0" decorator docutils feedparser gevent Jinja2 lxml mako \
  mock passlib "pillow<=3.4.2" psutil psycogreen "psycopg2>=2.2" "pydot<1.2.0" "pyparsing<2" pypdf pyserial \
  python-dateutil python-ldap python-openid pytz pyusb>=1.0.0b1 pyyaml qrcode reportlab \
  requests simplejson unittest2 vatnumber vobject werkzeug xlwt MarkupSafe PyWebDAV \
  "gdata>=2.0.11" "supervisor>=3.0" "virtualenv>=1.11.4" pudb flask wsgiref \
  suds-jurko ofxparse jcconv argparse Python-Chart pysftp && \
  pip2.7 install https://nicolas-van.github.io/variousfiles/PyChart-1.39.tar.gz

# supervisord
ADD ./supervisord.conf /etc/supervisord.conf

# install wkhtmltopdf
RUN wget http://nicolas-van.github.io/variousfiles/wkhtmltox-linux-amd64_0.12.0-03c001d.tar.xz && \
  tar -Jxvf wkhtmltox*.tar.xz && \
  cp wkhtmltox/bin/wkhtmltopdf /usr/bin/wkhtmltopdf && \
  chmod 755 /usr/bin/wkhtmltopdf

# install less
RUN npm config set strict-ssl false && \
  npm install -g less less-plugin-clean-css

# ssh service
# (it's necessary to disable pam)
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
  sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
  sed -i "s/\#UseDNS yes/UseDNS no/" /etc/ssh/sshd_config && \
  sed -i "s/GSSAPIAuthentication yes/GSSAPIAuthentication no/" /etc/ssh/sshd_config

# user
RUN adduser user

ADD ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22
VOLUME ["/home/user", "/tmp", "/var/tmp"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord"]
