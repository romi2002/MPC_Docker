import setuptools
from Cython.Build import cythonize
from pathlib import Path
import os

with open("README.md", 'r') as f:
    long_description = f.read()

parent_path = "/tmp/fatrop/"

fatrop_extension = setuptools.Extension(
    name="fatrop.fatropy",
    sources=["src/fatrop/fatropy/fatropy.pyx"],
    libraries=["fatrop"],
    library_dirs=["../build/fatrop"],
    runtime_library_dirs=["/usr/local/lib"],
    include_dirs=[f"{parent_path}/fatrop/ocp",f"{parent_path}/fatrop/aux",f"{parent_path}/fatrop/solver",f"{parent_path}/fatrop/blasfeo_wrapper",f"{parent_path}/fatrop/templates",f"{parent_path}/fatrop", "/opt/blasfeo/include", f"{parent_path}/external/blasfeo/include","src/fatrop/fatropy"],
    language="c++",
    define_macros=[("LEVEL1_DCACHE_LINE_SIZE","64")]
)
setuptools.setup(
    package_dir={"": "src"},
    long_description=long_description,
    packages=setuptools.find_namespace_packages(where='src'),
    ext_modules=cythonize([fatrop_extension],compiler_directives={'language_level' : "3"})
)
