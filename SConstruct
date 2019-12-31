# -*- python -*-

# ------------------- configuration section -------------------

build_dir = Dir('build')

# ------------------- implementation section -------------------

import imp
import os
import random
import re
import subprocess
import sys
import urllib2

import SCons

SCons.Warnings.suppressWarningClass(SCons.Warnings.DuplicateEnvironmentWarning)

def default_environment():
    """
    The environment that is used to build everything.
    """
    env = Environment(ENV = os.environ)
    env['CC'] = os.environ.get('CC', env['CC'])
    env['CXX'] = os.environ.get('CXX', env['CXX'])
    env['ENV'].update(val for val in os.environ.items() if val[0].startswith('CCC_'))

    env['bin_dir'] = Dir('bin')
    env['lib_dir'] = Dir('lib')
    env['pylib_dir'] = env['lib_dir']
    env['top_level'] = Dir('.')
    env.Append(source_file_globs = ['*.cc', '*.cpp', '*.cxx', '*.c++', '*.C++',
                                    '*.c', '*.C'])

    # Because scons behaves poorly if these aren't initialized as lists
    env['CPPPATH'] = []
    env['LIBPATH'] = []
    env['RPATH'] = []
    env['LIBS'] = []

    if 'VERBOSE' not in ARGUMENTS:
        brief_output(env)

    if 'NOCOLOR' not in ARGUMENTS:
        ansi_colors(env)

    # OSX errors if there are undefined symbols in a shared library.
    # This is not desirable, because the symbols could be present in a
    # different library, or in the main executable.
    if sys.platform=='darwin' and 'clang' in env['CC']:
        env.Append(SHLINKFLAGS=['-undefined','dynamic_lookup'])

    env.Append(CCFLAGS=['-pthread','-Wall','-Wextra','-pedantic'])
    env.Append(CXXFLAGS=['-std=c++14'])
    env.Append(LINKFLAGS=['-pthread'])


    if 'CODE_COVERAGE' in ARGUMENTS:
        env.Append(CPPFLAGS=['--coverage'])
        env.Append(LINKFLAGS=['--coverage'])
    elif 'OPTIMIZE' in ARGUMENTS:
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

    enable_system_header_support(env)

    env.AddMethod(shared_library_dir, 'SharedLibraryDir')
    env.AddMethod(python_library_dir, 'PythonLibraryDir')
    env.AddMethod(main_dir, 'MainDir')
    env.AddMethod(unit_test_dir, 'UnitTestDir')
    env.AddMethod(compile_folder_dwim, 'CompileFolderDWIM')
    env.AddMethod(irrlicht_lib, 'IrrlichtLib')
    env.AddMethod(is_special_dir, '_is_special_dir')
    env.AddMethod(glob_src_dir, 'GlobSrcDir')
    env.AddMethod(non_variant_dir, 'NonVariantDir')
    env.AddMethod(find_libraries, 'FindLibraries')

    return env

def enable_system_header_support(env):
    '''Add support for system headers

    System headers are useful, because no warnings are issued within
    them.  Implementation taken from
    http://scons-users.scons.narkive.com/Dzj1kRym/support-of-the-isystem-option-for-gcc
    '''
    # declare and use a new PATH variable for system headers : CPPSYSTEMPATH
    env['CPPSYSTEMPATH'] = []
    env['SYSTEMINCPREFIX'] = '-isystem '
    env['SYSTEMINCSUFFIX'] = ''
    env['_CPPSYSTEMINCFLAGS'] = '$( ${_concat(SYSTEMINCPREFIX,CPPSYSTEMPATH, SYSTEMINCSUFFIX, __env__, RDirs, TARGET, SOURCE)} $)'
    env['_CCCOMCOM'] += ' $_CPPSYSTEMINCFLAGS'
    # add this variable to the C scanner search path
    env['_CPPPATHS'] = ['$CPPPATH', '$CPPSYSTEMPATH']
    setattr(SCons.Tool.CScanner, 'path_function',
    SCons.Scanner.FindPathDirs('_CPPPATHS'))

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
    env['CCCOMSTR']     = '${DBLUE}Compiling C object ${DCYAN}${TARGETS}${RESET_COLOR}'
    env['CXXCOMSTR']    = '${DBLUE}Compiling C++ object ${DCYAN}${TARGETS}${RESET_COLOR}'
    env['NVCCCOMSTR']   = '${DBLUE}Compiling C++ CUDA object ${DCYAN}${TARGETS}${RESET_COLOR}'
    env['ARCOMSTR']     = '${DBLUE}Packing static library ${DCYAN}${TARGETS}${RESET_COLOR}'
    env['RANLIBCOMSTR'] = '${DBLUE}Indexing static library ${DCYAN}${TARGETS}${RESET_COLOR}'
    env['SHCCCOMSTR']   = '${DBLUE}Compiling shared C object ${DCYAN}${TARGETS}${RESET_COLOR}'
    env['SHCXXCOMSTR']  = '${DBLUE}Compiling shared C++ object ${DCYAN}${TARGETS}${RESET_COLOR}'
    env['SHNVCCCOMSTR'] = '${DBLUE}Compiling shared C++ CUDA object ${DCYAN}${TARGETS}${RESET_COLOR}'
    env['LINKCOMSTR']   = '${DBLUE}Linking ${DCYAN}${TARGETS}${RESET_COLOR}'
    env['SHLINKCOMSTR'] = '${DBLUE}Linking shared ${DCYAN}${TARGETS}${RESET_COLOR}'

