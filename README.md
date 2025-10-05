# DevContainer per Reti Logiche

DevContainer per il corso di **Reti Logiche**.
È pensato per funzionare anche su **Apple Silicon** (tramite Docker Desktop) e su **Linux/Windows** senza bisogno di WSL/UTM.

---

## Requisiti

* Docker Desktop (su Mac/Windows) o Docker su Linux
* Visual Studio Code
* Estensione Dev Containers in VSCode

---

## Istruzioni rapide

1. Clona questa repo:

   ```bash
   git clone https://github.com/MartyMcFly2905/devcontainer_reti.git
   cd devcontainer_reti
   ```
2. Apri la cartella in VSCode.
3. Premi **F1** → “Dev Containers: Reopen in Container”.
4. Attendi la build (ci mette qualche minuto la prima volta).

---

## Setup Reti Logiche

L'ambiente per Reti Logiche viene configurato **automaticamente** la prima volta che il container viene creato.

Lo script `setup_reti.sh` esegue i seguenti passaggi:

1.  Scarica l'archivio ufficiale fornito dal docente.
2.  Estrae i file necessari in `/workspace/reti_logiche/`.
3.  Crea i file `assemble.sh` e `debug.sh`.

Al termine della build, troverai la cartella `reti_logiche/linux` pronta nel tuo workspace.

### Test

Per testare, deve restituire `Tutto OK`:

```
#nella cartella reti_logiche/linux

./assemble.sh demo/demo1.s

./demo/demo1
```

#### Debugger

Selezionare la propria architettura, lo script usa **gdb** su host **x86_64** o **qemu-i386 + gdb-multiarch** su host **ARM**.  
Uso: `./debug.sh <eseguibile>(es. demo/demo1)`, selezionare `1` per x86 o `2` per altro e attendere il collegamento.

*Nota:* Dopo il collegamento con QEMU/gdb-multiarch, potrebbe essere necessario inviare il comando `c` (continue) per raggiungere la funzione `_main` del proprio programma.

> All'esame i duali saranno semplicemente `assemble.ps1` e `debug.ps1`.

## Note

* Il container include già `nasm`, `gcc-multilib`, `gdb`, `iverilog`, `gtkwave`.
* Estensioni VSCode sono installate automaticamente.
