FROM ubuntu:24.04 
RUN apt-get update 
RUN apt-get install -y curl gcc vim tini git
RUN apt-get install -y  build-essential    pkg-config     libudev-dev llvm libclang-dev     protobuf-compiler libssl-dev 
RUN curl --proto '=https' --tlsv1.2 -sSfL https://solana-install.solana.workers.dev | bash
ENV PATH="/root/.nvm/versions/node/v24.10.0/bin:/root/.local/share/solana/install/active_release/bin:/root/.cargo/bin:$PATH"
RUN echo '[151,24,169,16,188,163,225,2,165,53,223,62,13,172,255,113,123,124,255,215,118,25,70,127,95,209,12,190,241,58,45,221,152,133,73,201,44,199,95,203,201,96,206,222,93,17,242,12,93,1,98,192,85,96,110,135,53,86,102,53,158,205,4,81]' > /root/.config/solana/id.json
RUN rustup component add rust-analyzer

RUN cargo build-sbf --install-only

RUN sh -c "$(curl -sSfL https://release.anza.xyz/stable/install)"
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension ms-python.python 
RUN code-server --install-extension rust-lang.rust-analyzer
# RUN rustc --version && solana --version && anchor --version && surfpool --version && node --version && yarn --version

EXPOSE 8080
EXPOSE 443
EXPOSE 3000
EXPOSE 3001
EXPOSE 80
EXPOSE 5173

RUN mkdir -p /app
WORKDIR /app

COPY settings.json /root/.local/share/code-server/Machine/settings.json


RUN npm install -g @anthropic-ai/claude-code && npm install -g @musistudio/claude-code-router

# RUN /root/.cargo/bin/rustup toolchain install 1.89.0

ENTRYPOINT ["/usr/bin/tini", "--"]
COPY CLAUDE.md /root/.claude/CLAUDE.md
ADD example /app/example
# RUN RUN which cargo && cd example && cargo build-sbf

CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none","/app"]