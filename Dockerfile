FROM golang:1.24 AS builder

WORKDIR maestro

COPY go.mod go.sum ./
COPY vendor/ vendor/
COPY . .


RUN go build -mod=vendor -o watcher maestro/client-a/main.go

FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

RUN microdnf update -y && \
    microdnf install -y util-linux && \
    microdnf clean all

COPY --from=builder maestro/watcher /usr/local/bin/
