#!/bin/bash

function Entrance {
    echo -e " [Info] One-Click Installation of netboot.xyz"
    InstallPackages
}

function InstallPackages {
    echo -e " [Info] Detecting OS and installing required packages..."
    # Detect the OS
    if [[ $(grep -Ei 'debian|buntu' /etc/*release) ]]; then
        # Install required packages on Debian/Ubuntu
        apt-get update
        apt-get -y install curl grub-common

    elif [[ $(grep -Ei 'centos|redhat' /etc/*release) ]]; then
        # Install required packages on CentOS/RHEL
        yum -y install curl grub2-tools

    else
        echo -e " [Error] Unsupported OS. Aborting."
        exit 1
    fi
    DownloadNetbootKernel
}

function DownloadNetbootKernel {
    echo -e " [Info] Downloading the netboot.xyz kernel..."
    # Download the netboot.xyz kernel
    NETBOOT_KERNEL="/boot/netboot.xyz.lkrn"
    if [ ! -f "$NETBOOT_KERNEL" ]; then
        curl -o "$NETBOOT_KERNEL" "https://boot.netboot.xyz/ipxe/netboot.xyz.lkrn"
    fi
    CreateGrubMenuEntry
}

function CreateGrubMenuEntry {
    echo -e " [Info] Creating a GRUB menu entry for netboot.xyz..."
    # Create a GRUB menu entry for netboot.xyz
    GRUB_CONFIG_DIR="/etc/grub.d"
    GRUB_DEFAULT_CONFIG="/etc/default/grub"
    
    cat > "${GRUB_CONFIG_DIR}/00_custom" <<-EOF
#!/bin/sh
exec tail -n +3 \$0
menuentry 'netboot.xyz' {
    search --no-floppy --set=root --file $NETBOOT_KERNEL
    linux16 $NETBOOT_KERNEL
}
EOF

    SetGrubMenuTimeout
}

function SetGrubMenuTimeout {
    echo -e " [Info] Setting GRUB menu timeout and updating GRUB configuration..."
    # Make the 00_custom file executable
    chmod +x "${GRUB_CONFIG_DIR}/00_custom"

    # Set the GRUB menu timeout to 60 seconds
    sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=60/' $GRUB_DEFAULT_CONFIG

    # Regenerate GRUB config
    if [[ $(grep -Ei 'debian|ubuntu' /etc/*release) ]]; then
        update-grub

    elif [[ $(grep -Ei 'centos|redhat' /etc/*release) ]]; then
        grub2-mkconfig -o /boot/grub2/grub.cfg
    fi
    echo -e " [Info] Enjoy!"
}

Entrance
