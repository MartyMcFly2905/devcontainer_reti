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

1.  Scarica l'archivio ufficiale(linux) fornito dal docente.
2.  Estrae i file necessari in `/workspace/reti_logiche/`.
3.  Crea i file `assemble.sh` e `debug.sh`.

Al termine della build, troverai la cartella `reti_logiche/linux` pronta nel tuo workspace.

### Compilatore

Per testare, deve restituire `Tutto OK`:

```
#nella cartella reti_logiche/linux

./assemble.sh demo/demo1.s

./demo/demo1
```

### Debugger

Il DevContainer include un **debugger adattivo** compatibile con host **x86** e **Apple Silicon (ARM)**.  
Lo script `debug.sh` riconosce automaticamente l’architettura e utilizza **GDB** o **QEMU + GDB Multiarch** per il debug a 32 bit.

#### Configurazione iniziale

Al primo avvio, il debugger richiederà di selezionare l’architettura del sistema host:

```
./debug.sh demo/demo1
```

Seleziona:

- `1` → **x86_64 (Intel/AMD)** – debug diretto con **GDB**  
- `2` → **ARM / Apple Silicon** – debug tramite **QEMU**  

La scelta viene salvata in `~/.config/reti_logiche/arch_config` e non richiede riconfigurazione ai successivi avvii.

#### Modalità di debug per ARM

Su sistemi **Apple Silicon / ARM**, sono disponibili tre modalità operative:

##### 1️⃣ Debug GDB puro (singolo terminale)

- **Per:** analisi di algoritmi, registri, memoria  
- **I/O:** ❌ *Non supportato* — funzioni come `inline` non ricevono input  
- **Uso ideale:** quando non è necessaria la verifica di interazioni con l’utente

##### 2️⃣ Debug a due terminali (interattivo)

- **Per:** debug interattivo completo (input e output reali), lo script stamperà sul terminale le istruzioni.

**Terminale 1 (QEMU):**

```
qemu-i386 -g 1234 ./demo/demo1
```

Qui puoi inserire input e visualizzare l’output del programma.

**Terminale 2 (GDB):**  

Si connette automaticamente tramite `debug.sh`.  
Da qui puoi gestire breakpoint, registri e istruzioni step-by-step.

> Quando incontri per esempio una `inline` su (gbd), lancia `n` e spostati nel terminale qemu, li puoi scrivere ed inviare l'input, quando incontri una `outline` per esempio su (gdb), vedrai l'output sul terminale qemu, non (gdb).


##### 3️⃣ Debug con input da file ⭐
- **Per:** debug interattivo su terminale singolo, tramite input predefiniti
- **Uso:**

```
./debug.sh demo/demo1 input.txt
```

###### Creazione del file di input

Crea un file di testo nella cartella `reti_logiche/linux` da vscode o dal terminale:

```
nano input_test.txt
```

**Formattazione corretta:**
- Un input per riga  
- Ogni riga equivale a ciò che digiteresti seguito da `INVIO`  
- Usa solo caratteri standard ASCII
- Lascia una riga vuota

**Esempio (programma che chiede nome, cognome, età):**
```
Mario
Rossi
25

```

**Esempio (programma che legge più caratteri consecutivi):**
```
A
B
C
D

```

###### Utilizzo

```
./debug.sh demo/demo7 input_test.txt
```

Gli input verranno inviati automaticamente al programma durante il debug, **simulando la digitazione in tempo reale**.

> ⚠️ Il file deve essere passato come **secondo parametro** e deve contenere **tutti gli input richiesti** dal programma, nell’ordine corretto.

#### Funzionamento tecnico

Su host ARM:
- **QEMU** avvia l’eseguibile e si mette in ascolto sulla porta `1234`
- **GDB Multiarch** si collega come debugger remoto
- Le syscall I/O vengono gestite direttamente dall’emulatore

> ⚠️ *Evita l’uso di “step-into” (`s`) dentro funzioni come `inchar` o `inline` etc.*:  
> contengono `int 0x80`, che può terminare il processo in debug.  
> Usa invece `n` o `c`.

#### Suggerimenti

- Per input complessi o ridondanti: crea più file (`test1.txt`, `test2.txt`, ecc.)  
- Se il debug si blocca: verifica che il file di input contenga abbastanza righe  
- Il debugger gestisce automaticamente processi e file temporanei  
- Per chiudere QEMU manualmente: `pkill qemu-i386`, o `q` da gdb.

### ⚠️ Per l’esame ⚠️

Durante l’esame (ambiente Windows/WSL) vengono usati `assemble.ps1` e `debug.ps1`, il primo appare praticamente identico, per quanto riguarda `debug.ps1`:
- funziona in un solo terminale
- accetta input direttamente nel debugger
- non richiede QEMU o configurazioni aggiuntive

È quindi analogo alla **Modalità 1**, ma con **I/O integrato**.

---

## Note

- Il container include già `nasm`, `gcc-multilib`, `gdb`, `iverilog`, `gtkwave`.
- Estensioni VSCode sono installate automaticamente.
- Per Verilog basta creare una cartella per gli esercizi e usare i comandi da terminale visti a lezione, GTKWave molto probabilemente non aprirà la finestra su Mac lanciandolo dal container, esistono workaround al riguardo, ma non essendo possessore di un Mac non li ho implementati.  
Tuttavia Verilog e GTKWave hanno versioni native su ARM, che potete installare e utilizzare direttamente su Mac.