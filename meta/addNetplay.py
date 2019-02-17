#!/user/bin/python3
# converts project to a netplay project.

import os
import sys
import itertools
import re

# replace draw_ with ndraw_...

srcDir = os.path.join(".", "..")
scriptDir = os.path.join(srcDir, "scripts")
objDir = os.path.join(srcDir, "objects")

draw_commands = [
"draw_rectangle",
"draw_set_alpha",
"draw_set_color",
"draw_set_halign",
"draw_set_valign",
"draw_sprite",
"draw_sprite_ext",
"draw_sprite_part",
"draw_sprite_part_ext",
"draw_text"
]

re_draw = re.compile("(?<!/\*LOCAL\*/ )\b\(" + "|".join(draw_commands) + "\)")

def repl(match):
	print(match.group(0))
	return "n" + match.group(0)

def listdir(dir):
	return map(lambda d: os.path.join(dir, d), os.listdir(dir))
	
for filename in itertools.chain(listdir(scriptDir), listdir(objDir)):
	if filename.endswith(".gmx") or filename.endswith(".gml"):
		print(filename)
		contents = ""
		with open(filename, "r", encoding="utf8") as file:
			contents = file.read()
		
		contents = re_draw.sub(repl, contents)
		
		with open(filename, "w", encoding="utf8") as file:
			file.write(contents)