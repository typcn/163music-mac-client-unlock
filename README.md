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
2. Open hijack.m
3. Change ```NSString *finalURL = [NSString stringWithFormat:@"http://m%d.music.126.net/%@/%@.mp3",arc4random_uniform(2)+1,base64String,fid];``` to ``` NSString *finalURL = [NSString stringWithFormat:@"http://p2.music.126.net/%@/%@.mp3",base64String,fid];```
4. Run ```clang -framework Foundation -o unlock.dylib -dynamiclib hijack.m```
5. Enter /Applications/NeteaseMusic.app/Contents/MacOS
6. Rename "NeteaseMusic" to "NeteaseMusic.org"
7. Put unlock.dylib and NeteaseMusic to the folder
8. Enjoy! All paid and blocked music are unlocked !

# Build
```clang -framework Foundation -o unlock.dylib -dynamiclib hijack.m```