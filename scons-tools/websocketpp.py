import io
import urllib
import zipfile

def exists(env):
    return True

def generate(env):
    asio_usage = env.FindLibraries(['asio'])[0]

    inc_dir = env['dep_dir'].Dir('websocketpp-master')
    usage = asio_usage
    usage['CPPSYSTEMPATH'].append(inc_dir)

    if inc_dir.exists():
        return usage


    response = urllib.request.urlopen('https://github.com/zaphoyd/websocketpp/archive/master.zip')
    contents = io.BytesIO(response.read())
    zipped = zipfile.ZipFile(contents)
    members = [filename for filename in zipped.namelist()
               if 'websocketpp-master/websocketpp/' in filename or 'COPYING' in filename]
    zipped.extractall(env['dep_dir'].abspath, members)

    return usage
