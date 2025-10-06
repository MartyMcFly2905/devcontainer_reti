# Forza architettura x86 anche su Mac ARM
FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/base:noble

ENV HOME=/home/vscode/

RUN apt-get update && apt-get install -y \
    build-essential python3 python3-venv zlib1g-dev \
    ninja-build ncurses-dev git wget curl unzip \
    gcc-multilib g++-multilib gdb gdb-multiarch nasm iverilog gtkwave qemu-user \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

USER vscode

WORKDIR /workspace