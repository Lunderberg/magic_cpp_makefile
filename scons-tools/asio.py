import io
import urllib
import zipfile

def exists(env):
    return True

def generate(env):
    inc_dir = env['dep_dir'].Dir('asio-1.10.6/include')

    usage = {'CPPDEFINES': ['ASIO_STANDALONE'],
             'CPPSYSTEMPATH': [inc_dir],
             }

    if inc_dir.exists():
        return usage


    response = urllib.request.urlopen(
        'https://downloads.sourceforge.net/project/'
        'asio/asio/1.10.6%20%28Stable%29/asio-1.10.6.zip')
    contents = io.BytesIO(response.read())
    zipped = zipfile.ZipFile(contents)

    members = [filename for filename in zipped.namelist() if
               'LICENSE' in filename or
               'include' in filename]
    zipped.extractall(env['dep_dir'].abspath, members)

    return usage
