; fat12 軟碟內容

CYLC equ 10 ; 相當於 #define CYLC 10

org 0x7c00
jmp entry

db 0x90 ;跳轉指令（跳過開頭一段區域）
db "HELLOIPL" ;OEM名稱（空格補齊）
dw 512 ;每個磁區的位元組數
db 1 ;每叢集磁區數
dw 1 ;保留磁區數
db 2 ;檔案配置表數目
dw 224 ;最大根目錄條目個數
dw 2880 ;總磁區數
db 0xf0 ;媒介描述
dw 9 ;每個檔案配置表的磁區
dw 18 ;每磁軌的磁區
dw 2 ;磁頭數
dd 0 ;隱藏磁區
dd 2880 ;總磁區數
db 0, 0, 0x29 ;
dd 0xffffffff
db "HELLO-OS   "
db "FAT12   "
resb 18

; 程式碼
entry:
	; mov ax, 0 ; 累加器 accumulator
	mov ss, ax ; 堆疊區塊 stack segment
	mov sp, 0x7c00 ; 堆疊指標 stack pointer
	mov ds, ax ; 資料區段 data sement
	; mov es, ax ; 額外區段 extra segment
	mov si, msg ; 來源索引 source index

	; 設定磁碟機
	mov ax, 0x0820 ; 寫入的記憶體地址
	mov es, ax ; 寫入的記憶體地址（為什麼不直接寫入？）
	; mov es, 0x0820 ; ipl.nas:37: error: invalid combination of opcode and operands
	mov bx, 0 ; 寫入的記憶體地址: es*16+bx
	mov ch, 0 ; 磁柱 0 
	mov dh, 0 ; 磁頭 0
	mov cl, 2 ; 磁區 2（1 是開機磁區？）
	mov al, 1 ; 1 個磁區
	mov dl, 0x00 ; 第 0 個磁碟機

readloop:
	mov si, 0 ; 失敗計數器

retry:
	mov ah, 0x02 ; mode: read sectors from drive
	int 0x13 
	jnc next ; jump if not carry
	add si, 1
	cmp si, 5
	jae error ; jump if above or equal 
	; reset
	mov ah, 0x00 
	mov dl, 0x00
	int 0x13 
	jmp retry

next:
	; 因為 es 不能做運算，所以丟到 ax
	mov ax, es 
	add ax, 0x20 
	mov es, ax

	; 如果(++目前磁區) <= 18，讀取下一個磁區
	add cl, 1 ; cl -> 要讀取的磁區 
	cmp cl, 18 
	jbe readloop

	; 讀完一面了，換下一個磁頭
	mov cl, 1
	add dh, 2 ; dh -> 目前的磁柱
	cmp dh, 2 
	jbe readloop 

	; 讀完一個磁柱兩面了，換下一個磁柱
	mov dh, 0
	add ch, 1 ; ch -> 要讀取的磁柱
	cmp ch, CYLC
	jbe readloop


error: 
	mov si, msg

putloop:
	mov al, [si] ; 將 si 指向的內容（1 byte）帶入 al, al = *si
	             ; 累加器低位部份 accumulator low
	add si, 1 ; 指向下一個 byte
	cmp al, 0 
	je fin 
	mov ah, 0x0e ; 累加器高位部份 accumulator high，設定模式為打字機輸出
	mov bx, 15 ; 基底 base 
	int 0x10 ; interupt
	jmp putloop
	
fin:
	hlt ; cpu 休眠
	jmp fin

msg:
	; 訊息
	db 0x0a, 0x0a
	db "hello, world"
	db 0x0a
	db 0

	resb 0x1fe-($-$$)

	db 0x55, 0xaa
