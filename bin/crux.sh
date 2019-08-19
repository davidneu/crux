#!/bin/sh
setup()
{
  export CRUX_USER=$USERNAME
  export CRUX_USER_HOME="/home/$CRUX_USER"
  export CRUX_HOME="$CRUX_USER_HOME/crux"
  export CRUX_BIN="$CRUX_HOME/bin"
  export CRUX_USER_HOME_BIN="$CRUX_USER_HOME/bin"
  mkdir -p $CRUX_USER_HOME_BIN
  export CRUX_ETC="$CRUX_HOME/etc"
  export CRUX_USER_HOME_SRC="$CRUX_USER_HOME/src"
  mkdir -p $CRUX_USER_HOME_SRC
}
package_management()
{
  sudo apt-get -y install aptitude
  sudo aptitude install -y software-properties-common
  sudo aptitude install -y apt-transport-https  
  sudo aptitude install -y ca-certificates     
}
ssh()
{
  sudo aptitude install -y openssh-server
  sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
  sudo sh -c "grep -q -F 'AllowUsers djneu' /etc/ssh/sshd_config || echo 'AllowUsers djneu' >> /etc/ssh/sshd_config"
  sudo /etc/init.d/ssh restart
}
firewall()
{
  sudo aptitude install -y ufw
  sudo ufw enable
  sudo ufw allow ssh/tcp
  # sudo ufw allow http
  # sudo ufw allow https
  sudo ufw enable
  sudo sh -c "grep -q -F 'djneu   ALL= NOPASSWD: /usr/sbin/ufw' /etc/sudoers || echo 'djneu   ALL= NOPASSWD: /usr/sbin/ufw' >> /etc/sudoers"
}
x_windows()
{
  sudo aptitude install -y xorg
  sudo aptitude install -y x11-utils
}
fonts()
{
  sudo aptitude install -y ttf-dejavu
  sudo aptitude install -y xfonts-terminus
  sudo aptitude install -y ttf-ubuntu-font-family
  sudo aptitude install -y fonts-liberation
  sudo aptitude install -y ttf-liberation
  sudo aptitude install -y fonts-inconsolata
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
  echo ttf-mscorefonts-installer msttcorefonts/present-mscorefonts-eula note | sudo debconf-set-selections
  sudo aptitude install -y ttf-mscorefonts-installer
}
window_manager()
{
  DWM_CONFIG_H=config-djneu.h

  sudo aptitude install -y build-essential
  sudo aptitude install -y libx11-dev
  sudo aptitude install -y libxext-dev
  sudo aptitude install -y libxinerama-dev
  sudo aptitude install -y libxft-dev
  sudo aptitude install -y libxrandr-dev

  # Note that we're running from here to the end of this function as $CRUX_USER
  mkdir -p $CRUX_USER_HOME_SRC; cd $CRUX_USER_HOME_SRC

  git clone http://git.suckless.org/dwm
  cd dwm
  wget http://dwm.suckless.org/patches/bottomstack/dwm-bottomstack-6.1.diff
  git apply dwm-bottomstack-6.1.diff
  cd ..
  git clone http://git.suckless.org/dmenu
  git clone http://git.suckless.org/slock
  git clone http://git.suckless.org/wmname

  cd "$CRUX_USER_HOME_SRC/dwm"; ln -sf "$CRUX_HOME/etc/dwm/$DWM_CONFIG_H" config.h; sudo make install clean
  cd "$CRUX_USER_HOME_SRC/dmenu"; sudo make install clean
  cd "$CRUX_USER_HOME_SRC/slock"; sudo make install clean
  cd "$CRUX_USER_HOME_SRC/wmname"; sudo make install clean

  # Uncomment the following line in ~/.xinitrc to automatically lock the screen after 15 minutes of inactivity.
  # xautolock -time 15 -locker slock
  sudo aptitude install -y xautolock
}
multi_monitor()
{
  sudo aptitude install -y arandr
  mkdir -p $CRUX_USER_HOME_SRC; cd $CRUX_USER_HOME_SRC
  git clone https://github.com/phillipberndt/autorandr.git
  cd autorandr
  make deb
  sudo dpkg -i *.deb
  sudo apt-get install -f
}
emacs()
{
    sudo rm -f /etc/apt/sources.list.d/emacs-snapshot.list
    sudo sh -c "echo 'deb http://ppa.launchpad.net/ubuntu-elisp/ppa/ubuntu $UBUNTU_RELEASE main' > /etc/apt/sources.list.d/emacs-snapshot.list"
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D62FCE72 
    sudo rm -f /etc/apt/preferences.d/emacs-snapshot.pref
    cd /etc/apt/preferences.d
    sudo ln -sf "$CRUX_ETC/apt/emacs-snapshot-$CRUX_OS_VERSION.pref" emacs-snapshot.pref
    sudo aptitude update
    sudo aptitude install -y emacs-snapshot
    sudo aptitude install -y dbus-x11
}
wireless()
{
    # Must install this manually because it asks a question about user groups:
    # aptitude install -y -R wicd
    sudo aptitude install -y wicd-curses
    sudo aptitude install -y wicd-cli
}
power_management()
{
    sudo aptitude install -y acpi
    sudo aptitude install -y pm-utils
    sudo aptitude install -y thermald
}
browsers()
{
    # Note: update-alternatives for x-www-browser is done in finishup()
    sudo aptitude install -y chromium-browser
    sudo aptitude install -y firefox
}
printing()
{
    sudo aptitude install -y cups
    sudo aptitude install -y cups-bsd
    sudo aptitude install -y cups-client
    sudo aptitude install -y hplip
}
scanner()
{
    sudo aptitude install -y xsane
    sudo adduser $CRUX_USER scanner
}
sound()
{
    sudo aptitude install -y alsa-base
    sudo aptitude install -y alsa-utils
    sudo aptitude install -y pulseaudio
    # play -n synth brownnoise  ## play brownnoise
    # sox -n /tmp/brown.mp3 synth 3 brownnoise  ## save 3 seconds of brown noise to a file
    # play /tmp/brown.mp3 ## play the file
    sudo aptitude install -y sox 
    sudo aptitude install -y libsox-fmt-all
    # sudo aptitude install -y vlc
    # sudo aptitude install -y mpg123
    sudo usermod -aG audio $CRUX_USER
    sudo usermod -aG video $CRUX_USER
}
version_control()
{
    sudo rm -f /etc/apt/sources.list.d/git-core.list
    sudo sh -c "echo 'deb http://ppa.launchpad.net/git-core/ppa/ubuntu $UBUNTU_RELEASE main' > /etc/apt/sources.list.d/git-core.list"
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E1DF1F24 
    sudo aptitude update
    sudo aptitude install -y git
    sudo aptitude install -y tig
    sudo aptitude install -y mercurial
    sudo aptitude install -y subversion
}
java()
{
    sudo add-apt-repository ppa:openjdk-r/ppa
    sudo aptitude update
    sudo aptitude install -y openjdk-11-jdk
}
clojure()
{
    cd $CRUX_USER_HOME_BIN
    wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
    chmod 755 ./lein
    ./lein
}
databases()
{
    sudo aptitude install -y sqlite3
    sudo aptitude install -y libsqlite3-dev
}
ledger()
{
    mkdir -p $CRUX_USER_HOME_SRC; cd $CRUX_USER_HOME_SRC
    git clone git://github.com/ledger/ledger.git
    cd ledger
    git checkout -b stable v3.1
    ./acprep dependencies
    ./acprep update
    sudo make install
}
r_project()
{
    sudo rm -f /etc/apt/sources.list.d/r-project.list
    sudo sh -c "echo 'deb http://cran.case.edu/R/CRAN/bin/linux/ubuntu $UBUNTU_RELEASE/' > /etc/apt/sources.list.d/r-project.list"
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9
    sudo aptitude install -y r-base
    sudo aptitude install -y r-base-dev
    sudo aptitude install -y r-recommended
    cd; ln -sf $CRUX_ETC/home/.Renviron
    cd; ln -sf $CRUX_ETC/home/.Rprofile
    mkdir -p $CRUX_USER_HOME/.Rlibs
    Rscript $CRUX_ETC/r-project/install-r-packages.R 
}
ruby()
{
  mkdir -p $CRUX_USER_HOME_SRC; cd $CRUX_USER_HOME_SRC
  git clone https://github.com/mernen/completion-ruby.git
}
office()
{
    sudo rm -f /etc/apt/sources.list.d/libreoffice.list
    sudo sh -c "echo 'deb http://ppa.launchpad.net/libreoffice/ppa/ubuntu $UBUNTU_RELEASE main' > /etc/apt/sources.list.d/libreoffice.list"
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 1378B444
    sudo aptitude update
    sudo aptitude install -y libreoffice
}
utilities()
{ 
    sudo aptitude install -y silversearcher-ag
    sudo aptitude install -y apt-file
    sudo aptitude install -y aspell
    sudo aptitude install -y autossh
    sudo aptitude install -y bash-completion
    sudo aptitude install -y conky-all
    # sudo modprobe pcspkr ## required for beep
    # sudo aptitude install -y beep
    sudo aptitude install -y curl
    sudo aptitude install -y debconf-utils
    sudo aptitude install -y dtach
    sudo aptitude install -y psmisc
    sudo aptitude install -y htop
    sudo aptitude install -y language-pack-en
    sudo update-locale LANG="en_US.UTF-8" LANGUAGE="en:en"
    sudo aptitude install -y lynx
    sudo aptitude install -y markdown
    sudo aptitude install -y pandoc
    sudo aptitude install -y traceroute
    sudo aptitude install -y rlwrap
    sudo aptitude install -y rsnapshot
    sudo aptitude install -y rsync
    sudo aptitude install -y rxvt-unicode-256color
    sudo update-alternatives --set x-terminal-emulator /usr/bin/urxvt
    sudo aptitude install -y texinfo
    sudo aptitude install -y tmux
    sudo aptitude install -y tofrodos
    sudo aptitude install -y tree
    sudo aptitude install -y unzip
    sudo aptitude install -y p7zip-full
    sudo aptitude install -y wamerican-huge
    sudo aptitude install -y whois
}
client_utilities()
{ 
    sudo aptitude install -y gxmessage
    sudo aptitude install -y scrot
    sudo aptitude install -y xfig
    sudo aptitude install -y xournal # can use to add an image to a pdf
}
pdf_postscript()
{
  sudo aptitude install -y gv
  sudo aptitude install -y xpdf
  sudo aptitude install -y zathura
}
latex()
{
  sudo aptitude install -y foiltex
  sudo aptitude install -y texlive-latex-base
  sudo aptitude install -y texlive-latex-extra
  sudo aptitude install -y texlive-latex-extra-doc
  sudo aptitude install -y texlive-latex-recommended
  sudo aptitude install -y texlive-fonts-recommended
}
finishup()
{
    sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /home/djneu/bin/cbtmp.sh 50
    sudo update-alternatives --set  x-www-browser /home/djneu/bin/cbtmp.sh
    sudo aptitude clean
    sudo aptitude autoclean
}
laptop()
{
    setup
    package_management
    ssh
    firewall
    x_windows
    fonts
    window_manager
    multi_monitor()
    emacs
    wireless
    power_management
    browsers
    printing
    scanner
    sound
    version_control
    java
    clojure
    databases
    ledger
    r_project
    ruby
    office
    utilities
    client_utilities
    pdf_postscript
    latex
    finishup
}
desktop()
{
    setup
    package_management
    ssh
    firewall
    x_windows
    fonts
    window_manager
    multi_monitor()
    emacs
    wireless
    # power_management
    browsers
    printing
    scanner
    sound
    version_control
    java
    clojure
    databases
    ledger
    r_project
    ruby
    office
    utilities
    client_utilities
    pdf_postscript
    latex
    finishup
}
server()
{
    setup
    package_management
    ssh
    firewall
    # x_windows
    # fonts
    # window_manager
    # multi_monitor()
    emacs
    # wireless
    # power_management
    # browsers
    # printing
    # scanner
    # sound
    version_control
    java
    clojure
    databases
    # ledger
    r_project
    ruby
    # office
    utilities
    client_utilities
    pdf_postscript
    latex
    finishup
}
set -o errexit; set -o nounset

