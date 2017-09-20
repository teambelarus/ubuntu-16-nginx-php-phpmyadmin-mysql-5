"""
Injectable modules for configurability

Python package configuration

 -==========================================================================-
    Dynamic configuration modules for configurability
    Allows config items like 'sql_mode' to be handled according to the needs
    of this image rather than generically.
 -==========================================================================-
"""

from distutils.core import setup
from distutils import util

setup(
    name='mysql_config_translator',
    version='0.1',
    url='https://github.com/1and1internet/',
    author='Brian Wilkinson',
    author_email='brian.wilkinson@1and1.co.uk',
    package_dir={
        'mysql_config_translator': '.',
    },
    packages=[
        'mysql_config_translator',
    ],
    install_requires=[
    ],
)
