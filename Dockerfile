FROM node:14-alpine as builder
# Set the working directory to /app inside the container
WORKDIR /app

COPY package.json package-lock.json ./

# Install dependencies (npm ci makes sure the exact versions in the lockfile gets installed)
RUN npm ci

# Copy app files
COPY . .

ARG REACT_APP_API_BASE_URL
ENV REACT_APP_API_BASE_URL=$REACT_APP_API_BASE_URL

# Build the app
RUN npm run build

#CMD npx serve build

## Bundle static assets with nginx
FROM nginx:1.21.0-alpine as production
#ENV NODE_ENV production
## Copy built assets from `builder` image
COPY --from=builder /app/build /usr/share/nginx/html
## Add your nginx.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
## Expose port
EXPOSE 80
## Start nginx
CMD ["nginx", "-g", "daemon off;"]