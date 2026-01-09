#!/usr/bin/env bash
set -e

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

    sudo pacman -S --noconfirm --needed base-devel git cmake extra-cmake-modules qt6-base qt6-svg qt6-tools qt6-declarative qt6-multimedia qt6-speech kcoreaddons kconfig kiconthemes ki18n kio solid kpmcore yaml-cpp boost boost-libs polkit-qt6 hwinfo libpwquality icu efibootmgr archiso
}

compile_calamares() {
    if [ -d "$CALAMARES_DIR/build" ] && [ -f "$CALAMARES_DIR/build/calamares" ]; then
        echo "Calamares detected in $CALAMARES_DIR/build, skipping compilation"
        return 0
    fi

    echo "Compilating calamares from source..."

    # clone repo if doesnt exist

    if [ ! -d "$CALAMARES_DIR" ]; then
        git clone "$CALAMARES_REPO" "$CALAMARES_DIR"
    fi

    cd $CALAMARES_DIR
    git pull # update repo if it exist

    # remove earlier build directories
    rm -rf "build"

    mkdir -p "build"
    cd "build"


    # configure and compile 
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make -j$COMPILATION_CORES
    sudo make install DESTDIR="../../../$AIROOTFS"

    #echo "Calamares compilation completed in $CALAMARES_BUILD_DIR"
    #cd ../../..
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

install_dependences_for_compilation
compile_calamares
build_iso

echo "Process sucessfully completed! enjoy your system"