namespace Rocketbot.Core

import System
import System.Collections.Generic
import System.Reflection
import System.IO

public class ScriptSandbox(IDisposable):
  protected _appDomain as AppDomain
  
  public def constructor(scriptDir):
    _appDomain = AppDomain.CreateDomain("");
  
  public def PrepareCompiler() as bool:
  	return false
  
  public def Dispose() as void:
  	AppDomain.Unload(_appDomain);
  	_appDomain = null;