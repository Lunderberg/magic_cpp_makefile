define WELCOME_MESSAGE
default.inc not found, generating now
-----------------------------------------------------
|                                                   |
|             Magic C/C++ Makefile                  |
|                   - Eric Lunderberg               |
|                                                   |
-----------------------------------------------------

  This is a makefile intended for compiling any
C/C++ project.  It will find all source files,
compile them appropriately into executables and
libraries, and track all dependencies.

  The makefile itself should not need to be
modified.  A "default.inc" file has been generated,
which contains many options for customizing the
behavior of the makefile for your particular
project.  The initial behavior assumes that most source
files are located in src, include files are
located in include, and source files containing
"int main()" are in the main directory.

  Additional description of the behavior of the
makefile can be found in "default.inc"
endef #WELCOME_MESSAGE

define DEFAULT_INC_CONTENTS
# The C compiler to be used
CC       = gcc

# The C++ compiler to be used
CXX      = g++

# The archiver to be used
AR       = ar

# The command to remove files
RM       = rm -f

# Flags to be passed to both C and C++ code
CPPFLAGS = -Wall -Wextra -pedantic

# Flags to be passed to C code
CFLAGS   =

# Flags to be passed to C++ code
CXXFLAGS = -g -O3

# Flags to be passed to the linker, prior to listing of object files.
LDFLAGS  =

# Flags to be passed to the linker, after the listing of object files.
LDLIBS   =

# A list of directories containing source files containing "int
# main()".  Each file will be compiled into a separate executable.
EXE_DIRECTORIES = .

# A list of directories containing other source files.  Each file will
# be compiled, with the resulting source file being linked into each
# executable.
SRC_DIRECTORIES = src

# A list of directories containing include files.  Each directory will
# be made available for #include directives for included files.
INC_DIRECTORIES = include

# A list of directories that contain libraries.  The list can also
# contain patterns that expand to directories that contain libraries.
# Each library is ex
LIB_DIRECTORIES = lib?*

# If BUILD_SHARED is non-zero, shared libraries will be generated.  If
# BUILD_SHARED is greater than BUILD_STATIC, executables will be
# linked against the shared libraries.
BUILD_SHARED = 1

# If BUILD_STATIC is non-zero, static libraries will be generated.  If
# BUILD_STATIC is greater than BUILD_SHARED, executables will be
# linked against the static libraries.
BUILD_STATIC = 0

# Mandatory arguments to both C and C++ compilers.  These arguments
# will be passed even if CPPFLAGS has been overridden by command-line
# arguments.
CPPFLAGS_EXTRA =

# Mandatory arguments to the C compiler.  These arguments will be
# passed even if CFLAGS has been overriden by command-line arguments.
CFLAGS_EXTRA =

# Mandatory arguments to the C++ compiler.  These arguments will be
# passed even if CXXFLAGS has been overridden by command-line arguments.
CXXFLAGS_EXTRA = -std=c++11

# Mandatory arguments to the linker, before the listing of object
# files.  These arguments will be passed even if LDFLAGS has been
# overridden by command-line arguments.
LDFLAGS_EXTRA  = -Llib -Wl,-rpath,\$$ORIGIN/../lib -Wl,--no-as-needed

# Mandatory arguments to the linker, after the listing of object
# files.  These arguments will be passed even if LDLIBS has been
# overridden by command-line arguments.
LDLIBS_EXTRA   =

# Static libraries that should be linked into the executables.  The
# order of libraries is the order of inclusion.
EXTERNAL_STATIC_LIBS =

# Flag to generate position-independent code.  This is passed to
# object files being compiled to shared libraries, but not to any
# other object files.
PIC_FLAG = -fPIC

# A space-delimited list of file extensions to be compiled as C code.
# No element of this list should be present in CPP_EXT.
C_EXT   = c

# A space-delimited list of file extensions to be compiled as C++
# code.  No element of this list should be present in C_EXT.
CPP_EXT = C cc cpp cxx c++ cp

# A space-delimited list of file patterns to be excluded
# For example, this may contain a source file or directory
# that is not to be compiled in the current build.
# % can be used to create wildcard exclusions.
# Note: Files in the base directory are excluded as ./filename.
EXCLUSIONS =

