import io
import urllib
import zipfile

def exists(env):
    return True

def generate(env):
    asio_usage = env.FindLibraries(['asio'])[0]

    inc_dir = env['dep_dir'].Dir('eweb-master/include')
    usage = {'CPPPATH': [inc_dir],
             }

    for key,value in asio_usage.items():
        if key in usage:
            usage[key].extend(value)
        else:
            usage[key] = value[:]

    if inc_dir.exists():
        return usage


    response = urllib.request.urlopen('https://github.com/Lunderberg/eweb/archive/master.zip')
    contents = io.BytesIO(response.read())
    zipped = zipfile.ZipFile(contents)
    members = [filename for filename in zipped.namelist()
               if 'eweb-master/include/' in filename]
    zipped.extractall(env['dep_dir'].abspath, members)

    return usage
