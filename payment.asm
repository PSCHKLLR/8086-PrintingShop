.model small
.stack 100h
.data

inp label BYTE
pay db 15
    db ?
    db 15 dup ('$')

; --------------< No. of paper each service >----------------
paperA4 dw 4 dup (?)          
paperA3 dw 4 dup (?) 
paperA2 dw 4 dup (?) 

;------------< Daily No. of paper each service >--------------
dailyA4 dw 4 dup (?) 
dailyA3 dw 4 dup (?)
dailyA2 dw 4 dup (?)
; --------------< price of each service >----------------
;           BW, Color, BW, Color
priceA4 dw 250, 500, 200, 400
priceA3 dw 450, 900, 400, 800
priceA2 dw 800, 1600, 750, 1500

salesPaper dw ?
cent dw 12 dup (?)  ; ----> Cents part of Price
ringgit dw 12 dup (?) ; ----> Ringgit part of Price
subTotalRinggit dw ?
subTotalCent dw ?
totalRinggit dw ?
totalCent dw ?
discountRinggit dw 0
discountCent dw 0
cashRinggit dw ?
cashCent dw ?
changeRinggit dw ?
changeCent dw ?
dailyDiscountRinggit dw ?
dailyDiscountCent dw ?
; -------< temp Reminder placeholder >--------------
rem1 dw ?
rem2 db ?
rem3 dw ?
; -----------< calculation tool >-------------
tenthousand dw 10000
thousand dw 1000
hundred db 100
ten db 10
; -------------< String Variable >------------------
rm db "RM $"
name1 db "PrintCrafters Printing Shop$"
thanks db "Thanks For Using Our Service!$"
printing db "Printing$"
photo db "Photocopy$"
bw db "Black & White $"
color db "Color $"
A4 db "A4 $"
A3 db "A3 $"
A2 db "A2 $"
discA db "(20%)$"
discB db "(40%)$"
discountStr db "Discount : $"
subtotalStr db "Subtotal : $"
totalStr db "Total    : $"
changeStr db "Change   : $"
cashStr db "Cash     : $"
line db "======================================================$"
;---------< Spacing tool >---------------
space db 9,9,9,32,32,'$'
bigspace db 9,9,9,9,32,32,'$'
tripleTab db 9,9,32,32,'$'
doubleTab db 9,32,32,'$'
tripleSpace db 32,32,32,'$'

;-------------- < MACRO >----------------
;-------------< Print String >----------
print macro str
    mov ah, 09h
    lea dx, str
    int 21h
endm

;-------------< Print Character >----------
putc macro char
    mov dl, char
    mov ah, 02h
    int 21h
endm

;------------< Character Input >----------
charIn macro char
    mov ah, 01h
    int 21h
    mov char, al
endm

;-------------< String Input >----------
input macro str
    mov ah, 0ah
    lea dx, str
    int 21h
endm

;-------------< Print No. Of Paper >----------
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

;-------------< Calculate Price >----------
calcPrice macro paper, price
    mov ax, paper
    mov bx, price
    mul bx

    mov bx, 1000
    div bx
    mov ringgit[di], ax
    mov cent[di], dx
endm

;-------------< Print Price >----------
printRM macro ringgit, cent
    print rm
    mov ax, ringgit
    mov bx, thousand
    mov dx, 0
    div bx
    mov rem1, dx
    mov bl, 10
    div bl
    add al, '0'
    add ah, '0'
    mov bl, al
    mov cl, ah
    putc bl
    putc cl

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

;-------------< Calculate Total No. Of Paper >----------
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

;-------------< Calculate Discount >----------
calcDiscount MACRO rate, ringgit, cent
    mov ax, subTotalRinggit
    mov dx, 0
    mov bx, rate
    mul bx
    mov bx, 10
    div bx
    mov rem1, dx
    mov ringgit, ax

    mov ax, subTotalCent
    mov dx, 0
    mov bx, rate
    mul bx
    mov bx, 10
    div bx
    mov rem3, dx
    mov cx, ax

    mov ax, rem1
    mov bl, hundred
    mul bl
    add cx, ax
    mov ax, cx
    mov bx, thousand
    mov dx, 0
    div bx
    mov cent, dx

    mov bx, ringgit
    add bx, ax
    mov ringgit, bx
