; Resident clock program for MS-DOS in 56 bytes
;
; Author: gergely@erdelyi.hu
; 
; This code is hereby placed to the PUBLIC DOMAIN. Enjoy.
;
; This was originally a contribution for Imphobia coder compo in
; 1996 which was unfortunately cancelled.
; Apparently the old page with intermediate compo results is still up:
;
; http://home.sch.bme.hu/~ervin/icc.html
;
; This code is rather straightforward, it reads the current time from
; the CMOS and directly writes it to video text memory. The update code
; is hooked into INT 1Ch, whih is the system timer tick interrupt.
;
; After many years the code was dusted off, converted to NASM and a few
; bytes shaved off. It works fine in DosBox (http://www.dosbox.com/).
;
; Assemble with: nasm -l clock.lst -o clock.com clock.asm
;
; Last modification: 2010-03-05
;
        org 100h

        mov ax, 251ch         ; Hook INT 1Ch (timer tick)
        mov dx, handler
        int 21h

        mov dx, ax
        int 27h               ; Terminate & Stay Resident

handler:
	pusha
        push es

        push 0b800h           ; ES => screen memory 
        pop es                

        mov di, 71*2          ; DI => display position
        mov cx, 0704h         ; CX <- colour attribute & CMOS register

mainloop:
        mov ax, cx
        out 70h, al           ; Read the clock register from CMOS
        in al, 71h

        push ax               ; Convert the numbers and write them to the display
        shr al, 4
        add al, 30h
        stosw
        pop ax
        and al, 0fh
        add al, 30h
        stosw

        dec cl                ; Bail out after the last digit
        js done               

        mov al,':'            ; Store the ':' with the colour attribute
        stosw                 

        dec cx                ; Decrease loop counter (CMOS reg selector)
        jmp short mainloop

done:   pop es               
        popa

	iret
