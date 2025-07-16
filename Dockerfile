FROM ubuntu:24.04

WORKDIR /workspace

# Install system dependencies
RUN apt-get update && apt-get install -y \
  git \
  curl \
  wget \
  vim \
  nano \
  openssh-client \
  sudo \
  bash \
  bash-completion \
  build-essential \
  pkg-config \
  libssl-dev \
  ca-certificates \
  nodejs \
  npm \
  coreutils \
  ripgrep \
  fd-find \
  clang \
  llvm \
  unzip \
  && rm -rf /var/lib/apt/lists/*

# Create claude user
RUN useradd -m -s /bin/bash claude && \
  echo 'claude ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Create workspace directories
RUN mkdir -p /workspace/projects /workspace/claude && \
  chown -R claude:claude /workspace

# Install Claude Code globally using npm
RUN npm install -g @anthropic-ai/claude-code

# Install Rust for claude user
USER claude
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
  . /home/claude/.cargo/env && \
  rustup default stable && \
  rustup install nightly

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
  export PATH="/home/claude/.local/bin:$PATH"

# Install foundryup and Foundry tools
RUN curl -L https://foundry.paradigm.xyz | bash && \
  export PATH="/home/claude/.foundry/bin:$PATH" && \
  foundryup

# Configure git for claude user (will be overridden by environment variables)
RUN git config --global user.name "Claude Container" && \
  git config --global user.email "claude@container.local" && \
  git config --global init.defaultBranch main

# Configure bash for claude user
RUN echo 'export TERM=xterm-256color' >> /home/claude/.bashrc && \
  echo 'set -o emacs' >> /home/claude/.bashrc && \
  echo 'bind "set show-all-if-ambiguous on"' >> /home/claude/.bashrc && \
  echo 'bind "set completion-ignore-case on"' >> /home/claude/.bashrc && \
  echo 'source $HOME/.cargo/env' >> /home/claude/.bashrc && \
  echo 'export PATH="/home/claude/.foundry/bin:/home/claude/.cargo/bin:/home/claude/.local/bin:$PATH"' >> /home/claude/.bashrc

# Create entrypoint script that sources environment
RUN echo '#!/bin/bash' > /home/claude/entrypoint.sh && \
  echo 'source /home/claude/.bashrc' >> /home/claude/entrypoint.sh && \
  echo '# Set environment variables for tools' >> /home/claude/entrypoint.sh && \
  echo 'export PATH="/home/claude/.foundry/bin:/home/claude/.cargo/bin:/home/claude/.local/bin:$PATH"' >> /home/claude/entrypoint.sh && \
  echo 'source /home/claude/.cargo/env' >> /home/claude/entrypoint.sh && \
  echo '# Configure git with environment variables if provided' >> /home/claude/entrypoint.sh && \
  echo 'if [ -n "$GIT_AUTHOR_NAME" ]; then git config --global user.name "$GIT_AUTHOR_NAME"; fi' >> /home/claude/entrypoint.sh && \
  echo 'if [ -n "$GIT_AUTHOR_EMAIL" ]; then git config --global user.email "$GIT_AUTHOR_EMAIL"; fi' >> /home/claude/entrypoint.sh && \
  echo 'exec "$@"' >> /home/claude/entrypoint.sh && \
  chmod +x /home/claude/entrypoint.sh

# Prepare for linking the credentials file
RUN mkdir -p /home/claude/.claude/
RUN touch /home/claude/.claude/.credentials.json

ENTRYPOINT ["/home/claude/entrypoint.sh"]
