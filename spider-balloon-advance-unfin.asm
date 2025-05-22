.model small
.stack 100h
.data
    player_x db 40    ; Vi tri x cua nguoi choi
    player_y db 12    ; Vi tri y cua nguoi choi
    old_player_x db 40; Vi tri x cu cua nguoi choi
    old_player_y db 12; Vi tri y cu cua nguoi choi
    max_balloons equ 3
    balloon_coords_x db max_balloons dup(?)   ;mang toa do X cua cac bong bay
    balloon_coords_y db max_balloons dup(?)   ;mang toa do Y cua cac bong bay 
    old_balloon_coords_x db max_balloons dup(?)   ;toa do X cu de xoa
    old_balloon_coords_y db max_balloons dup(?)   ;toa do Y cu de xoa
    score db 0        ; Diem so
    msg db 'Diem: $' ; Thong bao diem
    final_msg db 13,10,'Diem cuoi cung: $' ; Thong bao diem cuoi
    continue_msg db 13,10,'Bam T de tiep tuc hoac ESC de thoat$'
    game_seconds dw 60  ; Thoi gian con lai tinh bang GIAY THUC 
    loop_counter db 0   ; Bo dem so lan lap cua game_loop
    loops_per_second db 2 ; So lan lap game_loop de duoc khoang 1 giay 
    time_msg db 'Thoi gian: $'
    time_over_msg db 13,10,'HET GIO!$'

    
    ; Huong dan choi
    guide1 db '=== HUONG DAN CHOI ===$'
    guide2 db 13,10,'Su dung phim mui ten de di chuyen nhan vat *$'
    guide3 db 13,10,'Thu thap cac bong bay O de ghi diem$'
    guide4 db 13,10,'Nhan Q hoac ESC de thoat tro choi$'
    guide5 db 13,10,'Nhan phim bat ki de bat dau...$'
    guide6 db 13,10,'$'

.code
display_score proc
    mov ah, 2
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 10h
    
    mov ah, 9
    lea dx, msg
    int 21h
    
    mov ah, 2
    mov dl, score
    add dl, 30h
    int 21h
    ret
display_score endp

display_guide proc
    mov ah, 0    ; Chuyen ve che do text
    mov al, 3
    int 10h
    
    mov ah, 9    ; Hien thi huong dan
    lea dx, guide1
    int 21h
    lea dx, guide2 
    int 21h
    lea dx, guide3
    int 21h
    lea dx, guide4
    int 21h
    lea dx, guide5
    int 21h
    lea dx, guide6
    int 21h
    
    mov ah, 0    ; Cho nhan phim bat ki
    int 16h
    
    mov ax, 0003h ; Xoa man hinh
    int 10h
    ret
display_guide endp   

display_time proc
    push ax
    push bx
    push cx
    push dx
    
    mov ah, 2
    mov bh, 0
    mov dh, 0       ; Hang 0
    mov dl, 10      ; Cot 10 (sau diem so)
    int 10h
    
    mov ah, 9
    lea dx, time_msg
    int 21h
    
    
    mov ax, game_seconds          ;AX chua so giay con lai
    
    ;Hien thi so co 2 chu so
    xor dx, dx
    mov bx, 10
    div bx
    
    mov cl, al
    mov ch, dl
    
    add cl, 30h
    add ch, 30h  
    
    ;Hien thi hang chuc
    
    mov dl, cl
    mov ah, 2
    int 21h       
    
    ;Hien thi hang don vi
    
    mov dl, ch
    mov ah, 2
    int 21h
                 
    ;Khoang trong de xoa so cu             
    mov dl, ' '
    mov ah, 2
    int 21h
    int 21h
   
    pop dx
    pop cx
    pop bx
    pop ax
    ret
display_time endp

display_final_score proc
    mov ah, 0        ; Chuyen ve che do text
    mov al, 3
    int 10h
    
    mov ah, 9        ; Hien thi thong bao diem cuoi
    lea dx, final_msg
    int 21h
    
    mov ah, 2        ; Hien thi so diem
    mov dl, score
    add dl, 30h
    int 21h
    
    mov ah, 2        ; Xuong dong moi
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h
    
    ; Them thong bao lua chon
    mov ah, 9
    lea dx, continue_msg
    int 21h
    
