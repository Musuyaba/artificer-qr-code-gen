# Build stage
FROM golang:1.21.3 AS builder

# Set the working directory for the build stage
WORKDIR /build

# Copy go.mod and go.sum to the working directory
COPY go.mod go.sum ./

# Download Go module dependencies
RUN go mod download

# Copy main.go and .env.example to the working directory
COPY main.go .env.example /build/

# Copy the ./pkg directory to the working directory
COPY ./pkg /build/pkg/

# Build the Go application
RUN go build -o main .

# Runner stage
FROM ubuntu:latest AS runner

# Define an argument HOST_PROXY for use during build
ARG HOST_PROXY

# Set environment variables
ENV GO_VERSION=1.21.3 \
    GOPATH=/go \
    PATH=/go/bin:/usr/local/go/bin:$PATH

# Install required dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Download and install Go
RUN curl -fsSL https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz | tar -C /usr/local -xz

# Set the working directory to $GOPATH
WORKDIR $GOPATH

# Display Go version and build info
RUN go version

# Install Supervisor
RUN apt-get update && apt-get install -y supervisor

# Install envsubst
RUN apt-get update && apt-get install gettext-base

# Install Nginx
RUN apt-get update && apt-get install -y nginx

# Clean up unnecessary packages
RUN apt-get remove -y curl && \
    apt-get remove -y git && \
    apt-get autoremove -y && \
    apt-get clean

# Clear package lists to reduce image size
RUN rm -rf /var/lib/apt/lists/*

# Set the working directory for the application
WORKDIR /app

# Create a storage directory
RUN mkdir /app/storage

# Copy .env.example from the builder stage to /app
COPY --from=builder /build/.env.example /app/.env

# Copy the built application to /app with different names
COPY --from=builder /build/main /app/app1
COPY --from=builder /build/main /app/app2
COPY --from=builder /build/main /app/app3
COPY --from=builder /build/main /app/app4
COPY --from=builder /build/main /app/app5

# Copy supervisor configuration to /etc/supervisor/conf.d/
COPY ./supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy Nginx configuration template to /etc/nginx/
COPY ./nginx/nginx.conf.aio.template /etc/nginx/nginx.conf.aio.template

# Use envsubst to substitute environment variables in the Nginx configuration template
RUN envsubst < /etc/nginx/nginx.conf.aio.template > /etc/nginx/nginx.conf

# Expose port 80 for Nginx
EXPOSE 80

# Command to run the application using supervisord
CMD ["/bin/sh", "-c", "/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf"]
