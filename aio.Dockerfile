FROM golang:1.21.3 AS builder
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
COPY main.go .env.example /build/
COPY ./pkg /build/pkg/
RUN go build -o main .

FROM ubuntu:latest AS runner
# Set environment variables
ENV GO_VERSION=1.21.3 \
    GOPATH=/go \
    PATH=/go/bin:/usr/local/go/bin:$PATH

# Install dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Download and install Go
RUN curl -fsSL https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz | tar -C /usr/local -xz

# Create a workspace directory
WORKDIR $GOPATH

# Display Go version and build info
RUN go version

# Install Supervisor
RUN apt-get update && apt-get install -y supervisor

# Install envsubst
RUN apt-get update && apt-get install gettext-base

# Install nginx
RUN apt-get update && apt-get install -y nginx 

# Clean up unnecessary packages
RUN apt-get remove -y curl && \
    apt-get remove -y git && \
    apt-get autoremove -y && \
    apt-get clean

# Clear package lists to reduce image size
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN mkdir /app/storage

COPY --from=builder /build/.env.example /app/.env

COPY --from=builder /build/main /app/app1
COPY --from=builder /build/main /app/app2
COPY --from=builder /build/main /app/app3
COPY --from=builder /build/main /app/app4
COPY --from=builder /build/main /app/app5

COPY ./supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./nginx/nginx.conf.aio.template /etc/nginx/nginx.conf.aio.template

ARG HOST_PROXY

RUN envsubst < /etc/nginx/nginx.conf.aio.template > /etc/nginx/nginx.conf
EXPOSE 80

# CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
CMD ["/bin/sh", "-c", "/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf"]


