#!/usr/bin/env bash

#
# Requires Gimp 2.9.5 or better (from git), 7z, and wine (1.9.14 or better) to be installed.
#

export WINEPREFIX=${HOME}/.wine.nik
export WINEARCH=win32

TMP=/tmp/nik_tmp
GOOGLE_PATH1="${WINEPREFIX}/drive_c/users/Public/Local Settings/Application Data/Google"
GOOGLE_PATH2="${WINEPREFIX}/drive_c/users/Public/Application Data/Google"
GIMP_PLUGINS=${HOME}/.config/GIMP/2.9/plugins
NIK_COLLECTION=${HOME}/Downloads/nikcollection-full-1.2.11.exe
PROGRAMFILES="Program Files"

if [ -d ${TMP} ]; then 
    rm -fr ${TMP}
fi

if [ -d ${WINEPREFIX} ]; then 
    rm -fr ${WINEPREFIX}
fi

echo "Creating wine setup in $WINEPREFIX and configuring"
rm -fr ${WINEPREFIX}
wineboot -u 

echo "Creating missing folders"
mkdir -p "$GOOGLE_PATH1"
chmod -R 777 "$GOOGLE_PATH1"

mkdir -p "$GOOGLE_PATH2"
chmod -R 777 "$GOOGLE_PATH2"


if [ ! -f ${NIK_COLLECTION} ]; then
    echo "Downloading Nik Collection"
    curl https://dl.google.com/edgedl/photos/nikcollection-full-1.2.11.exe > ${NIK_COLLECTION}
fi
rm -fr ${TMP}
mkdir ${TMP}
cd ${TMP}

echo "Extracting files and olders"
7z x -onik -y ${NIK_COLLECTION} > /dev/null

