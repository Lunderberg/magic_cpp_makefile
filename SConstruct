# -*- python -*-

# ------------------- configuration section -------------------

build_dir = 'build'

bin_dir = 'bin'

lib_dir = 'lib'

source_file_globs = ['*.cc', '*.cpp', '*.cxx', '*.c++', '*.C++',
                     '*.c', '*.C']

# ------------------- implementation section -------------------

import os
import re
import subprocess
import sys

import SCons

def ansi_colors(env):
    env['RESET_COLOR'] = '\033[39;49m'

    env['BLUE']       = '\033[1;34m'
    env['YELLOW']     = '\033[1;33m'
    env['GREEN']      = '\033[1;32m'
    env['RED']        = '\033[1;31m'
    env['BLACK']      = '\033[1;30m'
    env['MAGENTA']    = '\033[1;35m'
    env['CYAN']       = '\033[1;36m'
    env['WHITE']      = '\033[1;37m'

    env['DBLUE']      = '\033[0;34m'
    env['DYELLOW']    = '\033[0;33m'
    env['DGREEN']     = '\033[0;32m'
    env['DRED']       = '\033[0;31m'
    env['DBLACK']     = '\033[0;30m'
    env['DMAGENTA']   = '\033[0;35m'
    env['DCYAN']      = '\033[0;36m'
    env['DWHITE']     = '\033[0;37m'

    env['BG_WHITE']   = '\033[47m'
    env['BG_RED']     = '\033[41m'
    env['BG_GREEN']   = '\033[42m'
    env['BG_YELLOW']  = '\033[43m'
    env['BG_BLUE']    = '\033[44m'
    env['BG_MAGENTA'] = '\033[45m'
    env['BG_CYAN']    = '\033[46m'

def brief_output(env):
    """
    Edits the various command strings printed to screen to be briefer.
    """
    env['CXXCOMSTR']    = '${DBLUE}Compiling C++ object ${DCYAN}${TARGETS}${RESET_COLOR}'
    env['CCCOMSTR']     = '${DBLUE}Compiling C object ${DCYAN}${TARGETS}${RESET_COLOR}'
    env['ARCOMSTR']     = '${DBLUE}Packing static library ${DCYAN}${TARGETS}${RESET_COLOR}'
    env['RANLIBCOMSTR'] = '${DBLUE}Indexing static library ${DCYAN}${TARGETS}${RESET_COLOR}'
    env['SHCCCOMSTR']   = '${DBLUE}Compiling shared C object ${DCYAN}${TARGETS}${RESET_COLOR}'
    env['SHCXXCOMSTR']  = '${DBLUE}Compiling shared C++ object ${DCYAN}${TARGETS}${RESET_COLOR}'
    env['LINKCOMSTR']   = '${DBLUE}Linking ${DCYAN}${TARGETS}${RESET_COLOR}'
    env['SHLINKCOMSTR'] = '${DBLUE}Linking shared ${DCYAN}${TARGETS}${RESET_COLOR}'

all_libs = []
def shared_library_dir(env, target=None, source=None, add_to_all_libs=True, dependencies=None):
    env = env.Clone()

    if source is None:
        source = target
        target = None

    source = Dir(source)

    if target is None:
        target = os.path.join(str(source), source.name)

    if dependencies is not None:
        dependencies = find_libraries(dependencies)
        for dep in dependencies:
            env.Append(**dep.attributes.usage)
        if dependencies:
            env.Append(RPATH=[Literal('\\$$ORIGIN')])

    if source.glob('include'):
        inc_dir = source.glob('include')[0]
    else:
        inc_dir = source
    inc_dir = inc_dir.RDirs('.')
    env.Append(CPPPATH=inc_dir)

    if source.glob('src'):
        src_dir = source.glob('src')[0]
    else:
        src_dir = source

    src_files = [src_dir.glob(g) for g in source_file_globs]

    shlib = env.SharedLibrary(target, src_files)[0]

    prefix = env.subst(env['SHLIBPREFIX'])
    suffix = env.subst(env['SHLIBSUFFIX'])
    shlib_name = shlib.name[len(prefix):-len(suffix)]

    shlib.attributes.usage = {
        'CPPPATH':inc_dir,
        'LIBPATH':[shlib.dir],
        'LIBS':[shlib_name],
        }

    env.Install(lib_dir, shlib)

    if add_to_all_libs:
        all_libs.append(shlib)

    return shlib


def find_libraries(lib_names):
    lib_names = [name.lower() for name in lib_names]

    output = []
    for shlib in all_libs:
        shlib_name = shlib.attributes.usage['LIBS'][0]
        if shlib_name.lower() in lib_names:
            output.append(shlib)

    return output


