class Parameter:
    IN = 0
    OUT = 1
    INOUT = 2

    def __init__(self, direction, param_type, name):
        self._direction = direction
        self._param_type = param_type
        self._name

    def getDirection(self):
        return self._direction

    def getParamType(self):
        return self._param_type

    def getName(self):
        return self._name