# A function that, when given the name of a library, should return the
# output file of a shared library.  For example, the default version,
# when passed "MyLibrary" as $(1), will return "lib/libMyLibrary.so".
SHARED_LIBRARY_NAME = lib/lib$(1).so

# A function that, when given the name of a library, should return the
# output file of a static library.  For example, the default version,
# when passed "MyLibrary" as $(1), will return "lib/libMyLibrary.a".
STATIC_LIBRARY_NAME = lib/lib$(1).a

#   A macro to determine whether executables will be linked against
# static libraries or shared libraries.  By default, will compile
# against the shared libraries if BUILD_SHARED has a greater numeric
# value than BUILD_STATIC, and will compile against the static
# libraries otherwise.
#   To always link against shared libraries, change this variable to
# 0.  To always link against static libraries, change this variable to 1.
LINK_AGAINST_STATIC = $(shell test "$(BUILD_SHARED)" -gt "$(BUILD_STATIC)"; echo $$?)

# A function that, given the base name of a source file, returns the
# output filename of the executable.  For example, the default
# version, when passed "MyProgram" as $(1), will return "bin/MyProgram".
EXE_NAME     = bin/$(1)

# Determines whether the output is in color or not.  To disable
# coloring, set this variable to 0.
USE_COLOR = 1

# The location to which extra resources should be installed.
INSTALL_DEST =

# Extra resources that should be copied to $(INSTALL_DEST).  These can
# be either files or directories.
INSTALL_RESOURCES =

# A listing of the files and directories to be cleaned when running
# "make clean".
CLEAN_TARGETS = bin lib build

# Which system is the target system.  This may be used by library
# targets to choose which system libraries to include.
SYSTEM = native

# The command to be run to run tests.  This command will be run when
# running "make test".  If this variable is an empty string, then this
# target will be left undefined.
TEST_COMMAND =

endef # DEFAULT_INC_CONTENTS

# Needed to replace newline with \n prior to printing.
define newline


endef

# Eval DEFAULT_INC_CONTENTS first.  This ensures that all required
# variables are defined, even if the default.inc present is from an
# older version of the makefile. This uses $(value ...) to avoid the
# first expansion of variables.
$(eval $(value DEFAULT_INC_CONTENTS))

# If default.inc does not exist, create it and display the welcome
# message.
ifeq (,$(wildcard default.inc))
    $(shell printf '$(subst $(newline),\n,$(value DEFAULT_INC_CONTENTS))' > default.inc)
    $(error $(WELCOME_MESSAGE))
endif

# Include the configuration file.
BUILD = default
include default.inc

# If the BUILD variable has been defined from the command line,
# include the appropriate build-target file.
ifneq ($(BUILD),default)
    include build-targets/$(BUILD).inc
endif

ifeq ($(SYSTEM),native)
  SYSTEM = $(shell uname | tr A-Z a-z)
endif

# Merge the mandatory and the optional flags.
ALL_CPPFLAGS := $(CPPFLAGS) $(CPPFLAGS_EXTRA)
ALL_CXXFLAGS := $(CXXFLAGS) $(CXXFLAGS_EXTRA)
ALL_CFLAGS   := $(CFLAGS)   $(CFLAGS_EXTRA)
ALL_LDFLAGS  := $(LDFLAGS)  $(LDFLAGS_EXTRA)
ALL_LDLIBS   := $(LDLIBS)   $(LDLIBS_EXTRA)

ALL_CPPFLAGS += $(addprefix -I,$(INC_DIRECTORIES))

.SECONDARY:
.PHONY: all clean force install_resources executables libraries

