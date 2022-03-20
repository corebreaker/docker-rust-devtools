FROM cimg/rust:1.59

RUN sudo apt-get update && sudo apt-get install -y \
        pkg-config \
        libssl-dev \
    && \
    sudo rm -rf /var/lib/apt/lists/*

RUN rustup toolchain install nightly
RUN cargo install grcov coveralls
