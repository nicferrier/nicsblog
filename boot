#!/bin/bash

# Start nics-blog in an emacs session

case "$1" in 
     start)
        /home/nferrier/emacs-local/bin/emacs -Q --daemon=nicsblog -l /home/nferrier/.emacs.d.nicsblog/init.el
        ;;

     client)
        /home/nferrier/emacs-local/bin/emacsclient -s /tmp/emacs1000/nicsblog /home/nferrier/.emacs.d.nicsblog
        ;;

esac

# End
