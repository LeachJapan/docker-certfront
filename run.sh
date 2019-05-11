if [[ $(certbot certificates -d ${DOMAIN} 2>/dev/null | grep -c "Certificate Name: ${DOMAIN}") -eq 0 ]]
then
  certbot certonly --standalone --domain ${DOMAIN} --email ${EMAIL} --agree-tos
else
  certbot renew
fi

NGINX_CONF=/etc/nginx.conf

cp /etc/nginx.conf.template ${NGINX_CONF}
sed -i -e "s/DOMAIN/${DOMAIN}/g" ${NGINX_CONF}
sed -i -e "s/APP_HOST/${APP_HOST}/g" ${NGINX_CONF}
sed -i -e "s/APP_PORT/${APP_PORT:-80}/g" ${NGINX_CONF}

if [ -z ${CLIENT_MAX_BODY_SIZE} ]; then
  sed -i -e "s/CLIENT_MAX_BODY_SIZE}/50m/g;" ${NGINX_CONF}
else
  sed -i -e "s/CLIENT_MAX_BODY_SIZE/${CLIENT_MAX_BODY_SIZE}/g;" ${NGINX_CONF}
fi

crond
nginx -c ${NGINX_CONF}
