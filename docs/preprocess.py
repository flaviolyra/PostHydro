def erase_lines_after_marker(filename, marker):
  """
  Erases all lines in a file after marker, adds an underline for the marker plus two blank lines.

  Args:
    filename (str): The path to the file.
    marker (str): Marker to be searched.
  """
  lines_to_keep = []
  found_marker = False
  with open(filename, 'r') as f_read:
    for line in f_read:
      if marker in line:
        found_marker = True
        lines_to_keep.append(line)  # Keep the marker line itself
        break  # Stop processing lines after the marker is found
      lines_to_keep.append(line)
  if found_marker:
    with open(filename, 'w') as f_write:
      # rewrites on the file the previous lines including the marker
      for line in lines_to_keep:
        f_write.write(line)
      # writes a new line with dashes, the size of the marker, plus two blank lines
      f_write.write('-' * len(marker) +'\n')
      f_write.write('\n')
      f_write.write('\n')

def process_method(classname, method_def, outfile):
  """
  Generates in outfile a Sphinx description of the classname method described by a list of lines in method_def
  """
  import re
  i = 0
  n = len(method_def)
  file_output = open(outfile, 'a')
  # join lines until : is found to create a raw name - signature of the method
  method_name_sign_raw = ''
  while not re.search(r":", method_def[i]):
    method_name_sign_raw = method_name_sign_raw + method_def[i]
    i = i + 1
  method_name_sign_raw = method_name_sign_raw + method_def[i]
  i = i +1
  # clean the raw name - signature of the method and create a corresponding automethod line on the output file
  method_name_sign_raw = method_name_sign_raw.replace(':', '')
  method_name_sign = ' '.join(method_name_sign_raw.split())[4:]
  file_output.writelines("\n.. function:: {0}".format(classname + '.' + method_name_sign))
  file_output.writelines('\n')
  # clean reamaining lines, without """ in method_def and transfer with 3 leading spaces to the output file
  while i < n:
    raw_line = method_def[i]
    raw_line = raw_line.replace('"""', '')
    line = ' '.join(raw_line.split())
    file_output.writelines("\n   {0}".format(line))
    i = i + 1
  # create in the output file a blank line plus a --- marker plus a blank line
  file_output.writelines("\n")
  file_output.writelines("\n---")
  file_output.writelines("\n")
  file_output.close()

def process_plugin_class(pluginname, modulename, classname):
  """
  Processes classname class, in modulename module, in pluginname directory
  and generates on docs/source/desktopclient.rst the methods (not __init__) documentation
  """
  import os
  import re
  infile = os.path.join(pluginname, modulename +'.py')
  outfile = os.path.join('docs','source', 'desktopclient.rst')
  class_pattern = r"class[ ]+(?P<class>[-_a-zA-Z0-9]+)\s*\("
  regexp_class = re.compile(class_pattern)
  # clean lines on outfile after the Methods marker
  erase_lines_after_marker(outfile, 'Methods')
  # open inputfile and skips lines until classname class is found
  file_input = open(infile, 'r')
  line = file_input.readline()
  result = regexp_class.search(line)
  while line and not (result and result.group('class') == classname):
    line = file_input.readline()
    result = regexp_class.search(line)
  # process input lines
  if (result and result.group('class') == classname):
    line = file_input.readline()
    while line and not regexp_class.search(line):
      method_def = []
      ind_comment = 0
      if re.search(r"\s*def[ ]+", line) and not re.search(r"__init__", line):
        # generate a method definition when one is found (and is not __init__)
        method_def.append(line[:-1])
        ind_comment = ind_comment + len(re.findall(r'"""', line))
        # add to the definition all subsequent lines until a second """ is found
        while ind_comment < 2:
          line = file_input.readline()
          method_def.append(line[:-1])
          ind_comment = ind_comment + len(re.findall(r'"""', line))
        process_method(classname, method_def, outfile)
      line = file_input.readline()

