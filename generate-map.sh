#!/bin/sh

# Create temporary directory to build list of included files
[ ! -d temp ] && mkdir temp

# FIXME: we do twice almost the same thing ... to be reworked

FILE=temp/content.txt

echo "// Automatically generated list of content - do not edit" > $FILE

for entry in $(find *_* -name '*txt' | sort)
do
	echo "include::../$entry[] \n" >> $FILE
done

FILE=temp/glossary.txt

echo "// Automatically generated list of content - do not edit
[glossary]
== Glossary
" > $FILE

for entry in $(find glossary -name '*txt' | sort)
do
	echo "include::../$entry[] \n" >> $FILE
done

## image resolution should be 150dpi for PDF export
for pic in $(find images -name \*.png)
do	
	if [ 150 != $(identify -verbose $pic | grep Resolution | cut -d x -f 2) ] 
	then
		echo "convert $pic to 150dpi"
		convert -density 150 $pic $pic	
	fi
done
