ARG BUILDPLATFORM=linux/amd64

FROM --platform=$BUILDPLATFORM rust:1-alpine3.15 AS builder
RUN apk add --no-cache musl-dev
RUN cargo install cargo-build-deps

WORKDIR /usr/src
RUN USER=root cargo new --bin star-wars-api-rust

# copy package manifests
COPY ./Cargo.toml /usr/src/star-wars-api-rust/Cargo.toml
COPY ./Cargo.lock /usr/src/star-wars-api-rust/Cargo.lock

WORKDIR /usr/src/star-wars-api-rust

# build dependencies
RUN cargo build-deps --release

# copy source code
COPY ./src /usr/src/star-wars-api-rust/src

# build project
RUN cargo build --release

FROM --platform=$BUILDPLATFORM alpine:3.15
USER 1000
WORKDIR /usr/app
COPY --from=builder /usr/src/star-wars-api-rust/target/release/star-wars-api-rust /usr/app/

EXPOSE 8080
ENTRYPOINT [ "/usr/app/star-wars-api-rust" ]
