#!/bin/bash
 
read -p "Select your password to copy: " searchPass
if [ $searchPass = 'github' ]
then
	file="/home/wall3n/workspace/credentials/gitkey.txt"
	        while IFS= read -r line
			    do
				            echo "$line" | xclip -selection c
					        done < "$file"
						    exit 0
fi
 
echo "Your service provided isn't registered" && exit 1
