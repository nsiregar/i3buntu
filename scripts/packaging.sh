#!/bin/bash

# This script serves as the main installation script
# for all neccessary packages. Via APT, core utils,
# browser, graphical environment and much more is
# being installed.
#
# current version - 0.8.0

sudo echo -e "\nPackaging stage has begun!"

# ? Preconfig

## directories and files - absolute & normalized
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BACK="$(readlink -m "${DIR}/../backups/packaging/$(date '+%d-%m-%Y--%H-%M-%S')")"
LOG="${BACK}/packaging_log"

IF=( --yes --allow-unauthenticated --allow-downgrades --allow-remove-essential --allow-change-held-packages )
AI=( sudo apt-get install ${IF[@]} )
SI=( sudo snap install )

## init of backup-directory
if [[ ! -d "$BACK" ]]; then
    mkdir -p "$BACK"
fi

## init of logfile
if [[ ! -f "$LOG" ]]; then
    if [[ ! -w "$LOG" ]]; then
        &>/dev/null sudo rm $LOG
    fi
    touch "$LOG"
fi
WTL=( tee -a "${LOG}" )

# ? Preconfig finished
# ? User-choices begin

echo -e "\nPlease make your choices:"

read -p "Would you like to execute ubuntu-driver autoinstall? [Y/n]" -r R1
read -p "Would you like to install OpenJDK? [Y/n]" -r R2
read -p "Would you like to install Cryptomator? [Y/n]" -r R3
read -p "Would you like to install Balena Etcher? [Y/n]" -r R4
read -p "Would you like to install TeX? [Y/n]" -r R5
read -p "Would you like to install ownCloud? [Y/n]" -r R6
read -p "Would you like to install Build-Essentials? [Y/n]" -r R7
read -p "Would you like to get RUST? [Y/n]" -r R8
read -p "Would you like to install VS Code? [Y/n]" -r R9

RC1="no"
if [[ $R9 =~ ^(yes|Yes|y|Y| ) ]] || [[ -z $R9 ]]; then
    read -p "Would you like to install recommended VS Code extensions? [Y/n]" -r RC1
fi

read -p "Would you like to install the JetBrains IDE suite? [Y/n]" -r R10

# ? User choices end
# ? Init of package selection

CRITICAL=( ubuntu-drivers-common htop intel-microcode curl wget libaio1 )

NETWORKING=( net-tools network-manager* firefox )

PACKAGING=( software-properties-common snapd )

DISPLAY=( xorg xserver-xorg lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings i3 )

GRAPHICS=( compton xbacklight feh rofi arandr mesa-utils mesa-utils-extra i3lock )

AUDIO=( pulseaudio gstreamer1.0-pulseaudio pulseaudio-module-raop pulseaudio-module-bluetooth )

FILES=( nemo file-roller p7zip-full filezilla )

SHELL=( rxvt-unicode vim xsel xclip neofetch )

AUTH=( policykit-desktop-privileges policykit-1-gnome gnome-keyring* libgnome-keyring0 )

THEMING=( gtk2-engines-pixbuf gtk2-engines-murrine lxappearance compton-conf)

FONTS=( fonts-roboto fonts-open-sans fonts-lyx )

MISCELLANEOUS=( gparted fontconfig evince gedit nomacs python3-distutils scrot thunderbird )

PONE=( "${CRITICAL[@]}" "${NETWORKING[@]}" "${PACKAGING[@]}" )
PTWO=( "${DISPLAY[@]}" "${GRAPHICS[@]}" "${AUDIO[@]}" "${FILES[@]}" "${FONTS[@]}" )
PTHREE=( "${SHELL[@]}" "${AUTH[@]}" "${THEMING[@]}" "${MISCELLANEOUS[@]}" )

PACKAGES=( "${PONE[@]}" "${PTWO[@]}" "${PTHREE[@]}" )

# ? End of init of package selection
# ? Actual script begins

echo -e "\nStarted at: $(date)\n\nInitial update" | ${WTL[@]}

