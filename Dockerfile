FROM golang:1.21.3 AS builder

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

COPY main.go .env.example /build/
COPY ./pkg /build/pkg

RUN go build -o main .

FROM golang:1.21.3

WORKDIR /app

COPY --from=builder /build/main .
COPY --from=builder /build/.env.example /app/.env

EXPOSE 8080

CMD ["./main"]
