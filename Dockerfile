# rust is the latest debian image with latest rust preinstalled
FROM rust

RUN apt-get update && apt-get install -y shellcheck
RUN cargo install -f typos-cli
