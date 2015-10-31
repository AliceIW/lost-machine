#!/usr/bin/env bash

MYSQL_PWD='root'

# Setting up configuration
# MYSQL
debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password password $MYSQL_PWD"
debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password_again password $MYSQL_PWD"

apt-get update

# Install Apache 2.4 PHP5 Mysql Phpunit Git
apt-get install -y apache2 php5 php5-mysql php5-curl php5-mcrypt php5-xsl php5-xdebug mysql-server-5.5 phpunit git git-extras
php5enmod mcrypt

# php.ini - date.timezone = "Europe/London"
find /etc/php5/ -type f -iname 'php.ini' | xargs -n1 -i@ sh -c \
    'sed -r -i "s/^;?(date\.timezone)\b.*/\1 = \"Europe\/London\"/" "@"'

# php.ini - short_open_tag = On
find /etc/php5/ -type f -iname 'php.ini' | xargs -n1 -i@ sh -c \
    'sed -r -i "s/^(short_open_tag)\b.*/\1 = On/" "@"'

# php.ini - error_reporting = E_ALL
find /etc/php5/ -type f -iname 'php.ini' | xargs -n1 -i@ sh -c \
    'sed -r -i "s/^;?(error_reporting)\b.*/\1 = E_ALL/" "@"'

# php.ini - display_errors = On
find /etc/php5/ -type f -iname 'php.ini' | xargs -n1 -i@ sh -c \
    'sed -r -i "s/^;?(display_errors)\b.*/\1 = On/" "@"'

# Install Composer
if [ ! -f /usr/local/bin/composer ]; then
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin
  ln -s composer.phar /usr/local/bin/composer
else
  /usr/local/bin/composer self-update
fi

# install wkhtmltopdf
if [ ! -f /usr/local/bin/wkhtmltopdf ]; then
  curl -OsSL http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb
  dpkg -i wkhtmltox *.deb
  apt-get -q -y -f install
fi

# LAMP CONF START

if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi

# Allow xdebug remote connections
if [ "$(grep 'xdebug.remote_enable = 1' /etc/php5/mods-available/xdebug.ini >/dev/null 2>&1; echo $?)" != "0" ]; then
  echo "xdebug.remote_enable = 1
xdebug.profiler_enable_trigger = 1
xdebug.profiler_output_name = cachegrind.out.%t
" | tee -a /etc/php5/mods-available/xdebug.ini >/dev/null
fi

# LAMP CONF END


apt-get install -y npm

if [ ! -h /usr/bin/node ]; then
  ln -s /usr/bin/nodejs /usr/bin/node
fi

# Install Bower
if [ ! -f /usr/local/bin/bower ]; then
 npm install -g bower
fi

# Restart Apache

apache2ctl restart
apache2ctl start >/dev/null # really make sure apache is started


# Clean packages
apt-get -q -y autoremove
apt-get -q -y autoclean

echo "Provision complete"