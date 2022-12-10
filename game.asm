.model small
.stack 100h
.data
    posx dw 080h ; kamuolio kintamieji: koordinates x ir y
    posy dw 01h ;dw gali talpinti 2 baitus
    ball_size dw 04h ; kamuolio dydis. Siuo atveju 4 pikseliai
    prev_time db 0h ; saugomas praeitas sistemos laikas
    direction dw 02h ; i kuria puse judes kamuolys
    speedx dw 04h ; kamuolio greitis x asyje
    speedy dw 04h ; kamuolio greitis y asyje
    floor_x dw 0100h ; pagrindo apatines kaires puses koordinates x, y
    floor_y dw 0beh ;
    floor_height dw 0fh
    floor_width dw 01eh
    point dw 0h
    filename db "rezults.txt", "$"
    handler dw ?
    text db "Your score is: $"
.code
start:
    mov ax, @data
    mov ds, ax

    laikas:
        mov ah, 2ch ; gauna laika is sistemos
        int 21h
        cmp dl, prev_time ; tikrinama, ar praejo laiko nuo paskutinio tikrinimo
        je laikas
    mov prev_time, dl

    call fonas ; istrina figuras po paskutinio judesio
    call check_boundries ; tikrina ar neatsitrenkta i sienas
    call draw ; nupiesia zaidimo kvadrata
    call move_floor ; judina apatini pagrinda
    call draw_floor ; nupiesia apatini pagrinda
    call move ; judina zaidimo kvadrata

    jmp laikas ; soka ir programos pradzia ir tikrina, ar praejo laiko tarpas po paskutinio tikrinimo
    ret
    
draw:
    mov cx, posx ; pradines koordinates: koordinate x
    mov dx, posy ; kooridante y

    draw_X:
        mov ah, 0ch ; pikselio sukurimas
        mov al, 04h ; pikselio spalva
        mov bh, 00h ; puslapio numeris
        int 10h

        inc cx
        mov ax, cx
        sub ax, posx ; randam, kiek poziciju buvo uzpildyta
        cmp ax, ball_size ; tikrinam, ar uzpildyta eilute, jei ne, tai piesiam dar viena pikseli
        jng draw_X

        mov cx, posx
        inc dx
        mov ax, dx
        sub ax, posy
        cmp ax, ball_size ; tikrinam, ar uzpildytas stulpelis
        jng draw_X

    ret

    draw_floor: ;toks pat principas kaip zaidimo kvadrato, tik piesiam apatini pagrinda
        mov cx, floor_x
        mov dx, floor_y

        draw_floor_X:
            mov ah, 0ch
            mov al, 0eh
            mov bh, 00h
            int 10h

            inc cx
            mov ax, cx
            sub ax, floor_x
            cmp ax, floor_width
            jng draw_floor_X

            mov cx, posx
            inc dx
            mov ax, dx
            sub ax, posy
            cmp ax, floor_height
            jng draw_floor_X
        ret

    fonas:
    mov ah, 00h ;pereinam i video mode
    mov al, 13h ; kuria video mode aplinka pasirenkam
    int 10h

    mov ah, 0bh
    mov bh, 00h ; nustatom backgrounda
    mov bl, 00h ; backgroundo spalva
    int 10h

    ret

    move: ; pakeicia pradines kvadrato koordinates, kad kito piesimo metu butu pakeista pozicija
    mov ax, speedx
    add posx, ax ; keiciam pradine x koordinate pagal x koordinates greiti
    mov ax, speedy ; keiciam pradine y koordinate pagal y koordinates greiti
    add posy, ax

    ret

    move_floor:
    mov ah, 01h ; tikrinam ar buvo paspaustas kazkoks mygtykas
    int 16h

    jz button ; jeigu niekas nebuvo paspausta, praleidziam

    mov ah, 00h ; jeigu buvo paspaustas, tikrinam kuris
    int 16h

    cmp al, 061h ; tikrinam ar paspaustas mygtukas 'a'
    je move_left

    cmp al, 064h ; tikrinam, ar paspaustas mygtukas 'd'
    je move_right
    button: 
    ret

    move_left:
    sub floor_x, 0fh ; jei buvo paspausta, keiciam x koordinate
    xor ah, ah
    ret

    move_right:
    add floor_x, 0fh ; jei buvo paspausta, keiciam x koordinate
    xor ah, ah
    ret 

    check_boundries: ; tikrinam, ar pasiekti reziai. Jei taip, atitinkamai keiciam judejimo
    ;greicio krypti
    cmp posx, 00h
    jle x_direction_change

    cmp posx, 0140h
    jge x_direction_change

    cmp posy, 0c8h
    jge y_direction_change

    cmp posy, 00h
    jle y_direction_change

    mov ax, floor_y
    sub ax, 04h
    cmp posy, ax ; tikrinam ar kvadrato x koordinate yra salia pagrindo y asies
    jge check_floor ; jei taip, ziurim, ar atsimus i kvadrata

    ret

    x_direction_change: ; keiciam judejimo krypti
    neg speedx
    ret
    y_direction_change:
    neg speedy
    ret

    check_floor:
    mov ax, floor_x ; tikrinam ar kvadratas yra is kaires pagrindui
    cmp posx, ax
    jle pabaiga ; jei taip, zaidimo pabaiga

    xor ax, ax
    add ax, floor_x ; tikrinam ar kvadratas yra is desines pagrindui
    add ax, floor_width

    cmp posx, ax
    jg pabaiga ; jei taip, zaidimo pabaiga

    neg speedy ; jei kvadratas atsimusa i pagrinda, tai keiciam judejimo krypti
    inc point

    ret

    pabaiga:
    mov ah, 03ch ; failo susikurimas
    mov cx, 0h
    mov dx, offset filename
    int 21h

  mov  handler, ax

  mov  ah, 40h
  mov  bx, handler
  mov  cx, 0fh
  mov  dx, offset text ; duomenu irasymas
  int  21h


add point, 30h
    mov  ah, 40h
  mov  bx, handler
  mov  cx, 01h
  mov  dx, offset point ; duomenu irasymas
  int  21h

  mov  ah, 3eh ; uzdarymas
  mov  bx, handler
  int  21h

    mov ah, 4ch ; isejimas is programos
    int 21h



end start
