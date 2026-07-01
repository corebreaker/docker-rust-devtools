FROM rust:1.80.0-bookworm AS build

RUN cargo install --locked --version 0.8.20 grcov
RUN cargo install --locked --version 0.1.5 coveralls

# ---------------------------------------------------------------------------------------------------------------------
FROM rust:1.80.0-bookworm

# Recrée l'environnement « circleci » fourni par les images cimg/rust (utilisateur circleci + sudo,
# boîte à outils, PATH) sur la base Rust officielle, qui n'embarque pas les outils conteneur vulnérables.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        sudo \
        git-lfs \
        jq \
        zip \
        cmake \
        python3-toml \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 1002 circleci \
    && useradd -m -u 1001 -g 1002 -s /bin/bash circleci \
    && echo 'circleci ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/50-circleci \
    && chmod 0440 /etc/sudoers.d/50-circleci \
    && groupadd -g 1000 coveralls \
    && usermod -aG coveralls circleci

# Déplace la toolchain Rust dans le home de circleci (comme cimg : ~/.cargo et ~/.rustup) pour que
# le cache CircleCI de ~/.cargo et l'installation de toolchains par circleci continuent de fonctionner.
RUN mv /usr/local/rustup /home/circleci/.rustup \
    && mv /usr/local/cargo /home/circleci/.cargo \
    && chown -R circleci:circleci /home/circleci/.rustup /home/circleci/.cargo

ENV RUSTUP_HOME=/home/circleci/.rustup \
    CARGO_HOME=/home/circleci/.cargo \
    RUST_VERSION=1.80.0 \
    PATH=/home/circleci/.cargo/bin:/home/circleci/bin:/home/circleci/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Debian réinitialise le PATH dans les shells de login (contrairement à Ubuntu/cimg) : on réinjecte les
# chemins de la boîte à outils via /etc/profile.d pour que cargo/rustc/grcov soient trouvés dans tous les shells.
RUN printf '%s\n' 'export PATH="/home/circleci/.cargo/bin:/home/circleci/bin:/home/circleci/.local/bin:$PATH"' \
        > /etc/profile.d/50-rust-devtools.sh \
    && chmod 0644 /etc/profile.d/50-rust-devtools.sh

COPY --chown=circleci:circleci bin /home/circleci/bin/
COPY --chown=circleci:circleci --from=build /usr/local/cargo/bin/grcov /home/circleci/.cargo/bin/
COPY --chown=circleci:circleci --from=build /usr/local/cargo/bin/coveralls /home/circleci/.cargo/bin/

USER circleci
WORKDIR /home/circleci

RUN rustup toolchain install nightly
