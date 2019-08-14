#!/bin/bash

##########################################################################
# Check supported DISTRO_NAME
##########################################################################

# Locate *NIX distribution by looking for match from various detection strategies
# We start with /etc/os-release, as this will also work for Docker containers
for command in "grep -E \"^NAME=\" /etc/os-release" \
               "lsb_release -i" \
               "cat /proc/version" \
               "uname -a" ; do
    distro_string=$(eval $command 2>/dev/null)
    unset DISTRO_NAME
    if [[ ${distro_string,,} == *"debian"* ]]; then
      DISTRO_NAME=Debian
    elif [[ ${distro_string,,} == *"red hat"* ]]; then
      DISTRO_NAME=RedHat
    elif [[ ${distro_string,,} == *"centos"* ]]; then
      DISTRO_NAME=CentOS
    elif [[ ${distro_string,,} == *"ubuntu"* ]]; then
      DISTRO_NAME=Ubuntu
    elif [[ ${distro_string,,} == *"suse"* ]]; then
      echo "Sorry, this script does not support Suse."
      exit 1
    elif [[ ${distro_string,,} == *"darwin"* ]]; then
      echo "Sorry, this script does not support macOS."
      exit 1
    fi
    if [[ $DISTRO_NAME ]] ; then break ; fi
done
if [[ ! $DISTRO_NAME ]] ; then
  echo -e "\nERROR: Unable to auto-detect your *NIX distribution!\n" 1>&2
  exit 1
fi

##########################################################################
# Configuration global variables
##########################################################################

# Install folder path
CKAN_INSTALL_DIR="$(dirname "$(dirname "$(readlink -fm "$0")")")"
CKAN_INSTALL_SOLR_DIR=$CKAN_INSTALL_DIR/solr-conf
CKAN_INSTALL_SOLR_SCHEMA=$CKAN_INSTALL_DIR/ckan/config/solr/managed-schema
CKAN_INSTALL_APACHE_DIR=$CKAN_INSTALL_DIR/apache-conf
CKAN_INSTALL_APACHE_WSGI=$CKAN_INSTALL_APACHE_DIR/apache.wsgi
CKAN_INSTALL_APACHE_SITE=$CKAN_INSTALL_APACHE_DIR/site/ckan_default.conf
CKAN_INSTALL_APACHE_CONF=$CKAN_INSTALL_APACHE_DIR/conf/ckan_default.conf
CKAN_INSTALL_NGINX_DIR=$CKAN_INSTALL_DIR/nginx-conf
CKAN_INSTALL_CKAN_SITE=$CKAN_INSTALL_NGINX_DIR/site/ckan

# Ckan home dir for files
CKAN_LIB_DIR=/usr/lib/ckan
CKAN_LIB_DEFAULT_DIR=$CKAN_LIB_DIR/default

# Configuration folder ckan
CKAN_ETC_DIR=/etc/ckan
CKAN_ETC_DEFAULT_DIR=$CKAN_ETC_DIR/default

# Configuration file generate for installer
CKAN_CONFIG_INI=${CKAN_ETC_DEFAULT_DIR}/production.ini

# Var folder using create inner files
CKAN_VAR_LIB=/var/lib/ckan/

# Configuration Solr for install files conf ckan
SOLR_DIR=/var/solr
SOLR_DATA_DIR=$SOLR_DIR/data
SOLR_DATA_CKAN_DIR=$SOLR_DATA_DIR/ckan
SOLR_COMMAND=/opt/solr/bin/solr

