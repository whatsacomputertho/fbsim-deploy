cat /opt/fbsim/template.nginx.conf | envsubst '${FBSIM_DOMAIN}' > /etc/nginx/nginx.conf
nginx -g 'daemon off;'