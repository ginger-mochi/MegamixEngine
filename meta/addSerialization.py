import regex
import statistics
import os
import sys
from processVariables import walkObjects

if len(sys.argv) <= 1:
	print("usage: ./addSerialization.py object-directory")
	sys.exit()
else:
	for result in walkObjects(sys.argv[-1], True):
		pass