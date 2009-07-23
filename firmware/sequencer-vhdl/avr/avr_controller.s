
        ldi r24, 0x22
        out 0x1A, r24
        out 0x1B, r24
        in  r23, 0x19
        out 0x1B, r23
        lds r22, 0xFF00
        sts 0xFF00, r22
        call 0x16
        nop
Blah2:  ldi r28, 66
        call 0x1a
        ret
Blah:
        push r28
        push r29
        pop  r29
        pop  r28
        ret

        ldi r30, 0x00
        ldi r31, 0xff
        icall
        