wait_key:    
    mov ah, 0        ; Doi phim
    int 16h
    
    cmp al, 't'      ; Neu bam t
    je restart_game
    cmp al, 'T'      ; Neu bam T
    je restart_game
    cmp al, 27       ; Neu bam ESC
    je exit_prog
    jmp wait_key     ; Neu khong phai T hoac ESC, tiep tuc doi
    
restart_game:
    mov score, 0     ; Reset diem ve 0
    ret
    
exit_prog:
    mov ax, 4c00h    ; Thoat chuong trinh
    int 21h
    
display_final_score endp    

init_one_balloon proc
    pusha
    
    ;Tao vi tri ngau nhien cho bong bay
    
    mov ah, 0
    int 1ah           ; Lay thoi gian he thong CX:DX

    mov ax, dx        ; Su dung phan thap DX
    xor dx, dx        ; DX=0 cho phep chia
    mov cx, 70        ; Chia cho 70 (0-69)
    div cx            ; Du trong DX
    add dl, 5         ; Toa do X tu 5 den 74
    
    mov [balloon_coords_x + bx], dl
    mov [old_balloon_coords_x + bx], dl
    
    mov ax, dx        ;Su dung lai so du
    xor dx, dx
    mov cx, 20
    div cx
    add dl, 2
    mov [balloon_coords_y + bx], dl 
    mov [old_balloon_coords_y + bx], dl 
    
    popa
    ret
init_one_balloon endp

init_all_balloons proc
    push bx
    push cx

    mov cx, MAX_BALLOONS ; So luong bong bay can khoi tao
    mov bx, 0            ; Index bat dau tu 0  
    
init_loop:
    call init_one_balloon ; Goi thu tuc khoi tao cho bong bay tai index BX
    inc bx                ; Tang index
    loop init_loop        ; Lap lai cho den khi CX = 0

    pop cx
    pop bx
    ret
init_all_balloons endp
main proc
    mov ax, @data
    mov ds, ax
    
restart:    
    ; Reset vi tri nguoi choi va bong bay
    mov player_x, 40
    mov player_y, 12
    mov old_player_x, 40
    mov old_player_y, 12
    mov score, 0   
    mov game_seconds, 60           ;Bat dau tu 60s
    mov loop_counter, 0            ;Reset bo dem vong lap
    
    ; Khoi tao bong bay
    call init_all_balloons
    
    ; Hien thi huong dan
    call display_guide
    
    ; An con tro
    mov ah, 1
    mov ch, 2bh
    mov cl, 0bh
    int 10h
    
    ; Xoa man hinh lan dau
    mov ax, 0003h
    int 10h
    
    ; Hien thi diem ban dau
    call display_score
    call display_time
    
game_loop:  
    inc loop_counter
    mov al, loop_counter
    cmp al, loops_per_second                 ;So sanh voi so vong lap can thiet cho 1 giay
    jl continue_game_loop_processing        ;Neu chua du, tiep tuc xu ly game
                                     
    mov loop_counter, 0
    dec game_seconds                         ;Giam so giay con lai
    
    call display_time 
    
    ;Kiem tra het gio
    mov ax, game_seconds
    cmp ax, 0
    jle game_over_by_time
    
continue_game_loop_processing:                                
    ; Xoa vi tri cu cua nguoi choi
    mov ah, 2
    mov bh, 0
    mov dh, old_player_y
    mov dl, old_player_x
    int 10h
    
    mov ah, 2
    mov dl, ' '
    int 21h
    
    ; Ve nguoi choi o vi tri moi
    mov ah, 2
    mov bh, 0
    mov dh, player_y
    mov dl, player_x
    int 10h
    
    mov ah, 2
    mov dl, '*'
    int 21h
    
    ; Luu vi tri hien tai lam vi tri cu
    mov al, player_x
    mov old_player_x, al
    mov al, player_y
    mov old_player_y, al
    
    ; Ve bong bay
    push cx
    push bx
    push si       ;lam con tro trong mang
    
    mov cx, max_balloons
    mov si, 0
 
