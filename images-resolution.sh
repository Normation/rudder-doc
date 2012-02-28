#!/bin/sh

for pic in $(find images -name \*.png)
do
	dpi=$(identify -units PixelsPerInch -verbose $pic | grep Resolution | cut -d x -f 2)
	if [ 150 != $dpi -a "149.99" != $dpi ] 
	then
		echo "convert $pic to 150dpi"
		convert -units PixelsPerInch -density 150 $pic $pic	
	else
		echo "Image density already set for $pic"
	fi
done

