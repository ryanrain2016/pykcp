from setuptools import setup, Extension
from Cython.Build import cythonize

ext = Extension("pykcp.ckcp",
        sources = ["pykcp/ckcp.pyx", "pykcp/ikcp.c"],
        )

core = cythonize(ext)

setup(
        name = "pykcp",
        version = '0.1',
        packages = ["pykcp"],
        description = "python binds for skywind3000's kcp",
        author = "ryan",
        license = "GPL",
        keywords=["kcp", "python"],
        ext_modules = core,
)