>/dev/null 2>>"${LOG}" sudo apt-get -y update
>/dev/null 2>>"${LOG}" sudo apt-get -y upgrade

echo -e "Installing packages:\n" | ${WTL[@]}

printf "%-35s | %-15s | %-15s" "PACKAGE" "STATUS" "EXIT CODE"
printf "\n"
for PACKAGE in "${PACKAGES[@]}"; do
    >/dev/null 2>>"${LOG}" ${AI[@]} ${PACKAGE}

    EC=$?
    if (( $EC != 0 )); then
        printf "%-35s | %-15s | %-15s" "${PACKAGE}" "Not Installed" "${EC}"
    else
        printf "%-35s | %-15s | %-15s" "${PACKAGE}" "Installed" "${EC}"
        printf "\n"
    fi

    &>>"${LOG}" echo -e "${PACKAGE}\n\t -> EXIT CODE: ${EC}"
done

>/dev/null 2>>"${LOG}" sudo apt-get remove ${IF[@]} suckless-tools
EC=$?
printf "%-35s | %-15s | %-15s" "dmenu" "Removed" "${EC}"
printf "\n"
&>>"${LOG}" echo -e "dmenu\n\t -> EXIT CODE: ${EC}"
unset EC

echo -e "\nIcon-Theme is being processed..." | ${WTL[@]}
(
    cd "${DIR}/../resources/icon_theme"
    &>>"${LOG}" find . -maxdepth 1 -iregex "[a-z0-9_\.\/\ ]*\w\.sh" -type f -exec chmod +x {} \;
    &>>"${LOG}" ./icon_theme.sh "$LOG"
)

if ! dpkg -s adapta-gtk-theme-colorpack >/dev/null 2>&1; then
    echo -e "Color-Pack is being processed...\n" | ${WTL[@]}
    >/dev/null 2>>"${LOG}" sudo dpkg -i "${DIR}/../resources/design/AdaptaGTK_colorpack.deb"
fi

echo -e 'Post-Update via APT' | ${WTL[@]}
>/dev/null 2>>"${LOG}" sudo apt-get -y update
>/dev/null 2>>"${LOG}" sudo apt-get -y upgrade

echo -e '\nFinished with the actual script.' | ${WTL[@]}

# ? Actual script finished
# ? Extra script begins

echo -e 'Processing user-choices:\n' | ${WTL[@]}

## Graphics driver
if [[ $R1 =~ ^(yes|Yes|y|Y| ) ]] || [[ -z $R1 ]]; then
    echo -e 'Enabling ubuntu-drivers autoinstall...' | ${WTL[@]}
    &>>"${LOG}" sudo ubuntu-drivers autoinstall
fi

if [[ $R2 =~ ^(yes|Yes|y|Y| ) ]] || [[ -z $R2 ]]; then
    if [[ $(lsb_release -r) == *"18.04"* ]]; then
        echo -e 'Installing OpenJDK 11...' | ${WTL[@]}
        >/dev/null 2>>"${LOG}" ${AI[@]} openjdk-11-jdk openjdk-11-demo openjdk-11-doc openjdk-11-jre-headless openjdk-11-source
    else
        echo -e 'Installing OpenJDK 12...' | ${WTL[@]}
        >/dev/null 2>>"${LOG}" ${AI[@]} openjdk-12-jdk openjdk-12-demo openjdk-12-doc openjdk-12-jre-headless openjdk-12-source
    fi
fi

if [[ $R3 =~ ^(yes|Yes|y|Y| ) ]] || [[ -z $R3 ]]; then
    echo -e 'Installing Cryptomator...' | ${WTL[@]}
    &>>"${LOG}" sudo add-apt-repository -y ppa:sebastian-stenzel/cryptomator
    >/dev/null 2>>"${LOG}" ${AI[@]} cryptomator
fi

