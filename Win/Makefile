# If you want to get console output, you have to take out -mwindows and add in
# -lgdi32 -lcomdlg32 -luser32.  There are a couple commented-out lines below to do
# this.

# Requires the Windows SDK to be installed.
WINDOWS_INCLUDE=/cygdrive/c/Program Files/Microsoft SDKs/Windows/v7.0/Include

# Requires the OpenAL SDK to be installed.
OPENAL_SDK=/cygdrive/c/Program Files/OpenAL 1.1 SDK
OPENAL_INCLUDE=${OPENAL_SDK}/include
OPENAL_LIB=${OPENAL_SDK}/libs/Win32

CFLAGS=-mno-cygwin -mwindows -std=c99 -O3 -U_WIN32
#CFLAGS=-mno-cygwin -std=c99 -g -U_WIN32
INCLUDES=-I../Portable -I../External/Build/win32/include
LIBRARIES=-lopengl32 \
	  -lglu32 \
	  -L"${OPENAL_LIB}" \
	  -lOpenAL32 \
	  -L../External/Build/win32/lib \
	  -lgd \
	  -ljpeg \
	  -lpng \
	  -lz \
	  -lmpg123 \
	  -lsndfile
POTENTIALLY_DYNAMIC_LIBRARIES=-lopengl32 -lglu32 -L"${OPENAL_LIB}" -lOpenAL32
STATIC_LIBRARIES=\
	../External/Build/win32/lib/libgd.a \
	../External/Build/win32/lib/libjpeg.a \
	../External/Build/win32/lib/libpng.a \
	../External/Build/win32/lib/libz.a \
	../External/Build/win32/lib/libmpg123.a \
	../External/Build/win32/lib/libsndfile.a
#LIBRARIES=${LIBRARIES} -lgdi32 -lcomdlg32 -luser32
INTERNAL_HEADERS=../Portable/Emerald-Frame.h ../Portable/Unicode.h
OBJECTS=build/Portable/Emerald-Frame.o \
	build/Portable/Unicode.o \
	build/Portable/Audio.o \
	build/Win/General.o \
	build/Win/Video.o \
	build/Win/Audio.o \
	build/Win/Time.o \
	build/Win/Configuration.o

all: buildprep build/Test-Dynamic.exe build/Test-Static.exe

build/Test-Dynamic.exe: build/Test.o build/Libraries/EmeraldFrame.dll
	gcc -mno-cygwin -mwindows -o $@ $(filter %.o,$^) -Lbuild/Libraries -lEmeraldFrame.dll ${POTENTIALLY_DYNAMIC_LIBRARIES}

build/Test-Static.exe: build/Test.o build/Libraries/libEmeraldFrame.a
	gcc -mno-cygwin -mwindows -static -o $@ $(filter %.o,$^) -Lbuild/libraries -lEmeraldFrame ${LIBRARIES}

buildprep:
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/Portable ; then mkdir build/Portable ; fi
	if ! test -d build/Win ; then mkdir build/Win ; fi
	if ! test -d build/Libraries ; then mkdir build/Libraries ; fi

build/Test.o: Test.c ${INTERNAL_HEADERS}
	gcc ${CFLAGS} ${INCLUDES} -c -o $@ $(filter %.c,$^)

build/Portable/Emerald-Frame.o: ../Portable/Emerald-Frame.c ${INTERNAL_HEADERS}
	gcc ${CFLAGS} ${INCLUDES} -c -o $@ $(filter %.c,$^)

build/Portable/Unicode.o: ../Portable/Unicode.c ${INTERNAL_HEADERS}
	gcc ${CFLAGS} ${INCLUDES} -c -o $@ $(filter %.c,$^)

build/Portable/Audio.o: ../Portable/Audio.c ${INTERNAL_HEADERS}
	gcc ${CFLAGS} ${INCLUDES} -c -o $@ $(filter %.c,$^)

build/Win/General.o: General.c ${INTERNAL_HEADERS}
	gcc ${CFLAGS} ${INCLUDES} -c -o $@ $(filter %.c,$^)

build/Win/Video.o: Video.c ${INTERNAL_HEADERS}
	gcc ${CFLAGS} ${INCLUDES} -c -o $@ $(filter %.c,$^)

build/Win/Audio.o: Audio.c ${INTERNAL_HEADERS}
	gcc ${CFLAGS} ${INCLUDES} -c -o $@ $(filter %.c,$^)

build/Win/Time.o: Time.c ${INTERNAL_HEADERS}
	gcc ${CFLAGS} ${INCLUDES} -c -o $@ $(filter %.c,$^)

build/Win/Configuration.o: Configuration.c ${INTERNAL_HEADERS}
	gcc ${CFLAGS} ${INCLUDES} -c -o $@ $(filter %.c,$^)

build/Libraries/libEmeraldFrame.a: ${OBJECTS}
	ar cr $@ $(filter %.o,$^)

build/Libraries/EmeraldFrame.dll: ${OBJECTS} EmeraldFrame.def
	gcc -mno-cygwin -shared -o $@ $(filter %.o,$^) $(filter %.def,$^) ${POTENTIALLY_DYNAMIC_LIBRARIES} ${STATIC_LIBRARIES} -lgdi32 -lwinmm -ldxguid -lole32
	dlltool --output-lib build/Libraries/libEmeraldFrame.dll.a --dllname build/Libraries/EmeraldFrame.dll --input-def EmeraldFrame.def

.dummy: all buildprep