ENDM

.code ; <------------------------------- CODE START HERE!!!!!!
main proc
    mov ax, @data
    mov ds, ax

    ;---------- < Test Only >-------------
    mov ax, 1
    mov bx, 0
    mov cx, 5
    mov si, 0
    mov paperA4[si], ax
    mov si, 2
    mov paperA4[si], bx
    mov si, 4
    mov paperA4[si], cx
    mov si, 6
    mov paperA4[si], cx
    mov si, 0
    mov paperA3[si], ax
    mov si, 2
    mov paperA3[si], ax
    mov si, 4
    mov paperA3[si], bx
    mov si, 6
    mov paperA3[si], ax
    mov si, 0
    mov paperA2[si], bx
    mov si, 2
    mov paperA2[si], ax
    mov si, 4
    mov paperA2[si], bx
    mov si, 6
    mov paperA2[si], cx

    ;------------------< Price Calculation >-------------------
    call calculate

    ;-------------------< Calculate Subtotal >-----------------
    call calcSubtotal

    ;----------------< Calculate Total Paper >--------------
    totalPaper salesPaper, paperA2, paperA3, paperA4

    ;-----------------< Print Reciept >----------------
    reciept:
    call printItem
    call discOpt

    pays:
    ;Total = subtotal - discount
        putc 10
        print discountStr
        putc 9
        putc 9
        mov ax, salesPaper
        cmp ax, 100
        ja disSTR
    jmp cont
    
    disSTR:
        cmp ax, 200
        jbe Astr
        jmp Bstr

    Astr:
        print discA 
    jmp cont

    Bstr:
        print discB   
    jmp cont

    cont:
        print tripleTab
        printRM discountRinggit, discountCent
        putc 10
        print line
        putc 10
        print totalStr
        putc 9
        putc 9
        paperNo salesPaper
        print tripleTab
        printRM totalRinggit, totalCent
        putc 10
        print cashStr
        print bigspace
        print rm
        input pay
    call isdigit
    call parseInt
    call validateAmount

    balance:
        putc 10
        print changeStr
        print bigspace
        ;printRM cashRinggit, cashCent
        call return
        printRM changeRinggit, changeCent
        putc 10
        print line
        putc 10
        print doubleTab
        print tripleSpace
        print thanks
        call dailySum
        ;---------< Reset Value >-----------
        call resetSales
   
    mov ax, 4c00h
    int 21h
main endp

;----------< Clear >------------
clear proc
    xor ax, ax    ; Clear AX register
    xor bx, bx    ; Clear BX register
    xor cx, cx    ; Clear CX register
    xor dx, dx    ; Clear DX register
    xor si, si    ; Clear SI register
    xor di, di    ; Clear DI register
    ret
clear endp

;-----------< Calculate all >----------
calculate PROC
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
    ret
calculate ENDP

;-------------< Calculate Subtotal >----------
calcSubtotal PROC
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
    ret
calcSubtotal ENDP

;-------------< Clear Screen >----------
cls PROC
    mov ax, 0007h
    int 10h
    ret
cls ENDP

;-------------< Calculate Balance >----------
return PROC
    mov ax, cashCent
    cmp ax, totalCent
    jb lend

    blance:
        mov ax, cashRinggit
        sub ax, totalRinggit
        mov changeRinggit, ax

        mov ax, cashCent
        sub ax, totalCent
        mov changeCent, ax
    ret

    lend:
        mov ax, cashRinggit
        sub ax, 1
        mov cashRinggit, ax

        mov ax, cashCent
        add ax, 1000
        mov cashCent, ax
    jmp blance
    ret
return ENDP

