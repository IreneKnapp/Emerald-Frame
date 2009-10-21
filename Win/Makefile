# Requires the OpenAL SDK to be installed.
OPENAL_INCLUDE=/cygdrive/c/Program Files/OpenAL 1.1 SDK/include/

Test.exe: Test.c ../Portable/Emerald-Frame.c General.c Video.c Audio.c Time.c Configuration.c
	gcc -static -g -std=c99 -I../Portable/ "-I${OPENAL_INCLUDE}" -I../External/Build/win32/include -mno-cygwin -mwindows -o $@ $^ -lopengl32 -lglu32 -L../External/Build/win32/lib -lgd -ljpeg -lpng -lz

# Also consider, for debugging:
#	gcc -g -std=c99 -I../Portable/ "-I${OPENAL_INCLUDE}" -I../External/Build/win32/include -mno-cygwin -o $@ $^ -lopengl32 -lglu32 -L../External/Build/win32/lib -lgd -ljpeg -lpng -lz -lgdi32 -lcomdlg32 -luser32
