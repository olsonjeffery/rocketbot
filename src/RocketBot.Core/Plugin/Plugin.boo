namespace RocketBot.Core

import System
import System.Collections.Generic

public class Plugin:
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

  public def GetCommands() as List[of CommandWrapper]:
    return _internalPlugin.GetCommands()

  public def constructor(plugin as IPlugin):
    _internalPlugin = plugin