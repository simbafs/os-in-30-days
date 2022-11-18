# day 01

## 機器語言
第一個 helloos.img 打好久，而且 xxd 一直出錯，後來是用 vim 先編輯好 helloos.img.ascii 再用 `xxd -r helloos.img.ascii > helloos.img` 才成功，在 vim 裡面用 `:%! xxd -r` 轉出來的東西一直怪怪的

## 組語
接著作者介紹用組語再寫一個一樣的東西，這次就對程式有比較詳細的解說。我用得組譯器是 nasm，用 apt 就可以安裝了。但是有個地方組譯一直不過，查 Google 後發現大概是語法問題，`RESB 0x1fe-$` 要寫成 `RESB 0x1fe-($-$$)`，參考這個網頁 https://zhuanlan.zhihu.com/p/353391541 。然後組譯的時候會出現 `warning: uninitialized space declared in .text section: zeroing [-w+zeroing]` 的警告，根據 https://www.asmcommunity.net/forums/topic/?id=9845 的說明，忽略他  
最後檢查有沒有打錯，有一個地方我把 `0x8e` 打成 `0xbe` 了 XD  

## 開機
我用的是 qemu 進行測試，命令如下
```
sudo qemu-system-x86_64 -m 2048 -boot c -enable-kvm -net nic -net user -hda helloos.img
```

## 兩個映像檔
應該叫映像檔吧？反正就是一個手打的和一個用 nasm 組譯出來的，用 `diff <(xxd helloos.img) <(xxd helloos2.img)` 比較後發現只差 1 byte
```
8,9c8,9
< 00000070: eef4 ebfd 0a0a 6865 6c6c 6f2c 2077 6f72  ......hello, wor
< 00000080: 6c64 0a00 0000 0000 0000 0000 0000 0000  ld..............
---
> 00000070: eef4 ebfd 0a0a 4865 6c6c 6f20 776f 726c  ......Hello worl
> 00000080: 6421 0a00 0000 0000 0000 0000 0000 0000  d!..............
```

> <(cmd) 是 bash 語法，會把命令輸出塞到一個站存檔，然後回傳路徑  

> 更：仔細看會發現那只是我印的訊息不一樣的關係，改掉後兩個就一模一樣了  

## 檔案
```
helloos.nas         nasm 程式原始碼
helloos2.img        用 nasm 編出來的映像檔
helloos.img.ascii   xxd helloos.img
helloos.img         親自打出來的映像檔
```

# Day 02
首先引入了更多的組語命令，把昨天看不懂的那坨組語重新改寫，然後介紹了一大堆暫存器

