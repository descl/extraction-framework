#!/bin/bash


# Usage: sh downloadDumps.sh "wikicode"
# files will be placed in $HOME/workspace/dump/"wikicode"wiki

# initiallizing parameters
wiki="$1wiki"

# urlRoot is set to the url containing the latest wikipedia dumps
# of the specified language wiki
urlRoot="http://dumps.wikimedia.org/$wiki/latest/"

# initializing an array containing the names of the files we want to download
names[0]="$wiki-latest-pages-articles.xml.bz2"
names[1]="$wiki-latest-imagelinks.sql.gz"
names[2]="$wiki-latest-image.sql.gz"
names[3]="$wiki-latest-langlinks.sql.gz"
names[4]="$wiki-latest-templatelinks.sql.gz"


# initializing an array of urls where the files are located
for i in "${!names[@]}"
do
	files[$i]="$urlRoot${names[$i]}"
done

# initializing the folder path where the downloaded files will be places
path="$HOME/workspace/dump/$wiki"

# making sure the folder exists, otherwise it will be created
if ![ -f "$path" ]
then
	mkdir -p path
fi
cd $path

# checking if the files allready exist in the folder
# if they allready exist they will be deleted and downloaded again
for i in "${names[@]}"
do
	if [ -f "$i" ]
	then
		rm $i
	fi
done

# downloading the specified files in the $path folder
for i in "${files[@]}"
do
	echo -n "Downloading $i:"
	wget "$i"
done

# extracting the files in the #path folder
echo -n "Extracting file ${names[0]} , this will take several minutes" 
bzip2 -d ${names[0]}
for i in {1..${#names[@]}}
do
	echo -n "Extracting files ${names[$i]}" 
	gzip -d ${names[$i]}
done
