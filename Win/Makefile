# Requires the OpenAL SDK to be installed.
OPENAL_SDK=/cygdrive/c/Program Files/OpenAL 1.1 SDK
OPENAL_INCLUDE=${OPENAL_SDK}/include
OPENAL_LIB=${OPENAL_SDK}/libs/Win32

Test.exe: Test.c ../Portable/Emerald-Frame.c ../Portable/Audio.c General.c Video.c Audio.c Time.c Configuration.c
	gcc -static -g -std=c99 -I../Portable/ "-I${OPENAL_INCLUDE}" -I../External/Build/win32/include -mno-cygwin -o $@ $^ -lopengl32 -lglu32 "-L${OPENAL_LIB}" -lopenal32 -L../External/Build/win32/lib -lgd -ljpeg -lpng -lz -lmpg123 -lsndfile -lgdi32 -lcomdlg32 -luser32

# The good one is:
#	gcc -static -g -std=c99 -I../Portable/ "-I${OPENAL_INCLUDE}" -I../External/Build/win32/include -mno-cygwin -mwindows -o $@ $^ -lopengl32 -lglu32 "-L${OPENAL_LIB}" -lopenal32 -L../External/Build/win32/lib -lgd -ljpeg -lpng -lz -lmpg123 -lsndfile

# Also consider, for debugging:p
#	gcc -static -g -std=c99 -I../Portable/ "-I${OPENAL_INCLUDE}" -I../External/Build/win32/include -mno-cygwin -o $@ $^ -lopengl32 -lglu32 -L../External/Build/win32/lib -lgd -ljpeg -lpng -lz -lmpg123 -lsndfile -lgdi32 -lcomdlg32 -luser32