## org
`org` 是一個組語命令，原文是 origin，我的理解他是指定接下來的程式要載入到記憶體的 `0x7c00` 位置，但為什麼是這裡 [這篇部落格](https://www.ruanyifeng.com/blog/2015/09/0x7c00.html) 有提出歷史因素

## 組語命令

| 組語                  | 對應的 c                |
| :---:                 | :---                    |
| `mov a, b`            | `a = b`                 |
| `mov a, [b]`          | `a = *b`                |
| `jump lebel`          | `goto lable`            |
| `cmp a, b ; je lebel` | `if(a == b) goto lebel` |
| `add a, b`            | `a += b`                |
| `int` | interupt，調用 BIOS 函數 |

## 16 位元暫存器與 8 位元暫存器

| 名稱 | 英文              | 中文     | 八位元 |
| `ax` | accumulator       | 累加器   | ah+al  |
| `cx` | counter           | 計數器   | ch+cl  |
| `dx` | data              | 資料     | dh+dl  |
| `bx` | base              | 基底     | bh+dl  |
| `sp` | stack pointer     | 堆疊指標 |        |
| `bp` | base pointer      | 基底指標 |        |
| `si` | source index      | 來源索引 |        |
| `di` | destination index | 目的索引 |        |
`ax`、`cx`、`dx`、`bx` 各自有分高低位暫存器，其實就是把他從中間拆開，0~7 位元稱作低位暫存器，8~15 位元稱作高位暫存器  
書中提到，在 32 位元暫存器中，名稱就是加上 `e`，例如 32 位元累加器就是 `eax`，低位部份就是 `ax`，但高位部份沒有名字  

## 區段暫存器

| 名稱  | 英文          | 中文       |
| :---: | :---          | :---       |
| `es`  | extra segment | 額外區段   |
| `cs`  | code segment  | 程式碼區段 |
| `ss`  | stack segment | 堆疊區段   |
| `ds`  | data segment  | 資料區段   |
| `fs`  |               |            |
| `gs`  |               |            |

## int 0x10
這個東西會調用 BIOS 中關於繪圖、字元輸出的功能，除了這裡印字串以外也可以畫圖。使用時他會去讀其中幾個暫存器的值，並且會有不同作用，以這次的程式為例  

| 暫存器 | 值     | 說明                       |
| :---:  | :---:  | :---                       |
| `ah`   | `0x0e` | 打字機模式                 |
| `al`   | `[si]` | 要印的字元                 |
| `bh`   | 未指定 | 頁碼（不知道是什麼）       |
| `bl`   | `15`   | 顏色，但是目前的模式不能用 |

## list file
list file 中文翻譯作清單檔案，他的功能是讓你知道每一行的組語翻譯出來是什麼，產生的方式是 `nasm -l ipl.lst ipl.nas`

## 參考資料
* https://stackoverflow.com/questions/8140016/x86-nasm-org-directive-meaning
* https://zh.wikipedia.org/wiki/INT_10H
* https://stackoverflow.com/questions/16154870/how-to-read-a-nasm-assembly-program-lst-listing-file

# Day 03 
## 讀入一個磁區
1. 設定讀入的記憶體地址
2. 設定磁柱、磁頭、磁區、一次幾個磁區
ipl.nas:37: error: invalid combination of opcode and operands
3. 設定[模式](https://en.wikipedia.org/wiki/INT_13H#List_of_INT_13h_services)
4. 設定磁碟機
5 `int 0x13`
6. 如果沒有錯誤跳到 `fin`
7. 計數器 + 1 
8. 如果計數器 >= 5，跳到 error
9. 再試一次

> **Warning**  
> 書上這邊有錯誤，`jnc fin` 後面的註解應該是「如果『沒有』錯誤......」

## 讀入 18 個磁區
這邊跟讀入 1 個磁區的步驟基本上一樣，但是加上一個迴圈的功能  
1. 把 `jnc fin` 改成 `jnc next`
2. 在失敗計數器 `mov si, 0` 前新增一個 label `readloop`，因為這個暫存器每次讀入都要重設，相當於區域變數
2. 新增 label `next`，負責處理迴圈的 ++ 和判斷式的部份
```nasm
next;
	; 因為 es 不能做運算，所以丟到 ax
	mov ax, es 
	add ax, 0x20 
	mov es, ax
	; 如果(++目前磁區) <= 18，讀取下一個磁區
	add cl, 1 
	cmp cl, 18 
	jbe readloop
```

> **Warning**  
> 這裡 1. 的地方書上範例忘記改了，但是光碟裡的檔案是正確的

## 讀入 10 個磁柱
模仿[讀入 18 個磁區](#讀入 18 個磁區)的作法，將 next 擴充，這裡用到一個新語法 `equ`，下面會介紹。我們讀取的順去是讀完 18 個磁區後翻面用另一個磁頭，接這換到下一個磁柱
```nasm
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
```

### EQU
`equ` 語法跟 c 中的 `#define` 一樣，都是在編譯/組譯時期就替換掉的
```
CYLC equ 10 ; 相當於 #define CYLC 10
```
根據產生的 [ipl.lst](https://github.com/simbafs/os-in-30-days/tree/main/03/10cylinder/ipl.lst)
```
     1                                  ; fat12 軟碟內容
     2                                  
     3                                  CYLC equ 10 ; 相當於 #define CYLC 10
     4                                  
     5                                  org 0x7c00
     6 00000000 EB4E                    jmp entry
```
看這裡的第 3 行，可以發現 `equ` 指令不會被翻譯，往下拉到 `next` 中用到 `CYLC` 的部份，也就是第 84 行附近
```
    81                                  	; 讀完一個磁柱兩面了，換下一個磁柱
    82 0000009E B600                    	mov dh, 0
    83 000000A0 80C501                  	add ch, 1 ; ch -> 要讀取的磁柱
    84 000000A3 80FD0A                  	cmp ch, CYLC
    85 000000A6 76C4                    	jbe readloop
```
可以看到應該放 `CYLC` 的地方被 `0x0A` 取代，也就是 `CYLC` 的值 `10`

## 疑問
這邊似乎沒有方式檢驗是否成功把磁區都讀進來了，因為我的程式不是完全照書上打，也許迴圈一開始就沒進去，直接進到 `fin`。似乎只能等到用到那些磁區的資料的時候才知道了

## 簡單的 OS
這邊就有點麻煩了，因為用到作者自己寫得工具，而且檔案有點多，看作者的 Makefile 大概理解流程是
```
記號 'a -> (b c)' a 依賴於 b 和 c，換句話說要先產生 b 和 c 才能產生 a
haribote.img -> (ipl.bin -> (ipl.nas) haribote.sys -> (haribote.nas))
```
看起來是把這次新增的 OS 本體（haribote.nas）和原本的 ipl 各自組譯後弄成一個檔案（haribote.img），有點像 c 編譯後要連結的概念（？這裡我有一個小疑惑，為什麼作者要把 `Makefile` 加進依賴項裡面，如果 `Makefile` 不存在根本不會執行才對，那為什麼要做白工？或許是某種歷史因素？  

檢查了一下作者給的 ipl10.nas，裡面在 `next` 的最後面加上了
```nasm 
MOV	[0x0ff0], CH
JMP	0xc200
```		
然後把最後面的 `msg` 改成 `loading error`
意思大概是全部載入成功的話就會執行新增的那兩行，如果中間曾經跳到 `error`，就會把 `msg` 中的錯誤訊息印出來。而 `0xc200` 根據作者的解釋是 os 在讀進來的磁碟在記憶體中的位置，那麼現在的唯一的問題就是要怎麼正確的「連結」了
