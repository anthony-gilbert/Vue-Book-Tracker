# Backend Dockerfile
FROM golang:1.21

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN go build -o main ./cmd/server

# Expose port 8080
EXPOSE 8080

# Run the application
CMD ["./main"]