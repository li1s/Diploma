FROM registry.astralinux.ru/aa/aa-base-ee:0.1.1 as terraform
FROM golang:1.20.1-buster
COPY --from=terraform /usr/local/bin/terraform /usr/local/bin/
WORKDIR /src
COPY test/integration/go.* /src/
RUN go mod download
COPY ./ /src
WORKDIR /src/test/integration
ENTRYPOINT [ "go" ]
