# Use the official Nginx image from Docker Hub
FROM nginx:alpine

# Copy your website files into the Nginx container
COPY ./oxer-html/ /usr/share/nginx/html

# Expose port 80 (HTTP)
EXPOSE 80

# Nginx is the default CMD for the Nginx image
CMD ["nginx", "-g", "daemon off;"]

