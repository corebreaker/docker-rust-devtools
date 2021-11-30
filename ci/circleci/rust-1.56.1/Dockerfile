FROM cimg/rust:1.56.1

RUN sudo apt-get update && sudo apt-get install -y \
        pkg-config \
        libssl-dev \
    && \
    sudo rm -rf /var/lib/apt/lists/*

RUN cargo install grcov &&\
    cargo install coveralls
