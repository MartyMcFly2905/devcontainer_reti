# Forza architettura x86 anche su Mac ARM
FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/base:noble

ENV HOME=/home/vscode/

# Strumenti base + pacchetti per Reti Logiche con supporto ARM (qemu + gdb-multiarch)
RUN apt-get update && apt-get install -y \
    build-essential python3 python3-venv zlib1g-dev \
    ninja-build ncurses-dev git wget curl unzip \
    gcc-multilib g++-multilib gdb gdb-multiarch nasm iverilog gtkwave qemu-user \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN chmod +x /workspace/setup_reti.sh

# Torna all’utente vscode
USER vscode

WORKDIR /workspace