all_libs = {}
def shared_library_dir(env, target=None, source=None, is_python_lib=False,
                       dependencies=None, requires=None, optional=None):
    if source is None:
        source = target
        target = None

    if optional is None:
        optional = []

    
    env = env.Clone()


    source = Dir(source)

    if target is None:
        lib_name = source.name
        if is_python_lib and lib_name.startswith('py'):
            lib_name = lib_name[2:]
        target = os.path.join(str(source), lib_name)
    else:
        lib_name = os.path.splitext(os.path.split(str(target))[1])[0]


    if is_python_lib:
        optional.append(lib_name)


    libs_before = len(env['LIBS'])
    transitive = add_dependencies(env, dependencies, requires, optional)
    depends_on_libs = (len(env['LIBS']) != libs_before)


    if depends_on_libs:
        from_dir = env['pylib_dir'] if is_python_lib else env['lib_dir']
        rel_path = from_dir.rel_path(env['lib_dir'])
        env.Append(RPATH=[Literal(os.path.join('\\$$ORIGIN',rel_path))])


    if is_python_lib:
        env.Append(CPPPATH=get_pybind11_dir().Dir('include'))
        env.Append(CPPPATH=find_python_include(env.get('PYTHON_VERSION',None)))
        env['SHLIBPREFIX'] = ''

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

    src_files = env.GlobSrcDir(src_dir)

    shlib = env.SharedLibrary(target, src_files)[0]

    prefix = env.subst(env['SHLIBPREFIX'])
    suffix = env.subst(env['SHLIBSUFFIX'])
    shlib_name = shlib.name[len(prefix):-len(suffix)]

    shlib.attributes.usage = {
        'CPPPATH':inc_dir + transitive['CPPPATH'],
        'CPPSYSTEMPATH': transitive['CPPSYSTEMPATH'],
        'CPPDEFINES': transitive['CPPDEFINES'],
        'LIBPATH':[shlib.dir],
        'LIBS':[shlib_name],
        }

    if is_python_lib:
        env.Install(env['pylib_dir'], shlib)
    else:
        env.Install(env['lib_dir'], shlib)
        all_libs[shlib_name.lower()] = shlib.attributes.usage

    return shlib


def find_libraries(env, lib_names, required=True):
    lib_names = [name.lower() for name in lib_names]

    output = []
    for lib_name in lib_names:
        try:
            lib = all_libs[lib_name]
        except KeyError:
            lib = download_compile_dependency(env, lib_name, required)
            if lib is None:
                lib = {}
            elif not isinstance(lib, dict):
                lib = lib.attributes.usage
            all_libs[lib_name] = lib

        if lib is not None:
            output.append(lib)

    return output


def download_compile_dependency(env, lib_name, required):
    disabled = ARGUMENTS.get('disable-{}'.format(lib_name), 0)
    if disabled:
        if required:
            raise RuntimeError('"{}" is a required library, and cannot be disabled'.format(lib_name))
        else:
            return None

    try:
        tool = download_tool(lib_name)
    except urllib2.HTTPError as e:
        if required:
            e.message = (e.message +
                         '\nCould not download required library "{}"'.format(lib_name))
            raise
        else:
            return None

    if not tool.exists(env):
        if required:
            raise RuntimeError('Cannot install "{}" library, missing requirements'.format(lib_name))
        else:
            return None

    return tool.generate(env)


def python_library_dir(env, target=None, source=None,
                       dependencies=None, requires=None, optional=None):
    return env.SharedLibraryDir(target, source, is_python_lib=True,
                                dependencies=dependencies,
                                requires=requires,
                                optional=optional)


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
    zipped.extractall(dep_dir.abspath,members)

    return folder


