        ;; Clear the command port
        ldi r17, 0x00
        out 0x12, r17
        ;; Get the self ip address to make sure that works
        ;; Set the control port (D) to the self ip address byte addresses
        ;; in succession and then read from data port (E)
        ldi r17, 0xb0
        out 0x12, r17
        in  r21, 0x01
        ldi r17, 0xc0
        out 0x12, r17
        in  r22, 0x01
        ldi r17, 0xd0
        out 0x12, r17
        in  r23, 0x01
        ldi r17, 0xe0
        out 0x12, r17
        in  r24, 0x01
        ;; write out the transmit start buffer
        ldi r17, 0x11
        ldi r18, 0xF0
        out 0x12, r17
        out 0x03, r18
        ldi r17, 0x21
        ldi r18, 0xF0
        out 0x12, r17
        out 0x03, r18
        ;; write out the receive start buffer
        ldi r17, 0x31
        ldi r18, 0x22
        out 0x12, r17
        out 0x03, r18
        ldi r17, 0x41
        ldi r18, 0x22
        out 0x12, r17
        out 0x03, r18
        ;; write back out as the TCP destination address
        ldi r17, 0x71
        out 0x12, r17          ; 0x70 | 0x01
        out 0x03, r21
        ldi r17, 0x81
        out 0x12, r17
        out 0x03, r22
        ldi r17, 0x91
        out 0x12, r17
        out 0x03, r23
        ldi r17, 0xa1
        out 0x12, r17
        out 0x03, r24

        ;; wait for receive
Recv_Poll:
        sbis 0x10, 3            ; skip if recv cyc is set (break out of loop)
        rjmp Recv_Poll

        ;; read the recv src IP address
        ldi r17, 0x70
        out 0x12, r17
        in r21, 0x01
        ldi r17, 0x80
        out 0x12, r17
        in r22, 0x01
        ldi r17, 0x90
        out 0x12, r17
        in r23, 0x01
        ldi r17, 0xa0
        out 0x12, r17
        in r24, 0x01

        ;; read the recv length
        ldi r17, 0x50
        out 0x12, r17
        in r18, 0x01
        ldi r17, 0x60
        out 0x12, r17
        in r19, 0x01

        ;; echo it
        ;; fill out the xmit buffer with the recv length and first two bytes
        sts 0xF0F0, r18
        sts 0xF0F1, r19
        lds r20, 0x2222
        sts 0xF0F2, r20
        lds r20, 0x2223
        sts 0xF0F3, r20

        ;; write out the transmit length (4)
        ldi r17, 0x51
        out 0x12, r17
        ldi r17, 0x00
        out 0x03, r17
        ldi r17, 0x61
        out 0x12, r17
        ldi r17, 0x04
        out 0x03, r17
        ;; let 'er rip!
        ldi r17, 0x04
        out 0x12, r17
Xmit_Poll:
        sbis 0x10, 2            ; skip if xmit ack is set (break out of loop)
        rjmp Xmit_Poll
        ldi r17, 0x00           ; stop writing
        out 0x12, r17
        