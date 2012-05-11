import re

import gidl.module
import gidl.interface
import gidl.attribute
import gidl.annotation

class Parser:
    def __init__(self):
        self._scanner = re.Scanner([
            (r'module \s+ [a-zA-Z0-9] \s+ {', self._module_token),
            (r'interface \s+ [a-zA-Z0-9] \s+ {', self._interface_token),
        ])

        self._modules = []

    def _module_token(self, token):
        pass

    def _interface_token(self, token):
        pass

    def parse(self, string):
        self._scanner.scan(string)