def unit_test_dir(env, target=None, source=None,
                  extra_inc_dir=None, extra_src_dir=None,
                  dependencies=None, requires=None, optional=None):
    env = env.Clone()
    add_dependencies(env, dependencies, requires, optional)

    if source is None:
        source = target
        target = None
    source = Dir(source)

    if target is None:
        target = os.path.join(str(source), 'run_tests')

    for dep in all_libs.values():
        env.Append(**dep)

    if all_libs:
        env.Append(RPATH=[Literal(os.path.join('\\$$ORIGIN',
                                               env['bin_dir'].rel_path(env['lib_dir'])))])

    googletest_dir = get_googletest_dir()
    env.Append(CPPPATH=googletest_dir.Dir('googletest').RDirs('.'))
    env.Append(CPPPATH=googletest_dir.Dir('googletest/include').RDirs('.'))

    src_files = env.GlobSrcDir(source)
    src_files.extend(googletest_dir.glob('main.cc'))
    src_files.extend(googletest_dir.glob('googletest/src/gtest-all.cc'))

    if extra_inc_dir is not None:
        env.Append(CPPPATH=Dir(extra_inc_dir).RDirs('.'))

    if extra_src_dir is not None:
        extra_src_dir = Dir(extra_src_dir)
        src_files.extend(env.GlobSrcDir(extra_src_dir))

    src_files = [env.Object(src.abspath) for src in Flatten(src_files)]
    prog = env.Program(target, src_files)
    env.Install(env['bin_dir'], prog)


def get_googletest_dir():
    folder = dep_dir.Dir('googletest-master')
    if folder.exists():
        return folder

    import urllib2
    import StringIO
    import zipfile
    response = urllib2.urlopen('https://github.com/google/googletest/archive/master.zip')
    contents = StringIO.StringIO(response.read())
    zipped = zipfile.ZipFile(contents)
    members = [filename for filename in zipped.namelist() if
               'googletest/include' in filename or
               'googletest/src' in filename or
               'googletest/LICENSE' in filename]
    zipped.extractall(dep_dir.abspath,members)

    with open(os.path.join(folder.abspath, 'main.cc'),'w') as f:
        f.write("""
                #include <gtest/gtest.h>

                int main(int argc, char** argv){
                  ::testing::InitGoogleTest(&argc, argv);
                  return RUN_ALL_TESTS();
                }""")

    return folder


