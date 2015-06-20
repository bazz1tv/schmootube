#!/bin/bash

for url in `cat work/URLS.txt`; do
	#echo "$num" ; num=$((num + 1))
	#echo $url
	# get username to save to img/$username.jpg
	user=$(echo "$url" | sed 's#http://www.youtube.com/user/##g')
	echo $user
done