def python_library_dir(env, target=None, source=None, dependencies=None):
    if source is None:
        source = target
        target = None

    source = Dir(source)
    if target is None:
        lib_name = source.name
        if lib_name.startswith('py'):
            lib_name = lib_name[2:]
        target = os.path.join(str(source), lib_name)
    else:
        lib_name = os.path.splitext(os.path.split(str(target))[1])[0]

    if dependencies is None:
        dependencies = []
    dependencies.append(lib_name)

    py_env = env.Clone()
    py_env.Append(CPPPATH=get_pybind11_dir().Dir('include'))
    py_env.Append(CPPPATH=find_python_include(env.get('PYTHON_VERSION',None)))

    py_env['SHLIBPREFIX'] = ''

    return shared_library_dir(py_env, target, source,
                              add_to_all_libs=False, dependencies=dependencies)


def find_python_include(python_version = None):
    """
    Find the include directory for Python.h
    If python_version is specied, look for that one.
    Otherwise, search for python3, then python, then python2.
    """
    import distutils.spawn
    import subprocess

    if python_version is None:
        python_versions = ['python3','python','python2']
    else:
        python_versions = [python_version]

    for version in python_versions:
        exe = distutils.spawn.find_executable(version)
        if exe:
            break
    else:
        raise RuntimeError("Could not find python executable")

    output = subprocess.check_output([exe, '-c',
                                      'from distutils.sysconfig import get_python_inc;'
                                      'print (get_python_inc())'])
    return output[:-1] # remove training newline


def get_pybind11_dir():
    """
    Returns the directory to pybind11.
    If it already exists, just return.
    Otherwise, download it from github and unzip.
    """
    folder = dep_dir.Dir('pybind11-master')
    if folder.exists():
        return folder

    import urllib2
    import StringIO
    import zipfile
    response = urllib2.urlopen('https://github.com/pybind/pybind11/archive/master.zip')
    contents = StringIO.StringIO(response.read())
    zipped = zipfile.ZipFile(contents)
    members = [filename for filename in zipped.namelist()
               if 'include' in filename or 'LICENSE' in filename]
    zipped.extractall(str(dep_dir),members)

    return folder


def main_dir(env, main, inc_dir='include', src_dir='src'):
    main = Dir(main)

    inc_dir = main.Dir(inc_dir).RDirs('.')

    src_files = [main.Dir(src_dir).glob(g) for g in source_file_globs]
    main_files = [main.glob(g) for g in source_file_globs]

    env = env.Clone()
    env.Append(CPPPATH=inc_dir)
    env.Append(RPATH=[Literal(os.path.join('\\$$ORIGIN',
                                           bin_dir.rel_path(lib_dir)))])
    for shlib in all_libs:
        env.Append(**shlib.attributes.usage)

    progs = [env.Program([main_file] + src_files)
             for main_file in Flatten(main_files)]
    env.Install(bin_dir, progs)

    return progs


def compile_folder_dwim(env, base_dir):
    base_dir = Dir(base_dir)

    sconscript = base_dir.glob('SConscript')
    # The extra "base_dir != Dir('.')" is to prevent infinite
    # recursion, if a SConscript calls CompileFolderDWIM.
    if sconscript and base_dir != Dir('.'):
        env.SConscript(sconscript, exports=['env'])

    else:
        for dir in build_dir.glob('lib*'):
            if dir not in special_paths:
                env.SharedLibraryDir(dir)

        for dir in build_dir.glob('py*'):
            if dir not in special_paths:
                env.PythonLibraryDir(dir)

        env.MainDir(base_dir)

def default_environment():
    """
    The environment that is used to build everything.
    """
    env = Environment(ENV = os.environ)
    env['CPPPATH'] = []
    env['LIBPATH'] = []
    env['RPATH'] = []
    env['LIBS'] = []

    if 'VERBOSE' not in ARGUMENTS:
        brief_output(env)

    if 'NOCOLOR' not in ARGUMENTS:
        ansi_colors(env)

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

    if 'PYTHON_VERSION' in ARGUMENTS:
        env['PYTHON_VERSION'] = ARGUMENTS['PYTHON_VERSION']

    env.AddMethod(shared_library_dir, 'SharedLibraryDir')
    env.AddMethod(python_library_dir, 'PythonLibraryDir')
    env.AddMethod(main_dir, 'MainDir')
    env.AddMethod(compile_folder_dwim, 'CompileFolderDWIM')

    return env


env = default_environment()
env.VariantDir(build_dir,'.',duplicate=False)

build_dir = Dir(build_dir)
dep_dir = build_dir.Dir('.dependencies')

special_paths = [build_dir,
                 Dir(bin_dir),
                 Dir(lib_dir),
                 build_dir.Dir(bin_dir),
                 build_dir.Dir(lib_dir),
                 dep_dir,
]
bin_dir = Dir(bin_dir)
lib_dir = Dir(lib_dir)

env.CompileFolderDWIM(build_dir)

if bin_dir != Dir('.'):
    env.Clean('.',bin_dir)

if lib_dir != Dir('.'):
    env.Clean('.',lib_dir)
