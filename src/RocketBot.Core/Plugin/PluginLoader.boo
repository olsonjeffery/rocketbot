namespace RocketBot.Core

import System
import System.Collections.Generic
import System.Reflection
import System.IO

public static class PluginLoader:

  private _pluginsByGuid as Dictionary[of Guid, PluginWrapper]
  private _pluginsByName as Dictionary[of String, PluginWrapper]

  public Plugins as Dictionary[of Guid, PluginWrapper]:
    get:
      return _pluginsByGuid

  
  public def InitializePluginsDict():
    _pluginsByGuid = Dictionary[of Guid, PluginWrapper]() if _pluginsByGuid is null
    _pluginsByName = Dictionary[of string, PluginWrapper]() if _pluginsByName is null
  
  public def LoadPluginsFromScriptsInPath(pluginPath as string):
    InitializePluginsDict()
    
    compiler = ScriptCompiler()
    
    files as (FileInfo) = DirectoryInfo(pluginPath).GetFiles('*.boo')
    for file in files:
      Utilities.DebugOutput("LOADING SCRIPT: "+file.FullName)
      asm = compiler.CompileCodeAndGetAssembly(file.FullName)
      
      LoadPluginsInAssembly(asm)
  
  public def LoadPluginsFromAssembliesInPath(pluginPath as string):
    
    // we're basically going to run through the directory
    // provided and load every dll there into memory. along
    // the way, we'll get an instance of every class in those
    // dll's that happen to have the PredibotPlugin attribute.
    // The reason that we load every dll is also so that we can
    // cover deps. yay!!! I wonder what happens with interdependencies?
    InitializePluginsDict();
    
    asm as Assembly
    files as (FileInfo) = DirectoryInfo(pluginPath).GetFiles('*.dll')
    Utilities.DebugOutput(((('Plugins found in dir \'' + pluginPath) + '\': ') + files.Length))
    
    for file as FileInfo in files:
      asm = Assembly.LoadFile(file.FullName)
      LoadPluginsInAssembly(asm)
  
  public def DisablePlugin(name as string) as bool:
    if not _pluginsByName.ContainsKey(name):
      return false
    elif not _pluginsByName[name].IsEnabled:
      return false
    _pluginsByName[name].IsEnabled = false
    return true
  
  public def EnablePlugin(name as string) as bool:
    if not _pluginsByName.ContainsKey(name):
      return false
    elif _pluginsByName[name].IsEnabled:
      return false
    _pluginsByName[name].IsEnabled = true
    return true
  
  public def LoadPluginsInAssembly(asm as Assembly):
    if asm is not null:
      for type as Type in asm.GetTypes():    
        if type.IsAbstract:
          continue 

        implementsIPlugin = typeof(IPlugin).IsAssignableFrom(type)
        if implementsIPlugin:
          PluginClass = type
          rawPlugin = (Activator.CreateInstance(PluginClass) as IPlugin)
          
          Utilities.DebugOutput(('Found plugin: ' + rawPlugin.Name))
          
          // add code here to deal with plugins with the same name... ?
          plugin = PluginWrapper(rawPlugin)
          _pluginsByGuid.Add(plugin.PluginId, plugin)
          if _pluginsByName.ContainsKey(plugin.Name):
            raise "there is already a loaded plugin named '"+plugin.Name+"'"
          _pluginsByName.Add(plugin.Name, plugin)
          plugin.Setup()
          
          // register all the commands in this plugin
          for wrapper as CommandWrapper in plugin.GetCommands():
            wrapper.PluginId = plugin.PluginId
            if wrapper.CommandType == CommandType.PrivMSGCommand:
              PrivMSGRunner.RegisterCommand(wrapper)
            elif wrapper.CommandType == CommandType.RawMSGCommand:
              RawMSGRunner.RegisterCommand(wrapper)
            elif wrapper.CommandType == CommandType.TimerCommand:
              TimerRunner.RegisterCommand(wrapper)