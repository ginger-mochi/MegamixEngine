# reads object files from stdin, reads all variables and invokes callback.

import regex
import statistics
import os
import sys

srevarname = "[a-zA-Z_][a-zA-Z0-9_]*"

reFindVars = regex.compile(r"\s*(" + srevarname + "\.)?(" + srevarname + ")(\[(?P<accessor>.*)\])?\s*=(?!=)(?P<assignment>[^;\n]*)")
reFindLocals = regex.compile(r"\s*var (\s*(" + srevarname + ")\s*(=[^,;\n]+\s*)?,?)+")
reParent = regex.compile(r"<parentName>([^<]*)</parentName>")
reObjectFileParse = regex.compile(r"^(.*)\.object\.gmx$")
reScriptFileParse = regex.compile(r"^(.*)\.gml$")

builtin = {'hspeed', 'vspeed', 'solid', 'visible', 'persistent', 'depth', 'alarm', 'object_index',
			'sprite_index', 'image_index', 'image_alpha', 'image_angle', 'image_blend',
			'image_speed', 'image_xscale', 'image_yscale', 'image_single', 'mask_index', 'friction',
			'gravity', 'gravity_direction', 'direction', 'hspeed', 'vspeed', 'speed', 
			'x', 'y', 'xprevious', 'yprevious', 'xstart', 'ystart',
			'background_colour', 'background_color', 'view_xview', 'view_yview', 'view_wview', 'view_hview', 'view_visible',
			'view_enabled', 'room_speed', 'background_visible'}
			
class GlobalsParseResult:
	def __init__(self):
		self.globals = True
		self.variables = []
		self.variableIsArray = {}
		self.variableType = {}
		self.variableAssignments = {}
			
class ObjectParseResult:
	def __init__(self):
		self.globals = False
		self.name = ""
		self.path = ""
		# parse result for parent.
		self.parentResult = None
		# variables which are declared in a var statement.
		self.localVariables = []
		# instance variables that any ancestor of this object had.
		self.instanceVariablesInherited = []
		# any instance variable in object that is not inherited nor local.
		self.instanceVariables = []
		# of the above, those which were not mentioned in the create event.
		self.instanceVariablesQuestionable = []
		# any instance variable that is not inherited, local, or questionable.
		self.instanceVariablesDefinite = []
		# union of instanceVariables and instanceVariablesInherited.
		self.instanceVariablesAll = []
		# this and any ancestor's definite instance variable.
		self.instanceVariablesDefiniteAll = []
		# these variables are arrays
		self.instanceVariableIsArray = {}
		# maps vars which have a known type to their type ('id', 'map', etc.)
		self.instanceVariableType = {}
		# maps variables to a list of all rhs of the assignments they appear in.
		self.instanceVariableAssignments = {}
		
