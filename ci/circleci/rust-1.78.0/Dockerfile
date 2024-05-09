FROM rust:1.78.0 as build
RUN cargo install --version 0.8.19 grcov
RUN cargo install --version 0.1.5 coveralls

FROM cimg/rust:1.78.0

RUN sudo apt-get update && sudo apt install -y \
        pkg-config \
        libssl-dev \
        python3-toml \
    && \
    sudo rm -rf /var/lib/apt/lists/*

COPY --chown=circleci:circleci bin /home/circleci/bin/
COPY --chown=circleci:circleci --from=build /usr/local/cargo/bin/grcov /home/circleci/.cargo/bin/
COPY --chown=circleci:circleci --from=build /usr/local/cargo/bin/coveralls /home/circleci/.cargo/bin/

RUN rustup toolchain install nightly

