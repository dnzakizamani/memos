FROM golang:1.25-alpine AS builder

# Install dependencies required for building
RUN apk add --no-cache git

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 go build -buildvcs=false -o memos -ldflags="-s -w" ./bin/memos/main.go

FROM alpine:latest

# Update repositories and install ca-certificates
RUN apk update && apk add --no-cache ca-certificates

WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /app/memos /app/memos

# Create a non-root user
RUN addgroup -g 65532 memos && \
    adduser -u 65532 -G memos -s /bin/sh -D memos

# Create data directory and set permissions
RUN mkdir -p /var/opt/memos && \
    chown -R memos:memos /app /var/opt/memos

USER memos

EXPOSE 5230

VOLUME ["/var/opt/memos"]

CMD ["/app/memos", "--driver=postgres"]