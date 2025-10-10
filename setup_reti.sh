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

gcc -m32 -o "${sourceFile%.s}" -Wa,-a="${name}.lst" -Wa,--defsym,LINUX=1 -g ./files/main.c "$sourceFile" ./files/utility.s

if [ $? -eq 0 ]; then
    echo "Compiled successfully: ${sourceFile%.s}"
else
    echo "Compilation failed"
    exit 1
fi
EOF

# Crea debug.sh
echo ">>> Creazione debug.sh..."
cat > debug.sh << 'EOF_SCRIPT'
#!/bin/bash
# Debug script adattivo per Reti Logiche
# - Configurazione architettura persistente
# - Tre modalità di debug per ARM

[ $# -eq 0 ] && echo "Usage: $0 <executable> [input_file]" && exit 1

exe=$1
input_file=$2

if [ ! -f "$exe" ]; then
    echo "Error: file '$exe' not found"
    exit 1
fi

# File di configurazione persistente
CONFIG_DIR="$HOME/.config/reti_logiche"
CONFIG_FILE="$CONFIG_DIR/arch_config"

# Se non esiste, chiedi all'utente di configurare
if [ ! -f "$CONFIG_FILE" ]; then
    echo "=== Configurazione Architettura ==="
    echo "Seleziona l'architettura del tuo sistema host:"
    echo "1) x86_64 (Intel/AMD)"
    echo "2) ARM/Apple Silicon"
    echo "3) Altra architettura"
    read -p "Scelta [1/2/3]: " arch_choice
    
    mkdir -p "$CONFIG_DIR"
    case $arch_choice in
        1) echo "x86_64" > "$CONFIG_FILE" ;;
        2) echo "arm" > "$CONFIG_FILE" ;;
        3) echo "other" > "$CONFIG_FILE" ;;
        *) echo "x86_64" > "$CONFIG_FILE" ;;
    esac
    echo "Configurazione salvata in $CONFIG_FILE"
    echo ""
fi

# Leggi configurazione
ARCH_TYPE=$(cat "$CONFIG_FILE")

# Su x86_64, usa GDB diretto
if [ "$ARCH_TYPE" = "x86_64" ]; then
    echo ">>> Architettura x86_64 - GDB nativo"
    if [ -f "./files/gdb_startup" ]; then
        if [ -n "$input_file" ] && [ -f "$input_file" ]; then
            gdb -x "./files/gdb_startup" "$exe" < "$input_file"
        else
            gdb -x "./files/gdb_startup" "$exe"
        fi
    else
        gdb "$exe"
    fi
    exit 0
fi

# Per ARM/altre architetture
echo "=== Architettura $ARCH_TYPE - Debug con QEMU ==="
echo ""
echo "Seleziona modalità debug:"
echo "1) Debug singolo terminale (GDB puro, senza I/O)"
echo "2) Debug due terminali (I/O su terminale QEMU)"
echo "3) Debug con input da file (pipe injection)"
read -p "Scelta [1/2/3]: " debug_choice

case $debug_choice in
    1)
        # Debug singolo terminale - solo GDB
        echo ">>> Modalità 1: Debug GDB puro (senza I/O)"
        echo "NOTA: Le funzioni I/O non riceveranno input"
        echo ""
        
        qemu-i386 -g 1234 "$exe" &
        QEMU_PID=$!
        sleep 0.5

        # Crea script GDB temporaneo
        GDB_SCRIPT=$(mktemp)
        cat > "$GDB_SCRIPT" << 'EOF'
set architecture i386
target remote :1234

# Funzioni helper per simulare input
define simchar
    if $argc == 1
        set $al = $arg0
        printf "Carattere simulato: 0x%02x\n", $arg0
    else
        echo "Usage: simchar <valore_esadecimale>\n"
        echo "Esempio: simchar 0x41 (per 'A')\n"
    end
end

define simstr
    if $argc == 1
        set $ptr = $arg0
        while (*(char*)$ptr != 0)
            set $al = *(char*)$ptr
            printf "Simulato: '%c' (0x%02x)\n", $al, $al
            set $ptr = $ptr + 1
        end
    else
        echo "Usage: simstr <indirizzo_stringa>\n"
    end
end

break _main
continue
EOF

        gdb-multiarch -x "$GDB_SCRIPT" "$exe"
        
        # Cleanup
        kill $QEMU_PID 2>/dev/null
        rm -f "$GDB_SCRIPT"
        ;;
        
    2)
        # Debug due terminali
        echo ">>> Modalità 2: Debug con due terminali"
        echo ""
        echo "ISTRUZIONI:"
        echo "1. APRITE UN SECONDO TERMINALE"
        echo "2. Nel secondo terminale, eseguite:"
        echo "   qemu-i386 -g 1234 $exe"
        echo ""
        echo "3. In QUESTO terminale vedrete GDB"
        echo "4. Nel SECONDO terminale vedrete l'I/O"
        echo "   - Inserite gli input lì"
        echo "   - Vedrete gli output lì"
        echo ""
        echo "Premi Invio quando hai aperto il secondo terminale..."
        read
        
        # Script GDB per connessione
        GDB_SCRIPT=$(mktemp)
        cat > "$GDB_SCRIPT" << 'EOF'
set architecture i386
target remote :1234
break _main
continue
EOF

        echo ">>> Connessione a QEMU in corso..."
        gdb-multiarch -x "$GDB_SCRIPT" "$exe"
        rm -f "$GDB_SCRIPT"
        ;;
        
    3)
        # Debug con input da file
        if [ -z "$input_file" ]; then
            echo "ERRORE: Specifica un file di input come secondo parametro"
            echo "Esempio: $0 $exe input.txt"
            exit 1
        fi
        
        if [ ! -f "$input_file" ]; then
            echo "ERRORE: File di input non trovato: $input_file"
            exit 1
        fi
        
        echo ">>> Modalità 3: Debug con input da file"
        echo "File: $input_file"
        echo "Contenuto:"
        cat -n "$input_file" | sed 's/^/   /'
        echo ""
        
        # Crea FIFO
        FIFO=$(mktemp -u)
        mkfifo "$FIFO"
        echo ">>> FIFO creata: $FIFO"
        
        # Inietta l'input nella FIFO
        echo ">>> Iniezione input in corso..."
        cat "$input_file" > "$FIFO" &
        CAT_PID=$!
        
        # Avvia QEMU che legge dalla FIFO
        qemu-i386 -g 1234 "$exe" < "$FIFO" &
        QEMU_PID=$!
        sleep 0.5

        # Script GDB
        GDB_SCRIPT=$(mktemp)
        cat > "$GDB_SCRIPT" << 'EOF'
set architecture i386
target remote :1234
break _main
continue
EOF

        echo ">>> Avvio GDB..."
        gdb-multiarch -x "$GDB_SCRIPT" "$exe"
        
        # Cleanup
        kill $QEMU_PID $CAT_PID 2>/dev/null
        rm -f "$GDB_SCRIPT" "$FIFO"
        echo ">>> Pulizia completata"
        ;;
        
    *)
        echo "Scelta non valida"
        exit 1
        ;;
esac
EOF_SCRIPT

# Rendi eseguibili gli script
chmod +x assemble.sh debug.sh

echo ">>> Setup completato!"
echo ">>> Script creati: assemble.sh, debug.sh"