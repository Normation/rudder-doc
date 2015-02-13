#!/bin/sh

for pic in $(find images -name \*.png)
do
	dpi=$(identify -units PixelsPerInch -verbose $pic | grep Resolution | cut -d x -f 2)
	if [ "${dpi}" != "150" ] && [ "${dpi}" != "149.99" ]
	then
		convert -units PixelsPerInch -density 150 $pic $pic
	fi
done

