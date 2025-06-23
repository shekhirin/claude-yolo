FROM alpine:latest

WORKDIR /workspace

# Install system dependencies
RUN apk update && apk add --no-cache \
  git \
  curl \
  wget \
  vim \
  nano \
  openssh \
  sudo \
  bash \
  bash-completion \
  build-base \
  pkgconf \
  openssl-dev \
  libc6-compat \
  libgcc \
  libstdc++ \
  ca-certificates \
  nodejs \
  npm \
  coreutils \
  ripgrep \
  fd \
  && rm -rf /var/cache/apk/*

# Create claude user
RUN adduser -D -s /bin/bash claude && \
  echo 'claude ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Create workspace directories
RUN mkdir -p /workspace/projects /workspace/claude && \
  chown -R claude:claude /workspace

# Install Rust for clade user
USER claude
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
  source /home/claude/.cargo/env && \
  rustup default stable

# Configure npm to use user directory for global packages
RUN mkdir -p /home/claude/.npm-global && \
  npm config set prefix '/home/claude/.npm-global'

# Install Claude Code as claude user
RUN npm install -g @anthropic-ai/claude-code

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
  echo 'export PATH="/home/claude/.cargo/bin:/home/claude/.npm-global/bin:$PATH"' >> /home/claude/.bashrc

# Create entrypoint script that sources environment
RUN echo '#!/bin/bash' > /home/claude/entrypoint.sh && \
  echo 'source /home/claude/.bashrc' >> /home/claude/entrypoint.sh && \
  echo '# Configure git with environment variables if provided' >> /home/claude/entrypoint.sh && \
  echo 'if [ -n "$GIT_AUTHOR_NAME" ]; then git config --global user.name "$GIT_AUTHOR_NAME"; fi' >> /home/claude/entrypoint.sh && \
  echo 'if [ -n "$GIT_AUTHOR_EMAIL" ]; then git config --global user.email "$GIT_AUTHOR_EMAIL"; fi' >> /home/claude/entrypoint.sh && \
  echo 'exec claude --dangerously-skip-permissions "$@"' >> /home/claude/entrypoint.sh && \
  chmod +x /home/claude/entrypoint.sh

# Prepare for linking the credentials file
RUN mkdir -p /home/claude/.claude/
RUN touch /home/claude/.claude/.credentials.json

ENTRYPOINT ["/home/claude/entrypoint.sh"]
