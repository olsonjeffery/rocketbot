namespace RocketBot.Core

import System
import System.Collections.Generic

public class PluginWrapper:
  private _internalPlugin as IPlugin

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
  
  _guidId as Guid
  public PluginId as Guid:
    get:
      return _guidId
  
  [property(IsEnabled)]
  _isEnabled as bool
  
  public def Setup():
    _internalPlugin.Setup()
  
  public def GetCommands() as List[of CommandWrapper]:
    return _internalPlugin.GetCommands()

  public def constructor(plugin as IPlugin):
    _isEnabled = true
    _guidId = Guid.NewGuid()
    _internalPlugin = plugin