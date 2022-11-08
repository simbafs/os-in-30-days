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
| 名稱 | 英文          | 中文       |
| `es` | extra segment | 額外區段   |
| `cs` | code segment  | 程式碼區段 |
| `ss` | stack segment | 堆疊區段   |
| `ds` | data segment  | 資料區段   |
| `fs` |               |            |
| `gs` |               |            |

## int 0x10
這個東西會調用 BIOS 中關於繪圖、字元輸出的功能，除了這裡印字串以外也可以畫圖。使用時他會去讀其中幾個暫存器的值，並且會有不同作用，以這次的程式為例
| 暫存器 | 值     | 說明                       |
| `ah`   | `0x0e` | 打字機模式                 |
| `al`   | `[si]` | 要印的字元                 |
| `bh`   | 未指定 | 頁碼（不知道是什麼）       |
| `bl`   | `15`   | 顏色，但是目前的模式不能用 |

## list file
list file 中文翻譯作清單檔案，他的功能是讓你知道每一行的組語翻譯出來是什麼，產生的方式是 `nasm -l ipl.lst ipl.nas`

## 參考資料
* https://stackoverflow.com/questions/8140016/x86-nasm-org-directive-meaning
* https://zh.wikipedia.org/wiki/INT_10H
