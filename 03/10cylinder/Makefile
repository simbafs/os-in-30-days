default: ipl.img run

ipl.img: 
	nasm -o ipl.img ipl.nas

ipl.lst:
	nasm -l ipl.lst -o ipl.img ipl.nas

run:
	sudo qemu-system-x86_64 -m 2048 -boot c -enable-kvm -net nic -net user -hda ipl.img

clean:
	rm *.lst
	rm *.img
