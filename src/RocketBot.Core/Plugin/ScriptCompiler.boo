namespace RocketBot.Core

import System
import System.Collections.Generic
import System.IO
import System.Reflection
import Boo.Lang.Compiler
import Boo.Lang.Compiler.IO
import Boo.Lang.Compiler.Pipelines


class ScriptCompiler:
  public def CompileCodeAndGetAssembly(filePaths as List[of string]) as Assembly:

    booC = BooCompiler()
    
    for path in filePaths:
      stream = StreamReader(FileInfo(path).Open(FileMode.Open), true)
      code = stream.ReadToEnd()
      booC.Parameters.Input.Add(StringInput(FileInfo(path).Name, code))
    
    for i in AppDomain.CurrentDomain.GetAssemblies():
      booC.Parameters.AddAssembly(i)
    booC.Parameters.Pipeline = CompileToMemory()
    booC.Parameters.Ducky = false
    compileContext = booC.Run()
    raise join(e for e in compileContext.Errors, "\n") if compileContext.GeneratedAssembly is null
    
    return compileContext.GeneratedAssembly