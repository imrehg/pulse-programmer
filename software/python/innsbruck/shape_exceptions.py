class TooManyShapes(Exception):
  
    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)

class ShapeNotKnown(Exception):
  
    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)

class ParallelEnvException(Exception):
  
    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)
