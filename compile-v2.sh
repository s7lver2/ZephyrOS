#!/usr/bin/env bash
set -e

TEMP_DIR='temp'
ARCHISO_TEMP_DIR="$TEMP_DIR/airootfs"
AIROOTFS="archiso/airootfs"
ISO_OUTPUT_DIR="out"
ARCHISO_PROFILE_DIR="archiso"
COMPILATION_CORES=$(nproc)

## CALAMARES CONFIG

CALAMARES_REPO='https://codeberg.org/Calamares/calamares.git'
CALAMARES_DIR="$TEMP_DIR/calamares"
CALAMARES_BUILD_DIR="$CALAMARES_DIR/build"
CALAMARES_LIB_DIRECTORY="$AIROOTFS/usr/local/lib/calamares-libs"
CALAMARES_BIN_DIRECTORY="$AIROOTFS/usr/local/bin/"
CALAMARES_MODULES_DIRECTORY="$AIROOTFS/usr/local/lib/calamares/modules"

compile_calamares() {
    if [ -d "$CALAMARES_BUILD_DIR" ] && [ -f "$CALAMARES_BUILD_DIR/calamares" ]; then
        echo "Calamares detected in $CALAMARES_BUILD_DIR, skipping compilation"
        return 0
    fi

    echo "Compilating calamares from source..."

    # clone repo if doesnt exist

    if [ ! -d "$CALAMARES_DIR" ]; then
        git clone "$CALAMARES_REPO" "$CALAMARES_DIR"
    fi

    cd $CALAMARES_DIR
    git pull # update repo if it exist

    mkdir -p "$CALAMARES_BUILD_DIR"
    cd "$CALAMARES_BUILD_DIR"

    # configure and compile 
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make -j$COMPILATION_CORES

    echo "Calamares compilation completed in $CALAMARES_BUILD_DIR"
    cd ../../..
}

install_calamares_to_airootfs() {
    echo "Moving Calamares files into $AIROOTFS..."

    cd "$CALAMARES_BUILD_DIR"
    sudo make install DESTDIR="$PWD../../../$AIROOTFS"

    cd ../../..
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

# compile_calamares
# install_calamares_to_airootfs
build_iso

echo "Process sucessfully completed! enjoy your system"