# import numpy
import os


def tt():
    CallBackObj.PrintHello("salut c'est un print")
    CallBackObj.PrintHello(os.getcwd())
    file = open("text.txt", "r")
    CallBackObj.PrintHello(file.readlines())
    return "c'est un return"


def nump():
    a = numpy.arange(15).reshape(3, 5)
    CallBackObj.PrintHello(a)
    return a
