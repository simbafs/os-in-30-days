; fat12 軟碟內容
db 0xeb, 0x4e, 0x90 ;跳轉指令（跳過開頭一段區域）
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
db 0xb8, 0x00, 0x00, 0x8e, 0xd0, 0xbc, 0x00, 0x7c
db 0x8e, 0xd8, 0x8e, 0xc0, 0xbe, 0x74, 0x7c, 0x8a
db 0x04, 0x83, 0xc6, 0x01, 0x3c, 0x00, 0x74, 0x09
db 0xb4, 0x0e, 0xbb, 0x0f, 0x00, 0xcd, 0x10, 0xeb
db 0xee, 0xf4, 0xeb, 0xfd

; 訊息
db 0x0a, 0x0a
db "hello, world"
db 0x0a
db 0

resb 0x1fe-($-$$)
db 0x55, 0xaa

db 0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
resb 4600
db 0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
resb 1469432
