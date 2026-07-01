FROM cimg/rust:1.96.0 AS build

RUN sudo apt update && sudo apt install -y libgit2-dev

RUN cargo install --version 0.10.7 grcov
RUN cargo install --version 0.2.0 -F libgit coveralls
RUN cargo install --version 1.0.3 no-crlf

# ---------------------------------------------------------------------------------------------------------------------
FROM cimg/rust:1.96.0

RUN sudo apt update \
    && sudo apt install -y \
        pkg-config \
        libssl-dev \
        python3-toml \
    && sudo rm -rf /var/lib/apt/lists/* \
    && sudo groupadd -g 1000 coveralls \
    && sudo usermod -G coveralls circleci

ENV RUST_LOG=info

COPY --chown=circleci:circleci bin /home/circleci/bin/
COPY --chown=circleci:circleci --from=build /home/circleci/.cargo/bin/grcov /home/circleci/.cargo/bin/
COPY --chown=circleci:circleci --from=build /home/circleci/.cargo/bin/coveralls /home/circleci/.cargo/bin/
COPY --chown=circleci:circleci --from=build /home/circleci/.cargo/bin/no-crlf /home/circleci/.cargo/bin/

RUN /home/circleci/.cargo/bin/no-crlf -r /home/circleci/bin/

RUN rustup toolchain install nightly