def walkObjects(directory, verbose=False, ignore=None, ignoreFiles=[], globals=True):
	# yields ObjectParseResults for all objects and scripts in the given parse directory.
	# final yield is of type GlobalsParseResult (unless globals is False, in which case all yields are ObjectParseResults)
	# verbose: print to stdout
	# ignore: variables names to ignore (built-in variables are always ignored)

	if ignore is None:
		ignore = builtin
	else:
		ignore |= builtin
		
	ignoreFiles = list(map(lambda p : p.replace(os.path.sep, '/'), ignoreFiles))
		
	dir = directory
	objdir = os.path.join(dir, "objects")
	scrdir = os.path.join(dir, "scripts")
	needs_processing = [dir]
	if not dir.endswith(".object.gmx"):
		needs_processing = list(map(lambda p : os.path.join(objdir, p).replace(os.path.sep, '/'), os.listdir(objdir)))
		if globals:
			# process scripts (and process them before the objects)
			needs_processing = list(map(lambda p : os.path.join(scrdir, p).replace(os.path.sep, '/'), os.listdir(scrdir))) + needs_processing
		
		
	processed = []
	process_count = len(needs_processing)

	objvars = {}
	results = {}
	instanceVarCounts = []
	questionableVarCounts = []
	localVarCounts = []
	
	globalresult = GlobalsParseResult()
	globalvars = set()
	globalrhs = dict()
	globalisarray = set()
	
	while len(needs_processing) > 0:
		file = needs_processing.pop(0).strip()
		if file in ignoreFiles:
			continue
		objFileNameMatch = reObjectFileParse.match(file)
		isObject = objFileNameMatch is not None
		isScript = reScriptFileParse.match(file) is not None
		if not isObject and not isScript:
			continue
		if isScript and not globals:
			# todo: search scripts to flag non-local definitions.
			continue
		result = None
		with open(file, "r", encoding="utf8") as f:
			fcontents = f.read()
			result = None
			if isObject:
				# objects must be parsed in order.
				parentMatch = reParent.search(fcontents)
				parentFile = None
				if parentMatch is not None:
					parent = parentMatch.group(1)
					if parent != "" and parent != "&lt;undefined&gt;":
						# put file back on list and process parent instead
						parentFile = os.path.join(os.path.dirname(file), parent + ".object.gmx").replace(os.path.sep, '/')
						if parentFile not in processed:
							needs_processing.insert(0, file)
							if parentFile in needs_processing:
								needs_processing.remove(parentFile)
							needs_processing.insert(0, parentFile)
							continue
					
				result = ObjectParseResult()
				result.name = objFileNameMatch.group(1)
				result.path = file
				if parentFile is not None:
					result.parentResult = results[parentFile]
			
			# find create event
			createStart = fcontents.find("<event eventtype=\"0\" enumb=\"0\">")
			createEnd = -1
			if createStart >= 0:
				createEnd = fcontents.find("</event>", createStart)
			
			# find comments
			commentSpans = parseComments(fcontents, file.endswith(".object.gmx"))
			
			# find all with () { ... } ranges
			withSpans = parseWiths(fcontents)
			
			# find variable names
			vars = set()
			locals = set()
			definite = set()
			rhs = dict()
			isArray = set()
			
			for match in reFindVars.finditer(fcontents):
				varName = match.group(2)
				# ignore comments
				if inFlatSpans(match.span()[0], commentSpans):
					continue
				# var belonging to other objects or global, e.g. t.xspeed, global.health
				varInstance = len(match.captures(1)) == 0
				varOther = False
				if "other." in match.captures(1):
					# could potentially be other.other
					varInstance = True
					varOther = True
				if varInstance and isObject:
					# check with spans to see if this is definitely being assigned to a different instance.
					withsTreeLocation = locateInWithsTree(match.span()[0], withSpans)
					if len(withsTreeLocation) > 0:
						if withsTreeLocation[-1] != "other" and withsTreeLocation[-1] != "(other)":
							continue
							
					# check if var assigned to other at top-level
					if len(withsTreeLocation) == 0:
						if varOther:
							continue
					
					# try to determine swizzle type
					assignment = match.group('assignment').strip()
					if varName not in rhs:
						rhs[varName] = []
					rhs[varName].append(assignment)
					if len(match.captures("accessor")) > 0:
						accessor = match.group("accessor")
						if (not accessor.startswith("?") and not accessor.startswith("|") and not accessor.startswith("#") and not accessor.startswith("@")):
							isArray.add(varName)
					
					# possibly an instance variable.
					vars.add(varName)
					if match.span()[0] < createEnd:
						definite.add(varName)
				else: # other/global?
					if match.group(1) == "global." and globals:
						varName = "global." + varName
						assignment = match.group('assignment').strip()
						if varName not in globalrhs:
							globalrhs[varName] = []
						globalrhs[varName].append(assignment)
						
						if len(match.captures("accessor")) > 0:
							accessor = match.group("accessor")
							if (not accessor.startswith("?") and not accessor.startswith("|") and not accessor.startswith("#") and not accessor.startswith("@")):
								globalisarray.add(varName)
							
						globalvars.add(varName)
						
			# local vars (var statements)
			for match in reFindLocals.finditer(fcontents):
				# list of vars declared in this var statement (can be more than one!)
				localDecls = match.captures(2)
				for local in localDecls:
					locals.add(local)
			vars -= locals
			vars -= ignore
			locals -= ignore
			if isObject:
				objvars[file] = vars.copy()
				if parentFile is not None:
					vars -= objvars[parentFile]
					objvars[file] |= objvars[parentFile]
					
				definite &= vars
				questionable = vars - definite
				type = {}
				for varName in rhs.keys():
					type[varName] = inferTypeFromAssignments(rhs[varName])
				result.instanceVariableIsArray = isArray
				
				isArray = isArray & vars

				if verbose:
					print(file)
					print("\"with\" statements:", withSpans)
					if parentFile is not None:
						print("> inherits from ({})".format(parent))
					for var in vars:
						symbol = "*"
						if var in type.keys():
							symbol = type[var]
						if symbol is "":
							symbol = "*"
						if var in isArray:
							symbol += "[]"
						if var not in questionable:
							varLine = "{:<8} {}".format(symbol, var)
							alignLen = max(0, 60 - len(varLine))
							varLine += " "*alignLen
							varLine += str(rhs[var])
							print(varLine)
					for var in questionable:
						symbol = ""
						if var in type.keys():
							symbol = type[var]
						print("{:<8} {}".format(symbol + "?", var))
					for local in locals:
						print("(local) {}".format(local))
					print()
				instanceVarCounts.append(len(vars))
				questionableVarCounts.append(len(questionable))
				localVarCounts.append(len(locals))
				
				result.localVariables = locals
				result.instanceVariables = vars
				result.instanceVariablesQuestionable = questionable
				result.instanceVariablesDefinite = vars - questionable
				result.instanceVariableAssignments = rhs
				result.instanceVariableType = type
				if parentFile is not None:
					result.instanceVariableType = {**result.parentResult.instanceVariableType, **type}
					result.instanceVariableIsArray |= result.parentResult.instanceVariableIsArray
					result.instanceVariablesInherited   = objvars[parentFile]
					result.instanceVariablesAll         = vars                             | result.parentResult.instanceVariablesAll
					result.instanceVariablesDefiniteAll = result.instanceVariablesDefinite | result.parentResult.instanceVariablesDefiniteAll
				else:
					result.instanceVariablesAll         = vars
					result.instanceVariablesDefiniteAll = result.instanceVariablesDefinite
			
		processed.append(file)
		if verbose:
			print (" "*50, round(100 - 100 * len(needs_processing) / process_count, 1), "%")
		if isObject:
			if result is not None:
				results[file] = result
				yield result
	if globals:
		globaltype = {}
		for varName in globalrhs.keys():
				globaltype[varName] = inferTypeFromAssignments(globalrhs[varName])
			
		globalresult.variables = globalvars
		globalresult.variableIsArray = globalisarray
		globalresult.variableAssignments = globalrhs
		globalresult.variableType = globaltype
		
		if verbose:
			print("Globals:")
			for var in globalvars:
				symbol = "*"
				if var in globaltype.keys():
					symbol = globaltype[var]
				if symbol is "":
					symbol = "*"
				if var in isArray:
					symbol += "[]"
				if var not in questionable:
					print("{:<8} {}".format(symbol, var))
			print()
			
		yield(globalresult)
	if verbose:
		print("Stats:")
		print("mean instance vars: ", round(statistics.mean(instanceVarCounts), 2))
		print("mean questionable:", round(statistics.mean(questionableVarCounts), 2))
		print("mean locals:", round(statistics.mean(localVarCounts), 2))
		print()
		print("median instance vars: ", statistics.median(instanceVarCounts))
		print("median questionable: ", statistics.median(questionableVarCounts))
		print("median locals: ", statistics.median(localVarCounts))

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False
		
