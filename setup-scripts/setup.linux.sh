
main()
{
    install_packages
}

install_packages()
{
    echo installing the packages
    sudo apt-get install -y gcc
    sudo apt-get install -y grub
    sudo apt-get install -y nasm
    sudo apt-get install -y virtualbox
    sudo apt-get install -y qemu qemu-system
    # with execution scripts check for qemu name e.g. qemu, qemu-system-i386 e.t.c.
}

main $*