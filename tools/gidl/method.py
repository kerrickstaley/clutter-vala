class Method:
    def __init__(self, ret_type, name, params=[]):
        self._ret_type = ret_type
        self._name = name
        self._params = params

    def getReturnType(self):
        return self._ret_type

    def getName(self):
        return self._name

    def getParameters(self):
        return self._params
