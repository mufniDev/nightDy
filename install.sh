#!/bin/bash

# Verifikasi apakah user yang menjalankan script adalah root user atau bukan
if (( $EUID != 0 )); then
    echo "Tolong Jalankan sebagai root"
    exit
fi

clear

# Fungsi untuk membuat backup dari directory pterodactyl
installTheme(){
    cd /var/www/
    tar -cvf MinecraftPurpleThemebackup.tar.gz pterodactyl
    echo "Memasang tema...tunggu ya"
    cd /var/www/pterodactyl
    rm -r MinecraftPurpleTheme
    git clone https://github.com/Angelillo15/MinecraftPurpleTheme.git
    cd MinecraftPurpleTheme
    rm /var/www/pterodactyl/resources/scripts/MinecraftPurpleTheme.css
    rm /var/www/pterodactyl/resources/scripts/index.tsx
    mv index.tsx /var/www/pterodactyl/resources/scripts/index.tsx
    mv MinecraftPurpleTheme.css /var/www/pterodactyl/resources/scripts/MinecraftPurpleTheme.css
    cd /var/www/pterodactyl

    # Install dependencies
    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    apt update
    apt install -y nodejs

    npm i -g yarn
    yarn

    cd /var/www/pterodactyl
    yarn build:production
    sudo php artisan optimize:clear
}

# Fungsi untuk menanyakan user apakah yakin ingin menginstall theme atau tidak
installThemeQuestion(){
    while true; do
        read -p "Kamu beneran mau memasang tema ini [y/n]? " yatidak
        case $yatidak in
            [Yy]* ) installTheme; break;;
            [Nn]* ) exit;;
            * ) echo "Tolong jawab y(ya) atau n(tidak).";;
        esac
    done
}

# Fungsi untuk memperbaiki panel jika terjadi error pada saat menginstall theme
repair(){
    bash <(curl https://raw.githubusercontent.com/Angelillo15/MinecraftPurpleTheme/main/repair.sh)
}

# Fungsi untuk mengembalikan backup dari directory pterodactyl
restoreBackUp(){
    echo "Memulihkan cadangan..."
    cd /var/www/
    tar -xvf nightDy.tar.gz
    rm nightDy.tar.gz

    cd /var/www/pterodactyl
    yarn build:production
    sudo php artisan optimize:clear
}

# Menampilkan menu pilihan
echo "Copyright © nightDy | by mufni.Dev"
echo "dilarang mengedit, mendistribusikan, script ini tanpa seijin creator"
echo ""
echo "Discord: gak ada"
echo "Website: https://mufni.rf.gd"
echo ""
echo "[❶] Pasang tema"
echo "[❷] Pulihkan backup"
echo "[❸] perbaiki panel (gunakan jika kamu mengalami error saat menginstall tema)"
echo "[❹] Keluar"

# Meminta user untuk memilih pilihan
read -p "Mohon masukkan angka: " choice

# Menjalankan pilihan yang dipilih oleh user
if [ $choice == "1" ]; then
    installThemeQuestion
fi

if [ $choice == "2" ]; then
    restoreBackUp
fi

if [ $choice == "3" ]; then
    repair
fi

if [ $choice == "4" ]; then
    exit
fi
