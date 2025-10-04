#!/bin/bash
# Script di setup per ambiente Reti Logiche nel DevContainer

set -e

COURSE_DIR="/workspace/reti_logiche"
ZIP_URL="https://docenti.ing.unipi.it/~a080368/Teaching/RetiLogiche/pdf/Ambienti/linux.zip"
ZIP_FILE="linux.zip"

echo ">>> Creazione cartella $COURSE_DIR..."
mkdir -p "$COURSE_DIR"

# Scarica lo zip ufficiale se non già presente
if [ ! -f "$ZIP_FILE" ]; then
    echo ">>> Scarico l'ambiente ufficiale da $ZIP_URL..."
    wget -O "$ZIP_FILE" "$ZIP_URL"
else
    echo ">>> Trovato $ZIP_FILE in locale."
fi

# Estrazione
echo ">>> Estraggo $ZIP_FILE in $COURSE_DIR..."
unzip -o "$ZIP_FILE" -d "$COURSE_DIR"

cd "$COURSE_DIR/linux"

# Crea assemble.sh
echo ">>> Creazione assemble.sh..."
cat > assemble.sh << 'EOF'
#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <file.s>"
    exit 1
fi

sourceFile=$1
name=$(basename "$sourceFile" .s)

gcc -m32 -o "${sourceFile%.s}" -Wa,-a -Wa,--defsym,LINUX=1 -g ./files/main.c "$sourceFile" ./files/utility.s

if [ $? -eq 0 ]; then
    echo "Compiled successfully: ${sourceFile%.s}"
else
    echo "Compilation failed"
    exit 1
fi
EOF

# Crea debug.sh
echo ">>> Creazione debug.sh..."
cat > debug.sh << 'EOF'
#!/bin/bash
# Debug script adattivo per Reti Logiche
# - x86: usa gdb diretto
# - ARM: usa qemu-i386 + gdb-multiarch
# Sempre carica gdb_startup se presente (breakpoint su _main)

[ $# -eq 0 ] && echo "Usage: $0 <executable>" && exit 1
exe=$1

if [ ! -f "$exe" ]; then
    echo "Error: file '$exe' not found"
    exit 1
fi

# Richiedi all'utente di selezionare l'architettura
echo "Seleziona l'architettura:"
echo "1) x86 (gdb diretto)"
echo "2) altro (qemu-i386 + gdb-multiarch)"
read -p "Scelta [1/2]: " scelta

case $scelta in
    1)
        echo ">>> Modalità x86 selezionata → avvio gdb diretto"
        if [ -f "./files/gdb_startup" ]; then
            gdb -x "./files/gdb_startup" "$exe"
        else
            gdb "$exe"
        fi
        ;;
    2)
        echo ">>> Modalità altro selezionata → uso QEMU gdbserver + gdb-multiarch"

        if ! command -v qemu-i386 &>/dev/null; then
            echo "Errore: qemu-i386 non trovato. Installa con:"
            echo "  sudo apt-get update && sudo apt-get install -y qemu-user"
            exit 1
        fi
        if ! command -v gdb-multiarch &>/dev/null; then
            echo "Errore: gdb-multiarch non trovato. Installa con:"
            echo "  sudo apt-get update && sudo apt-get install -y gdb-multiarch"
            exit 1
        fi

        # Avvia QEMU in gdbserver
        qemu-i386 -g 1234 "$exe" &
        QEMU_PID=$!
        sleep 1

        if [ -f "./files/gdb_startup" ]; then
            gdb-multiarch -ex "set architecture i386" -ex "target remote :1234" -x "./files/gdb_startup" "$exe"
        else
            gdb-multiarch -ex "set architecture i386" -ex "target remote :1234" "$exe"
        fi

        kill $QEMU_PID 2>/dev/null
        ;;
    *)
        echo "Errore: scelta non valida. Usa 1 per x86 o 2 per altro."
        exit 1
        ;;
esac
EOF

# Rendi eseguibili gli script
chmod +x assemble.sh debug.sh

echo ">>> Setup completato!"
echo ">>> Script creati: assemble.sh, debug.sh"