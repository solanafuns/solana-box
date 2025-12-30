# Solana Box

A Docker container for Solana development with a web-based VS Code environment.

## Overview

Solana Box is a pre-configured development container that includes all the tools you need to build Solana applications. It comes with:

- **Solana CLI** - Latest Solana tools and utilities
- **Rust Toolchain** - Rust 1.89.0 for Solana program development
- **Code Server** - VS Code in your browser with extensions pre-installed
  - Python extension
  - Rust Analyzer extension
- **Development Tools** - Build essentials, pkg-config, protobuf compiler, and more

## Quick Start

Run the container with the following command:

```bash
docker run -d --rm -p 8080:8080 --platform=linux/amd64 ghcr.io/solanafuns/solana-box:latest
```

After starting the container, open your browser and navigate to:

```
http://localhost:8080
```

You'll see VS Code running in your browser, ready for Solana development!

## Usage

### Basic Run

The simplest way to run the container:

```bash
docker run -d --rm -p 8080:8080 --platform=linux/amd64 ghcr.io/solanafuns/solana-box:latest
```

### With Volume Mounting

To persist your work and mount your local project directory:

```bash
docker run -d --rm \
  -p 8080:8080 \
  --platform=linux/amd64 \
  -v $(pwd):/workspace \
  ghcr.io/solanafuns/solana-box:latest
```

### With Custom Port

If port 8080 is already in use, you can map to a different port:

```bash
docker run -d --rm -p 3000:8080 --platform=linux/amd64 ghcr.io/solanafuns/solana-box:latest
```

Then access it at `http://localhost:3000`

## What's Included

- **Ubuntu 24.04** - Base operating system
- **Solana CLI** - Installed via official installer
- **Rust 1.89.0** - Rust toolchain for Solana program development
- **Code Server** - Web-based VS Code editor
- **Development Tools**:
  - gcc, build-essential
  - pkg-config
  - libudev-dev, llvm, libclang-dev
  - protobuf-compiler
  - libssl-dev
  - curl, vim

## Exposed Ports

The container exposes the following ports:

- `8080` - Code Server (VS Code web interface)
- `443` - HTTPS
- `3000` - Additional development port
- `3001` - Additional development port
- `80` - HTTP

## Features

- **No Authentication** - Code server runs with `--auth none` for easy access
- **Pre-configured Solana Wallet** - A default wallet keypair is included
- **Ready to Code** - All tools are installed and configured, just start coding!

## Building from Source

If you want to build the image locally:

```bash
docker build -t solana-box:latest .
```

Then run it:

```bash
docker run -d --rm -p 8080:8080 solana-box:latest
```

## Notes

- The container runs code-server with no authentication by default. For production use, consider adding authentication.
- A default Solana wallet keypair is included in the container. For production, use your own keypair.
- The container is built for `linux/amd64` platform.

## License

See the repository for license information.

