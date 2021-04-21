#!/bin/bash

usage() {
    echo ''
    echo 'Usage:    ventoy_openwrt_squashfs.sh  openwrt-xxx-combined-squashfs.img.gz'
    echo 'Example:  ventoy_openwrt_squashfs.sh  openwrt-19.07.7-x86-64-combined-squashfs.img.gz'
    echo ''
}


if [ -f "$1" ]; then    
    suffix=${1##*.}
    name=${1%.*}
    
    if [ "$suffix" != "gz" ]; then
        echo "Error: $1 is not a gzip file."
        usage
        exit 1
    fi
    
    echo "decompressing $1 ..."    
    zcat "$1" > $name
    
    B3=$(dd if=$name bs=1 count=1 skip=477 status=none | hexdump -n1 -e  '1/1 "%02X"') 
    B2=$(dd if=$name bs=1 count=1 skip=476 status=none | hexdump -n1 -e  '1/1 "%02X"') 
    B1=$(dd if=$name bs=1 count=1 skip=475 status=none | hexdump -n1 -e  '1/1 "%02X"') 
    B0=$(dd if=$name bs=1 count=1 skip=474 status=none | hexdump -n1 -e  '1/1 "%02X"') 
    secnum=$(printf "%ld" "0x$B3$B2$B1$B0")
    
    B3=$(dd if=$name bs=1 count=1 skip=473 status=none | hexdump -n1 -e  '1/1 "%02X"') 
    B2=$(dd if=$name bs=1 count=1 skip=472 status=none | hexdump -n1 -e  '1/1 "%02X"') 
    B1=$(dd if=$name bs=1 count=1 skip=471 status=none | hexdump -n1 -e  '1/1 "%02X"') 
    B0=$(dd if=$name bs=1 count=1 skip=470 status=none | hexdump -n1 -e  '1/1 "%02X"') 
    startsec=$(printf "%ld" "0x$B3$B2$B1$B0")
    
    endsec=$(expr $secnum + $startsec)
    echo "partition 2: startsec=$startsec secnum=$secnum endsec=$endsec "
    
    filesize=$(stat -c "%s" $name)
    mod=$(expr $filesize \% 512)
    
    echo "filesize=$filesize mod=$mod"
    
    if [ $mod -ne 0 ]; then
        delta=$(expr 512 - $mod)
        echo "align file mod=$mod delta=$delta"
        dd if=/dev/zero of=$name bs=1 count=$delta seek=$filesize conv=notrunc status=none && sync
        
        filesize=$(stat -c "%s" $name)
        echo "align size is $filesize"
    fi
    
    filesec=$(expr $filesize / 512)
    echo "endsec=$endsec filesize=$filesize filesec=$filesec"
    
    alignsec=$(expr $endsec - $filesec)
    echo "Appending $alignsec sectors at the end of the file ..."
    
    dd if=/dev/zero of=$name bs=512 count=$alignsec seek=$filesec conv=notrunc status=none && sync
    
    echo ""
    echo "======== SUCCESS ========="
    echo ""
else
    usage
    exit 1
fi
