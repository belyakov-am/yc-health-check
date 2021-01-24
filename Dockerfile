# build container
FROM golang:alpine AS builder

WORKDIR /build

COPY src/go.mod .
COPY src/go.sum .
RUN go mod download

COPY src/ .

RUN go build -o main .

# main container
FROM alpine

WORKDIR /app

RUN    apk update                                \
    && apk add bash ca-certificates libc6-compat \
    && rm -rf /var/cache/apk/*

COPY --from=builder /build/main .

COPY bin/entrypoint.sh .
COPY .env .

ENTRYPOINT ["./entrypoint.sh"]