SOLR_HOME=${SOLR_HOME:-/opt/solr}
SOLR_URL=${SOLR_HOST:-http://localhost:8983}
SOLR_CORE=${SOLR_CORE:-ckan}

# Configuration apache2
APACHE_ETC_DIR=/etc/apache2
APACHE_ETC_SITES_DIR=$APACHE_ETC_DIR/sites-available
APACHE_ETC_CONF_DIR=$APACHE_ETC_DIR/conf-available

# Configuration nginx
CKAN_SITE_AVALIABLE=/etc/nginx/sites-available/ckan

# User and group ckan
CKAN_USER_GROUP=ckan

# User group solr
SOLR_USER_GROUP=solr

##########################################################################
# Validation requeriments for install
##########################################################################

if [[ $EUID -ne 0 ]]; then
  echo -e "\nERROR: This script must be run as root\n" 1>&2
  exit 1
fi

if [ ! -d "$SOLR_DIR" ]; then
  echo -e "\nERROR: Depends Solr installed download in https://www.apache.org/dyn/closer.lua/lucene/solr/8.2.0/solr-8.2.0.tgz\n" 1>&2
  exit 1
fi

if [ ! -d "$APACHE_ETC_DIR" ]; then
  echo -e "\nERROR: Depends Apache2 installed\n" 1>&2
  exit 1
fi

##########################################################################
# Global functions
##########################################################################

print_error() {
  echo $1
  exit 1
}

##########################################################################
# Start install and configuration
##########################################################################

if [ "$DISTRO_NAME" == "Debian" ] || [ "$DISTRO_NAME" == "Ubuntu" ] ; then
  apt-get install python-dev libpq-dev python-pip python-virtualenv git-core openjdk-8-jdk redis-server apache2 libapache2-mod-wsgi libapache2-mod-rpaf nginx
fi

# create user if not exists
CKAN_UID="`id -u "$CKAN_USER_GROUP"`"
if [ $? -ne 0 ]; then
  echo "Creating new user: $CKAN_USER_GROUP"
  if [ "$DISTRO_NAME" == "RedHat" ] || [ "$DISTRO_NAME" == "CentOS" ] ; then
    adduser --disabled-login --system -U -m --home-dir "$CKAN_LIB_DIR" "$CKAN_USER_GROUP"
  elif [ "$DISTRO_NAME" == "SUSE" ]; then
    /usr/bin/getent passwd ckan || /usr/sbin/useradd -m -s /sbin/nologin -d $CKAN_LIB_DIR -c "CKAN User" $CKAN_USER_GROUP
    useradd --system -U -m --home-dir "$CKAN_LIB_DIR" "$CKAN_USER_GROUP"
  else
    adduser --disabled-login --system --shell /bin/bash --group --disabled-password --home "$CKAN_LIB_DIR" "$CKAN_USER_GROUP"
  fi
fi

mkdir -p $CKAN_LIB_DEFAULT_DIR
chown -R $CKAN_USER_GROUP:$CKAN_USER_GROUP $CKAN_LIB_DIR

mkdir -p $CKAN_ETC_DEFAULT_DIR
chown -R $CKAN_USER_GROUP:$CKAN_USER_GROUP $CKAN_ETC_DIR

mkdir -p $CKAN_VAR_LIB
mkdir -p $CKAN_VAR_LIB/default
mkdir -p $CKAN_VAR_LIB/resources
mkdir -p $CKAN_VAR_LIB/storage
mkdir -p $CKAN_VAR_LIB/storage/uploads
chown -R $CKAN_USER_GROUP:$CKAN_USER_GROUP $CKAN_VAR_LIB
chmod 777 -R $CKAN_VAR_LIB/storage
chmod 777 $CKAN_VAR_LIB/resources

if [ ! -d "$SOLR_DATA_CKAN_DIR" ]; then
  cp -R $CKAN_INSTALL_SOLR_DIR $SOLR_DATA_CKAN_DIR
  cp $CKAN_INSTALL_SOLR_SCHEMA $SOLR_DATA_CKAN_DIR/conf/managed-schema
  chown -R $SOLR_USER_GROUP:$SOLR_USER_GROUP $SOLR_DATA_CKAN_DIR
fi

cp $CKAN_INSTALL_APACHE_SITE $APACHE_ETC_SITES_DIR
cp $CKAN_INSTALL_APACHE_CONF $APACHE_ETC_CONF_DIR
cp $CKAN_INSTALL_CKAN_SITE $CKAN_SITE_AVALIABLE

curl "$SOLR_URL/solr/admin/cores?action=CREATE&name=$SOLR_CORE&instanceDir=$SOLR_CORE&config=solrconfig.xml&dataDir=data&name=ckan&schema=managed-schema&wt=json"

su -s /bin/bash - $CKAN_USER_GROUP <<EOF

virtualenv --no-site-packages ${CKAN_LIB_DEFAULT_DIR}
cd ${CKAN_LIB_DEFAULT_DIR}
. ${CKAN_LIB_DEFAULT_DIR}/bin/activate
pip install setuptools==36.1
pip install $CKAN_INSTALL_DIR
pip install -r $CKAN_INSTALL_DIR/requirements.txt

if [ ! -f "$CKAN_CONFIG_INI" ]; then
    paster make-config ckan $CKAN_CONFIG_INI
fi

chmod -R 777 $CKAN_LIB_DEFAULT_DIR/lib/python2.7/site-packages/ckan/public/base/i18n/
deactivate

cp $CKAN_INSTALL_DIR/who.ini $CKAN_ETC_DEFAULT_DIR/who.ini
cp $CKAN_INSTALL_APACHE_WSGI $CKAN_ETC_DEFAULT_DIR/apache.wsgi

EOF

rm -rf $CKAN_LIB_DIR/.cache

a2ensite ckan_default
a2dissite 000-default
rm -vi /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/ckan /etc/nginx/sites-enabled/ckan_default
service apache2 reload
service nginx reload

systemctl restart apache2
systemctl restart nginx