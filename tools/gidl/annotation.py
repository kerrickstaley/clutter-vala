class Annotation:
    def __init__(self, name, value=None):
        self._name = name
        self._value = value

    def getName(self):
        return self._name

    def getValue(self):
        return self._value