;------< Parse to Int >---------
parseInt PROC
        xor ax, ax
        xor cx, cx
        mov si, 2
        mov di, 0
        n:
            mov al, pay[si]
            cmp al, 2eh
            je dot

            cmp al, 13
            jne firstR
            ret

        firstR:
            cmp di, 0
            jne nR

            sub al, '0'
            mov bl, 1
            mul bl
            mov cashRinggit, ax
            inc si
            inc di
        jmp n
    
        nR:
            mov ax, cashRinggit
            mov bx, 10
            mul bx
            mov cx, 1
            div cx
            mov cx, ax

            xor ax, ax

            mov al, pay[si]
            sub al, '0'
            mov bl, 1
            mul bl

            add cx, ax
            mov cashRinggit, cx
            inc si
        jmp n

        dot:
            inc si
            mov di, 0
        jmp lower

        lower:
            mov al, pay[si]
            cmp al, 13
            jne firstC
        ret

        firstC:
            cmp di, 0
            jne secondC

            sub al, '0'
            mov bl, 100
            mul bl
            mov cashCent, ax
            inc si
            inc di
        jmp lower
    
        secondC:
            cmp di, 1
            jne thirdC

            mov al, pay[si]
            sub al, '0'
            mov bl, 10
            mul bl
            add ax, cashCent
            mov cashCent, ax
            inc si
            inc di
        jmp lower

        thirdC:
            mov al, pay[si]
            sub al, '0'
            mov bl, 1
            mul bl
            add ax, cashCent
            mov cashCent, ax
            inc si
            inc di
        jmp lower   
parseInt ENDP

;------< Reset Sales Variable >-------
resetSales PROC
        xor ax, ax
        mov discountCent, ax
        mov si, 0
        mov paperA4[si], ax
        mov si, 2
        mov paperA4[si], ax
        mov si, 4
        mov paperA4[si], ax
        mov si, 6
        mov paperA4[si], ax
        mov si, 0
        mov paperA3[si], ax
        mov si, 2
        mov paperA3[si], ax
        mov si, 4
        mov paperA3[si], ax
        mov si, 6
        mov paperA3[si], ax
        mov si, 0
        mov paperA2[si], ax
        mov si, 2
        mov paperA2[si], ax
        mov si, 4
        mov paperA2[si], ax
        mov si, 6
        mov paperA2[si], ax
        ret    
resetSales ENDP

;-------< Discount Option >------
discOpt PROC
    mov ax, salesPaper
    cmp ax, 100
    ja discount

    mov bx, subTotalRinggit
    mov cx, subTotalCent
    mov totalRinggit, bx
    mov totalCent, cx
    ret
    
    discount:
        cmp ax, 200
        jbe discountA
    jmp discountB

    discountA:
        ; Discount A =  20% x subtotal
        calcDiscount 2, discountRinggit, discountCent
        calcDiscount 8, totalRinggit, totalCent
    ret

    discountB:
        calcDiscount 4, discountRinggit, discountCent
        calcDiscount 6, totalRinggit, totalCent    
    ret
discOpt ENDP

;-----< Sum for Daily Report >------
dailySum PROC
    mov cx, 4
        mov si, 0
        calcdailyA4:
            mov ax, dailyA4[si]
            add ax, paperA4[si]
            mov dailyA4[si], ax
            add si, 2
        loop calcdailyA4

        mov cx, 4
        mov si, 0
        calcdailyA3:
            mov ax, dailyA3[si]
            add ax, paperA3[si]
            mov dailyA3[si], ax
            add si, 2
        loop calcdailyA3

        mov cx, 4
        mov si, 0
        calcdailyA2:
            mov ax, dailyA2[si]
            add ax, paperA2[si]
            mov dailyA2[si], ax
            add si, 2
        loop calcdailyA2

        mov ax, dailyDiscountRinggit
        add ax, discountRinggit
        mov dailyDiscountRinggit, ax

        mov ax, dailyDiscountCent
        add ax, discountCent
        mov dx, 0
        mov bx, 1000
        div bx
        mov dx, dailyDiscountCent
        mov cx, dailyDiscountRinggit
        add cx, ax
        mov dailyDiscountRinggit, cx
        ret   
dailySum ENDP

