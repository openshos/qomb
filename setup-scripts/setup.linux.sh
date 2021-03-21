#!/bin/bash

# 
# 
# 
# 
# License: MIT
# Author: Adewale Azeez <azeezadewale98@gmail.com>

# with execution scripts check for qemu name e.g. qemu, qemu-system-i386 e.t.c.

ARG=
YEAR=2021
ARG_MATCH=
LOUD=false
LICENSE=MIT
VERSION=v1.0
AUTHOR="Adewale Azeez"
EXTRACTED_ARG_VALUE=
INSTALL_SUPPLEMENTARY=false
SELECTED_PROGRAMMING_LANGUAGES=()
SUPPORTED_PROGRAMMING_LANGUAGES=(
    c
    c++
    rust
    go
)

echo "QOMB Setup Script $VERSION"
echo "The $LICENSE License Copyright (c) $YEAR $AUTHOR"

main()
{
    for ARG in "$@"
    do
        match_and_extract_argument $ARG
        if [[ "-h" == "$ARG_MATCH" || "--help" == "$ARG_MATCH" ]]; then
            print_help

        elif [[ "-l" == "$ARG_MATCH" || "--loud" == "$ARG_MATCH" ]]; then
            LOUD=true

        elif [[ "--install-supplement" == "$ARG_MATCH" ]]; then
            INSTALL_SUPPLEMENTARY=true

        elif [[ "--lang" == "$ARG_MATCH" ]]; then
            if [[ ! " ${SUPPORTED_PROGRAMMING_LANGUAGES[@]} " =~ " ${EXTRACTED_ARG_VALUE} " ]]; then
                fail_with_message "Unsupported programming language: '$EXTRACTED_ARG_VALUE'"
            fi
            SELECTED_PROGRAMMING_LANGUAGES+=($EXTRACTED_ARG_VALUE)

        else
            fail_with_message "Unknow option '$ARG_MATCH'"

        fi
    done
    update_apt
    install_essential_packages
    for PROGRAMMING_LANGUAGE in ${SELECTED_PROGRAMMING_LANGUAGES[@]}; do
        if [[ "$PROGRAMMING_LANGUAGE" == "c" || "$PROGRAMMING_LANGUAGE" == "c++" ]]; then
            install_c_cpp_packages
        elif [[ "$PROGRAMMING_LANGUAGE" == "rust" ]]; then
            install_rust_packages
        elif [[ "$PROGRAMMING_LANGUAGE" == "go" ]]; then
            install_go_packages
        fi
    done
    if [[ "$INSTALL_SUPPLEMENTARY" == "true" ]]; then
        install_supplement_packages
    fi
}

match_and_extract_argument() {
    ARG=$1
    ARG_MATCH=${ARG%=*}
    EXTRACTED_ARG_VALUE=${ARG#*=}
}

update_apt()
{
    echo -n "Updating apt-get repositories..."
    if [[ "$LOUD" == "false" ]]; then
        sudo apt-get update > /dev/null
        echo "done"
    else
        sudo apt-get update
    fi
}

# This function installs the essential packages needed to build the 
# compile the assembly sources and link the object file to create the 
# operating system, also install qemu which is usefull for booting into 
# the created operating system.
install_essential_packages()
{
    echo "installing the essential packages"
    if [[ "$LOUD" == "false" ]]; then
        sudo apt-get install -y nasm > /dev/null
        sudo apt-get install -y qemu qemu-system > /dev/null
        echo "nasm, qemu, qemu-system...done"
    else
        sudo apt-get install -y nasm
        sudo apt-get install -y qemu qemu-system
    fi
}

# Install the C and C++ packages neccasary to compile the C and C++ 
# source code into object file to be linked with the kernel.asm 
# object file. Add the option --lang=c or --lang=cpp to install 
# these packages
install_c_cpp_packages()
{
    echo "installing the c and c++ packages"
    if [[ "$LOUD" == "false" ]]; then
        sudo apt-get install -y gcc > /dev/null
        echo "gcc...done"
    else
        sudo apt-get install -y gcc
    fi
}

# Install the Rust packages neccasary to compile the Rust
# source code into object file to be linked with the kernel.asm 
# object file. Add the option --lang=rust to install 
# these packages
install_rust_packages()
{
    echo "installing the rust packages"
}

# Install the GO packages neccasary to compile the GO
# source code into object file to be linked with the kernel.asm 
# object file. Add the option --lang=go to install 
# these packages
install_rust_packages()
{
    echo "installing the go packages"
}

# Install supplement packages that are not crucial to the environment but 
# are useful for executing extra step. E.g. the grub package to convert 
# the .bin file into .iso and virtualbox package for you know the fine  
# click click.. virtualization.
#
# It important to install the supplement if you intend to convert your 
# binary file into ISO. add the option `--install-supplement` to the script
# to install the suplementary packages.
install_supplement_packages()
{
    echo "installing the supplementary packages"
    if [[ "$LOUD" == "false" ]]; then
        sudo apt-get install -y virtualbox > /dev/null
        sudo apt-get install -y grub > /dev/null
        echo "virtualbox, grub...done"
    else
        sudo apt-get install -y virtualbox
        sudo apt-get install -y grub
    fi
}

# print the help message that shows the options accepted by this script
print_help()
{
    echo "Usage: sudo bash ./setup.linux.sh [OPTIONS]"
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