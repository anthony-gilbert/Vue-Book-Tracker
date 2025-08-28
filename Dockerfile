# Frontend Dockerfile
FROM node:16-alpine as build-stage

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . /app

# Build the application
RUN npm run build

# Production stage
FROM nginx:alpine as production-stage

# Copy built application from build stage
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 8070

# Start nginx
CMD ["nginx", "-g", "daemon off;"]