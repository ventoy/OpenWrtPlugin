#!/bin/bash


proc_ipk() {
    file=$1
    
    [ -d ./kk ] && rm -rf ./kk    
    mkdir ./kk
    
    tar xzf $file -C ./kk/
    
    cd kk
    tar xf data.tar.gz
    
    kv=$(ls ./lib/modules)
    cd ..

    if echo $file | grep -q 'x86_64'; then
        machine=64
    elif echo $file | grep -q 'i386_pentium4'; then
        machine=generic
    else
        machine=legacy
    fi
    
    mkdir -p ventoy_openwrt/$kv/$machine
    for ko in dm-mod.ko dax.ko; do
        if [ -f kk/lib/modules/$kv/$ko ]; then
            echo "copy ventoy_openwrt/$kv/$machine/$ko ..."
            
            [ -f ventoy_openwrt/$kv/$machine/$ko ] && rm -f ventoy_openwrt/$kv/$machine/$ko            
            cp -a kk/lib/modules/$kv/$ko ventoy_openwrt/$kv/$machine/
        fi
    done
    
    rm -rf ./kk
}

for i in $(ls *.ipk); do
    proc_ipk $i
    rm -f $i
done

sh pack.sh

echo ""
echo "======= SUCCESS ======="
echo ""