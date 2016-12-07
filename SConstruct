# -*- python -*-

build_dir = 'build'

bin_dir = 'bin'

lib_dir = 'lib'

file_extensions = ['cc','cpp','cxx','c++','C++',
                   'c','C']

import os

env = Environment(ENV = os.environ)

env['CPPPATH'] = []
env['LIBPATH'] = []
env['RPATH'] = []
env['LIBS'] = []

# More readable output
if not ARGUMENTS.get('VERBOSE'):
    env['CXXCOMSTR'] = 'Compiling C++ object $TARGETS'
    env['CCCOMSTR'] = 'Compiling C object $TARGETS'
    env['ARCOMSTR'] = 'Packing static library $TARGETS'
    env['RANLIBCOMSTR'] = 'Indexing static library $TARGETS'
    env['SHCCCOMSTR'] = 'Compiling shared C object $TARGETS'
    env['SHCXXCOMSTR'] = 'Compiling shared C++ object $TARGETS'
    env['LINKCOMSTR'] = 'Linking $TARGETS'
    env['SHLINKCOMSTR'] = 'Linking shared $TARGETS'



def glob_all_in_dir(path):
    path = str(path)
    output = []
    for ext in file_extensions:
        output.extend(Glob(os.path.join(path,'*.{}'.format(ext))))
    return output

def apply_lib_dir(env, lib_env, lib_dir):
    src_dir = os.path.join(str(lib_dir),'src')
    inc_dir = os.path.join(str(lib_dir),'include')
    src_files = glob_all_in_dir(src_dir)

    cpppath = lib_env['CPPPATH'] + [inc_dir]
    env.Append(CPPPATH=[inc_dir])
    shlib = lib_env.SharedLibrary(src_files, CPPPATH=cpppath)[0]
    env.Append(LIBPATH=[shlib.dir])
    env.Append(LIBS=[shlib.name])

    return shlib

env.VariantDir(build_dir,'.',duplicate=False)

lib_directories = Glob(os.path.join(build_dir,'lib?*'))
lib_env = env.Clone()
shared_libs = [apply_lib_dir(env,lib_env,lib) for lib in lib_directories]

src_files = glob_all_in_dir(os.path.join(build_dir,'src'))
exe_files = glob_all_in_dir(os.path.join(build_dir,'.'))
env.Append(CPPPATH=['include'])
env.Append(RPATH=[Literal(os.path.join('\\$$ORIGIN','..',lib_dir))])

progs = [env.Program([exe_file,src_files]) for exe_file in exe_files]

env.Install(lib_dir,shared_libs)
env.Install(bin_dir,progs)

env.Clean('.',build_dir)
env.Clean('.',bin_dir)
env.Clean('.',lib_dir)
