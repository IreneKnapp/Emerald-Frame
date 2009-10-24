CFLAGS=-mno-cygwin -O3 -std=gnu99 -DAL_BUILD_LIBRARY
INCLUDES=-I/usr/local/include -isystem /usr/include/mingw
ALC_INCLUDES=-Iinclude -IOpenAL32/include ${INCLUDES}
ALU_INCLUDES=-Iinclude -IOpenAL32/include ${INCLUDES}
OPENAL32_INCLUDES=-Iinclude -IOpenAL32/include ${INCLUDES}
ROUTER_INCLUDES=-Iinclude ${INCLUDES}

all: build/libwrap_oal.a build/libOpenAL32.a

#build/libALc.a: build/Alc/ALc.o
#	if ! test -d build ; then mkdir build ; fi
#	ar cr $@ $(filter %.o,$^)

build/Alc/ALc.o: ALc/Alc.c
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/Alc ; then mkdir build/Alc ; fi
	gcc ${CFLAGS} -c -o $@ ${ALC_INCLUDES} $^

#build/libALu.a: build/Alu/ALu.o
#	if ! test -d build ; then mkdir build ; fi
#	ar cr $@ $(filter %.o,$^)

build/Alu/ALu.o: ALu/Alu.c
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/Alu ; then mkdir build/Alu ; fi
	gcc ${CFLAGS} -c -o $@ ${ALU_INCLUDES} $^

build/libwrap_oal.a: \
	build/Alc/ALc.o \
	build/Alu/ALu.o \
	build/OpenAL32/alBuffer.o \
	build/OpenAL32/alEax.o \
	build/OpenAL32/aleax2.o \
	build/OpenAL32/alError.o \
	build/OpenAL32/alExtension.o \
	build/OpenAL32/alListener.o \
	build/OpenAL32/alSource.o \
	build/OpenAL32/alState.o \
	build/OpenAL32/alThunk.o \
	build/OpenAL32/OpenAL32.o \
	build/OpenAL32/openal32.res.o
	if ! test -d build ; then mkdir build ; fi
	ar cr $@ $(filter %.o,$^) $(filter %.a,$^)

build/OpenAL32/alBuffer.o: OpenAL32/alBuffer.c
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/OpenAL32 ; then mkdir build/OpenAL32 ; fi
	gcc ${CFLAGS} -c -o $@ ${OPENAL32_INCLUDES} $^

build/OpenAL32/alEax.o: OpenAL32/alEax.c
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/OpenAL32 ; then mkdir build/OpenAL32 ; fi
	gcc ${CFLAGS} -c -o $@ ${OPENAL32_INCLUDES} $^

build/OpenAL32/aleax2.o: OpenAL32/aleax2.c
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/OpenAL32 ; then mkdir build/OpenAL32 ; fi
	gcc ${CFLAGS} -c -o $@ ${OPENAL32_INCLUDES} $^

build/OpenAL32/alError.o: OpenAL32/alError.c
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/OpenAL32 ; then mkdir build/OpenAL32 ; fi
	gcc ${CFLAGS} -c -o $@ ${OPENAL32_INCLUDES} $^

build/OpenAL32/alExtension.o: OpenAL32/alExtension.c
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/OpenAL32 ; then mkdir build/OpenAL32 ; fi
	gcc ${CFLAGS} -c -o $@ ${OPENAL32_INCLUDES} $^

build/OpenAL32/alListener.o: OpenAL32/alListener.c
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/OpenAL32 ; then mkdir build/OpenAL32 ; fi
	gcc ${CFLAGS} -c -o $@ ${OPENAL32_INCLUDES} $^

build/OpenAL32/alSource.o: OpenAL32/alSource.c
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/OpenAL32 ; then mkdir build/OpenAL32 ; fi
	gcc ${CFLAGS} -c -o $@ ${OPENAL32_INCLUDES} $^

build/OpenAL32/alState.o: OpenAL32/alState.c
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/OpenAL32 ; then mkdir build/OpenAL32 ; fi
	gcc ${CFLAGS} -c -o $@ ${OPENAL32_INCLUDES} $^

build/OpenAL32/alThunk.o: OpenAL32/alThunk.cpp
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/OpenAL32 ; then mkdir build/OpenAL32 ; fi
	gcc ${CFLAGS} -c -o $@ ${OPENAL32_INCLUDES} $^

build/OpenAL32/OpenAL32.o: OpenAL32/OpenAL32.c
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/OpenAL32 ; then mkdir build/OpenAL32 ; fi
	gcc ${CFLAGS} -c -o $@ ${OPENAL32_INCLUDES} $^

build/OpenAL32/openal32.res.o: OpenAL32/openal32.rc
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/OpenAL32 ; then mkdir build/OpenAL32 ; fi
	windres $^ $@

build/libOpenAL32.a: \
	build/Router/al.o \
	build/Router/alc.o \
	build/Router/alList.o \
	build/Router/OpenAL32.o \
	build/Router/OpenAL32.res.o
	if ! test -d build ; then mkdir build ; fi
	ar cr $@ $(filter %.o,$^) $(filter %.a,$^)

build/Router/al.o: Router/al.cpp
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/Router ; then mkdir build/Router ; fi
	gcc ${CFLAGS} -c -o $@ ${ROUTER_INCLUDES} $^

build/Router/alc.o: Router/alc.cpp
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/Router ; then mkdir build/Router ; fi
	gcc ${CFLAGS} -c -o $@ ${ROUTER_INCLUDES} $^

build/Router/alList.o: Router/alList.cpp
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/Router ; then mkdir build/Router ; fi
	gcc ${CFLAGS} -c -o $@ ${ROUTER_INCLUDES} $^

build/Router/OpenAL32.o: Router/OpenAL32.cpp
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/Router ; then mkdir build/Router ; fi
	gcc ${CFLAGS} -c -o $@ ${ROUTER_INCLUDES} $^

build/Router/OpenAL32.res.o: Router/OpenAL32.rc
	if ! test -d build ; then mkdir build ; fi
	if ! test -d build/Router ; then mkdir build/Router ; fi
	windres $^ $@

.dummy: all
