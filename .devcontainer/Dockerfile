# Forza architettura x86 anche su Mac ARM
FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/base:noble

ENV HOME=/home/vscode/
ENV GDB_DIR=${HOME}workspace/reti_logiche/linux/files

RUN apt-get update && apt-get install -y \
    build-essential gcc-multilib g++-multilib gdb gdb-multiarch \
    qemu-user git wget unzip \
    iverilog gtkwave \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

USER vscode

WORKDIR /workspace