def inferTypeFromAssignment(assignment):
	if assignment.endswith('.id') or assignment == 'id':
		return 'id'
	elif assignment.startswith('instance_create'):
		return 'id'
	elif assignment.startswith('instance_find'):
		return 'id'
	elif assignment.startswith('instance_nearest'):
		return 'id'
	elif assignment.startswith('instance_place'):
		return 'id'
	elif assignment.startswith('instance_position'):
		return 'id'
	elif assignment.startswith('instance_copy'):
		return 'id'
	elif assignment.startswith('surface_create'):
		return 'surface'
	elif assignment.startswith('ds_map_create'):
		return 'map'
	elif assignment.startswith('ds_list_create'):
		return 'list'
	elif assignment.startswith('ds_grid_create'):
		return 'grid'
	elif assignment.startswith('ds_stack_create'):
		return 'stack'
	elif assignment.startswith('ds_queue_create'):
		return 'queue'
	elif assignment.startswith('ds_priority_create'):
		return 'priority'
	elif assignment.startswith('external_define'):
		return 'external-function'
	elif assignment.startswith('string(') or assignment.startswith('"'):
		return 'string'
	elif is_number(assignment):
		return 'number'
	elif assignment == 'false' or assignment == 'true':
		return 'number'
	return '?'
		