;-------< Print Item >---------
printItem PROC
call cls
        print doubleTab
        print tripleSpace
        putc 32
        print name1
        putc 10
        print line
        putc 10
        mov di, 0
        mov ax, paperA4[di]
        cmp ax, 0
        ja A40
        jmp A41

        A40:
            mov si, 0
            paperNo paperA4[si]
            putc 32
            print A4
            print bw
            print printing
            print tripleTab
            printRM ringgit[si], cent[si]
            putc 10

        A41:
            mov si, 2
            mov ax, paperA4[si]
            cmp ax, 0
            ja a411
        jmp A42

        a411:
            paperNo paperA4[si]
            putc 32
            print A4
            print color
            print printing
            print space
            printRM ringgit[si], cent[si]
            putc 10

        A42:
            mov si, 4
            mov ax, paperA4[si]
            cmp ax, 0
            ja a421
        jmp A43

        a421:
            paperNo paperA4[si]
            putc 32
            print A4
            print bw
            print photo
            print doubleTab
            printRM ringgit[si], cent[si]
            putc 10


        A43:
            mov si, 6
            mov ax, paperA4[si]
            cmp ax, 0
            ja a431
        jmp A31

        a431:
            paperNo paperA4[si]
            putc 32
            print A4
            print color
            print photo
            print tripleTab
            printRM ringgit[si], cent[si]
            putc 10

        A31:
            mov di, 0
            mov ax, paperA3[di]
            cmp ax, 0
            ja a311
        jmp A32

        a311:
            mov si, 8
            paperNo paperA3[di]
            putc 32
            print A3
            print bw
            print printing
            print tripleTab
            printRM ringgit[si], cent[si]
            putc 10

        A32:
            mov di, 2
            mov ax, paperA3[di]
            cmp ax, 0
            ja a321
        jmp A33

        a321:
            mov si, 10
            paperNo paperA3[di]
            putc 32
            print A3
            print color
            print printing
            print space
            printRM ringgit[si], cent[si]
            putc 10

        A33:
            mov di, 4
            mov ax, paperA3[di]
            cmp ax, 0
            ja a331
        jmp A34

        a331:
            mov si, 12
            paperNo paperA3[di]
            putc 32
            print A3
            print bw
            print photo
            print doubleTab
            printRM ringgit[si], cent[si]
            putc 10

        A34:
            mov di, 6
            mov ax, paperA3[di]
            cmp ax, 0
            ja a341
        jmp A21

        a341:
            mov si, 14
            paperNo paperA3[di]
            putc 32
            print A3
            print color
            print photo
            print tripleTab
            printRM ringgit[si], cent[si]
            putc 10

        A21:
            mov di, 0
            mov ax, paperA2[di]
            cmp ax, 0
            ja a211
        jmp A22

        a211:
            mov si, 16
            paperNo paperA2[di]
            putc 32
            print A2
            print bw
            print printing
            print tripleTab
            printRM ringgit[si], cent[si]
            putc 10

        A22:
            mov di, 2
            mov ax, paperA2[di]
            cmp ax, 0
            ja a221
        jmp A23

        a221:
            mov si, 18
            paperNo paperA2[di]
            putc 32
            print A2
            print color
            print printing
            print space
            printRM ringgit[si], cent[si]
            putc 10

        A23:
            mov di, 4
            mov ax, paperA2[di]
            cmp ax, 0
            ja a231
        jmp A24

        a231:
            mov si, 20
            paperNo paperA2[di]
            putc 32
            print A2
            print bw
            print photo
            print doubleTab
            printRM ringgit[si], cent[si]
            putc 10

        A24:
            mov di, 6
            mov ax, paperA2[di]
            cmp ax, 0
            ja a241
        jmp done

        a241:
            mov si, 22
            paperNo paperA2[di]
            putc 32
            print A2
            print color
            print photo
            print tripleTab
            printRM ringgit[si], cent[si]
            putc 10

        done:
        print line
        putc 10
        print subtotalStr
        print bigspace
        printRM subTotalRinggit, subTotalCent
        ret   
printItem ENDP

;--------< Cash Amount Validation >-----------
validateAmount PROC
    mov ax, cashRinggit
    cmp ax, totalRinggit
    je validateCent
    ja back
    jmp reciept

    validateCent:
        mov ax, cashCent
        cmp ax, totalCent
        jae back
    jmp reciept

    back: 
        ret   
validateAmount ENDP

;description
isdigit PROC
    mov si , 2
    mov di , 0

    digit:
    mov al, pay[si]
    cmp al, 13
    jne dotnot
    ret

    dotnot:
    cmp al, 2eh
    je dot2

    cmp al, 57
    jb less
    jmp reciept

    less:
    cmp al, 48
    inc si
    ja digit
    jmp reciept

    dot2:
    inc si
    inc di
    cmp di, 1
    jbe digit
    jmp reciept   
isdigit ENDP
end main