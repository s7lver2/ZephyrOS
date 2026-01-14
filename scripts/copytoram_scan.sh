#!/bin/bash

# Ruta esperada por Calamares (bootmnt)
BOOTMNT_SFS="/run/archiso/bootmnt/arch/x86_64/airootfs.sfs"
BOOTMNT_KERNEL_DIR="/run/archiso/bootmnt/arch/boot/x86_64/"
BOOTMNT_KERNEL="/run/archiso/bootmnt/arch/boot/x86_64/vmlinuz-linux"

# Ruta real con copytoram
COPYTORAM_SFS="/run/archiso/copytoram/airootfs.sfs"
COPYTORAM_KERNEL_DIR="/run/archiso/copytoram/arch/boot/x86_64/"
COPYTORAM_KERNEL="/run/archiso/copytoram/arch/boot/x86_64/vmlinuz-linux"

# Si copytoram está activo, crea los symlinks
if [ -f "$COPYTORAM_SFS" ]; then
    sudo mkdir -p "$(dirname "$BOOTMNT_SFS")"
    sudo ln -sf "$COPYTORAM_SFS" "$BOOTMNT_SFS"

    # Para el kernel y otros en boot/, si faltan
    if [ -d "$COPYTORAM_KERNEL_DIR" ]; then
        sudo mkdir -p "$BOOTMNT_KERNEL_DIR"
        sudo ln -sf "$COPYTORAM_KERNEL" "$BOOTMNT_KERNEL"
        # Opcional: symlink todo el directorio boot/ si hay más archivos
        # ln -sf "$COPYTORAM_KERNEL_DIR"/* "$BOOTMNT_KERNEL_DIR"
    fi
    echo "Copytoram detectado: symlinks creados para Calamares."
else
    echo "Copytoram no detectado: no se necesita fix."
fi