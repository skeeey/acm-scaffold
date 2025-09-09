# FROM golang:1.24 AS builder



# COPY go.mod go.sum ./
# COPY vendor/ vendor/
# COPY . .


# RUN go build -o watcher maestro/client-a/main.go

FROM registry.access.redhat.com/ubi9/ubi-minimal:latest
COPY watcher watcher

RUN microdnf update -y && \
    microdnf install -y util-linux && \
    microdnf clean all

COPY watcher /usr/local/bin/
