FROM ubuntu:24.04 
RUN apt-get update 
RUN apt-get install -y curl gcc vim 
RUN apt-get install -y  build-essential    pkg-config     libudev-dev llvm libclang-dev     protobuf-compiler libssl-dev 
RUN curl --proto '=https' --tlsv1.2 -sSfL https://solana-install.solana.workers.dev | bash
ENV PATH="/root/.local/share/solana/install/active_release/bin:$PATH"
# RUN rustc --version && solana --version && anchor --version && surfpool --version && node --version && yarn --version
