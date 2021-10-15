from setuptools import setup
from Cython.Build import cythonize

setup(
    ext_modules = cythonize("vtk_room_fuentes.pyx",language_level = "3")
)