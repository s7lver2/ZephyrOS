#!/usr/bin/env bash
set -euo pipefail

USB_BURN_CONFIRMATION=true
USB_DRIVE_DEFAULT='/dev/sdd'
TEMP_DIR='temp'
ARCHISO_TEMP_DIR="$TEMP_DIR/airootfs"
AIROOTFS="archiso/airootfs"
ISO_OUTPUT_DIR="out"
ARCHISO_PROFILE_DIR="archiso"
COMPILATION_CORES=8

## CALAMARES CONFIG

CALAMARES_REPO='https://codeberg.org/Calamares/calamares.git'
CALAMARES_DIR="$TEMP_DIR/calamares"
CALAMARES_BUILD_DIR="/build"
CALAMARES_LIB_DIRECTORY="$AIROOTFS/usr/local/lib/calamares-libs"
CALAMARES_BIN_DIRECTORY="$AIROOTFS/usr/local/bin/"
CALAMARES_MODULES_DIRECTORY="$AIROOTFS/usr/local/lib/calamares/modules"

install_dependences_for_compilation() {
    echo "Installing dependences for compilation"
    sudo pacman -S --noconfirm --needed base-devel git cmake extra-cmake-modules \
        qt6-base qt6-svg qt6-tools qt6-declarative qt6-multimedia qt6-speech \
        kcoreaddons kconfig kiconthemes ki18n kio solid kpmcore yaml-cpp boost \
        boost-libs polkit-qt6 hwinfo libpwquality icu efibootmgr archiso clang \
        llvm lld

}

compile_calamares() {
    if [ -d "$CALAMARES_DIR/build" ] && [ -f "$CALAMARES_DIR/build/calamares" ]; then
        echo "Calamares detected in $CALAMARES_DIR/build, skipping compilation"
        return 0
    fi

    echo "Compilating calamares from source..."

    # clone repo if doesnt exist

    if [ ! -d "$CALAMARES_DIR" ]; then
        git clone "$CALAMARES_REPO" "$CALAMARES_DIR" --depth=1
    fi

    cd $CALAMARES_DIR
    git pull # update repo if it exist

    # remove earlier build directories
    rm -rf "build"

    mkdir -p "build"
    cd "build"


    # configure and compile 
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DQT_DEFAULT_MAJOR_VERSION=6 -DSKIP_MODULES=" plasmanetinstall webview interactiveterminalweb"
    make -j$COMPILATION_CORES
    sudo make install DESTDIR="../../../$AIROOTFS"

    # copy custom scripts and modules
    cd ../../../
    sudo cp -r temp/calamares/build/src/qml archiso/airootfs/etc/calamares


    sudo mkdir -p archiso/airootfs/usr/lib/calamares/modules/copytoram_scan
    sudo cp -r scripts/copytoram_scan.sh archiso/airootfs/usr/lib/calamares/modules/copytoram_scan/main.sh
    sudo chmod +x archiso/airootfs/usr/lib/calamares/modules/copytoram_scan/main.sh
    sudo mkdir -p archiso/airootfs/usr/lib/calamares/modules/enable_services
    sudo cp -r scripts/enable_services.sh archiso/airootfs/usr/lib/calamares/modules/enable_services/main.sh
    sudo chmod +x archiso/airootfs/usr/lib/calamares/modules/enable_services/main.sh
    
    echo "Calamares compilation completed in $CALAMARES_DIR"
}

build_iso() {
    echo "Setting up Archiso Profile..."

    # Cleaning earlier directories and creating new ones
    sudo rm -rf $ARCHISO_TEMP_DIR
    sudo rm -rf $ISO_OUTPUT_DIR
    mkdir -p $ARCHISO_TEMP_DIR
    mkdir -p $ISO_OUTPUT_DIR

    # run mkarchiso with our config

    sudo mkarchiso -v -w "$ARCHISO_TEMP_DIR" -o "$ISO_OUTPUT_DIR" "$ARCHISO_PROFILE_DIR"

    echo "ISO file created in $ISO_OUTPUT_DIR/$(ls $ISO_OUTPUT_DIR/*.iso)"
}

burn_iso_to_usb() {
    local target_device="$1"

    # Comprobaciones de seguridad
    if [[ ! -b "$target_device" ]]; then
        echo "ERROR: $target_device not found or it is not a block drive"
        exit 1
    fi

    if ! lsblk -no TYPE "$target_device" | grep -q "^disk$"; then
        echo "ERROR: $target_device doesnt seems to be a hard drive"
        exit 1
    fi

    # Buscamos la iso más reciente (la última creada)
    local iso_file
    iso_file=$(ls -t "$ISO_OUTPUT_DIR"/*.iso | head -n1)

    if [[ ! -f "$iso_file" ]]; then
        echo "ERROR: ISO file not found in $ISO_OUTPUT_DIR"
        exit 1
    fi

    echo
    echo "THIS ISO FILE WILL BE BURNED:"
    echo " → $iso_file"
    echo
    echo "ON THE DEVICE:"
    echo " → $target_device  ($(lsblk -no SIZE "$target_device" | head -n1))"
    echo
    echo "THIS WILL EARSE ALL THE INFORMATION OF THE DEVICE"
    echo

    if $USB_BURN_CONFIRMATION; then
        read -p "Continue? [Y/n] " -n 1 -r confirm
        echo
        if [[ ! $confirm =~ ^[Yy]$ ]] && [[ -n $confirm ]]; then
            echo "ERROR: Cancell by user"
            exit 0
        fi
    else
        echo "No confirmation required, continue..."
    fi

    echo "Unmounting partitions"
    sudo umount "${target_device}"* 2>/dev/null || true

    echo
    echo "Writing ISO file (this can take some minutes)"
    sudo dd if="$iso_file" of="$target_device" bs=8M status=progress oflag=direct,sync

    sync

    echo
    echo "Writing sucessfully completed!"
}


install_dependences_for_compilation
compile_calamares
build_iso

if [[ $# -eq 1 ]]; then
    echo "Trying to burn in: $1"
    burn_iso_to_usb "$1"
else
    echo
    echo "Not parameter in execution assigned"
    echo "skipping usb writing"
    echo "ISO reeady in: $ISO_OUTPUT_DIR/"
    ec[sudo] password for s7lver: 
󰣇 ~/Projects/ZephyrOS   fix-bugs-1  !?⇡1 ❯                                                                                                              14:43 ho
fi

echo 'Process sucessfully completed! enjoy your system'