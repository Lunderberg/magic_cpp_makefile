BUILD_SHARED = 0
BUILD_STATIC = 1

CC = x86_64-w64-mingw32-gcc
CXX = x86_64-w64-mingw32-g++
AR = x86_64-w64-mingw32-ar
SHARED_LIBRARY_NAME = $(patsubst lib%,bin/%.dll,  $(1))
STATIC_LIBRARY_NAME = $(patsubst lib%,lib/%.dll.a,$(1))
EXE_NAME = bin/$(1).exe
CXXFLAGS_EXTRA =

PIC_FLAG = # Because g++ complains about the flag when it is a win32 target.

LDFLAGS_EXTRA = -Lbin
ifeq ($(shell test $(BUILD_STATIC) -gt $(BUILD_SHARED); echo $$?),0)
  LDFLAGS_EXTRA += -static
endif
