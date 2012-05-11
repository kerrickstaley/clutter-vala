class Module:
    def __init__(self, name):
        self._name = name
        self._interfaces = []

    def getName(self):
        return self._name

    def addInterface(self, interface):
        self._interfaces.append(interface)

    def getInterfaces(self):
        return self._interfaces
