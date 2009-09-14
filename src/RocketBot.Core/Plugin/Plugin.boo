namespace RocketBot.Core

import System
import System.Collections
import System.Collections.Generic
import System.Text
import System.Text.RegularExpressions
import System.Data
import System.Reflection
import System.IO

public interface IPlugin:

  
  Name as string:
    get

  Description as string:
    get

  Version as string:
    get

  Author as string:
    get

  
  def GetCommands() as List[of CommandWrapper]
  
  



[AttributeUsage(AttributeTargets.Class)]
public final class PluginAttribute(Attribute):
  pass
  


public class Plugin(IPlugin):

  
  private _internalPlugin as IPlugin

  
  
  #region IPlugin Members
  
  public Name as string:
    get:
      return _internalPlugin.Name

  
  public Description as string:
    get:
      return _internalPlugin.Description

  
  public Version as string:
    get:
      return _internalPlugin.Version

  
  public Author as string:
    get:
      return _internalPlugin.Author

  
  public def GetCommands() as List[of CommandWrapper]:
    return _internalPlugin.GetCommands()

  
  public def constructor(plugin as IPlugin):
    _internalPlugin = plugin
    
  
  #endregion



