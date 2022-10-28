FROM golang:1.19 as build

RUN mkdir /build
COPY go.mod /build/
COPY go.sum /build/
COPY main.go /build/

WORKDIR /build

RUN CGO_ENABLED=0 GOOS=linux go build -a -o app

FROM alpine:3.16
COPY --from=build /build/app .

ENTRYPOINT [ "./app" ]
