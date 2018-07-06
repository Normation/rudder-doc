#!/bin/sh

FILE=modules/ROOT/nav.adoc

echo "// Automatically generated list of content - do not edit" > $FILE

for entry in $(find modules/ROOT/pages/ -name '*.adoc' | sort)
do
	raw_title=$(grep -E '^=' ${entry}| head -n 1)
	title=$(echo ${raw_title} | sed 's/^[= \t]*//')
	level=$(echo ${raw_title} | sed 's/[^=]//g' | sed 's/=/*/g')
	path=$(echo ${entry} | sed 's@modules/ROOT/pages/@@')
	echo "${level} xref:${path}[${title}]" >> $FILE
done

