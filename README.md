# Colour Maximite 2 - CSUB Example and ARM Cortex-M7 Embedded Code

This document demonstrates how to embed ARM Cortex-M7 machine code directly into your BASIC program on the Colour Maximite 2 using the `CSUB` directive. It covers a minimal example, explains the embedded machine code, and provides detailed instructions on writing, compiling, and embedding ARM Thumb-2 assembly or C routines.

---

## What is CSUB?

`CSUB` allows embedding raw ARM machine code or compiled C/assembly routines into Colour Maximite 2 BASIC programs. These embedded routines appear as BASIC commands or functions and run natively on the ARM Cortex-M7 processor, enabling efficient, low-level operations beyond standard BASIC capabilities.

According to the Colour Maximite 2 user manual:

> `CSUB name [type [, type] …]`  
> hex [[ hex[…]]  
> hex [[ hex[…]]  
> `END CSUB`  
>  
> Defines the binary code for an embedded machine code program module written in C or ARM assembler. The module will appear in MMBasic as the command 'name' and can be used in the same manner as a built-in command.

Multiple embedded routines can be used in a program, each defining a different module with a different name. The first hex word is a 32-bit word which is the offset in bytes from the start of the CSUB to the entry point of the embedded routine (usually the function `main()`). The following hex words are the compiled binary code for the module.

---

## CSUB Code Example

```basic
CSUB test
00000000 20420047
END CSUB

test()

PRINT "Returned value in R0 was 42"
````

---

## What Does This Thumb-2 Machine Code Do?

* The **first 32-bit word** (`00000000`) is the **entry point offset**, meaning execution starts at the first instruction.
* The **second 32-bit word** (`20420047`) encodes **two Thumb instructions**:

  * `movs r0, #42` (load immediate value 42 into register R0),
  * `bx lr` (branch to link register, i.e., return).
* When `test()` is called, it runs these two instructions: loads 42 into R0 (commonly used to return values) and then returns.
* The BASIC program then continues and prints `Returned value in R0 was 42`.

---

## ARM Thumb-2 Assembly Example Corresponding to the Machine Code

```asm
.syntax unified
.thumb
.global main

main:
    movs r0, #42       @ Load immediate value 42 into register R0
    bx lr              @ Return from subroutine
```

### Explanation

* `.syntax unified`: Use modern unified ARM assembler syntax.
* `.thumb`: Assemble for the Thumb instruction set used by Cortex-M7.
* `.global main`: Declare the `main` symbol as global (entry point).
* `movs r0, #42`: Move the immediate value 42 into register `R0` (standard register for function return values).
* `bx lr`: Branch to the address stored in the Link Register (`LR`), returning control to the caller.

---

## How to Compile, Link, and Extract Binary

### Step 1: Save Assembly Code

Save the code above as `main.s`.

### Step 2: Assemble to Object File

```bash
arm-none-eabi-as -mcpu=cortex-m7 -mthumb main.s -o main.o
```

* `-mcpu=cortex-m7`: Target Cortex-M7 CPU.
* `-mthumb`: Use Thumb instruction set.

### Step 3: Link to ELF Executable

```bash
arm-none-eabi-ld main.o -Ttext=0x0 -o main.elf
```

Or combine compiling and linking with GCC:

```bash
arm-none-eabi-gcc -mcpu=cortex-m7 -mthumb -nostartfiles -Wl,-Ttext=0x0 -o main.elf main.s
```

* `-nostartfiles`: Avoid linking standard startup code.
* `-Ttext=0x0`: Load address set to 0.

### Step 4: Extract Raw Binary

```bash
arm-none-eabi-objcopy -O binary main.elf main.bin
```

### Step 5: View Machine Code as Hex

```bash
xxd -e main.bin
```

Sample output:

```
00000000: 20420047
```

* `20420047` is the machine code word representing `movs r0, #42` and `bx lr`.

---

## Preparing the CSUB Block

* The **first 32-bit word** is the entry point offset (usually `00000000`).
* Following words are your compiled machine code in 32-bit hex words.

Example:

```basic
CSUB myfunc
00000000 20420047
END CSUB

myfunc()

PRINT "Returned value in R0 was 42"
```

---

## Passing Arguments and Returning Data

* You can specify argument types in the CSUB definition, e.g.,

```basic
CSUB MySub integer, integer, string
```

* Up to 10 arguments are supported.
* Variables or arrays passed are pointers to their data. This allows embedded routines to modify passed data directly.
* Constants and expressions are passed as pointers to temporary memory containing their values.
* Remember to call `routinechecks()` regularly in longer-running routines to keep USB and watchdog timers active, or keep your routine execution within a few milliseconds.

---

## Additional Tips and Verification

* Use `arm-none-eabi-objdump -d main.elf` to disassemble and verify your machine code.
* Compile C routines similarly, specifying `-mcpu=cortex-m7 -mthumb` in compiler flags.
* Place CSUB blocks anywhere in your BASIC code; MMBasic will skip over them during execution.
* Each hex word must be exactly eight hex digits and separated by spaces or new lines.
* Errors in formatting or hex data will cause runtime errors in MMBasic.

---

## License

This document and any accompanying code are released under the MIT License.
