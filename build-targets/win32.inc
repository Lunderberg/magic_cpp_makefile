BUILD_SHARED = 0
BUILD_STATIC = 1

CC = i686-w64-mingw32-gcc
CXX = i686-w64-mingw32-g++
AR = i686-w64-mingw32-ar

EXE_NAME = bin/$(1).exe
SHARED_LIBRARY_NAME = bin/$(1).dll
STATIC_LIBRARY_NAME = lib/$(1).dll.a

PIC_FLAG = # Because g++ complains about the flag when it is a win32 target.

LDFLAGS_EXTRA = -Lbin
ifeq ($(LINK_AGAINST_STATIC),1)
  LDFLAGS_EXTRA += -static -Llib
endif

SYSTEM = windows