def irrlicht_lib(env):
    env = env.Clone()

    irrlicht_dir = get_irrlicht_dir()

    inc_dir = irrlicht_dir.Dir('include')
    internal_inc_dir = [irrlicht_dir.Dir(dname) for dname in
                        ['source/Irrlicht/zlib', 'source/Irrlicht/jpeglib',
                         'source/Irrlicht/libpng']]

    src_dir = irrlicht_dir.Dir('source/Irrlicht')

    src_files = env.GlobSrcDir(src_dir)

    lzma_files = ['lzma/LzmaDec.c']
    zlib_files = ['zlib/adler32.c', 'zlib/compress.c', 'zlib/crc32.c', 'zlib/deflate.c',
                  'zlib/inffast.c', 'zlib/inflate.c', 'zlib/inftrees.c', 'zlib/trees.c',
                  'zlib/uncompr.c', 'zlib/zutil.c']
    jpeglib_files = ['jpeglib/jcapimin.c', 'jpeglib/jcapistd.c', 'jpeglib/jccoefct.c', 'jpeglib/jccolor.c',
                     'jpeglib/jcdctmgr.c', 'jpeglib/jchuff.c', 'jpeglib/jcinit.c', 'jpeglib/jcmainct.c',
                     'jpeglib/jcmarker.c', 'jpeglib/jcmaster.c', 'jpeglib/jcomapi.c', 'jpeglib/jcparam.c',
                     'jpeglib/jcprepct.c', 'jpeglib/jcsample.c', 'jpeglib/jctrans.c', 'jpeglib/jdapimin.c',
                     'jpeglib/jdapistd.c', 'jpeglib/jdatadst.c', 'jpeglib/jdatasrc.c', 'jpeglib/jdcoefct.c',
                     'jpeglib/jdcolor.c', 'jpeglib/jddctmgr.c', 'jpeglib/jdhuff.c', 'jpeglib/jdinput.c',
                     'jpeglib/jdmainct.c', 'jpeglib/jdmarker.c', 'jpeglib/jdmaster.c', 'jpeglib/jdmerge.c',
                     'jpeglib/jdpostct.c', 'jpeglib/jdsample.c', 'jpeglib/jdtrans.c', 'jpeglib/jerror.c',
                     'jpeglib/jfdctflt.c', 'jpeglib/jfdctfst.c', 'jpeglib/jfdctint.c', 'jpeglib/jidctflt.c',
                     'jpeglib/jidctfst.c', 'jpeglib/jidctint.c', 'jpeglib/jmemmgr.c', 'jpeglib/jmemnobs.c',
                     'jpeglib/jquant1.c', 'jpeglib/jquant2.c', 'jpeglib/jutils.c', 'jpeglib/jcarith.c',
                     'jpeglib/jdarith.c', 'jpeglib/jaricom.c']
    png_files = ['libpng/png.c', 'libpng/pngerror.c', 'libpng/pngget.c', 'libpng/pngmem.c',
                    'libpng/pngpread.c', 'libpng/pngread.c', 'libpng/pngrio.c', 'libpng/pngrtran.c',
                    'libpng/pngrutil.c', 'libpng/pngset.c', 'libpng/pngtrans.c', 'libpng/pngwio.c',
                    'libpng/pngwrite.c', 'libpng/pngwtran.c', 'libpng/pngwutil.c']
    aesGladman_files = ['aesGladman/aescrypt.cpp', 'aesGladman/aeskey.cpp', 'aesGladman/aestab.cpp', 'aesGladman/fileenc.cpp',
                'aesGladman/hmac.cpp', 'aesGladman/prng.cpp', 'aesGladman/pwd2key.cpp', 'aesGladman/sha1.cpp',
                'aesGladman/sha2.cpp']
    bzip2_files = ['bzip2/blocksort.c', 'bzip2/huffman.c', 'bzip2/crctable.c', 'bzip2/randtable.c',
                   'bzip2/bzcompress.c', 'bzip2/decompress.c', 'bzip2/bzlib.c']

    all_lib_files = [src_dir.File(f) for f in
                     Flatten([lzma_files, zlib_files, jpeglib_files, png_files, aesGladman_files, bzip2_files])]


    defines = {'IRRLICHT_EXPORTS': 1,
               'PNG_THREAD_UNSAFE_OK': '',
               'PNG_NO_MMX_CODE': '',
               'PNG_NO_MNG_FEATURES': '',
               }

    env.Append(CCFLAGS=['-w']) # Because irrlicht has too many warnings.
    env.Append(CPPPATH=[inc_dir,internal_inc_dir])
    env.Append(LIBS=['GL','Xxf86vm','Xext','X11','Xcursor'])
    env.Append(CPPDEFINES=defines)
    env.Append(CCFLAGS=['-U__STRICT_ANSI__'])

    shlib = env.SharedLibrary('Irrlicht', [src_files, all_lib_files])[0]

    shlib.attributes.usage = {
        'CPPSYSTEMPATH': [inc_dir],
        'LIBPATH': shlib.dir,
        'LIBS': ['Irrlicht'],
        'CPPDEFINES': defines,
        }
    all_libs['irrlicht'] = shlib.attributes.usage

    env.Install(env['lib_dir'], shlib)

    return shlib


def get_irrlicht_dir():
    folder = dep_dir.glob('irrlicht*')
    if folder:
        return folder[0]

    import urllib2
    import StringIO
    import zipfile
    response = urllib2.urlopen('https://downloads.sourceforge.net/project/irrlicht/Irrlicht%20SDK/1.8/1.8.4/irrlicht-1.8.4.zip')

    contents = StringIO.StringIO(response.read())
    zipped = zipfile.ZipFile(contents)

    members = [filename for filename in zipped.namelist() if
               'source/Irrlicht' in filename or
               'include' in filename or
               'license' in filename]
    zipped.extractall(dep_dir.abspath,members)

    return dep_dir.glob('irrlicht*')[0]


def add_dependencies(env, dependencies, requires, optional):
    if requires is None:
        requires = []
    elif isinstance(requires, str):
        requires = [requires]

    if optional is None:
        optional = []
    elif isinstance(optional, str):
        optional = [optional]

    if dependencies is not None:
        if isinstance(dependencies, str):
            requires.append(dependencies)
        else:
            requires.extend(dependencies)

    transitive = {'CPPPATH': [],
                  'CPPSYSTEMPATH': [],
                  'CPPDEFINES': [],
                  }

    requires = find_libraries(env, requires, required=True)
    optional = find_libraries(env, optional, required=False)
    for dep in requires+optional:
        env.Append(**dep)
        for key in transitive:
            if key in dep:
                transitive[key].extend(dep[key])

    return transitive





