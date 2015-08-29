# This is a makefile intended for compiling any C++ project.

# It assumes that you have one or more source files in the main directory,
#    each of which contains an "int main()".
# There may also be a "src" directory, containing additional source files.
# All include files will be automatically listed as dependencies.

# Any folders starting with "lib" will be compiled into libraries.
# libMyLibrary should contain libMyLibrary/src and libMyLibrary/include
# -IlibMyLibrary/include will be added to the compiler flags
# All .cc files in libMyLibrary/src will be compiled into the library.

# If BUILD_SHARED is non-zero, shared object libraries will be made.
#    The default name is libMyLibrary.so
# If BUILD_STATIC is non-zero, static object libraries will be made.
#    The default name is libMyLibrary.a
# If BUILD_STATIC has a greater value than BUILD_SHARED,
#    the executables will be linked against the static libraries.
# Otherwise, they will be linked against the shared libraries.


# Standard build variables, can be overridden by command line options.

BUILD    = default

CC       = gcc
CXX      = g++
AR       = ar

CPPFLAGS =
CXXFLAGS = -g -O3
LDFLAGS  =
LDLIBS   =
RM       = rm -f

BUILD_SHARED = 1
BUILD_STATIC = 0


# More build variables, can be modified in build-target

CPPFLAGS_EXTRA = -Iinclude
CXXFLAGS_EXTRA =
LDFLAGS_EXTRA  = -Llib -Wl,-rpath,\$$ORIGIN/../lib -Wl,--no-as-needed
LDLIBS_EXTRA   =
PIC_FLAG = -fPIC

C_EXT   = c
CPP_EXT = C cc cpp cxx c++ cp

SHARED_LIBRARY_NAME = $(patsubst %,lib/%.so,$(1))
STATIC_LIBRARY_NAME = $(patsubst %,lib/%.a,$(1))

# Will be 1 if the executables will be linking against a static library.
LINK_AGAINST_STATIC = $(shell test $(BUILD_SHARED) -gt $(BUILD_STATIC); echo $$?)

EXE_NAME     = bin/$(1)

ifneq ($(BUILD),default)
    include build-targets/$(BUILD).inc
endif

# Additional flags that are necessary to compile.
# Even if not specified on the command line, these should be present.

ALL_CPPFLAGS = $(CPPFLAGS) $(CPPFLAGS_EXTRA)
ALL_CXXFLAGS = $(CXXFLAGS) $(CXXFLAGS_EXTRA)
ALL_CFLAGS   = $(CFLAGS)   $(CFLAGS_EXTRA)
ALL_LDFLAGS  = $(LDFLAGS)  $(LDFLAGS_EXTRA)
ALL_LDLIBS   = $(LDLIBS)   $(LDLIBS_EXTRA)

# EVERYTHING PAST HERE SHOULD WORK AUTOMATICALLY

.SECONDARY:
.SECONDEXPANSION:
.PHONY: all clean force

include PrettyPrint.inc

