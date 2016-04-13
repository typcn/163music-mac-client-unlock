# 163music-mac-client-unlock
Unlock netease music mac client using dylib inject

# Usage

## Inside China
1. Download this repo
2. Enter /Applications/NeteaseMusic.app/Contents/MacOS
3. Rename "NeteaseMusic" to "NeteaseMusic.org"
4. Put unlock.dylib and NeteaseMusic to the folder
5. Enjoy! All paid and blocked music are unlocked !

## Outside China
1. Download this repo
2. Enter /Applications/NeteaseMusic.app/Contents/MacOS
3. Rename "NeteaseMusic" to "NeteaseMusic.org"
4. Put unlock_outside.dylib and NeteaseMusic to the folder
5. Rename unlock_outside.dylib to unlock.dylib
5. Enjoy! All paid and blocked music are unlocked !


If you got LSOpenURL error , run ```chmod +x  /Applications/NeteaseMusic.app/Contents/MacOS/NeteaseMusic```

# UPDATE：情况说明
本 dylib 可以用于解锁部分付费歌曲，以及大部分被下架/版权的歌曲。

但是对于部分已经下架的日语歌，网易最近直接在 CDN 上把文件给删掉了，访问全部 404，如果国内版不行，可以试试海外版，可能还存在一些缓存，如果有缓存赶紧下载，如果下不到那就没办法了，过段时间想想能不能利用音乐云盘绕过。


# App Store
Apps from app store will apply force signature verification, will not work after replace the main executeable, if you are using app store version , please use offical website version instead.

# Build

If you need change the source code , build with this command

```clang -framework Foundation -o unlock.dylib -dynamiclib hijack.m```