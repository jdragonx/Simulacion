from setuptools import setup
from Cython.Build import cythonize

setup(
    ext_modules = cythonize("figures.pyx",language_level = "3")
)