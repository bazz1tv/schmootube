#!/bin/bash

### YOUTUBE TOP100 THUMBNAIL DOWNLOADER WITH IMAGE RESIZE
## written by bazz (http://www.bazz1.com)
### written on OSX, should work on any *nix

## dependencies
## bash, curl, sed (osx sed is OK), sort -- all of these should be typical on a *nix box


## HOW IT WORKS
# It's made to custom-scrape the top100 youtube channel list @ https://socialblade.com/youtube/top/100/mostsubscribed 
# and converts the listing into youtube URLS.. 
# It then scrapes the youtube channel page by looking for the currently used <img class="channel-header-profile-image"
# token that is representative of the thumnbnail.. By doing that we have access to the thumbnail, which can be dynamically
# resized by changing the url, for instance from s100 to s512 (see below for implementation, search for imgurl)

# GLOBAL VARIABLES
IMAGE_DIMENSION="512" #square image

###### Reference URL
# top 100
#URL="https://socialblade.com/youtube/top/100/mostsubscribed"
# top 500 gamers
URL="https://socialblade.com/youtube/top/category/games/mostviewed"
### WARNING!!!
## the script assumes s100 is default URL thumbnail size, which it is currently ;) 
##

# BEGIN CODE!!!
mkdir -p img
mkdir -p work

# Scrape https://socialblade.com/youtube/top/100/mostsubscribed for all links 
curl "$URL" > work/Socialblade_YouTube_Stats.html

# convert channel references to Youtube URLs
cat work/Socialblade_YouTube_Stats.html | grep "/youtube/user/" | sed 's/href = /href=/g' | sed 's#<a href="/youtube\([^"]*\)".*#http://www.youtube.com\1#g' | \
	sed 's#%c2%a0##g' | sort -u > work/URLS.txt
# I noticed some urls scraped had a weird code %c2%a0 which I remove above in the last sed

##### PREPARE FOR PROCESSING!!!
# let us know which number we're on
num=1

for url in `cat work/URLS.txt`; do
	echo "$num" ; num=$((num + 1))
	echo $url
	# get username to save to img/$username.jpg
	user=$(echo "$url" | sed 's#http://www.youtube.com/user/##g')
	#echo $user

	imgurl="`curl -L --referer youtube.com "$url" | \
		# find the thumbnail URL line 
		grep '<img class="channel-header-profile-image"' | \
		# scrape just the URL of thumbnail 
		sed 's/.*src="\([^"]*\)".*/\1/' | \
		# resize the image (assumes s100 is default)
		sed "s/s100/s${IMAGE_DIMENSION}/g"`"
	echo "$imgurl"

	# curl cannot do protocol-relative URLS
	if echo "$imgurl" | grep "^//" ; then
		imgurl="http:$imgurl"
	fi
	extension="${imgurl##*.}" # get file extension
	extension="${extension/\?*/}" # remove question mark crap from some urls.. ie. star.jpg?v=34343
	#echo "extension = $extension"

	# save images as youtube username . image file extension
	# but only if they do not already exist
	if ! test -f img/$user.$extension; then 
		curl -L "$imgurl" > img/$user.$extension
	fi
done 

# consider zipping the img directory as a final step
# zip -r foo.zip img