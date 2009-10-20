# Requires the OpenAL SDK to be installed.
OPENAL_INCLUDE=/cygdrive/c/Program Files/OpenAL 1.1 SDK/include/

BUILTIN_LIBRARIES=\
	../External/Build/win32/lib/libcharset.a \
	../External/Build/win32/lib/libfreetype.a \
	../External/Build/win32/lib/libgd.a \
	../External/Build/win32/lib/libjpeg.a \
	../External/Build/win32/lib/libpng.a \
	../External/Build/win32/lib/libz.a

Test.exe: Test.c ../Portable/Emerald-Frame.c General.c Video.c Audio.c Time.c Configuration.c
	gcc -g -std=c99 -I../Portable/ "-I${OPENAL_INCLUDE}" -I../External/Build/win32/include -mno-cygwin -o $@ $^ -lopengl32 -lglu32 -lgdi32 -lcomdlg32 -luser32 -L. -lgdiplus -L../External/Build/win32/lib -lgd

#	gcc -g -std=c99 -I../Portable/ "-I${OPENAL_INCLUDE}" -I../External/Build/win32/include -mno-cygwin -o $@ $^ -lopengl32 -lglu32 -lgdi32 -lcomdlg32 -luser32 -L. -lgdiplus ${BUILTIN_LIBRARIES}
#	gcc -std=c99 -I../Portable/ "-I${OPENAL_INCLUDE}" -mno-cygwin -mwindows -o $@ $^ -lopengl32 -lglu32
