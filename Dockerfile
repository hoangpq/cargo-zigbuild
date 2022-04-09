ARG RUST_VERSION=1.60.0

FROM rust:$RUST_VERSION as builder

# Compile dependencies only for build caching
ADD Cargo.toml /cargo-zigbuild/Cargo.toml
ADD Cargo.lock /cargo-zigbuild/Cargo.lock
RUN mkdir /cargo-zigbuild/src && \
    touch  /cargo-zigbuild/src/lib.rs && \
    cargo build --manifest-path /cargo-zigbuild/Cargo.toml --release

# Build cargo-zigbuild
ADD . /cargo-zigbuild/
# Manually update the timestamps as ADD keeps the local timestamps and cargo would then believe the cache is fresh
RUN touch /cargo-zigbuild/src/lib.rs /cargo-zigbuild/src/bin/cargo-zigbuild.rs
RUN cargo build --manifest-path /cargo-zigbuild/Cargo.toml --release

FROM rust:$RUST_VERSION

# Install Zig
ARG ZIG_VERSION=0.9.1
RUN curl -L "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-$(uname -m)-${ZIG_VERSION}.tar.xz" | tar -J -x -C /usr/local && \
    ln -s "/usr/local/zig-linux-$(uname -m)-${ZIG_VERSION}/zig" /usr/local/bin/zig

# Install macOS SDKs
RUN curl -L "https://github.com/phracker/MacOSX-SDKs/releases/download/11.3/MacOSX10.9.sdk.tar.xz" | tar -J -x -C /opt
RUN curl -L "https://github.com/phracker/MacOSX-SDKs/releases/download/11.3/MacOSX11.3.sdk.tar.xz" | tar -J -x -C /opt
ENV SDKROOT=/opt/MacOSX11.3.sdk

COPY --from=builder /cargo-zigbuild/target/release/cargo-zigbuild /usr/local/cargo/bin/