if [[ $R4 =~ ^(yes|Yes|y|Y| ) ]] || [[ -z $R4 ]]; then
    echo -e 'Installing Etcher...' | ${WTL[@]}
    if [[ ! -e /etc/apt/sources.list.d/balena-etcher.list ]]; then
        sudo touch /etc/apt/sources.list.d/balena-etcher.list
    fi

    echo "deb https://deb.etcher.io stable etcher" | >/dev/null sudo tee /etc/apt/sources.list.d/balena-etcher.list
    &>>"${LOG}" sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
    >/dev/null 2>>"${LOG}" ${AI[@]} balena-etcher-electron
fi

if [[ $R5 =~ ^(yes|Yes|y|Y| ) ]] || [[ -z $R5 ]]; then
    echo -e 'Installing LaTeX...' | ${WTL[@]}
    >/dev/null 2>>"${LOG}" ${AI[@]} texlive-full
fi

if [[ $R6 =~ ^(yes|Yes|y|Y| ) ]] || [[ -z $R6 ]]; then
    echo -e 'Installing OwnCloud...' | ${WTL[@]}
    >/dev/null 2>>"${LOG}" ${AI[@]} owncloud-client
fi

if [[ $R7 =~ ^(yes|Yes|y|Y| ) ]] || [[ -z $R7 ]]; then
    echo -e 'Installing build-essential & cmake...' | ${WTL[@]}
    >/dev/null 2>>"${LOG}" ${AI[@]} build-essential cmake
fi

if [[ $R8 =~ ^(yes|Yes|y|Y| ) ]] || [[ -z $R8 ]]; then
    echo -e '\n\nInstalling RUST...' | ${WTL[@]}
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile complete
    source "${HOME}/.cargo/env"
    
    mkdir -p "${HOME}/.local/share/bash-completion/completions"
    touch "${HOME}/.local/share/bash-completion/completions/rustup"
    rustup completions bash > "${HOME}/.local/share/bash-completion/completions/rustup"

    COMPONENTS=( rust-docs rust-analysis rust-src rustfmt rls clippy )
    for COMPONENT in ${COMPONENTS[@]}; do
        &>>"${LOG}" rustup component add $COMPONENT
    done

    if [[ ! -z $(which code) ]]; then
        code --install-extension rust-lang.rust
    fi

    &>>"${LOG}" rustup update
fi

if [[ $R9 =~ ^(yes|Yes|y|Y| ) ]] || [[ -z $R9 ]]; then
    echo -e '\nInstalling VS Code...' | ${WTL[@]}
    >/dev/null 2>>"${LOG}" ${SI[@]} code --classic
fi

if [[ $RC1 =~ ^(yes|Yes|y|Y| ) ]] || [[ -z $RC1 ]]; then
    echo -e 'Installing VS Code Extensions...' | ${WTL[@]}
    sudo chmod +x "${DIR}/../resources/sys/vscode/extensions.sh"
    &>>"${LOG}" "${DIR}/../resources/sys/vscode/extensions.sh"
fi

if [[ $R10 =~ ^(yes|Yes|y|Y| ) ]] || [[ -z $R10 ]]; then
    echo -e "Installing JetBrains' IDE suite..." | ${WTL[@]}
    >/dev/null 2>>"${LOG}" ${SI[@]} intellij-idea-ultimate --classic
    >/dev/null 2>>"${LOG}" ${SI[@]} kotlin --classic
    >/dev/null 2>>"${LOG}" ${SI[@]} kotlin-native --classic
    >/dev/null 2>>"${LOG}" ${SI[@]} pycharm-professional --classic
    >/dev/null 2>>"${LOG}" ${SI[@]} clion --classic
fi

echo -e 'Finished with processing user-choices. One last update...' | ${WTL[@]}

>/dev/null 2>>"${LOG}" sudo apt-get -y update
>/dev/null 2>>"${LOG}" sudo apt-get -y upgrade
>/dev/null 2>>"${LOG}" sudo snap refresh

# ? Extra script finished
# ? Postconfiguration and restart

echo -e "\nThe script has finished!\nEnded at: $(date)\n" | ${WTL[@]}

for I in {7..1..-1}; do
    echo -ne "\rRestart in $I seconds."
    sleep 1
done
sudo shutdown -r now
