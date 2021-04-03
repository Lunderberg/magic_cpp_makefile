import os
import urllib

def exists(env):
    return True

def generate(env):
    inc_dir = env['dep_dir'].Dir('CLI11')

    usage = {'CPPSYSTEMPATH': [inc_dir],
             }

    if inc_dir.exists():
        return usage


    response = urllib.request.urlopen(
        'https://github.com/CLIUtils/CLI11/releases/download/'
        'v1.1.0/CLI11.hpp')
    contents = response.read()

    os.makedirs(str(inc_dir))
    filename = os.path.join(str(inc_dir), 'CLI11.hpp')
    with open(filename, 'w') as f:
        f.write(contents)

    return usage
