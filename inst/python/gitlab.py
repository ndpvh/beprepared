import os
import sys
import urllib.request, base64

# Make sure we have a way to build the Module type
Module = type(urllib.request)

# Apparently, it is unsafe in Mac to use urllib as is. We need to put a system
# variable to "*" to avoid problems.
os.environ["no_proxy"] = "*"

# Create a class that will serve as an importer of the remote code of the people
# developing QVEmod. Done to ensure that we can use this code, as it is not 
# available nor structured as a Python package, meaning we cannot install it 
# directly.
class GitlabImporter:
    # This function takes in a remote directory and checks whether it has the 
    # correct number of arguments to potentially point to a repository
    def find_module(self, remote):
        # Split the remote in different parts. 
        parts = remote.split('.')

        # Perform a check
        if len(parts) < 3:
            raise ImportError('Gitlab imports must be of the form gitlab.<user>.<repo>.<etc>')
        
        return self

    # Once you have the remote, you can load it. 
    def load_module(self, remote):
        # Create a path out of the provided repository
        parts = remote.replace('gitlab.', '')
        print(parts)


        # Load module off Gitlab via urllib, which makes sure that the user and 
        # repository exist.
        url = 'https://git.wur.nl/' + path
        print("i am here")
        request = urllib.request.Request(url) 
        base64string = base64.b64encode(bytes('%s:%s' % ('login', 'password'), 'ascii'))
        request.add_header("Authorization", "Basic %s" % base64string.decode('utf-8'))
        with urllib.request.urlopen(request) as stream:
            code = stream.read()

        compiled_code = compile(code, url, 'exec')
        print("i am here")
        print(compiled_code)
        module = Module(parts)
        eval(compiled_code, locals=module.__dict__)
        return module

sys.meta_path.append(GitlabImporter())

# Load the QVEmod through the Gitlab repository
# import gitlab.bosch123.smallscalecorona as QVEmod