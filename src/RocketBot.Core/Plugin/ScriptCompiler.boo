namespace RocketBot.Core

import System
import System.IO
import System.Reflection
import Boo.Lang.Compiler
import Boo.Lang.Compiler.IO
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Pipelines


class ScriptCompiler:
"""Description of ScriptCompiler"""
  public def constructor():
    pass

  public def CompileCodeAndGetAssembly(filePath as string) as Assembly:

    booC = BooCompiler()
    stream = StreamReader(FileInfo(filePath).Open(FileMode.Open), true)
    code = stream.ReadToEnd()
    booC.Parameters.Input.Add(StringInput("foo", code))
    
    for i in AppDomain.CurrentDomain.GetAssemblies():
      booC.Parameters.AddAssembly(i)
    booC.Parameters.Pipeline = CompileToMemory()
    booC.Parameters.Ducky = false
    compileContext = booC.Run()
    print join(e for e in compileContext.Errors, "\n") if compileContext.GeneratedAssembly is null
    raise "SCRIPT COMPILE FAIL: "+filePath if compileContext.GeneratedAssembly is null
    
    return compileContext.GeneratedAssembly