# usage='Usage: sudo -u djneu -H sh -c "./crux.sh TARGET COMMAND", where TARGET is in {laptop, desktop, or server} and COMMAND is a function in crux.sh.\n'
usage='Usage: sudo -u djneu -H sh -c "./crux.sh COMMAND", where COMMAND is a function in crux.sh.\n'
echo $usage

# ensure script is run as root/sudo
# if [ $(id -u) -ne 0 ]; then
#     echo "ERROR: Use sudo to run this script"
#     exit 1
# fi

if [ -f ~/.cruxrc ]; then
    . ~/.cruxrc
else
    echo "File ~/.cruxrc not found.\n"
    exit 1
fi

# check the argument count
if [ $# -ne 1 ]; then
    echo "ERROR: crux.sh takes one argument."
    echo $usage
    exit 1
fi

# CRUX_TARGET=$1
command=$1

UBUNTU_RELEASE=bionic

if [ "$CRUX_TARGET" != "laptop" ] && [ "$CRUX_TARGET" != "desktop" ] && [ "$CRUX_TARGET" != "server" ]
then
    echo "ERROR: Illegal target = $CRUX_TARGET."
    exit 1
fi

setup
${command}
if [ $? -eq 0 ]; then
    echo "${command} ran successfully\n"
    return 0
else
    echo "ERROR: ${command} ran failed\n"
    exit 1
fi
