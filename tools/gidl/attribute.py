class Attribute:
    READABLE = 0
    WRITABLE = 1
    READWRITE = READABLE | WRITABLE

    def __init__(self, name, attr_type, attr_visibility=Attribute.READWRITE):
        self._name = name
        self._attr_type = attr_type
        self._attr_visibility = attr_visibility

    def getName(self):
        return self._name

    def getAttrType(self):
        return self._attr_type

    def isReadable(self):
        return self._attr_visibility & Attribute.READABLE

    def isWritable(self):
        return self._attr_visibility & Attribute.WRITABLE

class AttributeParser:
    pass

if __name__ == '__main__':
    import unittest

    attribute_decls_tests = [
    ]

    create_tests(TestProgram, 'test_attribute_decls', attribute_decls_tests)

    unittest.main()
