# Authors:
# https://github.com/AlexBio
# https://github.com/dbb
# https://github.com/Mappleconfusers
# Nicolas Jonas nextgenthemes.com
# https://github.com/loctauxphilippe
#
# Debian, Ubuntu and friends related zsh aliases and functions for zsh

alias acs='apt-cache search'
compdef _acs acs='apt-cache search'

alias afs='apt-file search --regexp'
compdef _afs afs='apt-file search --regexp'

alias acsp='apt-cache showpkg'
compdef _acsp acsp='apt-cache showpkg'

# superuser operations ######################################################
alias afu='sudo apt-file update'
compdef _afu afu='sudo apt-file update'

alias ppap='sudo ppa-purge'
compdef _ppap ppap='sudo ppa-purge'

alias apac='sudo apt autoclean'
alias apar='sudo apt autoremove'
alias apbd='sudo apt build-dep'
alias apc='sudo apt clean'
alias apdu='sudo apt dselect-upgrade'
alias api='sudo apt install'
alias app='sudo apt purge'
alias apr='sudo apt remove'
alias apu='sudo apt update'
alias apul='sudo apt update && apt list --upgradable'
alias apud='sudo apt update && sudo apt dist-upgrade'
alias apug='sudo apt upgrade'
alias apuu='sudo apt update && sudo apt upgrade'
alias apuf='sudo apt update && sudo apt full-upgrade'

alias aps='apt show'
compdef _aps aps='apt show'

compdef _apac apac='sudo apt autoclean'
compdef _apar apar='sudo apt autoremove'
compdef _apbd apbd='sudo apt build-dep'
compdef _apc apc='sudo apt clean'
compdef _apdu apdu='sudo apt dselect-upgrade'
compdef _api api='sudo apt install'
compdef _app app='sudo apt purge'
compdef _apr apr='sudo apt remove'
compdef _apu apu='sudo apt update'
compdef _apud apud='sudo apt update && sudo apt dist-upgrade'
compdef _apug apug='sudo apt upgrade'
compdef _apuu apuu='sudo apt update && sudo apt upgrade'

# Remove ALL kernel images and headers EXCEPT the one in use
alias kclean='sudo aptitude remove -P ?and(~i~nlinux-(ima|hea) \
	?not(~n`uname -r`))'

# Misc. #####################################################################
# print all installed packages
alias allpkgs='aptitude search -F "%p" --disable-columns ~i'

# Create a basic .deb package
alias mydeb='time dpkg-buildpackage -rfakeroot -us -uc'

# apt-add-repository with automatic install/upgrade of the desired package
# Usage: aar ppa:xxxxxx/xxxxxx [packagename]
# If packagename is not given as 2nd argument the function will ask for it and guess the default by taking
# the part after the / from the ppa name which is sometimes the right name for the package you want to install
function aar() {
	if [ -n "$2" ]; then
		PACKAGE=$2
	else
		read "PACKAGE?Type in the package name to install/upgrade with this ppa [${1##*/}]: "
	fi

	if [ -z "$PACKAGE" ]; then
		PACKAGE=${1##*/}
	fi

	sudo apt-add-repository $1 && sudo apt update
	sudo apt install $PACKAGE
}

# Prints apt history
# Usage:
#   apt-history install
#   apt-history upgrade
#   apt-history remove
#   apt-history rollback
#   apt-history list
# Based On: http://linuxcommando.blogspot.com/2008/08/how-to-show-apt-log-history.html
apt-history () {
  case "$1" in
    install)
      zgrep --no-filename 'install ' $(ls -rt /var/log/dpkg*)
      ;;
    upgrade|remove)
      zgrep --no-filename $1 $(ls -rt /var/log/dpkg*)
      ;;
    rollback)
      zgrep --no-filename upgrade $(ls -rt /var/log/dpkg*) | \
        grep "$2" -A10000000 | \
        grep "$3" -B10000000 | \
        awk '{print $4"="$5}'
      ;;
    list)
      zgrep --no-filename '' $(ls -rt /var/log/dpkg*)
      ;;
    *)
      echo "Parameters:"
      echo " install - Lists all packages that have been installed."
      echo " upgrade - Lists all packages that have been upgraded."
      echo " remove - Lists all packages that have been removed."
      echo " rollback - Lists rollback information."
      echo " list - Lists all contains of dpkg logs."
      ;;
  esac
}

# Kernel-package building shortcut
kerndeb () {
    # temporarily unset MAKEFLAGS ( '-j3' will fail )
    MAKEFLAGS=$( print - $MAKEFLAGS | perl -pe 's/-j\s*[\d]+//g' )
    print '$MAKEFLAGS set to '"'$MAKEFLAGS'"
	appendage='-custom' # this shows up in $ (uname -r )
    revision=$(date +"%Y%m%d") # this shows up in the .deb file name

    make-kpkg clean

    time fakeroot make-kpkg --append-to-version "$appendage" --revision \
        "$revision" kernel_image kernel_headers
}

# List packages by size
function apt-list-packages {
    dpkg-query -W --showformat='${Installed-Size} ${Package} ${Status}\n' | \
    grep -v deinstall | \
    sort -n | \
    awk '{print $1" "$2}'
}
