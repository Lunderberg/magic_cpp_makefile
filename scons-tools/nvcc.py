"""SCons.Tool.nvcc

Tool-specific initialization for NVIDIA CUDA Compiler.

There normally shouldn't be any need to import this module directly.
It will usually be imported through the generic SCons.Tool.Tool()
selection method.
"""

import SCons.Tool
import SCons.Scanner.C
import SCons.Defaults
import os
import platform


CUDASuffixes = ['.cu']

# make a CUDAScanner for finding #includes
# cuda uses the c preprocessor, so we can use the CScanner
CUDAScanner = SCons.Scanner.C.CScanner()

def add_common_nvcc_variables(env):
  """
  Add underlying common "NVIDIA CUDA compiler" variables that
  are used by multiple builders.
  """

  # "NVCC common command line"
  if not env.has_key('_NVCCCOMCOM'):
    # nvcc needs '-I' prepended before each include path, regardless of platform
    env['_NVCCWRAPCPPPATH'] = '${_concat("-I ", CPPPATH, "", __env__)}'
    # prepend -Xcompiler before each flag
    env['_NVCCWRAPCFLAGS'] =     '${_concat("-Xcompiler ", CFLAGS,     "", __env__)}'
    env['_NVCCWRAPSHCFLAGS'] =   '${_concat("-Xcompiler ", SHCFLAGS,   "", __env__)}'
    env['_NVCCWRAPCCFLAGS'] =   '${_concat("-Xcompiler ", CCFLAGS,   "", __env__)}'
    env['_NVCCWRAPSHCCFLAGS'] = '${_concat("-Xcompiler ", SHCCFLAGS, "", __env__)}'
    # assemble the common command line
    env['_NVCCCOMCOM'] = '${_concat("-Xcompiler ", CPPFLAGS, "", __env__)} $_CPPDEFFLAGS $_NVCCWRAPCPPPATH'

def generate(env):
  """
  Add Builders and construction variables for CUDA compilers to an Environment.
  """

  if not exists(env):
    raise EnvironmentError('nvcc not present')


  # create a builder that makes PTX files from .cu files
  ptx_builder = SCons.Builder.Builder(action = '$NVCC -ptx $NVCCFLAGS $_NVCCWRAPCFLAGS $NVCCWRAPCCFLAGS $_NVCCCOMCOM $SOURCES -o $TARGET',
                                      emitter = {},
                                      suffix = '.ptx',
                                      src_suffix = CUDASuffixes)
  env['BUILDERS']['PTXFile'] = ptx_builder

  # create builders that make static & shared objects from .cu files
  static_obj, shared_obj = SCons.Tool.createObjBuilders(env)

  for suffix in CUDASuffixes:
    # Add this suffix to the list of things buildable by Object
    static_obj.add_action('$CUDAFILESUFFIX', '$NVCCCOM')
    shared_obj.add_action('$CUDAFILESUFFIX', '$SHNVCCCOM')
    static_obj.add_emitter(suffix, SCons.Defaults.StaticObjectEmitter)
    shared_obj.add_emitter(suffix, SCons.Defaults.SharedObjectEmitter)

    # Add this suffix to the list of things scannable
    SCons.Tool.SourceFileScanner.add_scanner(suffix, CUDAScanner)

  add_common_nvcc_variables(env)

  # set the "CUDA Compiler Command" environment variable
  # windows is picky about getting the full filename of the executable
  if os.name == 'nt':
    env['NVCC'] = 'nvcc.exe'
    env['SHNVCC'] = 'nvcc.exe'
  else:
    env['NVCC'] = 'nvcc'
    env['SHNVCC'] = 'nvcc'

  # set the include path, and pass both c compiler flags and c++ compiler flags
  env['NVCCFLAGS'] = SCons.Util.CLVar('')
  env['SHNVCCFLAGS'] = SCons.Util.CLVar('$NVCCFLAGS') + '-shared'

  # 'NVCC Command'
  env['NVCCCOM'] = '$NVCC -o $TARGET -c $NVCCFLAGS $_NVCCWRAPCFLAGS $NVCCWRAPCCFLAGS $_NVCCCOMCOM $SOURCES'
  env['SHNVCCCOM'] = '$SHNVCC -o $TARGET -c $SHNVCCFLAGS $_NVCCWRAPSHCFLAGS $_NVCCWRAPSHCCFLAGS $_NVCCCOMCOM $SOURCES'

  env['CUDAFILESUFFIX'] = '.cu'

  env.Append(LIBS = ['cuda', 'cudart'])
  env.Append(CPPDEFINES = ['CUDA_ENABLED'])

  env.AppendUnique(source_file_globs = ['*.cu'])

  try:
    architecture = env['cuda_architecture']
  except KeyError:
    architecture = 'sm_35'

  env.Append(NVCCFLAGS = ['-std=c++11', '-D_FORCE_INLINES',
                          '-arch={}'.format(architecture), '--expt-extended-lambda', '-m64'])

  cplusplus = getattr(SCons.Tool,'c++')
  cplusplus.CXXSuffixes.append('.cu')

def exists(env):
  return env.Detect('nvcc')
