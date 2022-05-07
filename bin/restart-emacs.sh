#!/bin/bash 

doom sync
killall emacs
/usr/bin/emacs --daemon &

