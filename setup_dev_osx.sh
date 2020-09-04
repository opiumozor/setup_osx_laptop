#!/bin/bash

set +e

##
## Apps & packages to install
##
apps_to_install=(
  appcleaner
  atom
  docker
  flux
  google-chrome
  iterm2
  slack
  spotify
  spectacle
  ## The following is for Primer
  postman
  zoomus
)

packages_to_install=(
  wget
  htop
  diff-so-fancy
  tree
  ansible
  kubectl
  ## The following is for Primer
  yarn
)

atom_packages_to_install=(
  atomic-emacs
  file-icons
  linter
  language-terraform
  highlight-selected
)

## Check if MacOS
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo 'setup_dev_osx.sh only works for MacOS'
  exit 1
fi

## Check for root
if [[ $(id -u) -eq 0 ]]; then
  echo 'setup_dev_osx.sh must be run as a normal user'
  exit 1
fi

## Setup 1.1.1.1 DNS
networksetup -setdnsservers Wi-Fi 1.1.1.1 1.0.0.1 2606:4700:4700::1111 2606:4700:4700::1001
networksetup -setdnsservers "USB 10/100/1000 LAN" 1.1.1.1 1.0.0.1 2606:4700:4700::1111 2606:4700:4700::1001

## Install Xcode command line tools
xcode-select --install

## Install Homebrew
if test ! "$(command -v brew)"; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
  brew update
  brew upgrade
  brew doctor
fi

## Setup ssh directory
if [[ ! -d "$HOME/.ssh" ]]; then
    mkdir "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
fi
if [[ "$(grep ^github.com "$HOME/.ssh/known_hosts")" = '' ]]; then
    ssh-keyscan 'github.com' >> "$HOME/.ssh/known_hosts" 2>/dev/null
fi

## Setup work directory
if [ "$(ls -A "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Work")" ]; then
     echo "Found files in iCloud Drive/Work, creating symlink in ~/Work"
     ln -sn "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Work" "$HOME/Work"
else
    echo "No Work files found in iCloud, creating directory"
    mkdir "$HOME/Work"
fi

## Setup git
git config --global user.name "Alex Bernard"
git config --global user.email "alexis.bernard33@gmail.com"

## Install apps & packages
for app in "${apps_to_install[@]}";
  do
    exec="brew cask install $app"
    if ${exec} ; then
      echo "Installed $app"
    else
      echo "Failed to install: $app"
    fi
  done

for pkg in "${packages_to_install[@]}";
  do
    exec="brew install $pkg"
    if ${exec} ; then
      echo "Installed $pkg"
    else
      echo "Failed to install: $pkg"
    fi
  done

for atm in "${atom_packages_to_install[@]}";
  do
    exec="apm install $atm"
    if ${exec} ; then
      echo "Installed $atm"
    else
      echo "Failed to install: $atm"
    fi
  done

## Install config from Github
if [[ ! -d "$HOME/.config" ]]; then
    mkdir "$HOME/.config"
fi
git clone https://github.com/opiumozor/config.git "$HOME/.config"
git -C "$HOME/.config/" pull

## Install coding fonts
cp $HOME/.config/fonts/* "$HOME/Library/Fonts/"

## setup python & pip
if test ! "$(command -v pip)"; then
  wget -nc https://bootstrap.pypa.io/get-pip.py -P /tmp
  python /tmp/get-pip.py
else
  echo "pip is already installed, skipping"
fi

## open docker for full setup
#open /Applications/Docker.app

## Install & setup Zsh // SHOULD BE LAST STEP
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
rm -rf ~/.zshrc
ln -s ~/.config/zsh/dot.zshrc ~/.zshrc
wget -nc https://raw.githubusercontent.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme -P "$HOME/.oh-my-zsh/themes"

## Infos
echo "To load & update Iterm preferences, add $HOME/.config/iTerm to Iterm"
echo "Don't forget to copy your ssh keys!"
