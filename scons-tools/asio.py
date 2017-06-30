

def exists(env):
    return True

def generate(env):
    inc_dir = env['dep_dir'].Dir('asio-1.10.6/include')

    usage = {'CPPDEFINES': ['ASIO_STANDALONE'],
             'CPPSYSTEMPATH': [inc_dir],
             }

    if inc_dir.exists():
        return usage

    import urllib2
    import StringIO
    import zipfile

    response = urllib2.urlopen('https://downloads.sourceforge.net/project/'
                               'asio/asio/1.10.6%20%28Stable%29/asio-1.10.6.zip')
    contents = StringIO.StringIO(response.read())
    zipped = zipfile.ZipFile(contents)

    members = [filename for filename in zipped.namelist() if
               'LICENSE' in filename or
               'include' in filename]
    zipped.extractall(env['dep_dir'].abspath, members)

    return usage
