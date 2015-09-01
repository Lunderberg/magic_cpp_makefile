BUILD_SHARED = 0
BUILD_STATIC = 1

CC = i686-w64-mingw32-gcc
CXX = i686-w64-mingw32-g++
AR = i686-w64-mingw32-ar

EXE_NAME = bin/$(1).exe
SHARED_LIBRARY_NAME = $(patsubst lib%,bin/%.dll,  $(1))
STATIC_LIBRARY_NAME = $(patsubst lib%,lib/%.dll.a,$(1))

PIC_FLAG = # Because g++ complains about the flag when it is a win32 target.

LDFLAGS_EXTRA = -Lbin
ifeq ($(LINK_AGAINST_STATIC),1)
  LDFLAGS_EXTRA += -static -Llib
endif

SYSTEM = windows
