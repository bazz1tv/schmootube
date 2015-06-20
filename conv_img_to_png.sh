#!/bin/bash

# Deps
# ImageMagick

mkdir -p png

num=1
for img in img/*; do
	# fbn = file base name (no extension and no directories)
	fbn=`basename $img`	
	fbn="${fbn%.*}"
	final_file_loc="png/$fbn.png"
	extension="${img##*.}"
	echo "$num. $img -> $final_file_loc"
	if [ "$extension" == "png" ]; then
		cp $img $final_file_loc
	else 
		convert $img $final_file_loc
	fi
	num=$((num + 1))
done

