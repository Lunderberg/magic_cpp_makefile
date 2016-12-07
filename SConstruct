# -*- python -*-

# ------------------- configuration section -------------------

build_dir = 'build'

bin_dir = 'bin'

lib_dir = 'lib'

source_file_extensions = ['cc','cpp','cxx','c++','C++',
                          'c','C']

# ------------------- implementation section -------------------

import os

import SCons

def brief_output(env):
    """
    Edits the various command strings printed to screen to be briefer.
    """
    env['CXXCOMSTR'] = 'Compiling C++ object $TARGETS'
    env['CCCOMSTR'] = 'Compiling C object $TARGETS'
    env['ARCOMSTR'] = 'Packing static library $TARGETS'
    env['RANLIBCOMSTR'] = 'Indexing static library $TARGETS'
    env['SHCCCOMSTR'] = 'Compiling shared C object $TARGETS'
    env['SHCXXCOMSTR'] = 'Compiling shared C++ object $TARGETS'
    env['LINKCOMSTR'] = 'Linking $TARGETS'
    env['SHLINKCOMSTR'] = 'Linking shared $TARGETS'

def glob_all_in_dir(path):
    """
    Given a path, find all source files in that directory.
    """
    path = str(path)
    output = []
    for ext in source_file_extensions:
        output.extend(Glob(os.path.join(path,'*.{}'.format(ext))))
    return output

def apply_lib_dir(env, lib_env, lib_dir, lib_name = None):
    """
    Apply all actions needed, given a particular library directory.
    Returns the shared library that was made.
    """
    src_dir = os.path.join(str(lib_dir),'src')
    inc_dir = os.path.join(str(lib_dir),'include')
    src_files = glob_all_in_dir(src_dir)

    if lib_name is None:
        lib_name = lib_dir.name

    cpppath = lib_env['CPPPATH'] + [inc_dir]
    env.Append(CPPPATH=[inc_dir])
    shlib = lib_env.SharedLibrary(
        os.path.join(str(lib_dir),lib_name),
        src_files, CPPPATH=cpppath)

    env.Append(LIBPATH=[shlib[0].dir])
    env.Append(LIBS=[shlib[0].name])

    return shlib

def default_environment():
    env = Environment(ENV = os.environ)
    env['CPPPATH'] = []
    env['LIBPATH'] = []
    env['RPATH'] = []
    env['LIBS'] = []
    if 'VERBOSE' not in ARGUMENTS:
        brief_output(env)

    env.Append(CCFLAGS=['-pthread','-Wall','-Wextra','-pedantic'])
    env.Append(CXXFLAGS=['-std=c++14'])
    env.Append(LINKFLAGS=['-pthread'])

    if 'OPTIMIZE' in ARGUMENTS:
        env.Append(CCFLAGS=['-O'+ARGUMENTS['OPTIMIZE']])
    else:
        env.Append(CCFLAGS=['-O3'])

    if 'RELEASE' in ARGUMENTS and ARGUMENTS['RELEASE'] != '0':
        env.Append(CPPDEFINES=['NDEBUG'])
        env.Append(CPPFLAGS=['-s'])
    else:
        env.Append(CPPFLAGS=['-g'])

    return env


special_paths = [build_dir, bin_dir, lib_dir]

env = default_environment()
lib_env = env.Clone()

env.VariantDir(build_dir,'.',duplicate=False)

lib_directories = [f for f in Glob(os.path.join(build_dir,'lib*'))
                   if isinstance(f, SCons.Node.FS.Dir) and f.name not in special_paths]
shared_libs = [apply_lib_dir(env,lib_env,lib) for lib in lib_directories]

src_files = glob_all_in_dir(os.path.join(build_dir,'src'))
exe_files = glob_all_in_dir(os.path.join(build_dir,'.'))
env.Append(CPPPATH=['include'])
env.Append(RPATH=[Literal(os.path.join('\\$$ORIGIN',
                                       os.path.relpath(bin_dir,lib_dir)))])

progs = [env.Program([exe_file,src_files]) for exe_file in exe_files]

env.Install(lib_dir,shared_libs)
env.Install(bin_dir,progs)

for path in special_paths:
    if path != '.':
        env.Clean('.',path)
