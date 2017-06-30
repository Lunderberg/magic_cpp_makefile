Import('env')

env.OptionalCUDA()
#env.CompileFolderDWIM('.')

env.SharedLibraryDir('libLibraryA')
env.SharedLibraryDir('libLibraryB')
env.SharedLibraryDir('libmixed_cpu_and_gpu', requires='cuda')
env.PythonLibraryDir('pyLibraryA')
env.UnitTestDir('tests',
                extra_inc_dir='include',
                extra_src_dir='src')
env.MainDir('.')
