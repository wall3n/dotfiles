#!/bin/bash 

read -p "Enter the name of the command: " command
read -p "Enter the script to alias:  " file

echo "alias $command=$file" >> ~/.dotfiles/shell/aliases.sh
