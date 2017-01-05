# -*- python -*-

# ------------------- configuration section -------------------

build_dir = 'build'

bin_dir = 'bin'

lib_dir = 'lib'

source_file_extensions = ['cc','cpp','cxx','c++','C++',
                          'c','C']

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

class BufferSpawn(object):
    def __init__(self):
        self.stdout = ''

    def __call__(self, sh, escape, cmd, args, spawnenv):
        asciienv = {key:str(value) for key,value in spawnenv.items()}

        # Call a subprocess, grabbing all output
        p = subprocess.Popen(
            ' '.join(args),
            shell=True,
            env=asciienv,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True)
        stdout,stderr = p.communicate()

        self.stdout = stdout

        return p.returncode

class CommandWrapper(object):
    _null = SCons.Action._null

    def __init__(self, env, com, comstr):
        self.overrides = {com:env[com],
                          #comstr:env[comstr],
                          }
        self.action = SCons.Action.Action('$'+com, '$'+comstr)
        self.pad_to = 75

    def __call__(self, target, source, env,
                               exitstatfunc=_null,
                               presub=_null,
                               show=_null,
                               execute=_null,
                               chdir=_null,
                               executor=None):
        # Generate the environment for the subordinate action
        overrides = self.overrides.copy()
        spawn = BufferSpawn()
        overrides['SPAWN'] = spawn
        env = env.Override(overrides)

        # Generate the status message to be printed
        try:
            to_print = self.action.strfunction(target, source, env, executor)
        except TypeError:
            to_print = self.action.strfunction(target, source, env)

        ansi_regex = re.compile(r'\033\[[;\d]*[A-Za-z]')
        num_ansi_chars = sum(len(ansi_escape) for ansi_escape in
                             ansi_regex.findall(to_print))

        to_print = to_print.ljust(self.pad_to + num_ansi_chars)

        # Print the before-command status
        #print '\033[A' + to_print + '\r',
        print '\033[A',
        sys.stdout.flush()

        # Run the command, without printing anything.
        show = False
        retval = self.action(target, source, env, exitstatfunc,
                             presub, show, execute, chdir, executor)

        # Figure out the change to the status message
        if retval:
            print_result = env.subst('${RED}[ERROR]${RESET_COLOR}')
        elif spawn.stdout:
            print_result = env.subst('${YELLOW}[WARNING]${RESET_COLOR}')
        else:
            print_result = env.subst('${GREEN}[OK]${RESET_COLOR}')

        # Print the after-command status, and the stdout, if any
        print '\r' + to_print + print_result
        if spawn.stdout:
            print spawn.stdout.strip()
        sys.stdout.flush()

def pretty_status(env):
    env['ARCOM'] = CommandWrapper(env, 'ARCOM', 'ARCOMSTR')
    env['CCCOM'] = CommandWrapper(env, 'CCCOM', 'CCCOMSTR')
    env['CXXCOM'] = CommandWrapper(env, 'CXXCOM', 'CXXCOMSTR')
    env['LINKCOM'] = CommandWrapper(env, 'LINKCOM', 'LINKCOMSTR')
    env['SHCCCOM'] = CommandWrapper(env, 'SHCCCOM', 'SHCCCOMSTR')
    env['SHCXXCOM'] = CommandWrapper(env, 'SHCXXCOM', 'SHCXXCOMSTR')
    env['SHLINKCOM'] = CommandWrapper(env, 'SHLINKCOM', 'SHLINKCOMSTR')

def glob_all_in_dir(path):
    """
    Given a path, find all source files in that directory.
    """
    output = []
    for ext in source_file_extensions:
        output.extend(path.glob('*.{}'.format(ext)))
    return output

