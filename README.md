# Solana Box

A Docker container for Solana development with a web-based VS Code environment.

## Overview

Solana Box is a pre-configured development container that includes all the tools you need to build Solana applications. It comes with:

- **Solana CLI** - Latest Solana tools and utilities
- **Rust Toolchain** - Rust 1.89.0 for Solana program development
- **Code Server** - VS Code in your browser with extensions pre-installed
  - Python extension
  - Rust Analyzer extension
- **Claude Code Router** - AI code assistant router with OpenRouter support
- **Development Tools** - Build essentials, pkg-config, protobuf compiler, and more

## Quick Start

Run the container with the following command:

```bash
docker run -d --rm -p 8080:8080 --platform=linux/amd64 -v /tmp:/app ghcr.io/solanafuns/solana-box:latest
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

## Configuration

### Proxy Settings

If you need to configure proxy settings inside the container (e.g., when behind a corporate firewall or using a local proxy), you can set the proxy environment variables. Inside the container's terminal, run:

```bash
export https_proxy=http://host.docker.internal:7890 http_proxy=http://host.docker.internal:7890 all_proxy=socks5://host.docker.internal:7890
```

**Note:** 
- `host.docker.internal` allows the container to access services running on the host machine
- Adjust the port number (7890) to match your proxy server's port
- These settings will only persist for the current session. To make them permanent, add them to your shell profile (e.g., `~/.bashrc` or `~/.zshrc`)

### Claude Code Router Configuration

The container includes `claude-code-router` pre-installed, which allows you to route AI code assistant requests through OpenRouter. To configure it:

1. **Copy the example configuration file:**

   ```bash
   cp example.json ~/.claude-code-router/config.json
   ```

2. **Edit the configuration file** and replace `your_openrouter_api_key_here` with your actual OpenRouter API key:

   ```bash
   vim ~/.claude-code-router/config.json
   ```

3. **Start the router:**

   ```bash
   claude-code-router start
   ```

   Or use the `ccr` command:

   ```bash
   ccr start
   ```

The router will be available at `http://localhost:3456` (or the port specified in your config).

**Configuration Options:**

The `example.json` file includes:
- OpenRouter API endpoint configuration
- Multiple Claude model options (3.5 Sonnet, Opus, Haiku)
- Default model routing settings
- Customizable host and port settings

You can customize the models and routing preferences in the configuration file according to your needs.

## What's Included

- **Ubuntu 24.04** - Base operating system
- **Solana CLI** - Installed via official installer
- **Rust 1.89.0** - Rust toolchain for Solana program development
- **Code Server** - Web-based VS Code editor
- **Claude Code Router** - Pre-installed for AI code assistant routing
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
- `3456` - Claude Code Router (AI assistant router)
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

