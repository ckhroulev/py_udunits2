from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import numpy
import os

# If the user set GSL_PREFIX, use it. Otherwise check some standard locations.
prefix = ""
try:
    prefix = os.environ['UDUNITS2_PREFIX']
except:
    print "Environment variable UDUNITS2_PREFIX not set. Trying known locations..."
    prefixes = ["/usr/", "/usr/local/", "/opt/local/", "/sw/"]

    for path in prefixes:
        print "Checking '%s'..." % path
        try:
            os.stat(path + "include/udunits2/udunits2.h")
            prefix = path
            print "Found UDUNITS-2 in '%s'" % prefix
            break
        except:
            pass

if prefix == "":
    print "Could not find UDUNITS-2. Stopping..."
    import sys
    sys.exit(1)


# If the user set NO_OPENMP, proceed with these options. Otherwise add options GCC uses.
libraries=['udunits2']
extra_compile_args=["-Wall", "-Wno-self-assign"]

# Define the extension
extension = Extension("udunits2",
                      sources=["udunits2.pyx",
                               ],
                      include_dirs=[numpy.get_include(), 'src', prefix + '/include'],
                      library_dirs=[prefix + "/lib"],
                      libraries=libraries,
                      extra_compile_args=extra_compile_args,
                      language="c")

setup(
    name = "udunits2",
    version = "0.1.0",
    description = "Python UDUNITS-2 wrapper",
    long_description = """
    UDUNITS-2 Python wrapper""",
    author = "Constantine Khroulev",
    author_email = "ckhroulev@alaska.edu",
    url = "https://github.com/ckhroulev/py_udunits2",
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Environment :: Console',
        'Environment :: X11 Applications',
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: GNU General Public License (GPL)',
        'Operating System :: MacOS :: MacOS X',
        'Operating System :: POSIX',
        'Programming Language :: C++',
        'Programming Language :: Cython',
        'Programming Language :: Python',
        'Topic :: Scientific/Engineering',
        'Topic :: Utilities'
          ],
    cmdclass = {'build_ext': build_ext},
    ext_modules = [extension]
    )
