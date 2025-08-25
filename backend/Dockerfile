# Backend Dockerfile
FROM golang:1.21-alpine AS build-stage

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./cmd/server

# Production stage
FROM alpine:latest

# Install ca-certificates for HTTPS requests
RUN apk --no-cache add ca-certificates

# Set working directory
WORKDIR /root/

# Copy the binary from build stage
COPY --from=build-stage /app/main .

# Expose port 8080
EXPOSE 8080

# Set environment variable
ENV PORT=8080

# Run the application
CMD ["./main"]