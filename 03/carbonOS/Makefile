default: ipl.img run

carbon.img: carbon.sys ipl.bin 
	echo hi

carbon.sys: carbon.nas
	nasm -o carbon.sys carbon.nas

ipl.bin: ipl.nas
	nasm -o ipl.bin ipl.nas

ipl.lst:
	nasm -l ipl.lst -o ipl.bin ipl.nas

run:
	sudo qemu-system-x86_64 -m 2048 -boot c -enable-kvm -net nic -net user -hda ipl.img

clean:
	rm *.img *.lst *.sys *.bin
