.model small
.stack 100h
.data
    PLAYER_X DB 40                                  ; Vi tri x cua nguoi choi
    PLAYER_Y DB 12                                  ; Vi tri y cua nguoi choi
    OLD_PLAYER_X DB 40                              ; Vi tri x cu cua nguoi choi
    OLD_PLAYER_Y DB 12                              ; Vi tri y cu cua nguoi choi
    MAX_BALLOONS EQU 3
    MAX_OBSTACLES EQU 30
    OBSTACLES_COORDS_X DB 12, 25, 38, 61, 70, 7, 45, 16, 55, 30, 22, 69, 10, 40, 64, 33, 49, 15, 72, 20, 5, 18, 59, 43, 27, 66, 37, 52, 74, 35
    OBSTACLES_COORDS_Y DB 3, 5, 4, 7, 2, 6, 9, 10, 8, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 2, 3, 5, 6, 8, 9, 10, 12, 14
    BALLOON_COORDS_X DB MAX_BALLOONS dup(?)         ; mang toa do X cua cac bong bay
    BALLOON_COORDS_Y DB MAX_BALLOONS dup(?)         ; mang toa do Y cua cac bong bay 
    OLD_BALLOON_COORDS_X DB MAX_BALLOONS dup(?)     ; toa do X cu de xoa
    OLD_BALLOON_COORDS_Y DB MAX_BALLOONS dup(?)     ; toa do Y cu de xoa
    SCORE DB 0                                      ; Diem so
    DEATH_MSG DB '                                   GAME OVER!$'
    MSG DB 'Diem: $'                                ; Thong bao diem
    FINAL_MSG DB 13,10,'                               Diem cuoi cung: $' ; Thong bao diem cuoi
    CONTINUE_MSG DB 13,10,'                      Bam T de tiep tuc hoac ESC de thoat$'
    GAME_SECONDS DW 60                              ; Thoi gian con lai tinh bang GIAY THUC 
    LOOP_COUNTER DW 0                               ; Bo dem so lan lap cua GAME_LOOP
    LOOPS_PER_SECOND DW 20                          ; So lan lap GAME_LOOP de duoc khoang 1 giay 
    TIME_MSG DB 'Thoi gian: $'
    TIME_OVER_MSG DB 13,10,'                Spider procrastinated so hard it ceased to exist.$'
    DEAD_MSG DB 13,10,'                             Spider: 0 - Spike: 1$'
    QUICK_QUIT_MSG DB 13,10,'                    Spider rage quit. Probably blaming lag.$'
    LOADING_MSG DB 13,10,13,10,13,10,13,10,13,10,'                                   LOADING...$'
    ENDL DB 13, 10, '$'
    X_TEMP DB 0
    Y_TEMP DB 0
    
    ; Huong dan choi
    GUIDE1 DB '                           === HUONG DAN CHOI ===$'
    GUIDE2 DB 13,10, '                   Su dung phim mui ten de di chuyen nhan vat *$'
    GUIDE3 DB 13,10, '                   Thu thap cac bong bay O de ghi diem$'
    GUIDE4 DB 13,10, '                   Nhan Q hoac ESC de thoat tro choi$'
    GUIDE5 DB 13,10, '                   Nhan phim bat ki de bat dau...$'
    GUIDEX DB 13,10, '                Tro choi duoc tao boi Nhom BTL4 - D23CQCE01-B!$'

    DIFF1 DB '                             Danh sach do kho cua game$'
    DIFF2 DB 13,10, '            1. Standard: Khong chuong ngai vat, 3 balloons, 1 pts/balloon$'
    DIFF3 DB 13,10, '            2. Maniac: Co chuong ngai vat, 3 balloons, 3 pts/balloon$'
    DIFF4 DB 13,10, '                Chon do kho: $'
    CURRENT_DIFF DB 1
