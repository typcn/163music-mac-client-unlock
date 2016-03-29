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

# App Store
Apps from app store will apply force signature verification, will not work after replace the main executeable, if you are using app store version , please use offical website version instead.

# Build

If you need change the source code , build with this command

```clang -framework Foundation -o unlock.dylib -dynamiclib hijack.m```