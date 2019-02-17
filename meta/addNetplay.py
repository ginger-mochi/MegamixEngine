#!/user/bin/python3
# converts project to a netplay project.

import os
import sys
import itertools

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

re_draw = re.compile("(?<!foo)\b(" + ",".join(draw_commands) + ")")

def repl(match):
	return "n" + match.group(0)

for filename in itertools.chain(os.listdir(scriptDir), os.listdir(objDir)):
	contents = ""
	with open(filename, "r") as file:
		contents = file.read()
	
	re_draw.sub(repl, contents):
		
	
	with open(filename, "w") as file:
		contents = file.write()