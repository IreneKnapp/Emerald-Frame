# Requires the OpenAL SDK to be installed.
OPENAL_INCLUDE=/cygdrive/c/Program Files/OpenAL 1.1 SDK/include/

Test.exe: Test.c ../Portable/Emerald-Frame.c General.c Video.c Audio.c Time.c
	gcc -I../Portable/ "-I${OPENAL_INCLUDE}" -mno-cygwin -mwindows -o $@ $^ -lopengl32 -lglu32