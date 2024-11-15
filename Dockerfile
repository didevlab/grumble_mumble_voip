# Build stage
FROM golang:1.17-alpine as builder

COPY . /go/src/mumble.info/grumble

WORKDIR /go/src/mumble.info/grumble

RUN apk add --no-cache git build-base

RUN go get -v -t ./... \
  && go build -o /go/bin/grumble mumble.info/grumble/cmd/grumble \
  && go test -v ./...
#
FROM alpine:edge

COPY --from=builder /go/bin/grumble /usr/bin/grumble

ENV DATADIR /data

RUN mkdir -p /data \
  && addgroup -S grumble \
  && adduser -S grumble -G grumble \
  && chown -R grumble:grumble /data

USER grumble

WORKDIR /data

VOLUME /data

EXPOSE 64738/tcp
EXPOSE 64738/udp

ENTRYPOINT [ "/usr/bin/grumble", "--datadir", "/data", "--log", "/data/grumble.log" ]