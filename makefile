all: lynarr

lynarr: lynarr.o asm_io.o
	 gcc -m32 -o lynarr driver.c lynarr.o asm_io.o
lynarr.o: lynarr.asm
	nasm -f elf32 -o lynarr.o lynarr.asm
asm_io.o: asm_io.asm
	nasm -f elf32 -d ELF_TYPE asm_io.asm
clean:
	rm asm_io.o lynarr.o lynarr
