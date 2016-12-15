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


def apply_py_dir(lib_env, py_dir, shared_libs, pybind11_dir, lib_name = None):
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
    py_env.Append(CPPPATH=pybind11_dir.Dir('include'))
    py_env.Append(CPPPATH=py_dir.Dir('include'))
    for dep in dependencies:
        py_env.Append(**dep.attributes.usage)

    if dependencies:
        py_env.Append(RPATH=[Literal(os.path.join('\\$$ORIGIN'))])

    py_env.Append(CPPPATH=find_python_include(lib_env.get('PYTHON_VERSION',None)))
    py_env['SHLIBPREFIX'] = ''

    return apply_lib_dir(py_env, py_dir, lib_name)


def get_pybind11_dir(build_dir):
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

    return build_dir.glob('pybind11-*')[0]


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
pybind11_dir = get_pybind11_dir(build_dir)

special_paths = [build_dir,
                 bin_dir,
                 lib_dir,
                 pybind11_dir,
]

env = default_environment()
lib_env = env.Clone()
env.VariantDir(build_dir,'.',duplicate=False)

lib_directories = [build_dir.Dir(f.name) for f in Glob('lib*')
                   if f not in special_paths]
shared_libs = [apply_lib_dir(lib_env,lib) for lib in lib_directories]

for shlib in shared_libs:
    # action = env.AddPreAction(shlib, Action('echo Before {}'.format(shlib),strfunction = lambda *args:''))
    # action = env.AddPostAction(shlib, Action('echo After {}'.format(shlib),strfunction = lambda *args:''))
    env.Append(**shlib.attributes.usage)


py_directories = [build_dir.Dir(f.name) for f in Glob('py*')
                  if f not in special_paths]
py_libs = [apply_py_dir(lib_env,py_dir,shared_libs,pybind11_dir) for py_dir in py_directories]

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


class PrettyWrapper(object):
    def __init__(self, env, com):
        self.cmd = [env[com]]

    def __call__(self, target, source, env):
        print 'Making {} from {}'.format(target,source)
        shell = env['SHELL']
        escape = env.get('ESCAPE', lambda x:x)
        passing_env = env['ENV']
        cmd = env.subst_list([self.cmd], 0, target, source)
        import IPython; IPython.embed()

def temp(sh, escape, cmd, args, spawnenv):
    print 'cmd=',cmd
    print 'args=',args
#env['SPAWN'] = temp
#import IPython; IPython.embed()

#env['CXXCOM'] = PrettyWrapper(env, 'CXXCOM')
#import pudb; pudb.set_trace()
