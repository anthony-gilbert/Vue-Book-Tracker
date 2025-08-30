# Frontend Dockerfile
FROM node:16-alpine AS build-stage

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . /app

# Build the application
RUN npm run build

# Production stage
FROM nginx:alpine AS production-stage

# Copy built application from build stage
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Copy custom nginx configuration  
COPY /nginx-config/booktracker.dev /etc/nginx/sites-available/booktracker.dev
COPY nginx-setup.sh /app
# RUN chmod +x /app/nginx-setup.sh

# Expose port 80
EXPOSE 5001

# Start nginx
CMD ["./nginx-setup.sh"]
# docker build -t vue-book-tracker-frontend:v1 .
# docker push anthonygilbertt/vue-book-tracker-frontend:v1