find_in_dir = $(foreach ext,$(2),$(wildcard $(1)/*.$(ext)))
o_file_name = $(foreach file,$(1),build/$(BUILD)/build/$(basename $(file)).o)

# Find the source files that will be used.
EXE_SRC_FILES = $(call find_in_dir,.,$(CPP_EXT) $(C_EXT))
EXECUTABLES = $(foreach cc,$(EXE_SRC_FILES),$(call EXE_NAME,$(basename $(cc))))
SRC_FILES = $(call find_in_dir,src/,$(CPP_EXT) $(C_EXT))
O_FILES = $(call o_file_name,$(SRC_FILES))

# Find each library to be made.
LIBRARY_FOLDERS   = $(wildcard lib?*)
LIBRARY_INCLUDES  = $(patsubst %,-I%/include,$(LIBRARY_FOLDERS))
ALL_CPPFLAGS     += $(LIBRARY_INCLUDES)
LIBRARY_FLAGS     = $(patsubst lib%,-l%,$(LIBRARY_FOLDERS))
ifneq ($(LINK_AGAINST_STATIC),1)
    ALL_LDLIBS       += $(LIBRARY_FLAGS)
endif
library_src_files = $(call find_in_dir,lib$(1)/src/,$(CPP_EXT) $(C_EXT))
library_o_files   = $(call o_file_name,$(call library_src_files,$(1)))
library_os_files   = $(addsuffix s,$(call library_o_files,$(1)))

ifneq ($(BUILD_STATIC),0)
    STATIC_LIBRARY_OUTPUT = $(foreach lib,$(LIBRARY_FOLDERS),$(call STATIC_LIBRARY_NAME,$(lib)))
endif

ifneq ($(BUILD_SHARED),0)
    SHARED_LIBRARY_OUTPUT = $(foreach lib,$(LIBRARY_FOLDERS),$(call SHARED_LIBRARY_NAME,$(lib)))
endif

all: $(EXECUTABLES) $(STATIC_LIBRARY_OUTPUT) $(SHARED_LIBRARY_OUTPUT)
	@printf "%b" "$(DGREEN)Compilation successful$(NO_COLOR)\n"

# Update dependencies with each compilation
ALL_CPPFLAGS += -MMD
-include $(shell find build -name "*.d" 2> /dev/null)

.build-target: force
	@echo $(BUILD) | cmp -s - $@ || echo $(BUILD) > $@

$(call EXE_NAME,%): build/$(BUILD)/$(call EXE_NAME,%) .build-target
	@$(call run_and_test,cp -f $< $@,Copying  )

$(call SHARED_LIBRARY_NAME,lib%): build/$(BUILD)/$(call SHARED_LIBRARY_NAME,lib%) .build-target
	@$(call run_and_test,cp -f $< $@,Copying  )

$(call STATIC_LIBRARY_NAME,lib%): build/$(BUILD)/$(call STATIC_LIBRARY_NAME,lib%) .build-target
	@$(call run_and_test,cp -f $< $@,Copying  )

ifeq ($(LINK_AGAINST_STATIC),0)
build/$(BUILD)/$(call EXE_NAME,%): build/$(BUILD)/build/%.o $(O_FILES) | $(SHARED_LIBRARY_OUTPUT)
	@$(call run_and_test,$(CXX) $(ALL_LDFLAGS) $^ $(ALL_LDLIBS) -o $@,Linking  )
else
build/$(BUILD)/$(call EXE_NAME,%): build/$(BUILD)/build/%.o $(O_FILES) $(STATIC_LIBRARY_OUTPUT)
	@$(call run_and_test,$(CXX) $(ALL_LDFLAGS) $^ $(ALL_LDLIBS) -o $@,Linking  )
endif

define CPP_BUILD_RULES
build/$$(BUILD)/build/%.o: %.$(1)
	@$$(call run_and_test,$$(CXX) -c $$(ALL_CPPFLAGS) $$(ALL_CXXFLAGS) $$< -o $$@,Compiling)

build/$$(BUILD)/build/%.os: %.$(1)
	@$$(call run_and_test,$$(CXX) -c $$(PIC_FLAG) $$(ALL_CPPFLAGS) $$(ALL_CXXFLAGS) $$< -o $$@,Compiling)
endef

$(foreach ext,$(CPP_EXT),$(eval $(call CPP_BUILD_RULES,$(ext))))


define C_BUILD_RULES
build/$$(BUILD)/build/%.o: %.$(1)
	@$$(call run_and_test,$$(CC) -c $$(ALL_CPPFLAGS) $$(ALL_CFLAGS) $$< -o $$@,Compiling)

build/$$(BUILD)/build/%.os: %.$(1)
	@$$(call run_and_test,$$(CC) -c $$(PIC_FLAG) $$(ALL_CPPFLAGS) $$(ALL_CFLAGS) $$< -o $$@,Compiling)
endef

$(foreach ext,$(C_EXT),$(eval $(call C_BUILD_RULES,$(ext))))


define library_variables
CPPFLAGS_LIB =
CFLAGS_LIB =
CXXFLAGS_LIB =
LDFLAGS_LIB  =
SHARED_LDLIBS  =
-include $(1)/Makefile.inc
build/$(1)/%.o: ALL_CPPFLAGS := $$(ALL_CPPFLAGS) $$(CPPFLAGS_LIB)
build/$(1)/%.o: ALL_CFLAGS := $$(ALL_CFLAGS) $$(CFLAGS_LIB)
build/$(1)/%.o: ALL_CXXFLAGS := $$(ALL_CXXFLAGS) $$(CXXFLAGS_LIB)
lib/$(1).so:  ALL_LDFLAGS  := $$(ALL_LDFLAGS)  $$(LDFLAGS_LIB)
lib/$(1).so:  SHARED_LDLIBS := $$(SHARED_LDLIBS)
endef

$(foreach lib,$(LIBRARY_FOLDERS),$(eval $(call library_variables,$(lib))))

build/$(BUILD)/$(call SHARED_LIBRARY_NAME,lib%): $$(call library_os_files,%)
	@$(call run_and_test,$(CXX) $(ALL_LDFLAGS) $^ -shared $(SHARED_LDLIBS) -o $@,Linking  )

build/$(BUILD)/$(call STATIC_LIBRARY_NAME,lib%): $$(call library_o_files,%)
	@$(call run_and_test,$(AR) rcs $@ $^,Linking  )

clean:
	@printf "%b" "$(DYELLOW)Cleaning$(NO_COLOR)\n"
	@$(RM) -r bin build lib .build-target