count_a=1
#I don't know how to guarantee this will work the same in every computer!
for i in nik/*; do
  new=$(printf "d_%02d" "$count_a") #02 pad to length of 2
  mv -- "$i" "nik/$new"
  let count_a=count_a+1
done

echo "Moving data"
# 1
cd $TMP/nik/d_05
cp -R Google "${WINEPREFIX}/drive_c/users/Public/Local Settings/Application Data/"
cp -R Google "${WINEPREFIX}/drive_c/users/Public/Application Data/"

# 2
cd $TMP/nik/d_04
NIK_FIL_ARRAY=("Analog Efex Pro 2" "Color Efex Pro 4" "HDR Efex Pro 2" "Silver Efex Pro 2")
NIK_RES_ARRAY=("common" "comparisonStatePresets" "cursors" "filters" "lng" "plugin_common" "resolutions" "styles" "textures" "presets")
for item in "${NIK_FIL_ARRAY[@]}"; do
    for jtem in "${NIK_RES_ARRAY[@]}"; do
        mkdir -p "${WINEPREFIX}/drive_c/users/Public/Application Data/Google/${item}/resource/"
        cp -fR "${jtem}" "${WINEPREFIX}/drive_c/users/Public/Application Data/Google/${item}/resource/"
    done
done

# 3
cd $TMP/nik/d_02
rm -rf "Analog Efex Pro 2/Analog Efex Pro 2 (64-Bit)"
rm -rf "Color Efex Pro 4/Color Efex Pro 4 (64-Bit)"
rm -rf "Dfine 2/Dfine 2 (64-Bit)"
rm -rf "HDR Efex Pro 2/HDR Efex Pro 2 (64-Bit)"
rm -rf "Sharpener Pro 3/Sharpener Pro 3 (64-Bit)"
rm -rf "Silver Efex Pro 2/Silver Efex Pro 2 (64-Bit)"
rm -rf "Viveza 2/Viveza 2 (64-Bit)"

NIK_PF="${WINEPREFIX}/drive_c/${PROGRAMFILES}/Google/Nik Collection"
mkdir -p "${NIK_PF}"
cp -R * "${NIK_PF}/"

#Let's create config files for each filter.
NIK_ARRAY=("Analog Efex Pro 2" "Dfine 2" "Color Efex Pro 4" "HDR Efex Pro 2" "Sharpener Pro 3" "Viveza 2" "Nik Collection" "Silver Efex Pro 2")
for item in "${NIK_ARRAY[@]}"; do
    NIK_F=$item
    NIK_F_NW="$(echo -e "${NIK_F}" | tr -d '[[:space:]]')"
    NIK_F_DIR="${WINEPREFIX}/drive_c/users/${USER}/Local Settings/Application Data/Google/${NIK_F}"
    mkdir -p "${NIK_F_DIR}"
    cat <<EOL >"${NIK_F_DIR}/${NIK_F_NW}.cfg"
<configuration>
    <group name="Language">
	<key name="Language" type="string" value="en"/>
    </group>
</configuration>
EOL
done

mkdir -p "${WINEPREFIX}/drive_c/users/Public/Application Data/Google/Nik Collection/"

cat <<EOF >"${WINEPREFIX}/drive_c/users/Public/Application Data/Google/Nik Collection/NikCollection.cfg"
<configuration>
    <group name="Update">
	<key name="Version" type="string" value="1.2.11"/>
    </group>
    <group name="Installer">
	<key name="LicensePath" type="string" value="C:\Program Files\Google\Nik Collection"/>
	<key name="Version" type="string" value="1.2.11"/>
	<key name="identifier" type="string" value="1415926535"/>
	<key name="edition" type="string" value="full"/>
    </group>
    <group name="Instrumentation">
	<key name="ShowInstrumentationScreen" type="bool" value="0"/>
	<key name="AllowSending" type="bool" value="0"/>
    </group>
</configuration>
EOF

echo "Install gimp nik plugin"
if [ ! -d "${HOME}/.config/GIMP/2.9/plug-ins" ]; then
    mkdir -p ${HOME}/.config/GIMP/2.9/plug-ins
fi
installation_dir="${HOME}/.config/GIMP/2.9/plug-ins/"
install -m 755 plug-ins/NIK-ColorEfexPro4.py $installation_dir
install -m 755 plug-ins/NIK-HDREfexPro2.py $installation_dir
install -m 755 plug-ins/NIK-SilverEfexPro2.py $installation_dir
install -m 755 plug-ins/NIK-AnalogEfexPro2.py $installation_dir
install -m 755 plug-ins/NIK-Dfine2.py $installation_dir
install -m 755 plug-ins/NIK-SharpenerPro3.py $installation_dir
install -m 755 plug-ins/NIK-Viveza2.py $installation_dir

echo "Install wine nik scripts"
installation_dir="/usr/local/bin"
sudo install -m 755 scripts/nik_analogefexpro2 $installation_dir
sudo install -m 755 scripts/nik_hdrefexpro2 $installation_dir
sudo install -m 755 scripts/nik_viveza2 $installation_dir
sudo install -m 755 scripts/nik_colorefexpro4 $installation_dir
sudo install -m 755 scripts/nik_sharpnerpro3 $installation_dir
sudo install -m 755 scripts/nik_dfine2 $installation_dir
sudo install -m 755 scripts/nik_silverefexpro2 $installation_dir

echo "Installing icons and desktop shortcuts"
installation_dir="${HOME}/Desktop"
install -m 755 desktop/analog_efex_pro_2.desktop $installation_dir
install -m 755 desktop/dfine_2.desktop $installation_dir
install -m 755 desktop/sharpner_pro_3.desktop $installation_dir
install -m 755 desktop/viveza_2.desktop $installation_dir
install -m 755 desktop/color_efex_pro_4.desktop $installation_dir
install -m 755 desktop/hdr_efex_pro_2.desktop $installation_dir
install -m 755 desktop/silver_efex_pro_3.desktop $installation_dir

if [ ! -d "${HOME}/.icons" ]; then
    mkdir -p ${HOME}/.icons
fi
install -m 644 desktop/analog_efex_pro_2.png ~/.icons/analog_efex_pro_2.png
install -m 644 desktop/dfine_2.png ~/.icons/dfine_2.png
install -m 644 desktop/sharpner_pro_3.png ~/.icons/sharpner_pro_3.png
install -m 644 desktop/viveza_2.png ~/.icons/viveza_2.png
install -m 644 desktop/color_efex_pro_4.png ~/.icons/color_efex_pro_4.png
install -m 644 desktop/hdr_efex_pro_2.png ~/.icons/hdr_efex_pro_2.png
install -m 644 desktop/silver_efex_pro_3.png ~/.icons/silver_efex_pro_3.png

if [ -d ${TMP} ]; then 
    rm -fr ${TMP}
fi