# Define all the ANSI color codes I want as options.  If the USE_COLOR
# variable is zero, then don't define any of the codes.
ifneq ($(USE_COLOR),0)
  RESET_COLOR   = \033[m

  BLUE       = \033[1;34m
  YELLOW     = \033[1;33m
  GREEN      = \033[1;32m
  RED        = \033[1;31m
  BLACK      = \033[1;30m
  MAGENTA    = \033[1;35m
  CYAN       = \033[1;36m
  WHITE      = \033[1;37m

  DBLUE      = \033[0;34m
  DYELLOW    = \033[0;33m
  DGREEN     = \033[0;32m
  DRED       = \033[0;31m
  DBLACK     = \033[0;30m
  DMAGENTA   = \033[0;35m
  DCYAN      = \033[0;36m
  DWHITE     = \033[0;37m

  BG_WHITE   = \033[47m
  BG_RED     = \033[41m
  BG_GREEN   = \033[42m
  BG_YELLOW  = \033[43m
  BG_BLUE    = \033[44m
  BG_MAGENTA = \033[45m
  BG_CYAN    = \033[46m
endif

# Define the colors to be used in run_and_test
COM_COLOR   = $(DBLUE)
OBJ_COLOR   = $(DCYAN)
OK_COLOR    = $(DGREEN)
ERROR_COLOR = $(DRED)
WARN_COLOR  = $(DYELLOW)
NO_COLOR    = $(RESET_COLOR)

OK_STRING    = "[OK]"
ERROR_STRING = "[ERROR]"
WARN_STRING  = "[WARNING]"

# A macro that will be used repeatedly.  Performs the command given,
# with colored output.  Uses the colors as defined above.
ifdef VERBOSE

    define run_and_test
        echo "$(1)"
        mkdir -p $(@D)
        $(1)
    endef

else

    define run_and_test
        mkdir -p $(@D)
        printf "%b" "$(COM_COLOR)$(2) $(OBJ_COLOR)$(@F)$(NO_COLOR)\r"; \
        $(1) 2> $@.log; \
        RESULT=$$?; \
        printf "%b" "$(COM_COLOR)$(2) $(OBJ_COLOR)"; \
        if [ $$RESULT -ne 0 ]; then \
          printf "%-40b%b" "$@" "$(ERROR_COLOR)$(ERROR_STRING)$(NO_COLOR)\n"; \
        elif [ -s $@.log ]; then \
          printf "%-40b%b" "$@" "$(WARN_COLOR)$(WARN_STRING)$(NO_COLOR)\n"; \
        else  \
          printf "%-40b%b" "$(@F)" "$(OK_COLOR)$(OK_STRING)$(NO_COLOR)\n"; \
        fi; \
        cat $@.log; \
        rm -f $@.log; \
        exit $$RESULT
    endef

endif


find_in_dir  = $(foreach ext,$(2),$(wildcard $(1)/*.$(ext)))
find_in_dirs = $(foreach dir,$(1),$(call find_in_dir,$(dir),$(2)))
o_file_name  = $(foreach file,$(1),build/$(BUILD)/build/$(basename $(file)).o)

# Find the source files that will be used.
SRC_FILES := $(call find_in_dirs,$(SRC_DIRECTORIES),$(CPP_EXT) $(C_EXT))
SRC_FILES := $(filter-out $(EXCLUSIONS),$(SRC_FILES))
O_FILES = $(call o_file_name,$(SRC_FILES))

# Find each library to be made.
LIBRARY_FOLDERS   = $(foreach lib,$(LIB_DIRECTORIES),$(wildcard $(lib)))
library_src_files = $(filter-out $(addprefix $(1)/,$(LIBRARY_EXCLUSIONS)),\
                                 $(call find_in_dirs,$(addprefix $(1)/,$(2)),$(CPP_EXT) $(C_EXT)))
library_o_files   = $(call o_file_name,$(call library_src_files,$(1),$(2)))
library_os_files   = $(addsuffix s,$(call library_o_files,$(1),$(2)))


all: default.inc executables libraries install_resources
	@printf "%b" "$(DGREEN)Compilation successful$(NO_COLOR)\n"

ifneq ($(TEST_COMMAND),)
  check: all
	@echo "Running tests"
	@$(TEST_COMMAND)
endif

# Update dependencies with each compilation
ALL_CPPFLAGS += -MMD -MP
-include $(shell find build -name "*.d" 2> /dev/null)

.build-target: force
	@echo $(BUILD) | cmp -s - $@ || echo $(BUILD) > $@


define SAMPLE_MAKEFILE_INC_CONTENTS
# This file can be placed inside of a library directory to customize
# the behavior of that library. Each option, if left commented, will
# assumed its default value.

# The name of the library.
# Defaults to LIBNAME, where libLIBNAME is the directory.
LIBRARY_NAME = $(patsubst lib%,%,$(notdir $(CURDIR)))

# The flag that will be passed to the include the library in
# executables.
LIBRARY_FLAG = -l$(LIBRARY_NAME)

# The directories containing source files for the library.
LIBRARY_SRC_DIRS = src

# The directories containing include files for the library. These
# directories will be added to the include path for all files in the
# project.
LIBRARY_INCLUDE_DIRS = include

# The directories containing include files for the library.  These
# directories will be added to the include path only for files within
# this library
LIBRARY_PRIVATE_INCLUDE_DIRS =

# A space-delimited list of file patterns to be excluded
# For example, this may contain a source file or directory
# that is not to be compiled in the current build.
# % can be used to create wildcard exclusions.
# Note: Files in the library's directory should be listed as "filename",
#    not "./filename".
LIBRARY_EXCLUSIONS =

# Extra flags that should be present when linking the shared library.
# This may include other libraries that should be included.
$(LIBRARY): SHARED_LDLIBS +=

# Compiler flag overrides for src files within this library.
$(LIBRARY):
endef

LibMakefile.inc:
	@echo '$(subst $(newline),\n,$(value SAMPLE_MAKEFILE_INC_CONTENTS))' > Makefile.inc
	@echo "Constructed Makefile.inc.  Place this into a library directory to customize behavior"

# Rules to copy each library into their final location.
$(call SHARED_LIBRARY_NAME,%): build/$(BUILD)/$(call SHARED_LIBRARY_NAME,%) .build-target
	@$(call run_and_test,cp --remove-destination $< $@,Copying  )

$(call STATIC_LIBRARY_NAME,%): build/$(BUILD)/$(call STATIC_LIBRARY_NAME,%) .build-target
	@$(call run_and_test,cp -f $< $@,Copying  )

libraries:
STATIC_LIBRARY_OUTPUT :=
SHARED_LIBRARY_OUTPUT :=

define library_commands
  CURDIR = $(1)
  STATIC_LIBRARY = $$(call STATIC_LIBRARY_NAME,$$(LIBRARY_NAME))
  SHARED_LIBRARY = $$(call SHARED_LIBRARY_NAME,$$(LIBRARY_NAME))
  LIBRARY = $$(SHARED_LIBRARY) $$(STATIC_LIBRARY)

  $$(eval $$(value SAMPLE_MAKEFILE_INC_CONTENTS))

  -include $(1)/Makefile.inc

  STATIC_LIBRARY_OUTPUT += $$(STATIC_LIBRARY)
  SHARED_LIBRARY_OUTPUT += $$(SHARED_LIBRARY)

  ifeq ($$(BUILD_STATIC),0)
    STATIC_LIBRARY :=
  endif

  ifeq ($$(BUILD_SHARED),0)
    SHARED_LIBRARY :=
  endif

  libraries: $$(LIBRARY)
  $$(LIBRARY): ALL_CPPFLAGS += $$(addprefix -I$(1)/,$$(LIBRARY_PRIVATE_INCLUDE_DIRS))

  ALL_CPPFLAGS += $$(addprefix -I$(1)/,$$(LIBRARY_INCLUDE_DIRS))
  ifneq ($$(LINK_AGAINST_STATIC),1)
    ALL_LDLIBS += $$(LIBRARY_FLAG)
  endif

  build/$$(BUILD)/$$(call SHARED_LIBRARY_NAME,$$(LIBRARY_NAME)): \
                          $$(call library_os_files,$(1),$$(LIBRARY_SRC_DIRS))
	@$$(call run_and_test,$$(CXX) $$(ALL_LDFLAGS) $$^ -shared $$(SHARED_LDLIBS) -o $$@,Linking  )

  build/$$(BUILD)/$$(call STATIC_LIBRARY_NAME,$$(LIBRARY_NAME)): \
                           $$(call library_o_files,$(1),$$(LIBRARY_SRC_DIRS))
	@$$(call run_and_test,$$(AR) rcs $$@ $$^,Linking  )
endef

$(foreach lib,$(LIBRARY_FOLDERS),$(eval $(call library_commands,$(lib))))

# Rules to build each executable
$(call EXE_NAME,%): build/$(BUILD)/$(call EXE_NAME,%) .build-target
	@$(call run_and_test,cp -f $< $@,Copying  )

executables:

define exe_rules
  EXE_SRC_FILES :=
  EXE_INCLUDE_DIRS :=
  EXTRA_SRC_FILES :=
  CURDIR := $(1)

  -include $(1)/Makefile.inc

  ifeq ($$(EXE_SRC_FILES),)
    EXE_SRC_FILES := $$(call find_in_dir,$(1),$$(CPP_EXT) $$(C_EXT))
    EXE_SRC_FILES := $$(filter-out $$(EXCLUSIONS),$$(EXE_SRC_FILES))
  else
    EXE_SRC_FILES := $$(addprefix $$(CURDIR)/,$$(EXE_SRC_FILES))
  endif

  EXTRA_SRC_FILES := $$(addprefix $$(CURDIR)/,$$(EXTRA_SRC_FILES))

  EXE_INCLUDE_DIRS := $$(addprefix $$(CURDIR)/,$$(EXE_INCLUDE_DIRS))
  EXTRA_O_FILES := $$(call o_file_name,$$(EXTRA_SRC_FILES))
  EXECUTABLES := $$(foreach cc,$$(EXE_SRC_FILES),$$(call EXE_NAME,$$(basename $$(notdir $$(cc)))))

  ifeq ($$(LINK_AGAINST_STATIC),0)
    build/$$(BUILD)/$$(call EXE_NAME,%): build/$$(BUILD)/build/$(1)/%.o $$(O_FILES) $$(EXTRA_O_FILES) $(EXTERNAL_STATIC_LIBS) | $$(SHARED_LIBRARY_OUTPUT)
	@$$(call run_and_test,$$(CXX) $$(ALL_LDFLAGS) $$^ $$(ALL_LDLIBS) -o $$@,Linking  )
  else
    build/$$(BUILD)/$$(call EXE_NAME,%): build/$$(BUILD)/build/$(1)/%.o $$(O_FILES) $$(EXTRA_O_FILES) $(EXTERNAL_STATIC_LIBS) $$(STATIC_LIBRARY_OUTPUT)
	@$$(call run_and_test,$$(CXX) $$(ALL_LDFLAGS) $$^ $$(ALL_LDLIBS) -o $$@,Linking  )
  endif

  executables: $$(EXECUTABLES)
  $$(EXECUTABLES): ALL_CPPFLAGS += $$(addprefix -I,$$(EXE_INCLUDE_DIRS))
endef

$(foreach dir,$(EXE_DIRECTORIES),$(eval $(call exe_rules,$(dir))))


# Rules to build object files from C code
define C_BUILD_RULES
build/$$(BUILD)/build/%.o: %.$(1)
	@$$(call run_and_test,$$(CC) -c $$(ALL_CPPFLAGS) $$(ALL_CFLAGS) $$< -o $$@,Compiling)

build/$$(BUILD)/build/%.os: %.$(1)
	@$$(call run_and_test,$$(CC) -c $$(PIC_FLAG) $$(ALL_CPPFLAGS) $$(ALL_CFLAGS) $$< -o $$@,Compiling)
endef

$(foreach ext,$(C_EXT),$(eval $(call C_BUILD_RULES,$(ext))))


# Rules to build object files from C++ code
define CPP_BUILD_RULES
build/$$(BUILD)/build/%.o: %.$(1)
	@$$(call run_and_test,$$(CXX) -c $$(ALL_CPPFLAGS) $$(ALL_CXXFLAGS) $$< -o $$@,Compiling)

build/$$(BUILD)/build/%.os: %.$(1)
	@$$(call run_and_test,$$(CXX) -c $$(PIC_FLAG) $$(ALL_CPPFLAGS) $$(ALL_CXXFLAGS) $$< -o $$@,Compiling)
endef

$(foreach ext,$(CPP_EXT),$(eval $(call CPP_BUILD_RULES,$(ext))))


# Rules to install
install_resources:

define INSTALL_RULES
$$(INSTALL_DEST)/%: $(dir $(abspath $(1)))/%
	@$$(call run_and_test,cp $$< $$@,Copying  )

INSTALL_SOURCES = $$(shell find $(abspath $(1)) -type f)
install_resources: $$(patsubst $(dir $(abspath $(1)))%,$$(INSTALL_DEST)/%,$$(INSTALL_SOURCES))
endef

$(foreach source,$(INSTALL_RESOURCES),$(eval $(call INSTALL_RULES,$(source))))



# Cleanup
clean:
	@printf "%b" "$(DYELLOW)Cleaning$(NO_COLOR)\n"
	@$(RM) -r $(CLEAN_TARGETS) .build-target
