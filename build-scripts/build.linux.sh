
BITS=32
GCC_FLAG=-m32
OUTPUT_DIR=dist

main()
{
	# check if 32, 64 bits or arm or other
	# OUTPUT_DIR can be accepted from terminal --outdir=./build

	OUTPUT_DIR=dist$BITS
	GCC_FLAG=-m$BITS
	mkdir -p $OUTPUT_DIR
	compile_object_files
	link_object_files
}

compile_object_files()
{
	nasm -f elf$BITS ../src/kernel/kernel.asm -o $OUTPUT_DIR/kernelasm.o
	gcc $GCC_FLAG -c ../src/kernel/kernel.c -o $OUTPUT_DIR/kernelc.o
}

link_object_files()
{
	ld -m elf_i386 -T link.linux.ld -o $OUTPUT_DIR/kernel.bin $OUTPUT_DIR/kernelasm.o $OUTPUT_DIR/kernelc.o
}

main