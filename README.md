# DevContainer per Reti Logiche

DevContainer per il corso di **Reti Logiche**.
È pensato per funzionare anche su **Apple Silicon** (tramite Docker Desktop) e su **Linux/Windows** senza bisogno di WSL/UTM.


## Requisiti

* Docker Desktop (su Mac/Windows) o Docker su Linux
* Visual Studio Code
* Estensione Dev Containers in VSCode


## Istruzioni rapide

1. Clona questa repo:
   ```
   $ git clone https://github.com/MartyMcFly2905/devcontainer_reti.git
   $ cd devcontainer_reti
   ```
2. Apri la cartella in VSCode
3. Premi **F1** → “Dev Containers: Reopen in Container”
4. Attendi la build (ci mette qualche minuto la prima volta)


## Setup Reti Logiche

L'ambiente per Reti Logiche viene configurato **automaticamente** la prima volta che il container viene creato.

Lo script `setup_ambiente` esegue i seguenti passaggi:

1.  Scarica l'archivio ufficiale (linux) fornito dal docente
2.  Estrae i file necessari in `/workspace/reti_logiche/`
3.  Crea i file `assemble.sh` e `debug.sh`

Al termine della build, troverai la cartella `reti_logiche/linux` pronta nel tuo workspace.


### Assemblaggio

Testare l'ambiente eseguendo questi comandi. Se viene stampato `Tutto OK` allora l'ambiente è funzionante:

```
$ cd reti_logiche/linux
$ ./assemble.sh demo/demo1.s
$ ./demo/demo1
```


### Debugging

Il DevContainer include un **debugger adattivo** compatibile con host **x86_64** e **Apple Silicon (ARM)**.  
Lo script `debug.sh` riconosce automaticamente l’architettura e utilizza **GDB** o **QEMU + GDB Multiarch** per il debug a 32 bit.


### Modalità di debug per ARM

Su sistemi **Apple Silicon / ARM**, sono disponibili due modalità operative:


#### 1️⃣ Debug (interattivo) a due terminali

Per avviare questa modalità, lancia il debugger passando **solo il file eseguibile** (senza il file di input):

```bash
$ ./debug.sh demo/demo1
```

Lo script si metterà in pausa e stamperà a schermo le istruzioni esatte per collegare il secondo terminale.

**Terminale 1 (GDB - Principale):** È il terminale in cui hai appena lanciato lo script. Una volta completati i passaggi nel secondo terminale, premi `INVIO` qui: si avvierà GDB collegandosi automaticamente al programma. Da qui puoi gestire breakpoint, registri e istruzioni step-by-step.

**Terminale 2 (QEMU - I/O):** Apri un secondo terminale su VS Code e lancia il comando che ti è stato suggerito (es. `$ qemu-i386 -g 1234 demo/demo1`). In questo terminale potrai digitare gli input e visualizzare gli output del programma.

> 💡 **Suggerimento:** Quando incontri una `inline` su (gdb), lancia il comando `n` e spostati nel terminale QEMU per digitare l'input. Quando incontri una `outline` su (gdb), vedrai l'output stampato sempre sul terminale QEMU, non nella finestra di (gdb).

#### 2️⃣ Debug con input da file

Debug interattivo su terminale singolo, tramite input predefiniti.
Gli input verranno inviati automaticamente al programma durante il debug

> ⚠️ Il file deve essere passato come **secondo parametro** e deve contenere **tutti gli input richiesti** dal programma, nell’ordine corretto.

Uso:
```
$ ./debug.sh demo/demo1 input.txt
```


##### Creazione del file di input

Crea un file di testo nella cartella `reti_logiche/linux` da vscode o dal terminale:

```
$ nano input_test.txt
```

**Formattazione corretta:**
- Un input per riga  
- Ogni riga equivale a ciò che digiteresti seguito da `INVIO`  
- Usa solo caratteri standard ASCII
- Lascia una riga vuota a fine file

Per esempio se il programma chiede in ordine nome, cognome, età, il file deve avere questo contenuto:
```
Mario
Rossi
25

```
> ⚠️ Notare la presenza di una riga vuota a fine file

#### Suggerimenti
 
- Se il debug si blocca: verifica che il file di input contenga abbastanza righe
- Per chiudere QEMU manualmente esegui `pkill qemu-i386` su terminale, o il comando `q` su gdb

## Note

- Il container include già `gcc-multilib`, `gdb`, `iverilog`, `gtkwave`
- Le estensioni VS Code consigliate durante il corso sono installate automaticamente
- Per Verilog basta creare una cartella per gli esercizi e usare i comandi da terminale visti a lezione. `GTKWave` molto probabilemente non aprirà la finestra su Mac lanciandolo dal container. Un possibile workaround è scaricarlo mediante Homebrew sulla propria macchina oppure cercare online su come compilare direttamente i file sorgenti

## Note per l’esame

Durante l’esame (ambiente Windows/WSL) vengono usati `assemble.ps1` e `debug.ps1`. Il primo appare praticamente identico a quello di questo ambiente, per quanto riguarda `debug.ps1`:
- funziona in un solo terminale
- accetta input direttamente nel debugger
- non richiede QEMU o configurazioni aggiuntive
