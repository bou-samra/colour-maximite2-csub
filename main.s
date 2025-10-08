.syntax unified
.thumb
.global main

main:
    movs r0, #42       @ Load immediate value 42 into register R0
    bx lr              @ Return from subroutine
