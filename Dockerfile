FROM golang:1.21.3 AS builder

WORKDIR /build

COPY . .

RUN go build -o main .

FROM golang:1.21.3

WORKDIR /app

COPY --from=builder /build/main .
COPY --from=builder /build/.env.example /app/.env

EXPOSE 8080

CMD ["./main"]