def process_function(infilename, outfilename):
  """
  Processes a PostgreSQL function or procedureresult = regexp_method.search(line)with Google document style
  and generates Sphinx Python type code documentation

  Args:
    infilename (str): The SQL code file.
    outfilename (str): The rts file where the Sphinx documentation wil be written.
  """
  import re
  # open input and output files
  file_input = open(infilename, 'r')
  file_output = open(outfilename, 'a')
  # create and compile pattern for function name
  name_pattern = r"\s*CREATE[ ]+(FUNCTION|PROCEDURE)[ ]*(?P<fname>[-_a-zA-Z0-9]+)\s*\("
  regexp_name = re.compile(name_pattern)
  # create and compile pattern for function arguments
  args_pattern = r"\s*(?P<arg>[-_a-zA-Z0-9]+)[ ]*.*?[,|\)]"
  regexp_args = re.compile(args_pattern)
  line = file_input.readline()
  # skip any preliminary comment lines
  while line[:3] == '-- ':
    line = file_input.readline()
  # concatenate as a single line all lines not comment
  lineconcat = ''
  while line[:3] != '-- ':
    lineconcat = lineconcat + line
    line = file_input.readline()
  # extract function name from line
  result = regexp_name.search(lineconcat)
  funcname = result.group('fname')
  file_output.writelines("\n.. py:function:: {0}".format(funcname) + ' (')
  # get remainder of line with function arguments
  line_args = re.sub(regexp_name,'',lineconcat)
  # while there are matches with regexg_args, write argument and clip line_args
  first = True
  result = regexp_args.search(line_args)
  while result:
    # write the argument with a preceding comma, if not first
    arg = result.group('arg')
    if first:
      file_output.writelines("{0}".format(arg))
    else:
      file_output.writelines(", {0}".format(arg))
    # make first false and clip the argument from line_args
    first = False
    line_args = re.sub(regexp_args,'',line_args, 1)
    result = regexp_args.search(line_args)
  # write a closing ')'
  file_output.writelines(')\n')
  # create and compile pattern for arguments and return type
  args_ret_pattern = r"--[ ]+(?P<pname>[-_a-zA-Z0-9]+)[ ]+\([ ]*(?P<ptype>[ -_a-zA-Z0-9]+)\):[ ]+(?P<pcomm>(.*))"
  regexp_arg_ret = re.compile(args_ret_pattern)
  file_output.writelines('\n')
  # while this line is a comment, and not Args: or Returns:, print the function comment
  while line[:3] == '-- ' and line[:-1] != '-- Args:' and line[:-1] != '-- Returns:':
    file_output.writelines ('   ' + line[3:-1] + '\n')
    line = file_input.readline()
  # write a blank line
  file_output.writelines('\n')
  # write the parameters names, types and comments
  if line[:-1] == '-- Args:':
    line = file_input.readline()
    while line [:4] == '--  ' and line[:-1] != '-- Returns:':
      result = regexp_arg_ret.search(line)
      paramname = result.group('pname')
      paramtype = result.group('ptype')
      paramcomment = result.group('pcomm')
      file_output.writelines('   :param ' + paramname + ': ' + paramcomment +'\n')
      file_output.writelines('   :type ' + paramname + ': ' + paramtype +'\n')
      line = file_input.readline()
  # write the return name and type
  if line[:-1] == '-- Returns:':
    line = file_input.readline()
    result = regexp_arg_ret.search(line)
    paramname = result.group('pname')
    paramtype = result.group('ptype')
    file_output.writelines('   :return: ' + paramname +'\n')
    file_output.writelines('   :rtype: ' + paramtype +'\n')
  # write a separator
  file_output.writelines('\n')
  file_output.writelines('---\n')
  file_output.writelines('\n')
  # close the input and output files
  file_input.close()
  file_output.close()

def process_dir(dirlevel, dirname, outfilename):
  """
  Processes recursively a PostHydro directory and searches for SQL Function or Procedure code
  to convert code documentation from Google style to Sphynx Python style

  Args:
    dirlevel (integer): level of the directory (0 = project directory)
    dirname (str): subdirectory name, relative to project directory.
    outfilename (str): The rts file name where the Sphinx documentation wil be written.
  """
  import os
  # basic directories (just directories - no functions or procedure definitions)
  # calls process_dir one more level to process them
  if dirlevel == 0:
    os.chdir('..')
    dirlist = os.listdir()
    for diritem in dirlist:
      if os.path.isdir(diritem) and diritem in ['InformationReferencing', 'StructureBuilding', 'UpstreamDownstreamNavigation']:
        process_dir(1, diritem, diritem.lower())
  elif dirlevel < 3:
    outfile = os.path.join('docs', 'source', outfilename + '.rst')
    # cleans procedure and function documentation in outfile
    erase_lines_after_marker(outfile, 'Procedures and Functions')
    dirlist = os.listdir(dirname)
    for diritem in dirlist:
      fulldiritem = os.path.join(dirname, diritem)
      if os.path.isdir(fulldiritem):
        if dirlevel < 2:
          process_dir(dirlevel + 1, fulldiritem, outfilename + '_' + diritem.lower())
        else:
          process_dir(dirlevel + 1, fulldiritem, outfilename)
      else:
        if (diritem[:15] == 'CreateProcedure' or diritem[:14] == 'CreateFunction') and diritem[-4:] == '.sql':
          funcfile = os.path.join(dirname, diritem)
          process_function(funcfile, outfile)
  else:
    outfile = os.path.join('docs', 'source', outfilename + '.rst')
    # cleans procedure and function documentation in outfile
    erase_lines_after_marker(outfile, 'Procedures and Functions')
    dirlist = os.listdir(dirname)
    for diritem in dirlist:
      fulldiritem = os.path.join(dirname, diritem)
      if os.path.isdir(diritem):
        process_dir(dirlevel + 1, fulldiritem, outfilename)
      else:
        if (diritem[:15] == 'CreateProcedure' or diritem[:14] == 'CreateFunction') and diritem[-4:] == '.sql':
          funcfile = os.path.join(dirname, diritem)
          process_function(funcfile, outfile)

if __name__ == "__main__":
  process_dir(0, '', '')
  process_plugin_class('upstream_downstream', 'upstream_downstream_tool', 'UpstreamDownstreamTool')