def apply_lib_dir(lib_env, lib_dir, lib_name = None):
    """
    Apply all actions needed, given a particular library directory.
    Returns the shared library that was made.
    """
    inc_dir = lib_dir.glob('include')
    inc_dir = [d.RDirs('.') for d in inc_dir]

    src_files = glob_all_in_dir(lib_dir.Dir('src'))

    if lib_name is None:
        lib_name = lib_dir.name

    cpppath = lib_env['CPPPATH'] + [inc_dir]
    shlib = lib_env.SharedLibrary(
        os.path.join(str(lib_dir),lib_name),
        src_files, CPPPATH=cpppath)[0]

    shlib.attributes.usage = {
        'CPPPATH':[inc_dir],
        'LIBPATH':[shlib.dir],
        'LIBS':[shlib.name]
    }

    return shlib

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


def apply_py_dir(lib_env, py_dir, shared_libs, lib_name = None):
    """
    Apply all actions needed, given a directory to be made into a python library.
    Returns the shared library that was made.
    """
    if lib_name is None:
        lib_name = py_dir.name
        if lib_name.startswith('py'):
            lib_name = lib_name[2:]


    dependencies = []
    prefix = lib_env.subst(lib_env['SHLIBPREFIX'])
    suffix = lib_env.subst(lib_env['SHLIBSUFFIX'])
    for shlib in shared_libs:
        if (shlib.name.startswith(prefix) and
            shlib.name.endswith(suffix)):
            name = shlib.name[len(prefix):-len(suffix)]
            if name.lower() == lib_name.lower():
                dependencies.append(shlib)

    py_env = lib_env.Clone()
    py_env.Append(CPPPATH=get_pybind11_dir().Dir('include'))
    py_env.Append(CPPPATH=py_dir.Dir('include'))
    for dep in dependencies:
        py_env.Append(**dep.attributes.usage)

    if dependencies:
        py_env.Append(RPATH=[Literal(os.path.join('\\$$ORIGIN'))])

    py_env.Append(CPPPATH=find_python_include(lib_env.get('PYTHON_VERSION',None)))
    py_env['SHLIBPREFIX'] = ''

    return apply_lib_dir(py_env, py_dir, lib_name)


def get_pybind11_dir():
    """
    Returns the directory to pybind11.
    If it already exists, just return.
    Otherwise, download it from github and unzip.
    """
    folder = build_dir.glob('pybind11-master')
    if folder:
        return folder[0]

    import urllib2
    import StringIO
    import zipfile
    response = urllib2.urlopen('https://github.com/pybind/pybind11/archive/master.zip')
    contents = StringIO.StringIO(response.read())
    zipped = zipfile.ZipFile(contents)
    members = [filename for filename in zipped.namelist()
               if 'include' in filename or 'LICENSE' in filename]
    zipped.extractall(str(build_dir),members)

    return build_dir.glob('pybind11-master')[0]


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

    if 'NOANSI' not in ARGUMENTS:
        pretty_status(env)

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

    return env


build_dir = Dir(build_dir)
bin_dir = Dir(bin_dir)
lib_dir = Dir(lib_dir)

special_paths = [build_dir,
                 bin_dir,
                 lib_dir,
]

env = default_environment()
lib_env = env.Clone()
env.VariantDir(build_dir,'.',duplicate=False)

lib_directories = [build_dir.Dir(f.name) for f in Glob('lib*')
                   if f not in special_paths]
shared_libs = [apply_lib_dir(lib_env,lib) for lib in lib_directories]

for shlib in shared_libs:
    env.Append(**shlib.attributes.usage)

py_directories = [build_dir.Dir(f.name) for f in Glob('py*')
                  if f not in special_paths]
py_libs = [apply_py_dir(lib_env,py_dir,shared_libs) for py_dir in py_directories]

src_files = glob_all_in_dir(build_dir.Dir('src'))
exe_files = glob_all_in_dir(build_dir)
env.Append(CPPPATH=['include'])
env.Append(RPATH=[Literal(os.path.join('\\$$ORIGIN',
                                       bin_dir.rel_path(lib_dir)))])

progs = [env.Program([exe_file,src_files]) for exe_file in exe_files]

env.Install(lib_dir,shared_libs)
env.Install(lib_dir,py_libs)
env.Install(bin_dir,progs)

if bin_dir != Dir('.'):
    env.Clean('.',bin_dir)

if lib_dir != Dir('.'):
    env.Clean('.',lib_dir)
