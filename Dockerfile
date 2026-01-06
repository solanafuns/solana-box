FROM ubuntu:24.04 

# 合并所有 apt 安装命令，并在最后清理缓存以减少镜像大小
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        gcc \
        tini \
        git \
        build-essential \
        pkg-config \
        libudev-dev \
        llvm \
        libclang-dev \
        protobuf-compiler \
        libssl-dev \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# 安装 Solana 工具链
RUN curl --proto '=https' --tlsv1.2 -sSfL https://solana-install.solana.workers.dev | bash

ENV PATH="/root/.nvm/versions/node/v24.10.0/bin:/root/.local/share/solana/install/active_release/bin:/root/.cargo/bin:$PATH"

# 配置 Solana 和 Rust 工具
RUN echo '[151,24,169,16,188,163,225,2,165,53,223,62,13,172,255,113,123,124,255,215,118,25,70,127,95,209,12,190,241,58,45,221,152,133,73,201,44,199,95,203,201,96,206,222,93,17,242,12,93,1,98,192,85,96,110,135,53,86,102,53,158,205,4,81]' > /root/.config/solana/id.json && \
    rustup component add rust-analyzer && \
    cargo build-sbf --install-only

# 安装 Anchor 和 code-server
RUN sh -c "$(curl -sSfL https://release.anza.xyz/stable/install)" && \
    curl -fsSL https://code-server.dev/install.sh | sh && \
    code-server --install-extension ms-python.python && \
    code-server --install-extension rust-lang.rust-analyzer

# 复制项目文件
ADD . /box

# 创建必要的目录和配置文件
RUN mkdir -p /app /root/.claude-router/logs /root/.claude-router/plugins /root/.claude/ && \
    cp /box/settings.json /root/.local/share/code-server/Machine/settings.json && \
    cp /box/CLAUDE.md /root/.claude/CLAUDE.md && \
    cp /box/ccr-config.json /root/.claude-router/config.json

# 安装 npm 全局包并构建项目
RUN npm install -g @anthropic-ai/claude-code @musistudio/claude-code-router && \
    cd /box/example && cargo build-sbf && \
    # 清理 Rust 构建缓存
    rm -rf /root/.cargo/registry/cache /root/.cargo/git/db && \
    # 清理 npm 缓存
    npm cache clean --force

WORKDIR /app

EXPOSE 8080 443 3000 3001 80 5173

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none","/app"]