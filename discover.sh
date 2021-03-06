#!/usr/bin/bash

# Bash script for automatic host discovery and port scanning
# Combines fping with threader3000 and nmap

if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "" ]; then
    echo "Usage: discover.sh [options]"
    echo "Options:"
    echo "  --help (-h)     Display this text"
    echo "  --net  (-n)     Set Target network"
    exit 0
fi

while getopts h:n: flag
do
	case "${flag}" in
		n) net=${OPTARG} ;;
	esac
done

if [ "$net" = "" ]; then
	echo "Network (-n) isn't set! Quitting..."
	exit 0
fi

echo "Network set to: $net"

# Create directory to store results
dirName=$(echo "$net" | tr "/" "-")
echo "dirName set to: $dirName"
mkdir $dirName 2>/dev/null
cd $dirName

# Run fping on the target network
echo "Discovering live hosts via fping..."
fping -a -g $net 2>/dev/null | tee fping.list
echo "Results written to fping.list."

# Parse fping output. Remove own host
localhost=$(hostname -I | awk '{print $NF}')
echo "localhost is $localhost"

grep -vx $localhost fping.list 2>/dev/null > fping.tmp
cat fping.tmp > fping.list
rm fping.tmp

# Run threader3000 on fping results
# really hacky way of making sure the results are stored in the right
# Directory. Will change this later but I'm lazy
cp ../threader6000.py ./
cp ../vanillaThreader.py ./
./threader6000.py -f ./fping.list && rm ./threader6000.py ./vanillaThreader.py && rm -rd ./__pycache__

# Run nmap on open ports (threader3000 output)
# This functionality is already implemented in Threader6000 (Tux version)
