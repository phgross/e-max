#!/usr/bin/env sh

# e-max install script

# Remark: A through-the-web installable script should be well commented for
# curious users. Also I am very bad at writing shell scripts - so I need
# that much comments to understand what I'm doing ;-)

cloneurl="https://github.com/senny/e-max.git"

echo ""
echo -e "\033[1;32mWelcome to the e-max installation wizard.\033[0m"
echo ""
echo "Permission / Ownership:"
echo -n "The installation process does not need any additonal privileges, "
echo "such as superuser permissions."
echo -n "All files are by default located in your userhome ($HOME) and "
echo "owned by the current user ($USER)."
echo ""


# Usually the emacs setup configuration goes into ~/.emacs.d . Emacs will
# load ~/.emacs.d/init.el automatically.
confdir=$HOME/.emacs.d

# XXX DEBUG
confdir=`pwd`/emacs-directory
cloneurl="/Users/jone/projects/e-max/"
echo "webinstall currently unsupported. script should not yet be used."
exit 1
# XXX / DEBUG



# First we need to check from where the install happens. This may either be
# through-the-web with curl, as mentioned in the readme, or by running the
# install script on a already cloned repository.

if [ -f `dirname $0`/install.sh ]; then
    # alread cloned, since the install.sh itself is somewhere laying around
    clone_repo=false

    if [[ `dirname $0` != /* ]]; then
        # script is run with relative path (./scripts/install.sh)
        if [[ $0 = './install.sh' ]]; then
            # The pwd is the "scripts" repository. doing a dirname on it
            # returns the parent.
            emaxdir=`dirname \`pwd\``
        else
            # The pwd is another relative path. We concat the pwd and the
            # script-path and remove the "install.sh". Then, remove "./"
            # parts from the path..
            emaxdir=`dirname \`pwd\`/\`dirname $0\` | sed -e 's/\/\.$//'`
        fi

    else
        # script run with absolute path (/home/me/e-max/scripts/install.sh)
        emaxdir=`dirname \`dirname $0\``
    fi

    echo -e "Your e-max repository is at \033[0;32m$emaxdir\033[0m"
    echo ""

else
    # If the script is run directly from curl, we are going to check out
    # the repository to ~/.e-max.
    emaxdir=$HOME/.e-max
    clone_repo=true

    if [ -d $emaxdir ]; then
        echo -e "\033[0;31mYou already have e-max installed at \033[0;31m$emaxdir\033[0m!"
        echo -e "You may want to run the update script at \033[0;31m$emaxdir/scripts/update.sh\033[0m instead."
        exit 1
    fi

fi



# We need to check if we would overwrite files in the ~/.emacs.d dir and
# ask the user what to do, if there are any.

templatedir=$emaxdir/templates/emacs.d
userfile="users/`whoami`.el"
machinefile="machines/`hostname -s`.el"
files_to_be_created="init.el bundles.el local.el $userfile $machinefile bin/update"

echo "These files will be created:"
conflicts=false
for name in $files_to_be_created; do
    path=$confdir/$name
    echo -n " - $path"
    if [ -e $path ]; then
        echo -en " - \033[1;31mALREADY EXISTING\033[0m"
        conflicts=true
    fi
    echo ""
done
echo ""

if $clone_repo; then
    echo -e "The e-max git repository will be cloned into \033[0;32m$emaxdir\033[0m"
    echo ""
fi

copy_init_only=false
if $conflicts; then
    echo -en "\033[1;31mWARNING\033[0m: Some of the files listed above are "
    echo "already existing. What would you like to do with them?"
    echo ""
    echo "Options:"
    echo " - [C] Cancel the install script. Nothing done yet."
    echo -e " - [i] Only overwrite \033[0;32m$confdir/init.el\033[0m and \033[0;32m$confdir/bin/update\033[0m"
    echo -e " - [b] Backup the \033[0;32m$confdir\033[0m directory and create a new one."
    echo " - [o] Overwrite current files. The files will be lost!"

    while [ true ]; do
        echo -n "Option [C/i/b/o]: "
        read option

        case $option in
            C* | c* | "")
            echo ""
            echo "Cancel. Nothing done yet."
            exit 1
            ;;

            i*)
            echo ""
            echo -e "Only \033[0;32m$confdir/init.el\033[0m will be rewritten."
            copy_init_only=true
            break
            ;;

            b*)
            echo ""
            backupdir=`date "+$HOME/.emacs-pre-e-max-%Y%m%d-%H%M%S"`
            echo -e "Renaming \033[0;32m$confdir\033[0m to \033[0;32m$backupdir\033[0m"
            if [ -e $backupdir ] || [[ `mv $confdir $backupdir` ]]; then
                echo -e "\033[1;31mAn error occurding while moving $confdir!\033[0m"
                echo "Plase check $confdir and $backupdir and clean it up - sorry!"
                exit 1
            fi
            break
            ;;

            o*)
                echo ""
                echo "Overwriting all existing files."
                break
                ;;
        esac
    done

    echo ""

else
    # We have no conflicts in this case. We have declared what we are going to do,
    # so ask for the "green light"
    echo -en "\033[0;33mPress any key\033[0m to continue creating the files listed above"
    echo -n " (cancel with Ctrl+c)"
    (read)
    echo ""
fi


# Clone the repository (usually only on through-the-web-install)
if $clone_repo; then
    echo -e "Cloning e-max to \033[0;32m$emaxdir\033[0m ..."
    /usr/bin/env git clone $cloneurl $emaxdir || exit 1
    (cd $emaxdir && /usr/bin/env git submodule init) || exit 1
    (cd $emaxdir && /usr/bin/env git submodule update) || exit 1
fi



# Create the files
echo -e "Configuring your configuration directory at \033[0;32m$confdir\033[0m:"
mkdir -p $confdir
echo " - $confdir/init.el (this file loads e-max and your custom files below - do not touch it)"
cat "$templatedir/init.el" | sed "s:E-MAX-DIR:$emaxdir:g" > $confdir/init.el

echo " - $confdir/bin/update (updates the e-max installation)"
mkdir -p $confdir/bin
cp $emaxdir/scripts/update.sh $confdir/bin/update

if ! $copy_init_only; then

    echo " - $confdir/bundles.el (enable here your favourite bundles)"
    cp $templatedir/bundles.el $confdir/bundles.el

    echo " - $confdir/$userfile (user based configuration)"
    mkdir -p $confdir/users
    cp $templatedir/_username.el $confdir/$userfile

    echo " - $confdir/$machinefile (user based configuration)"
    mkdir -p $confdir/machines
    cp $templatedir/_machine.el $confdir/$machinefile

    echo " - $confdir/local.el (will contain your customizations)"
    cp $templatedir/local.el $confdir/local.el
fi

echo ""
d="\033[0;34mX\033[0;32m"
echo -e "\033[0;32m  $d$d$d$d$d$d\          $d$d$d$d$d$d\ $d$d$d$d\   $d$d$d$d$d$d\  $d$d\   $d$d\     \033[0m"
echo -e "\033[0;32m  $d$d  __$d$d\ $d$d$d$d$d$d\ $d$d  _$d$d  _$d$d\  \____$d$d\  $d$d\ $d$d  |   \033[0m"
echo -e "\033[0;32m  $d$d$d$d$d$d$d$d |\______|$d$d / $d$d / $d$d | $d$d$d$d$d$d$d |  $d$d$d$d  /    \033[0m"
echo -e "\033[0;32m  $d$d   ____|        $d$d | $d$d | $d$d |$d$d  __$d$d | $d$d  $d$d<     \033[0m"
echo -e "\033[0;32m   $d$d$d$d$d$d$d\         $d$d | $d$d | $d$d |\ $d$d$d$d$d$d |$d$d  ^ $d$d\    \033[0m"
echo -e "\033[0;32m   \_______|        \__| \__| \__| \_______|\__/  \__|   \033[0m"
echo ""

echo "Your e-max installation was successful."
echo -n " - I recommend you as next step to activate your favourite bundles "
echo -e "at \033[0;32m$confdir/bundles.el\033[0m"
echo -n " - If you have any troubles, feel free to create a "
echo "issue at https://github.com/senny/e-max/issues"
echo -n " - If your favourite mode / extension / configuration is missing, fork it "
echo "and send us a pull requests. Contributions are very welcome!"
echo -n " - Update your e-max installation with the script at "
echo -e "\033[0;32m$confdir/bin/update\033[0m"
