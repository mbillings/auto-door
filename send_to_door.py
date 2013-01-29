from Tkinter import *
import serial
import time

DEVICE = '/dev/ttyASM0'
BAUD = 9600
ser = serial.Serial(DEVICE, BAUD)

root = Tk()

def 
