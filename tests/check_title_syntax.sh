#!/bin/sh

# Test that all files end with a blank line to avoid breaking titles

ERROR=0

for entry in $(find $(dirname $0)/../*_* -name '*txt')
do
    tail -1 ${entry} | grep -qP "[^\n]"
    if [ $? -eq 0 ]; then
        echo "Missing newline at the end of ${entry}"
        ERROR=1
    fi
done

if [ ${ERROR} -ne 0 ]; then
    echo "Error: This will likely break the manual formatting."
    exit 1
else
    echo "File ending by newlines: OK"
fi

# Test that there is not more than 5 "=" in title levels

ERROR=0

for entry in $(find $(dirname $0)/../*_* -name '*txt')
do
    LINE=$(grep -E "^======+ " ${entry})
    if [ $? -eq 0 ]; then
        echo "Incorrect title level in ${entry}: ${LINE}"
        ERROR=1
    fi
done

if [ ${ERROR} -ne 0 ]; then
    echo "Error: This will likely break the manual formatting."
    exit 1
else
    echo "Maximum title levelw: OK"
fi

