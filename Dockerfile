############
### prod ###
############

# base image
FROM nginx:1.16.0-alpine

# copy artifact build from the 'build environment'
COPY ./dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/nginx.conf

# expose ports 80 and 443
EXPOSE 80
EXPOSE 443

# run nginx
CMD ["nginx", "-g", "daemon off;"]