draw_erase_balloons_loop:
    ;xoa bong bay
    mov ah, 2
    mov bh, 0
    mov dh, [old_balloon_coords_y + si]         ;Lay Y cu tu mang
    mov dl, [old_balloon_coords_x + si]         ;Lay X cu tu mang  
    int 10h
    
    mov ah, 2
    mov dl, ' '
    int 21h
    
    ;ve bong bay o vi tri moi
    mov ah, 2
    mov bh, 0
    mov dh, [balloon_coords_y + si]     ; Lay Y moi tu mang
    mov dl, [balloon_coords_x + si]     ; Lay X moi tu mang
    int 10h
    
    mov ah, 2
    mov dl, '0'
    int 21h 
    
    ;cap nhat old-coords = current_coords cho lan sau
    mov al, [balloon_coords_x + si]
    mov [old_balloon_coords_x + si], al
    mov al, [balloon_coords_y + si]
    mov [old_balloon_coords_y + si], al
    inc si                 
    
    loop draw_erase_balloons_loop 
    
    pop si
    pop bx
    pop cx                  
                      
    ; Them do tre
    mov cx, 1
    mov dx, 0
    mov ah, 86h
    int 15h
    
    ; Kiem tra phim nhan
    mov ah, 1
    int 16h
    jz check_collision
    
    mov ah, 0
    int 16h
    
    ; Xu ly phim dieu huong
    cmp ah, 48h      ; Mui ten len
    je move_up
    cmp ah, 50h      ; Mui ten xuong
    je move_down
    cmp ah, 4bh      ; Mui ten trai
    je move_left
    cmp ah, 4dh      ; Mui ten phai
    je move_right
    cmp al, 'q'      ; q de thoat
    je exit_game
    cmp al, 'Q'      ; Q de thoat
    je exit_game
    cmp al, 27       ; ESC
    je exit_game
    jmp check_collision
    
move_up:
    cmp player_y, 1
    jle check_collision
    dec player_y
    jmp check_collision
    
move_down:
    cmp player_y, 24
    jge check_collision
    inc player_y
    jmp check_collision
    
move_left:
    cmp player_x, 1
    jle check_collision
    dec player_x
    jmp check_collision
    
move_right:
    cmp player_x, 79
    jge check_collision
    inc player_x
    
check_collision:
    ; Kiem tra va cham
    push cx
    push bx
    push si
    
    mov cx, max_balloons
    mov si, 0
    
check_loop:
    mov al, player_x
    mov bl, [balloon_coords_x + si]        ;Lay X cua bong bay hien tai
    cmp al, bl
    jne next_balloon_check                 ;Kiem tra bong bay tiep theo neu sai
    
    mov al, player_y
    mov bl, [balloon_coords_y + si]        ;Lay Y cua bong bay hien tai 
    cmp al, bl 
    
     
    jne next_balloon_check
    ; Tang diem va cap nhat hien thi
    inc score
    call display_score
    
    ; Tao vi tri ngau nhien cho bong bay vua va cham
    
    mov bx, si                           ; Dua index cua bong bay va cham vao BX
    call init_one_balloon
    
next_balloon_check:
    inc si
    loop check_loop  
    
no_collision_found: ; Neu khong co va cham nao trong vong lap
    pop si
    pop bx
    pop cx
    jmp no_collision
    
no_collision:
    jmp game_loop    

game_over_by_time: 
    mov ah, 2
    mov bh, 0
    mov dh, 14
    mov dl, 35
    int 10h
    
    mov ah, 9
    lea dx, time_over_msg
    int 21h
    
    ;Tao do tre hien thong bao
    mov cx, 0FFFFh
    mov dx, 0FFFFh
    mov ah, 86h
    int 15h
    
    jmp exit_game
    

exit_game:
    call display_final_score    ; Hien thi diem cuoi cung
    cmp al, 't'                ; Kiem tra neu bam T
    je restart                  ; Neu bam T thi choi lai
    cmp al, 'T'
    je restart
    
    mov ax, 4c00h              ; Neu khong thi thoat
    int 21h
main endp
end main