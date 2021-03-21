#!/bin/bash

# This script 
# 
# License: MIT
# Author: Adewale Azeez <azeezadewale98@gmail.com>


ARG=
ARCH=x86
RUN=false
YEAR=2021
ARG_MATCH=
LOUD=false
LICENSE=MIT
VERSION=v1.0
LINKER_FILE=
GCC_FLAGS=-m32
SOURCE_FILES=()
OUT_NAME=kernel
NASM_FLAGS=elf32
SOURCE_DIRECTORY=
EXTRACTED_ARG_VALUE=
AUTHOR="Adewale Azeez"
OUTPUT_DIRECTORY=dist
ASSEMBLY_OBJECT_FILES=()
SELECTED_OBJECT_FILES=()
LINKER_ARCH_FLAG=elf_i386
SUPPORTED_ARCHITECTURES=(
	x86
	i386
	
	x64
	amd64
	x86_64
	x86_x64
)
QEMU_COMMAND=qemu-system-i386

main()
{
	# check if 32, 64 bits or arm or other
	# OUTPUT_DIR can be accepted from terminal --outdir=./build
	for ARG in "$@"
    do
        match_and_extract_argument $ARG
        if [[ "-h" == "$ARG_MATCH" || "--help" == "$ARG_MATCH" ]]; then
            print_help

        elif [[ "-l" == "$ARG_MATCH" || "--loud" == "$ARG_MATCH" ]]; then
            LOUD=true

        elif [[ "-r" == "$ARG_MATCH" || "--run" == "$ARG_MATCH" ]]; then
            RUN=true

        elif [[ "--outputdir" == "$ARG_MATCH" ]]; then
            OUTPUT_DIRECTORY=$EXTRACTED_ARG_VALUE

        elif [[ "--sourcedir" == "$ARG_MATCH" ]]; then
            SOURCE_DIRECTORY=$EXTRACTED_ARG_VALUE

        elif [[ "--sourcefiles" == "$ARG_MATCH" ]]; then
			IFS=', ' read -r -a SOURCE_FILES <<< $EXTRACTED_ARG_VALUE

        elif [[ "--arch" == "$ARG_MATCH" ]]; then
			if [[ ! " ${SUPPORTED_ARCHITECTURES[@]} " =~ " ${EXTRACTED_ARG_VALUE} " ]]; then
                fail_with_message "Unsupported architecture: '$EXTRACTED_ARG_VALUE'"
            fi
            ARCH=$EXTRACTED_ARG_VALUE

        elif [[ "-objs" == "$ARG_MATCH" || "--objects" == "$ARG_MATCH" ]]; then
            SELECTED_OBJECT_FILES+=($EXTRACTED_ARG_VALUE)

        elif [[ "-aobjs" == "$ARG_MATCH" || "--assembly-objects" == "$ARG_MATCH" ]]; then
			IFS=', ' read -r -a ASSEMBLY_OBJECT_FILES <<< $EXTRACTED_ARG_VALUE

        elif [[ "-ldf" == "$ARG_MATCH" || "--ld-file" == "$ARG_MATCH" ]]; then
            LINKER_FILE=$EXTRACTED_ARG_VALUE

        elif [[ "-o" == "$ARG_MATCH" || "--outname" == "$ARG_MATCH" ]]; then
            OUT_NAME=$EXTRACTED_ARG_VALUE

        else
            fail_with_message "Unknow option '$ARG_MATCH'"

        fi
    done

	OUTPUT_DIRECTORY=$OUTPUT_DIRECTORY/$ARCH
	mkdir -p $OUTPUT_DIRECTORY/objfiles
	mkdir -p $OUTPUT_DIRECTORY/bin
	process_arch_for_flags
	compile_source_files
	create_linker_file
	generate_bin_from_objects
	run_generated_bin
}