.code
    ; MACRO TO PRINT 1-DIGIT NUMBER NUM
    PRINTF_DIGIT MACRO NUM 
        MOV AL, NUM                                 ; AL <- NUM
        ADD AL, '0'                                 ; AL <- AL + '0' (TURN AL TO ASCII)
        MOV DL, AL                                  ; DL <- AL
        MOV AH, 02h                                 ; PRINT CHAR MODE
        INT 21h
    ENDM

    ; MACRO TO PRINT N-DIGIT NUMBER NUM
    PRINTF_NUMBER MACRO NUM
        LOCAL CONVERT_LOOP, PRINT_LOOP
        ; AX = TARGET
        MOV AL, NUM                                 ; AL <- NUM
        XOR AH, AH                                  ; AH <- 0 (RESET AH -> 16BIT MODE)
        MOV CX, 10                                  ; CX <- 10
        XOR BX, BX                                  ; BX <- 0 (RESET BX FOR COUNT NUMBER OF DIGITS)

    CONVERT_LOOP:
        XOR DX, DX                                  ; DX <- 0 (RESET DX)
        DIV CX                                      ; AX / CX (10) => AX = Q, DX = R
        PUSH DX                                     ; PUSH DX (R) TO STACK
        INC BX                                      ; BX <- BX + 1
        CMP AX, 0                                   ; COMPARE AX (Q) WITH 0
        JNE CONVERT_LOOP                            ; IF AX != 0 LOOP BACK

    PRINT_LOOP:
        POP DX                                      ; DX <- POP DIGIT FROM STACK
        PRINTF_DIGIT DL                             ; PRINT DL
        DEC BX                                      ; BX <- BX - 1
        JNZ PRINT_LOOP                              ; IF BX != 0 LOOP BACK

    ENDM

    DISPLAY_SCORE PROC
        ; SET CURSOR TO X = 0, Y = 0
        MOV AH, 02h
        MOV BH, 00h
        MOV DH, 0
        MOV DL, 0
        INT 10h
        
        MOV AH, 9
        LEA DX, MSG
        INT 21h
        
        PRINTF_NUMBER SCORE
        MOV AH, 02h
        MOV DL, ' '
        INT 21h
        MOV DL, ' '
        INT 21h
        RET
    DISPLAY_SCORE ENDP

    DISPLAY_GUIDE PROC
        MOV AH, 00h                                 ; Chuyen ve che do text
        MOV AL, 03h
        INT 10h
        
        MOV AH, 09h                                 ; Hien thi huong dan
        LEA DX, ENDL
        INT 21h
        LEA DX, ENDL
        INT 21h
        LEA DX, ENDL
        INT 21h
        LEA DX, GUIDE1
        INT 21h
        LEA DX, GUIDE2 
        INT 21h
        LEA DX, GUIDE3
        INT 21h
        LEA DX, GUIDE4
        INT 21h
        LEA DX, ENDL
        INT 21h
        LEA DX, GUIDEX
        INT 21h
        LEA DX, ENDL
        INT 21h
        LEA DX, ENDL
        INT 21h
        LEA DX, GUIDE5
        INT 21h
        
        MOV AH, 07h                                 ; Cho nhan phim bat ki
        INT 21h

        RET
    DISPLAY_GUIDE ENDP   

    CHOOSE_DIFF PROC
        MOV AH, 00h                                 ; Chuyen ve che do text
        MOV AL, 03h
        INT 10h
        
        MOV AH, 09h                                 ; Hien thi huong dan
        LEA DX, ENDL
        INT 21h
        LEA DX, ENDL
        INT 21h
        LEA DX, ENDL
        INT 21h
        LEA DX, DIFF1
        INT 21h
        LEA DX, DIFF2 
        INT 21h
        LEA DX, DIFF3
        INT 21h
        LEA DX, DIFF4
        INT 21h
        RET
    CHOOSE_DIFF ENDP

    DISPLAY_TIME PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        
        MOV AH, 02h
        MOV BH, 00h
        MOV DH, 0                                   ; Hang 0
        MOV DL, 10                                  ; Cot 10 (sau diem so)
        INT 10h
        
        MOV AH, 09h
        LEA DX, TIME_MSG
        INT 21h
        
        MOV AX, GAME_SECONDS                        ; AX chua so giay con lai
        
        ; Hien thi so co 2 chu so
        XOR DX, DX
        MOV BX, 10
        DIV BX
        
        MOV CL, AL
        MOV CH, DL
        
        ADD CL, 30h
        ADD CH, 30h  
        
        ; Hien thi hang chuc
        MOV DL, CL
        MOV AH, 02h
        INT 21h       
        
        ; Hien thi hang don vi
        MOV DL, CH
        MOV AH, 02h
        INT 21h
                    
        ; Khoang trong de xoa so cu             
        MOV DL, ' '
        MOV AH, 02h
        INT 21h
    
        POP DX
        POP CX
        POP BX
        POP AX
        RET
    DISPLAY_TIME ENDP

    DISPLAY_FINAL_SCORE PROC 
        MOV AH, 09h                                 ; Hien thi thong bao diem cuoi
        LEA DX, FINAL_MSG
        INT 21h
        
        PRINTF_NUMBER SCORE
        
        MOV AH, 09h                                 ; Xuong dong moi
        LEA DX, ENDL
        INT 21h
        
        ; Them thong bao lua chon
        MOV AH, 09h
        LEA DX, CONTINUE_MSG
        INT 21h
        
    WAIT_KEY:    
        MOV AH, 08h                                 ; Doi phim
        INT 21h
        
        CMP AL, 't'                                 ; Neu bam t
        JE RESTART_GAME
        CMP AL, 'T'                                 ; Neu bam T
        JE RESTART_GAME
        CMP AL, 27                                  ; Neu bam ESC
        JE EXIT_PROG
        JMP WAIT_KEY                                ; Neu khong phai T hoac ESC, tiep tuc doi
        
    RESTART_GAME:
        MOV SCORE, 0                                ; Reset diem ve 0
        RET
        
    EXIT_PROG:
        MOV AH, 4Ch                                 ; Thoat chuong trinh
        INT 21h
        
    DISPLAY_FINAL_SCORE ENDP    

    INIT_ONE_BALLOON PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
               
        MOV AL, [CURRENT_DIFF]
        CMP AL, '1'
        JE CREATE_BALLOON_EASY
        JMP CREATE_BALLOON_HARD

    CREATE_BALLOON_EASY:
        ; Tao vi tri ngau nhien cho bong bay
        MOV AH, 00h
        INT 1Ah                                     ; Lay thoi gian he thong CX:DX

        MOV AX, DX                                  ; Su dung phan thap DX
        XOR DX, DX                                  ; DX = 0 cho phep chia
        MOV CX, 30                                  ; Chia cho 30 (0-29)
        DIV CX                                      ; Du trong DX, phan du = randomizer
        ADD DL, 20                                  ; Toa do X se random tu 20 den 50
        MOV [X_TEMP], DL
        
        MOV AX, DX                                  ; Su dung lai randomizer cho toa do Y
        XOR DX, DX
        MOV CX, 15
        DIV CX
        ADD DL, 5                                   ; Toa do Y se random tu 5 den 15
        MOV [Y_TEMP], DL 
        
        ; Kiem tra toa do co trung voi cac bong bay khac khong
        MOV SI, 0
        MOV CX, BX
        CMP CX, 0
        JE STORE_BALLOON_EASY

    CHECK_OVERLAP_LOOP_EASY:
        ; Vong lap kiem tra bong bay bi trung hay khong
        MOV AL, [BALLOON_COORDS_X + SI]
        CMP AL, [X_TEMP]
        JNE NO_MATCH_EASY
        MOV AL, [BALLOON_COORDS_Y + SI]
        CMP AL, [Y_TEMP]
        JE OVERLAP_FOUND_EASY                       ; Trung

    NO_MATCH_EASY:
        ; Khong bi trung -> bong bay tiep theo
        INC SI
        LOOP CHECK_OVERLAP_LOOP_EASY

    STORE_BALLOON_EASY:
        ; Luu vi tri bong bay
        MOV AL, [X_TEMP]
        MOV [BALLOON_COORDS_X + BX], AL
        MOV [OLD_BALLOON_COORDS_X + BX], AL
        MOV AL, [Y_TEMP]
        MOV [BALLOON_COORDS_Y + BX], AL
        MOV [OLD_BALLOON_COORDS_Y + BX], AL
        JMP CREATE_BALLOON_END

    OVERLAP_FOUND_EASY:
        ; Tim thay bong bay bi trung -> Khoi tao tu dau
        JMP CREATE_BALLOON_EASY

    CREATE_BALLOON_HARD:
        ; Tao vi tri ngau nhien cho bong bay
        MOV AH, 00h
        INT 1Ah                                     ; Lay thoi gian he thong CX:DX

        MOV AX, DX                                  ; Su dung phan thap DX
        XOR DX, DX                                  ; DX = 0 cho phep chia
        MOV CX, 70                                  ; Chia cho 70 (0-69)
        DIV CX                                      ; Du trong DX, phan du = randomizer
        ADD DL, 5                                   ; Toa do X se random tu 5 den 74
        MOV [X_TEMP], DL

        MOV AX, DX                                  ; Su dung lai randomizer cho toa do Y
        XOR DX, DX
        MOV CX, 20
        DIV CX
        ADD DL, 2                                   ; Toa do Y se random tu 2 den 22
        MOV [Y_TEMP], DL

        ; Kiem tra toa do co trung voi cac bong bay khac khong
        MOV SI, 0
        MOV CX, BX
        CMP CX, 0
        JE VALIDATE_OBSTACLES_HARD

    CHECK_OVERLAP_LOOP_HARD:
        MOV AL, [BALLOON_COORDS_X + SI]
        CMP AL, [X_TEMP]
        JNE NEXT_BALLOON_HARD
        MOV AL, [BALLOON_COORDS_Y + SI]
        CMP AL, [Y_TEMP]
        JE CREATE_BALLOON_HARD                      ; Trung

    NEXT_BALLOON_HARD:
        ; Khong trung -> Kiem tra bong bay tiep theo
        INC SI
        LOOP CHECK_OVERLAP_LOOP_HARD

    VALIDATE_OBSTACLES_HARD:
        ; Kiem tra co trung voi chuong ngai vat hay khong
        PUSH BX
        XOR DI, DI
        MOV CX, MAX_OBSTACLES
        
    EXIST_OBSTACLES_CHECK:
        MOV AL, [OBSTACLES_COORDS_X + DI]
        MOV DL, [X_TEMP]
        CMP AL, DL
        JNE NOT_EXIST

        MOV AL, [OBSTACLES_COORDS_Y + DI]
        MOV DL, [Y_TEMP]
        CMP AL, DL
        JNE NOT_EXIST

        POP BX
        JMP CREATE_BALLOON_HARD                     ; Trung

    NOT_EXIST:
        ; Khong trung -> kiem tra bong bay tiep theo
        INC DI                                      ; Tang index
        LOOP EXIST_OBSTACLES_CHECK
        POP BX

    STORE_BALLOON_HARD:
        ; Luu vi tri bong bay
        MOV AL, [X_TEMP]
        MOV [BALLOON_COORDS_X + BX], AL
        MOV [OLD_BALLOON_COORDS_X + BX], AL
        MOV AL, [Y_TEMP]
        MOV [BALLOON_COORDS_Y + BX], AL
        MOV [OLD_BALLOON_COORDS_Y + BX], AL
    
    CREATE_BALLOON_END:
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
        RET
    INIT_ONE_BALLOON ENDP

    INIT_ALL_BALLOONS PROC
        PUSH BX
        PUSH CX

        MOV CX, MAX_BALLOONS                      ; So luong bong bay can khoi tao
        XOR BX, BX                                  ; Index bat dau tu 0  
        
    INIT_LOOP_BALLOON:
        CALL INIT_ONE_BALLOON                       ; Goi thu tuc khoi tao cho bong bay tai index BX
        CALL DELAY
        INC BX                                      ; Tang index
        LOOP INIT_LOOP_BALLOON                      ; Lap lai cho den khi CX = 0

        POP CX
        POP BX
        RET
    INIT_ALL_BALLOONS ENDP

    DELAY PROC
        PUSH CX
        PUSH DX

        MOV CX, 50                                  ; Outer loop count (adjust for speed)
    DELAY_OUTER:
        MOV DX, 2000                                ; Inner loop count (adjust for delay)
    DELAY_INNER:
        NOP                                         ; No operation, just delay
        DEC DX
        JNZ DELAY_INNER

        DEC CX
        JNZ DELAY_OUTER

        POP DX
        POP CX
    DELAY ENDP

    CLS PROC
        MOV AX, 03h                                 ; AX <- 03h (80 X 25 MODE)
        INT 10h
        RET
    CLS ENDP
    
    HIDE_CURSOR PROC
        MOV AH, 1
        MOV CH, 2Bh
        MOV CL, 0Bh
        INT 10h
        RET
    HIDE_CURSOR ENDP

    LOADING_SCREEN PROC
        LEA DX, LOADING_MSG
        MOV AH, 09h
        INT 21h
        RET
    LOADING_SCREEN ENDP

    MAIN PROC
        MOV AX, @DATA
        MOV DS, AX
        
    RESTART:    
        ; Reset vi tri nguoi choi va bong bay
        MOV PLAYER_X, 40
        MOV PLAYER_Y, 12
        MOV OLD_PLAYER_X, 40
        MOV OLD_PLAYER_Y, 12
        MOV SCORE, 0   
        MOV GAME_SECONDS, 60                        ; Bat dau tu 60s
        MOV LOOP_COUNTER, 0                         ; Reset bo dem vong lap
        
        CALL CLS

        ; Hien thi huong dan
        CALL DISPLAY_GUIDE
        CALL CLS

        ; Chon do kho cua game
        CALL CHOOSE_DIFF
    
    VALIDATE_DIFF:
        MOV AH, 08h
        INT 21h

        MOV [CURRENT_DIFF], AL
        CMP AL, '1'
        JE START_NORMAL
        CMP AL, '2'
        JE START_HARDCORE
        JMP VALIDATE_DIFF

    START_HARDCORE:
        MOV LOOPS_PER_SECOND, 20
        JMP START_GAME

    START_NORMAL:
        MOV LOOPS_PER_SECOND, 10000
        JMP START_GAME
    
    START_GAME:
        ; Khoi tao man hinh doi
        CALL CLS
        CALL LOADING_SCREEN
        ; Khoi tao bong bay (De)
        CALL INIT_ALL_BALLOONS
        ; Xoa man hinh
        CALL CLS

        ; An con tro
        CALL HIDE_CURSOR
        
        ; Hien thi diem ban dau
        CALL DISPLAY_SCORE
        CALL DISPLAY_TIME
        
    GAME_LOOP:
        INC LOOP_COUNTER
        MOV AX, LOOP_COUNTER
        CMP AX, LOOPS_PER_SECOND                    ; So sanh voi so vong lap can thiet cho 1 giay
        JL CONTINUE_GAME_LOOP_PROCESSING            ; Neu chua du, tiep tuc xu ly game
                                        
        MOV LOOP_COUNTER, 0
        DEC GAME_SECONDS                            ; Giam so giay con lai
        
        CALL DISPLAY_TIME 
        
        ; Kiem tra het gio
        MOV AX, GAME_SECONDS
        CMP AX, 0
        JLE GAME_OVER_BY_TIME
        
    CONTINUE_GAME_LOOP_PROCESSING:                                
        ; Xoa vi tri cu cua nguoi choi
        MOV AH, 02h
        MOV BH, 00h
        MOV DH, OLD_PLAYER_Y
        MOV DL, OLD_PLAYER_X
        INT 10h
        
        MOV AH, 02h
        MOV DL, ' '
        INT 21h
        
        ; Ve nguoi choi o vi tri moi
        MOV AH, 02h
        MOV BH, 00h
        MOV DH, PLAYER_Y
        MOV DL, PLAYER_X
        INT 10h
        
        MOV AH, 02h
        MOV DL, '*'
        INT 21h
        
        ; Luu vi tri hien tai lam vi tri cu
        MOV AL, PLAYER_X
        MOV OLD_PLAYER_X, AL
        MOV AL, PLAYER_Y
        MOV OLD_PLAYER_Y, AL
        
        ; Ve bong bay
        PUSH CX
        PUSH BX
        PUSH SI                                     ; lam con tro trong mang
        
        MOV CX, MAX_BALLOONS
        MOV SI, 0
    
    DRAW_ERASE_BALLOONS_LOOP:
        ; Xoa bong bay
        MOV AH, 02h
        MOV BH, 00h
        MOV DH, [OLD_BALLOON_COORDS_Y + SI]         ; Lay Y cu tu mang
        MOV DL, [OLD_BALLOON_COORDS_X + SI]         ; Lay X cu tu mang  
        INT 10h
        
        MOV AH, 02h
        MOV DL, ' '
        INT 21h
        
        ; Ve bong bay o vi tri moi
        MOV AH, 02h
        MOV BH, 00h
        MOV DH, [BALLOON_COORDS_Y + SI]             ; Lay Y moi tu mang
        MOV DL, [BALLOON_COORDS_X + SI]             ; Lay X moi tu mang
        INT 10h
        
        MOV AH, 02h
        MOV DL, '0'
        INT 21h 
        
        ; Cap nhat old-coords = current_coords cho lan sau
        MOV AL, [BALLOON_COORDS_X + SI]
        MOV [OLD_BALLOON_COORDS_X + SI], AL
        MOV AL, [BALLOON_COORDS_Y + SI]
        MOV [OLD_BALLOON_COORDS_Y + SI], AL
        INC SI                 
        
        LOOP DRAW_ERASE_BALLOONS_LOOP 
        
        POP SI
        POP BX
        POP CX                  

        MOV AL, [CURRENT_DIFF]
        CMP AL, '1'
        JE INPUT_REGISTERING
        ; Ve chuong ngai vat
        PUSH CX
        PUSH BX
        PUSH SI                                       ; lam con tro trong mang
        
        MOV CX, MAX_OBSTACLES
        MOV SI, 0
    
    DRAW_OBSTACLES_LOOP:
        ; Ve chuong ngai vat o vi tri moi
        MOV AH, 02h
        MOV BH, 00h
        MOV DH, [OBSTACLES_COORDS_Y + SI]             ; Lay Y moi tu mang
        MOV DL, [OBSTACLES_COORDS_X + SI]             ; Lay X moi tu mang
        INT 10h
        
        MOV AH, 0Eh
        MOV AL, 30
        INT 10h

        INC SI
        LOOP DRAW_OBSTACLES_LOOP 

        POP SI
        POP BX
        POP CX

        ; Them do tre
        MOV CX, 1
        MOV DX, 0
        MOV AL, 0
        MOV AH, 86h
        INT 15h
        
    INPUT_REGISTERING:
        ; Kiem tra phim nhan
        MOV AH, 1
        INT 16h
        JZ CHECK_COLLISION
        
        MOV AH, 00h
        INT 16h
        
        ; Xu ly phim dieu huong
        CMP AH, 48h                                 ; Mui ten len
        JE MOVE_UP
        CMP AH, 50h                                 ; Mui ten xuong
        JE MOVE_DOWN
        CMP AH, 4Bh                                 ; Mui ten trai
        JE MOVE_LEFT
        CMP AH, 4Dh                                 ; Mui ten phai
        JE MOVE_RIGHT
        CMP AL, 'q'                                 ; q de thoat
        JE GAME_OVER_BY_QUICK_QUIT
        CMP AL, 'Q'                                 ; Q de thoat
        JE GAME_OVER_BY_QUICK_QUIT
        CMP AL, 27                                  ; ESC
        JE GAME_OVER_BY_QUICK_QUIT
        JMP CHECK_COLLISION
        
    MOVE_UP:
        CMP PLAYER_Y, 1
        JLE CHECK_COLLISION
        DEC PLAYER_Y
        JMP CHECK_COLLISION
        
    MOVE_DOWN:
        CMP PLAYER_Y, 24
        JGE CHECK_COLLISION
        INC PLAYER_Y
        JMP CHECK_COLLISION
        
    MOVE_LEFT:
        CMP PLAYER_X, 1
        JLE CHECK_COLLISION
        DEC PLAYER_X
        JMP CHECK_COLLISION
        
    MOVE_RIGHT:
        CMP PLAYER_X, 79
        JGE CHECK_COLLISION
        INC PLAYER_X
        
    CHECK_COLLISION:
        ; Kiem tra va cham
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH SI
        PUSH DI
        
        MOV CX, MAX_BALLOONS
        MOV SI, 0
        
    CHECK_LOOP:
        MOV AL, PLAYER_X
        MOV BL, [BALLOON_COORDS_X + SI]             ; Lay X cua bong bay hien tai
        CMP AL, BL
        JNE OBSTACLES_CHECK                         ; Kiem tra bong bay tiep theo neu sai
        
        MOV AL, PLAYER_Y
        MOV BL, [BALLOON_COORDS_Y + SI]             ; Lay Y cua bong bay hien tai 
        CMP AL, BL 
        JNE OBSTACLES_CHECK

        JMP ADD_SCORE_CHECK

    OBSTACLES_CHECK:
        MOV AL, [CURRENT_DIFF]
        CMP AL, '1'
        JE NEXT_BALLOON_CHECK
        
        ; HARDCORE MODE
        XOR DI, DI
                     
    OBSTACLES_CHECK_LOOP:
        MOV AL, PLAYER_X
        MOV BL, [OBSTACLES_COORDS_X + DI]           ; Lay X cua chuong ngai vat hien tai
        CMP AL, BL
        JNE OBSTACLES_INC                           ; Kiem tra chuong ngai vat tiep theo neu khong va cham

        MOV AL, PLAYER_Y
        MOV BL, [OBSTACLES_COORDS_Y + DI]           ; Lay Y cua chuong ngai vat hien tai
        CMP AL, BL
        JNE OBSTACLES_INC                           ; Kiem tra chuong ngai vat tiep theo neu khong va cham

        JMP GAME_OVER_BY_DEATH

    ; Tang index cua DI
    OBSTACLES_INC:
        XOR AH, AH
        MOV AL, MAX_OBSTACLES
        DEC AX
        INC DI
        CMP DI, AX
        JE NEXT_BALLOON_CHECK
        JMP OBSTACLES_CHECK_LOOP

    ADD_SCORE_CHECK:
        ; Tang diem va cap nhat hien thi
        MOV AL, [CURRENT_DIFF]
        CMP AL, '2'
        JE HARD_SCORING
        JMP EASY_SCORING
    
    HARD_SCORING:
        INC SCORE
        INC SCORE

    EASY_SCORING:
        INC SCORE
    
        CALL DISPLAY_SCORE
        
        ; Tao vi tri ngau nhien cho bong bay vua va cham
        MOV BX, SI                                  ; Dua index cua bong bay va cham vao BX
        CALL INIT_ONE_BALLOON
        
    NEXT_BALLOON_CHECK:
        INC SI
        LOOP CHECK_LOOP  
        
    NO_COLLISION_FOUND: 
        ; Neu khong co va cham nao trong vong lap
        POP DI
        POP SI
        POP CX
        POP BX
        POP AX
        JMP NO_COLLISION
        
    NO_COLLISION:
        JMP GAME_LOOP    

    GAME_OVER_BY_TIME:
        CALL CLS
        ; Xoa video memory (clean garbage)
        MOV AX, 0600h                               ; Ham 06h, AL = 0 (clear full window)
        MOV BH, 07h                                 ; Ki tu can xoa (light grey tren nen black)
        MOV CX, 0000h                               ; Goc tren ben trai (row 0, col 0)
        MOV DX, 184Fh                               ; Goc duoi ben phai (row 24, col 79)
        INT 10h
        
        MOV AH, 9
        LEA DX, ENDL
        INT 21h
        LEA DX, ENDL
        INT 21h
        LEA DX, DEATH_MSG
        INT 21h
        LEA DX, TIME_OVER_MSG
        INT 21h

        JMP EXIT_GAME

    GAME_OVER_BY_DEATH:
        CALL CLS
        
        MOV AH, 9
        LEA DX, ENDL
        INT 21h
        LEA DX, ENDL
        INT 21h
        LEA DX, DEATH_MSG
        INT 21h
        LEA DX, DEAD_MSG
        INT 21h
        
        JMP EXIT_GAME

    GAME_OVER_BY_QUICK_QUIT:
        CALL CLS
        
        MOV AH, 9
        LEA DX, ENDL
        INT 21h
        LEA DX, ENDL
        INT 21h
        LEA DX, DEATH_MSG
        INT 21h
        LEA DX, QUICK_QUIT_MSG
        INT 21h
        
        JMP EXIT_GAME
    
    EXIT_GAME:
        CALL DISPLAY_FINAL_SCORE                    ; Hien thi diem cuoi cung
        CMP AL, 't'                                 ; Kiem tra neu bam T
        JE RESTART                                  ; Neu bam T thi choi lai
        CMP AL, 'T'
        JE RESTART
        
        MOV AH, 4Ch                                 ; Neu khong thi thoat
        INT 21h
    main ENDP
end main