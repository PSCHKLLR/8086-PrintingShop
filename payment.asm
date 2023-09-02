.model small
.stack 100h
.data

inp label BYTE
pay db 10
    db ?
    db 10 dup ('$')

; --------------< No. of paper each service >----------------
paperA4 dw 1001, 1001, 1001, 1001 
paperA3 dw 1001, 1001 , 1001, 1001
paperA2 dw 1001, 1001, 1001, 1001

; --------------< price of each service >----------------
priceA4 dw 250, 500, 200, 400
priceA3 dw 450, 900, 400, 800
priceA2 dw 800, 1600, 750, 1500

cent dw 12 dup (?)  ; ----> Cents part of Price
ringgit dw 12 dup (?) ; ----> Ringgit part of Price
subTotalRinggit dw ?
subTotalCent dw ?
salesPaper dw ?
discount dw 0
; -------< temp Reminder placeholder >--------------
rem1 dw ?
rem2 db ?

; -----------< calculation tool >-------------
tenthousand dw 10000
thousand dw 1000
hundred db 100
ten db 10

; -------------< String Variable >------------------
rm db "RM $"
papers db "Paper : $"
printing db "Printing$"
photo db "Photocopy$"
bw db "Black & White$"
color db "Color$"
A4 db "A4$"
A3 db "A3$"
A2 db "A2$"


;-------------- < MACRO >----------------

print macro str
    mov ah, 09h
    lea dx, str
    int 21h
endm

putc macro char
    mov dl, char
    mov ah, 02h
    int 21h
endm

charIn macro char
    mov ah, 01h
    int 21h
    mov char, al
endm

scan macro str
    mov ah, 0ah
    lea dx, str
    int 21h
endm

paperNo macro paper
    mov ax, paper
    mov dx, 0
    mov bx, tenthousand
    div bx
    mov rem1, dx

    mov bl, 1
    div bl
    add al, '0'
    mov bl, al

    putc bl

    mov ax, rem1
    mov dx, 0
    mov bx, 100
    div bx
    mov rem1, dx

    mov bl, 10
    div bl
    add ah, '0'
    mov rem2, ah
    mov dl, al
    add dl, '0'
    putc dl
    putc rem2

    mov ax, rem1
    mov bl, ten
    div bl
    add al, '0'
    add ah, '0'
    mov bl, ah
    putc al
    putc bl
endm

calcPrice macro paper, price
    mov ax, paper
    mov bx, price
    mul bx

    mov bx, 1000
    div bx
    mov ringgit[di], ax
    mov cent[di], dx
endm

printRM macro ringgit, cent
    print rm
    mov ax, ringgit
    mov bx, thousand
    mov dx, 0
    div bx
    mov rem1, dx
    mov bl, 1
    div bl
    add al, '0'
    mov bl, al
    putc bl

    mov ax, rem1
    mov dx, 0
    mov bl, 100
    div bl
    mov dl, al
    mov rem2, ah
    add dl, '0'
    putc dl ; first digit

    mov al, rem2
    mov ah, 0
    mov bl, ten
    div bl
    mov dl, al
    mov bl, ah
    add dl, '0'
    putc dl ; second

    add bl, '0'
    putc bl ;third

    putc 2eh

    mov ax, cent
    mov bl, 100
    div bl
    mov dl, al
    mov rem2, ah
    add dl, '0'
    putc dl ; first digit

    mov al, rem2
    mov ah, 0
    mov bl, ten
    div bl
    mov dl, al
    mov bl, ah
    add dl, '0'
    putc dl ; second

    add bl, '0'
    putc bl ;third
endm

totalPaper macro total, a4, a3, A2
    mov ax, total
    mov cx, 4
    mov si, 0
    pp:
    add ax, a4[si]
    add ax, a3[si]
    add ax, A2[si]
    add si, 2
    loop pp
    mov total, ax
endm


.code


main proc
    mov ax, @data
    mov ds, ax



    ; --------------------< Price Calculation >---------------------
    mov cx, 4
    mov si, 0
    mov di, 0
    cal:
    calcPrice paperA4[si], priceA4[si]
    add di, 2
    add si, 2
    loop cal

    mov cx, 4
    mov di, 8
    mov si, 0
    cal2:
    calcPrice paperA3[si], priceA3[si]
    add si, 2
    add di, 2
    loop cal2

    mov cx, 4
    mov di, 16
    mov si, 0
    cal3:
    calcPrice paperA2[si], priceA2[si]
    add di, 2
    add si, 2
    loop cal3


    ;-------------------< Calculate Subtotal >-----------------
    mov cx, 12
    mov si, 0
    mov bx, subTotalRinggit
    mov ax, subTotalCent
    rm1:
    add bx, ringgit[si]
    add ax, cent[si]
    add si, 2
    loop rm1
    mov subTotalRinggit, bx
    mov subTotalCent, ax

    mov ax, subTotalCent
    mov bx, 1
    mul bx
    mov bx, thousand
    div bx
    mov subTotalCent, dx
    mov bx, ax
    mov ax, subTotalRinggit
    add ax, bx
    mov subTotalRinggit, ax


    ;----------------< Calculate Total Paper >--------------
;    mov ax, salesPaper
;    mov cx, 4
;    mov si, 0
;    pp:
;    add ax, paperA2[si]
;    add ax, paperA3[si]
;    add ax, paperA4[si]
;    add si, 2
;    loop pp
;    mov salesPaper, ax

    totalPaper salesPaper, paperA2, paperA3, paperA4

    print papers
    paperNo salesPaper

    putc 9
    putc 9
    putc 9
    printRM subTotalRinggit, subTotalCent

    mov ax, salesPaper
    cmp ax, 100
    jbe pay

    cmp ax, 200
    jbe discountA
    jmp discountB

    pay:
    ;Total = subtotal - discount

    discountA:
    ; Discount A =  20% x subtotal

    


    discountB:

    mov ax, 4c00h
    int 21h
main endp

clear proc
    xor ax, ax    ; Clear AX register
    xor bx, bx    ; Clear BX register
    xor cx, cx    ; Clear CX register
    xor dx, dx    ; Clear DX register
    xor si, si    ; Clear SI register
    xor di, di    ; Clear DI register
    xor bp, bp    ; Clear BP register
    xor sp, sp    ; Clear SP register
    ret
clear endp


end main