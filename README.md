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

## 檔案
```
helloos.nas         nasm 程式原始碼
helloos2.img        用 nasm 編出來的映像檔
helloos.img.ascii   xxd helloos.img
helloos.img         親自打出來的映像檔
```
