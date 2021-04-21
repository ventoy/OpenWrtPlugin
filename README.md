<h1 align="center">
  <a href=https://www.ventoy.net/en/doc_openwrt.html>Ventoy OpenWrt Plugin</a>
</h1>

# Description
This plugin is used for Ventoy to boot OpenWrt img file.  
For more details please refer: [https://www.ventoy.net/en/doc_openwrt.html](https://www.ventoy.net/en/doc_openwrt.html)

# Update for new OpenWrt release
For example, a new OpenWrt release come (e.g. 21.02.2)
1. git clone this repository.
2. Download the current `ventoy_openwrt.xz` and run `tar xf ventoy_openwrt.xz` to decompress it.
3. Download `kmod-dax_xxx.ipk` and `kmod-dm_xxx.ipk` for the new OpenWrt release.
```
The download link is as follows:
https://downloads.openwrt.org/releases/21.02.0-rc1/targets/x86/64/kmods/5.4.111-1-6a923af0c1e0327f4ae0f3ad78f2d1a1/kmod-dax_5.4.111-1_x86_64.ipk  
https://downloads.openwrt.org/releases/21.02.0-rc1/targets/x86/64/kmods/5.4.111-1-6a923af0c1e0327f4ae0f3ad78f2d1a1/kmod-dm_5.4.111-1_x86_64.ipk  
```
4. run `sh newver.sh` and it will create a new `ventoy_openwrt.xz`