def inferTypeFromAssignments(assignments):
	# takes a list of assigned values, produces a string suggesting the type.
	# valid outputs are as follows: '', 'number', 'string', 'mixed', 'id', 'surface', 'map', 'list', 'grid', 'stack', 'queue', 'priority'
	# mixed is very worrying and requires bespoke logic to handle.
	might_be_number = False
	might_be_string = False
	# these can be ascertained with a high probability when encountered.
	definite_types = ['id', 'surface', 'map', 'list', 'grid', 'stack', 'queue', 'priority', 'external-function']
	decided_types = []
	types = []
	for assignment in assignments:
		type = inferTypeFromAssignment(assignment)
		types.append(type)
		if type == '?':
			#ignore assignments which cannot be analyzed
			continue
		if 'number' == type:
			might_be_number = True
		if 'string' == type:
			might_be_string = True
		if type in definite_types and type not in decided_types:
			decided_types.append(type)
	if len(decided_types) > 1:
		return "mixed"
	if len(decided_types) == 1:
		return decided_types[0]
	if might_be_number and not might_be_string:
		return 'number'
	if might_be_string and not might_be_number:
		return 'string'
	return ""
	
		
def matchBrace(code, index=0):
	# finds index of matching brace for brace at given index
	braces = 0
	comment = 0
	for i in range(index, len(code)):
		c = code[i]
		c2 = code[i:min(i+2, len(code))]
		if comment == 0:
			if c2 == '//':
				comment = 1
			if c2 == '/*':
				comment = 2
			elif c == '{':
				braces += 1
			elif c == '}':
				braces -= 1
				if braces == 0:
					return i
		elif comment == 1:
			if c2 == '\n':
				comment = 0
		elif comment == 2:
			if c2 == '*/':
				comment = 0
	return -1
		
def locateInWithsTree(pos, withTree):
	location = []
	for span in withTree:
		if pos >= span[0] and pos <= span[1]:
			location = [span[2]]
			location.extend(locateInWithsTree(pos, span[3]))
			break
		if pos < span[0]:
			break
	return location
		
reWithBody = regex.compile(r"with(([\s\n]*|\()[^\{\n]*)[\s\n]*\{", regex.MULTILINE)
def parseWiths(code, start=0, end=-1):
	# returns list of tuples of (start:int, end:int, withid:string, subwiths:list)
	spans = []
	withSearchStart = start
	while True:
		match = reWithBody.search(code, withSearchStart)
		if match is None:
			break
		if end != -1 and match.span()[1] > end:
			break
		bodyStart = match.span()[1]
		braceIndex = matchBrace(code, bodyStart - 1)
		if braceIndex != -1:
			spans.append((bodyStart, braceIndex, match.group(1).strip(), parseWiths(code, bodyStart, braceIndex)))
			# check for nested spans
			withSearchStart = braceIndex
		else:
			break
	return spans
		
def inFlatSpans(pos, spans):
	for span in spans:
		if pos < span[0]:
			return False
		if pos >= span[0] and pos < span[1]:
			return True
	return False
		
		
def parseComments(code, xmlAreComments=False, start=0):
	# returns flat span of comments
	spans = []
	while True:
		nextCommentSL = code.find("//", start)
		nextCommentML = code.find("/*", start)
		nextCommentXML = code.find("<", start)
		if not xmlAreComments:
			nextCommentXML = -1
		if (nextCommentSL < nextCommentML or nextCommentML == -1) and (nextCommentSL < nextCommentXML or nextCommentXML == -1) and nextCommentSL != -1:
			prev = nextCommentSL
			start = code.find("\n", nextCommentSL) + 1
			span = (prev, start - 1)
			if start == 0:
				span = (prev, len(code))
				spans.append(span)
				break
			spans.append(span)
		elif (nextCommentML <= nextCommentSL or nextCommentSL == -1) and (nextCommentML < nextCommentXML or nextCommentXML == -1) and nextCommentML != -1:
			prev = nextCommentML
			start = code.find("*/", nextCommentML) + 1
			span = (prev, start)
			if start == 0:
				span = (prev, len(code))
				spans.append(span)
				break
			spans.append(span)
		elif (nextCommentXML <= nextCommentSL or nextCommentSL == -1) and (nextCommentXML <= nextCommentML or nextCommentML == -1) and nextCommentXML != -1:
			prev = nextCommentXML + 1
			start = prev
			if prev >= len(code) - 2:
				break
			if code[prev] == '/':
				continue
			endb = code.find(">", prev)
			if endb == -1:
				continue
			start = endb + 1
			spans.append((prev, endb))
		else:
			break
	return spans
		
if __name__ == '__main__':
	if len(sys.argv) <= 1:
		print("usage: ./processVariables.py object-directory")
	else:
		for result in walkObjects(sys.argv[-1], True):
			pass