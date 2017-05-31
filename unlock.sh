OUTSIDE="inside"
if [ -z "$1" ]
then
    OUTSIDE=$1
fi

mv /Applications/NeteaseMusic.app/Contents/MacOS/NeteaseMusic /Applications/NeteaseMusic.app/Contents/MacOS/NeteaseMusic.org
cp NeteaseMusic /Applications/NeteaseMusic.app/Contents/MacOS/ 
UNLOCKFN="unlock.dylib"
if [ "$OUTSIDE" = "outside" ]
then
    UNLOCKFN="unlock_outside.dylib"
fi
cp $UNLOCKFN /Applications/NeteaseMusic.app/Contents/MacOS/unlock.dylib

chmod +x /Applications/NeteaseMusic.app/Contents/MacOS/NeteaseMusic

if [ -z "$2" ]
then
    if [ "$2" = "true" ]
    then
        open -a NeteaseMusic
    fi
fi