match_and_extract_argument() 
{
    ARG=$1
    ARG_MATCH=${ARG%=*}
    EXTRACTED_ARG_VALUE=${ARG#*=}
}

# Use the ARCH value to process the appropriate flags to send to the 
# source language compiler, linker and generated assembly
process_arch_for_flags()
{
	if [[ "(x86 i386)" =~ $ARCH ]]; then
		GCC_FLAGS=-m32
		LINKER_ARCH_FLAG=elf_i386
		NASM_FLAGS=elf32
		QEMU_COMMAND=qemu-system-i386

	elif [[ "(x64 amd64 x86_64 x86_x64)" =~ $ARCH ]]; then
		GCC_FLAGS=-m64
		LINKER_ARCH_FLAG=elf_x64
		NASM_FLAGS=elf64
		QEMU_COMMAND=qemu-system-x64

	fi
}

compile_source_files()
{
	echo "compiling the source files..."
	for SOURCE_FILE in ${SOURCE_FILES[@]}; do
		if [ ! -f $SOURCE_FILE ]; then
			fail_with_message "The source file '$SOURCE_FILE' does not exist"
		fi
		FILE_NAME=${SOURCE_FILE##*/}
		FILE_NAME=${FILE_NAME##*\\}
		FILE_NAME=${FILE_NAME%.*}
		FILE_OBJECT_NAME=$FILE_NAME.o
		FILE_EXT=${SOURCE_FILE##*.}
		echo "compiling $SOURCE_FILE..."
		if [[ "$FILE_EXT" == "asm" ]]; then
			if [[ "$LOUD" == "false" ]]; then
				nasm -f $NASM_FLAGS $SOURCE_FILE -o $OUTPUT_DIRECTORY/objfiles/$FILE_OBJECT_NAME > /dev/null
			else
				nasm -f $NASM_FLAGS $SOURCE_FILE -o $OUTPUT_DIRECTORY/objfiles/$FILE_OBJECT_NAME
			fi
		elif [[ "$FILE_EXT" == "c" ]]; then
			if [[ "$LOUD" == "false" ]]; then
				gcc $GCC_FLAGS -c $SOURCE_FILE -o $OUTPUT_DIRECTORY/objfiles/$FILE_OBJECT_NAME > /dev/null
			else
				gcc $GCC_FLAGS -c $SOURCE_FILE -o $OUTPUT_DIRECTORY/objfiles/$FILE_OBJECT_NAME
			fi
		elif [[ "$FILE_EXT" == "cpp" ]]; then
			fail_with_message "to compile C++ file $SOURCE_FILE to object file"
		elif [[ "$FILE_EXT" == "rust" ]]; then
			fail_with_message "to compile Rust file $SOURCE_FILE to object file"
		elif [[ "$FILE_EXT" == "go" ]]; then
			fail_with_message "to compile GO file $SOURCE_FILE to object file"
		else
			fail_with_message "Unknow source file '$SOURCE_FILE'"
		fi
		SELECTED_OBJECT_FILES+=($OUTPUT_DIRECTORY/objfiles/$FILE_OBJECT_NAME )
	done

	if [[ "$SOURCE_DIRECTORY" != "" ]]; then
		echo "to compile source dirs files and create their objects"
    fi
}

create_linker_file()
{
	if [[ "$LINKER_FILE" == "" ]]; then
		echo "generate linker file"
		LINKER_FILE=sample.ld

	else
		if [ ! -f $LINKER_FILE ]; then
			fail_with_message "The specified ld file '$LINKER_FILE' does not exist"
		fi

	fi
}

# This function generate the final .bin file which contain the operating system 
# that can be executed in qemu. 
# The compiled and/or specified object files are flattend into a string to send
# to the linker.
generate_bin_from_objects()
{
	FLATTENED_ASSEMBLY_OBJECT_FILES=
	FLATTENED_SELECTED_OBJECT_FILES=

	echo "flattening the generated or specified assembly object files..."
	for ASSEMBLY_OBJECT_FILE in ${ASSEMBLY_OBJECT_FILES[@]}; do
		FLATTENED_ASSEMBLY_OBJECT_FILES="$FLATTENED_ASSEMBLY_OBJECT_FILES $ASSEMBLY_OBJECT_FILE"
	done
	echo "flattening the selected and compiled source object files..."
	for SELECTED_OBJECT_FILE in ${SELECTED_OBJECT_FILES[@]}; do
		FLATTENED_SELECTED_OBJECT_FILES="$FLATTENED_SELECTED_OBJECT_FILES $SELECTED_OBJECT_FILE"
	done

	echo "generating the final binary $OUTPUT_DIRECTORY/bin/$OUT_NAME.bin..."
	ld -m $LINKER_ARCH_FLAG -T $LINKER_FILE -o $OUTPUT_DIRECTORY/bin/$OUT_NAME.bin $FLATTENED_ASSEMBLY_OBJECT_FILES $FLATTENED_SELECTED_OBJECT_FILES
}

run_generated_bin()
{
	if [[ "$RUN" == "true" ]]; then
		$QEMU_COMMAND -kernel $OUTPUT_DIRECTORY/bin/$OUT_NAME.bin
	fi
}

# print the help message that shows the options accepted by this script
print_help()
{
	echo "QOMB Build Script $VERSION"
	echo "The $LICENSE License Copyright (c) $YEAR $AUTHOR"
    echo "Usage: qomb-build [OPTIONS]"
    echo ""
    echo "[OPTIONS]    : The script options"
    echo ""
    echo "The OPTIONS include:"
    echo "--install-supplement  Install supplement packages like virtualbox, grub e.t.c"
    echo "--lang=[LANGUAGE]     The language to setup the environment for. See the LANGUAGE list below"
    echo "-h --help             Display this help message and exit"
    echo "-l --loud             Echo garbage + meaningful info into the terminal"
    echo ""
    echo "The LANGUAGE includes:"
    echo "c"
    echo "c++"
    echo "rust"
    echo "go"
    echo ""
    echo "Examples"
    echo "sudo bash ./setup.linux.sh --lang=c"
    echo "sudo bash ./setup.linux.sh --lang=c --lang=rust --lang=go"
    echo "sudo bash ./setup.linux.sh --lang=c --install-supplement"
    exit 0
}

# Print the first argument and exit with code 1
fail_with_message() {
    echo -e "Error: $1"
    exit 1
}

main $@
exit 0