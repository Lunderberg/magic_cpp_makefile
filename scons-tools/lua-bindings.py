import io
import os
import urllib
import zipfile

def exists(env):
    return True

def generate(env):
    inc_dir = env['dep_dir'].Dir('lua-bindings/include/lua-bindings')

    if not inc_dir.exists():
        url = 'https://github.com/Lunderberg/lua-bindings/archive/master.zip'
        response = urllib.request.urlopen(url)
        contents = io.BytesIO(response.read())
        zipped = zipfile.ZipFile(contents)
        members = [filename for filename in zipped.namelist()
                   if '/tests/' not in filename and '/doc/' not in filename]
        zipped.extractall(env['dep_dir'].abspath, members)
        os.rename(env['dep_dir'].Dir('lua-bindings-master').abspath,
                  env['dep_dir'].Dir('lua-bindings').abspath)


    sconscript = env['dep_dir'].File('lua-bindings/SConscript_lib_only')
    usage = env.SConscript(sconscript, 'env')
    return usage
