#!/bin/sh

# Files
CFG=/etc/onetime/config
WEBFILES=/source/onetime/public/web
CSS=$WEBFILES/css/main.css

# Defaults
OTS_SSL=${OTS_SSL:='true'}
OTS_COLOR=${OTS_COLOR:='#dd4a22'}

echo "##### Performing vars check #####"
if [[ -z $OTS_DOMAIN || -z $OTS_MASTER_KEY || -z $OTS_REDIS_PW || -z $OTS_REDIS_HOST || -z $OTS_REDIS_PORT  ]]; then
  echo "Required variable is not defined!"
  echo "current configuration: "
  echo "OTS_DOMAIN = $OTS_DOMAIN"
  echo "OTS_MASTER_KEY = $OTS_MASTER_KEY"
  if [[ -z $OTS_REDIS_PW ]]; then
    echo "OTS_REDIS_PW = <not -set>"
  else
    echo "OTS_REDIS_PW = <variable is set>"
  fi
  echo "OTS_REDIS_HOST = $OTS_REDIS_HOST"
  echo "OTS_REDIS_PORT = $OTS_REDIS_PORT"
  exit 1
else
  echo "All required vars are set."
fi

echo "##### Building OTS configuration file from environment variables #####"
sed -i "s/__OTS_DOMAIN/$OTS_DOMAIN/g" $CFG
sed -i "s/__OTS_MASTER_KEY/$OTS_MASTER_KEY/g" $CFG
sed -i "s/__OTS_REDIS_PW/$OTS_REDIS_PW/g" $CFG
sed -i "s/__OTS_REDIS_HOST/$OTS_REDIS_HOST/g" $CFG
sed -i "s/__OTS_REDIS_PORT/$OTS_REDIS_PORT/g" $CFG
sed -i "s/__OTS_SSL/$OTS_SSL/g" $CFG

sed -i "s/__OTS_CREATE_SECRET/$OTS_CREATE_SECRET/g" $CFG
sed -i "s/__OTS_CREATE_ACCOUNT/$OTS_CREATE_ACCOUNT/g" $CFG
sed -i "s/__OTS_UPDATE_ACCOUNT/$OTS_UPDATE_ACCOUNT/g" $CFG
sed -i "s/__OTS_EMAIL_RECIPIENT/$OTS_EMAIL_RECIPIENT/g" $CFG
sed -i "s/__OTS_SEND_FEEDBACK/$OTS_SEND_FEEDBACK/g" $CFG
sed -i "s/__OTS_AUTHENTICATE_SESSION/$OTS_AUTHENTICATE_SESSION/g" $CFG
sed -i "s/__OTS_HOMEPAGE/$OTS_HOMEPAGE/g" $CFG
sed -i "s/__OTS_DASHBOARD/$OTS_DASHBOARD/g" $CFG
sed -i "s/__OTS_FAILED_PASSPHRASE/$OTS_FAILED_PASSPHRASE/g" $CFG
sed -i "s/__OTS_SHOW_METADATA/$OTS_SHOW_METADATA/g" $CFG
sed -i "s/__OTS_SHOW_SECRET/$OTS_SHOW_SECRET/g" $CFG
sed -i "s/__OTS_BURN_SECRET/$OTS_BURN_SECRET/g" $CFG

echo "##### Apply style customisations #####"
if [ ! -z "$OTS_IMAGE_FAV_ICON" ]; then
  rm -r $WEBFILES/img/favicon.png
  curl -o $WEBFILES/img/favicon.png $OTS_IMAGE_FAV_ICON
fi
if [ ! -z "$OTS_IMAGE_LOGO" ]; then
  rm -r $WEBFILES/img/logo.png
  curl -o $WEBFILES/img/logo.png $OTS_IMAGE_LOGO
fi
if [ ! -z "$OTS_COLOR" ]; then
  sed -i "s/__OTS_BANNER_COLOR/$OTS_COLOR/g" $CSS
  sed -i "s/__OTS_BUTTON_COLOR/$OTS_COLOR/g" $CSS
  sed -i "s/__OTS_BORDER_COLOR/$OTS_COLOR/g" $CSS
fi

echo "##### Starting OTS #####"
if [[ $DEBUG == "true" ]]; then
  echo "current configuration: "
  echo $(cat ${CFG})
fi

exec bundle exec thin -e dev -R config.ru -p 7143 start
