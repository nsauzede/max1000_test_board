#!/bin/bash

echo "ARGS for $0: $*"
arg1=$1
shift
arg2=$1
shift
arg3=$1
shift
arg4=$1
shift

echo "HELLO 1"
if [ "$arg1" = "--programmer" ]; then
echo "HELLO 2"
if [ "$arg2" = "ft2232_spi:type=2232H,port=B,divisor=4" ]; then
echo "HELLO 3"
if [ "$arg3" = "--write" ]; then
echo "HELLO 4"

cp -f "$arg4" "$arg4.orig"
truncate -s 8388608 "$arg4"
flashrom $arg1 $arg2 $arg3 $arg4 -c "W25Q64BV/W25Q64CV/W25Q64FV"
echo "HELLO 5"
exit 0

fi
fi
fi
echo "HELLO 6"

exit 1
