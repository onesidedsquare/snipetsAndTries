class ObjClass:
    def __init__(self, word, numb, boole):
        self.word = word
        self.numb = numb
        self.boole = boole

obj = ObjClass("FISHBREATH", 1234567890, True)

print("word " + obj.word)
print("number " + str(obj.numb))
print("FALSE " + str(obj.boole))
