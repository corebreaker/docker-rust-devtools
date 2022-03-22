FROM cimg/rust:1.59

RUN sudo apt-get update && sudo apt-get install -y \
        pkg-config \
        libssl-dev \
        python3-toml \
    && \
    sudo rm -rf /var/lib/apt/lists/*

COPY --chown=circleci:circleci bin /home/circleci/bin/

RUN rustup toolchain install nightly
RUN cargo install --version 0.8.8 grcov
RUN cargo install --version 0.1.2 coveralls
