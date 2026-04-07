# BASE IMAGE
FROM nginx:alpine

# IMAGE LABELING
LABEL maintainer="developer@trendstore.com" \
      org.opencontainers.image.title="Trend-Store" \
      org.opencontainers.image.version="1.0" \
      org.opencontainers.image.description="Trend Store"

# APP_BUILD COPYING
COPY app/. /usr/share/nginx/html/.

# NGINX CONF
COPY nginx.conf /etc/nginx/conf.d/default.conf