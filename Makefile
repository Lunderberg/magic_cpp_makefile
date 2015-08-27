# This is a makefile intended for compiling simple C++ projects.
# It assumes that you have one or more source files in the main directory,
#    each of which contains an "int main()".
# There may also be a "src" directory, containing additional source files.
# All include files will be automatically listed as dependencies.

# Any folders starting with "lib" will be compiled into shared libraries.
# libMyLibrary should contain libMyLibrary/src and libMyLibrary/include
# -IlibMyLibrary/include will be added to the compiler flags
# All .cc files in libMyLibrary/src will be compiled into the shared library.
# The library will be created as lib/libMyLibrary.so



# Default build variables, can be overridden by command line options.

CXX      = g++
CPPFLAGS =
CXXFLAGS = -g -O3
LDFLAGS  =
LDLIBS   =
RM       = rm -f
BUILD    = default

BUILD_SHARED = 1
BUILD_STATIC = 2

ifneq ($(BUILD),default)
    include build-targets/$(BUILD).inc
endif

# Additional flags that are necessary to compile.
# Even if not specified on the command line, these should be present.

override CPPFLAGS += -Iinclude
override CXXFLAGS +=
override LDFLAGS  += -Llib -Wl,-rpath,\$$ORIGIN/../lib -Wl,--no-as-needed
override LDLIBS   +=

# EVERYTHING PAST HERE SHOULD WORK AUTOMATICALLY

.SECONDARY:
.SECONDEXPANSION:
.PHONY: all clean force

include PrettyPrint.inc

# Find the source files that will be used.
EXE_SRC_FILES = $(wildcard *.cc)
EXECUTABLES = $(patsubst %.cc,bin/%,$(EXE_SRC_FILES))
SRC_FILES = $(wildcard src/*.cc)
O_FILES = $(patsubst %.cc,build/$(BUILD)/build/%.o,$(SRC_FILES))

# Find each library to be made.
LIBRARY_FOLDERS   = $(wildcard lib?*)
LIBRARY_INCLUDES  = $(patsubst %,-I%/include,$(LIBRARY_FOLDERS))
override CPPFLAGS += $(LIBRARY_INCLUDES)
LIBRARY_FLAGS     = $(patsubst lib%,-l%,$(LIBRARY_FOLDERS))
override LDLIBS   += $(LIBRARY_FLAGS)
library_src_files = $(wildcard lib$(1)/src/*.cc)
library_o_files   = $(patsubst %.cc,build/$(BUILD)/build/%.o,$(call library_src_files,$(1)))
library_os_files  = $(addsuffix s,$(call library_o_files,$(1)))

ifneq ($(BUILD_SHARED),0)
    SHARED_LIBRARY_OUTPUT = $(patsubst %,lib/%.so,$(LIBRARY_FOLDERS))
endif

ifneq ($(BUILD_STATIC),0)
    STATIC_LIBRARY_OUTPUT = $(patsubst %,lib/%.a,$(LIBRARY_FOLDERS))
endif

all: $(EXECUTABLES) $(SHARED_LIBRARY_OUTPUT) $(STATIC_LIBRARY_OUTPUT)
	@printf "%b" "$(DGREEN)Compilation successful$(NO_COLOR)\n"

# Update dependencies with each compilation
override CPPFLAGS += -MMD
-include $(shell find build -name "*.d" 2> /dev/null)

.build-target: force
	@echo $(BUILD) | cmp -s - $@ || echo $(BUILD) > $@

bin/%: build/$(BUILD)/bin/% .build-target
	@mkdir -p $(@D)
	@$(call run_and_test,cp -f $< $@,Copying  )

lib/%: build/$(BUILD)/lib/% .build-target
	@mkdir -p $(@D)
	@$(call run_and_test,cp -f $< $@,Copying  )

ifeq ($(shell test $(BUILD_SHARED) -gt $(BUILD_STATIC); echo $$?),0)
build/$(BUILD)/bin/%: build/$(BUILD)/build/%.o $(O_FILES) | $(SHARED_LIBRARY_OUTPUT)
	@mkdir -p $(@D)
	@$(call run_and_test,$(CXX) $(ALL_LDFLAGS) $^ $(ALL_LDLIBS) -o $@,Linking  )
else
build/$(BUILD)/bin/%: build/$(BUILD)/build/%.o $(O_FILES) $(STATIC_LIBRARY_OUTPUT)
	@mkdir -p $(@D)
	@$(call run_and_test,$(CXX) $(ALL_LDFLAGS) $^ $(ALL_LDLIBS) -o $@,Linking  )
endif

build/$(BUILD)/bin/%: build/$(BUILD)/build/%.o $(O_FILES) | $(LIBRARY_OUTPUT)
	@mkdir -p $(@D)
	@$(call run_and_test,$(CXX) $(LDFLAGS) $^ $(LDLIBS) -o $@,Linking  )

build/$(BUILD)/build/%.os: %.cc
	@mkdir -p $(@D)
	@$(call run_and_test,$(CXX) -c -fPIC $(CPPFLAGS) $(CXXFLAGS) $< -o $@,Compiling)

build/$(BUILD)/build/%.o: %.cc
	@mkdir -p $(@D)
	@$(call run_and_test,$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@,Compiling)


define library_variables
CPPFLAGS_EXTRA =
CXXFLAGS_EXTRA =
LDFLAGS_EXTRA  =
SHARED_LDLIBS  =
-include $(1)/Makefile.inc
build/$(1)/%.o: override CPPFLAGS := $$(CPPFLAGS) $$(CPPFLAGS_EXTRA)
build/$(1)/%.o: override CXXFLAGS := $$(CXXFLAGS) $$(CXXFLAGS_EXTRA)
lib/$(1).so:  override LDFLAGS  := $$(LDFLAGS)  $$(LDFLAGS_EXTRA)
lib/$(1).so:  override SHARED_LDLIBS := $$(SHARED_LDLIBS)
endef

$(foreach lib,$(LIBRARY_FOLDERS),$(eval $(call library_variables,$(lib))))

build/$(BUILD)/lib/lib%.a: $$(call library_o_files,%)
	@mkdir -p $(@D)
	@$(call run_and_test,$(AR) rcs $@ $^,Linking  )

build/$(BUILD)/lib/lib%.so: $$(call library_os_files,%)
	@mkdir -p $(@D)
	@$(call run_and_test,$(CXX) $(LDFLAGS) $^ -shared $(SHARED_LDLIBS) -o $@,Linking  )

clean:
	@printf "%b" "$(DYELLOW)Cleaning$(NO_COLOR)\n"
	@$(RM) -r bin build lib .build-target
