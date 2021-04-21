#!/bin/bash

usage() {
    echo ''
    echo 'Usage:    ventoy_openwrt_squashfs.sh  openwrt-xxx-combined-squashfs.img.gz'
    echo 'Example:  '
    echo '          ventoy_openwrt_squashfs.sh  openwrt-19.07.7-x86-64-combined-squashfs.img.gz'
    echo '          ventoy_openwrt_squashfs.sh  lede-17.01.7-x86-64-combined-squashfs.img'
    echo ''
}


if [ -f "$1" ]; then    
    suffix=${1##*.}
    
    if [ "$suffix" = "img" ]; then
        name=${1}
        echo "processing $1 ..."
    elif [ "$suffix" = "gz" ]; then
        name=${1%.*}
        echo "decompressing $1 ..."    
        zcat "$1" > $name
    else
        echo "Error: Invalid file format, $1 "
        usage
        exit 1
    fi
    
    efipart=$(dd if=$name bs=1 count=8 skip=512 status=none | hexdump -n8 -e  '8/1 "%02X"')
    
    if [ "$efipart" = "4546492050415254" ]; then
        echo "GPT partition table"
        
        B0=$(dd if=$name bs=1 count=1 skip=1192 status=none | hexdump -n1 -e  '1/1 "%02X"') 
        B1=$(dd if=$name bs=1 count=1 skip=1193 status=none | hexdump -n1 -e  '1/1 "%02X"') 
        B2=$(dd if=$name bs=1 count=1 skip=1194 status=none | hexdump -n1 -e  '1/1 "%02X"') 
        B3=$(dd if=$name bs=1 count=1 skip=1195 status=none | hexdump -n1 -e  '1/1 "%02X"') 
        B4=$(dd if=$name bs=1 count=1 skip=1196 status=none | hexdump -n1 -e  '1/1 "%02X"') 
        B5=$(dd if=$name bs=1 count=1 skip=1197 status=none | hexdump -n1 -e  '1/1 "%02X"') 
        B6=$(dd if=$name bs=1 count=1 skip=1198 status=none | hexdump -n1 -e  '1/1 "%02X"') 
        B7=$(dd if=$name bs=1 count=1 skip=1199 status=none | hexdump -n1 -e  '1/1 "%02X"') 
        
        startsec=$(printf "%ld" "0x$B7$B6$B5$B4$B3$B2$B1$B0")
        endsec=$(expr $startsec + 1)
        
        echo "partition 2: endsec=$endsec"    
    else
        echo "MBR partition table"
    
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
    fi
    
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

    if [ $endsec -gt $filesec ]; then
        alignsec=$(expr $endsec - $filesec)    
        echo "Appending $alignsec sectors at the end of the file ..."
        dd if=/dev/zero of=$name bs=512 count=$alignsec seek=$filesec conv=notrunc status=none && sync
    else
        echo "No need to process the file ..."
    fi

    echo ""
    echo "======== SUCCESS ========="
    echo ""
else
    usage
    exit 1
fi