def main_dir(env, main, inc_dir='include', src_dir='src',
             dependencies=None, requires=None, optional=None):
    env = env.Clone()
    add_dependencies(env, dependencies, requires, optional)

    main = Dir(main)

    inc_dir = main.Dir(inc_dir).RDirs('.')

    src_files = env.GlobSrcDir(main.Dir(src_dir))
    main_files = env.GlobSrcDir(main)

    env.Append(CPPPATH=inc_dir)
    env.Append(RPATH=[Literal(os.path.join('\\$$ORIGIN',
                                           env['bin_dir'].rel_path(env['lib_dir'])))])
    for shlib in all_libs.values():
        env.Append(**shlib)

    progs = [env.Program([main_file] + src_files)
             for main_file in Flatten(main_files)]
    env.Install(env['bin_dir'], progs)

    return progs


def compile_folder_dwim(env, base_dir,
                        dependencies=None, requires=None, optional=None):
    base_dir = Dir(base_dir)

    sconscript = base_dir.glob('SConscript')
    # The extra "base_dir != Dir('.')" is to prevent infinite
    # recursion, if a SConscript calls CompileFolderDWIM.
    if sconscript and base_dir != Dir('.'):
        env_bak = env
        env = env.Clone()
        add_dependencies(env, dependencies, requires, optional)
        output = env.SConscript(sconscript, exports=['env'])
        env = env_bak
        try:
            shlib_name = output.attributes.usage['LIBS'][0]
        except (AttributeError,IndexError):
            pass
        else:
            env.Install(lib_dir, output)
            all_libs[shlib_name.lower()] = output.attributes.usage



    else:
        for dir in base_dir.glob('lib*'):
            if not env._is_special_dir(dir):
                env.SharedLibraryDir(dir, dependencies=dependencies, requires=requires, optional=optional)

        for dir in base_dir.glob('py*'):
            if not env._is_special_dir(dir):
                env.PythonLibraryDir(dir, dependencies=dependencies, requires=requires, optional=optional)

        env.MainDir(base_dir, dependencies=dependencies, requires=requires, optional=optional)

        if base_dir.glob('tests'):
            env.UnitTestDir(base_dir.glob('tests')[0],
                            extra_inc_dir=base_dir.Dir('include'),
                            extra_src_dir=base_dir.Dir('src'),
                            dependencies=dependencies, requires=requires, optional=optional,
            )

def is_special_dir(env, query):
    query = Dir(query)
    top_level = env['top_level']
    bin_dir = env['bin_dir']
    lib_dir = env['lib_dir']

    special_paths = [build_dir,
                     dep_dir,
                     bin_dir,
                     lib_dir,
                     ]

    if bin_dir.is_under(top_level):
        special_paths.append(build_dir.Dir(top_level.rel_path(bin_dir)))
    if lib_dir.is_under(top_level):
        special_paths.append(build_dir.Dir(top_level.rel_path(lib_dir)))

    return query in special_paths

def download_tool(tool_name):
    # If scons-tools is present, use it instead of downloading a copy.
    output_file = File('#/scons-tools/{}.py'.format(tool_name)).abspath
    if os.path.exists(output_file):
        return open_module(output_file)

    # If a downloaded copy exists, use it.
    output_dir = dep_dir.Dir('scons-tools').abspath
    output_file = '{}/{}.py'.format(output_dir,tool_name)
    if os.path.exists(output_file):
        return open_module(output_file)

    # Otherwise, download the tool.
    import urllib2
    full_path = ('https://raw.githubusercontent.com/Lunderberg/'
                 'magic_cpp_makefile/master/scons-tools/'
                 '{}.py').format(tool_name)
    resp = urllib2.urlopen(full_path)


    if not os.path.exists(output_dir):
        os.makedirs(output_dir)


    with open(output_file,'wb') as f:
        f.write(resp.read())

    return open_module(output_file)

def open_module(filename):
    dummy_name = ''.join(random.choice('abcdefghijklmnopqrstuvwxyz')
                         for _ in range(10))
    return imp.load_source(dummy_name, filename)

def glob_src_dir(env, dir):
    result = Flatten([dir.glob(g) for g in env['source_file_globs']])
    return Flatten([dir.glob(g) for g in env['source_file_globs']])

def non_variant_dir(env, dir):
    return Dir(dir).RDirs('.')[-1]

env = default_environment()

env.VariantDir(build_dir,'.',duplicate=False)
dep_dir = build_dir.Dir('.dependencies')
env['dep_dir'] = dep_dir

env.CompileFolderDWIM(build_dir)
