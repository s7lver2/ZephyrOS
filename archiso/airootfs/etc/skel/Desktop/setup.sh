## Setup.sh

install_dependences() {
    # Ensure Dependences
    sudo pacman -Sy --noconfirm git base-devel go make

    # Install Yay Helper
    cd 
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -sicr
    cd ..
    rm -rf yay

    # Testing yay
    yay --version
}

echo "Este Script va a descargar contenidos en tu sistema LIVE, no en tu maquina, proceder? [Y/n]"

read -r anwser

if [[ "$anwser" == "y" ]]; then
    echo "instalando dependencias"
    install_dependences
else
    echo "error"
fi

