namespace RocketBot.Core

import System
import System.Collections.Generic
import System.Reflection
import System.IO

public static class PluginLoader:

  private _pluginsByGuid as Dictionary[of Guid, PluginWrapper]
  private _pluginsByName as Dictionary[of String, PluginWrapper]
  private _scriptsAsm as Assembly
  
  private domain as AppDomain
  
  public Plugins as Dictionary[of Guid, PluginWrapper]:
    get:
      return _pluginsByGuid

  
  public def InitializePluginsDict():
    _pluginsByGuid = Dictionary[of Guid, PluginWrapper]() if _pluginsByGuid is null
    _pluginsByName = Dictionary[of string, PluginWrapper]() if _pluginsByName is null
  
  public def LoadPluginsFromScriptsInPath(pluginPath as string):
    InitializePluginsDict()
    
    compiler = ScriptCompiler()
    
    if DirectoryInfo(pluginPath).Exists:
      files as (FileInfo) = DirectoryInfo(pluginPath).GetFiles('*.boo')
      dlls as (FileInfo) = DirectoryInfo(pluginPath).GetFiles('*.dll')
      paths = List of string()
      for dll in dlls:
        AppDomain.CurrentDomain.Load(Assembly.LoadFile(dll.FullName).GetName())
      for file in files:
        //Utilities.DebugOutput("LOADING SCRIPT: "+file.FullName)
        paths.Add(file.FullName)
      
      asm = compiler.CompileCodeAndGetAssembly(paths)
      _scriptsAsm = asm
      AppDomain.CurrentDomain.AssemblyResolve += ResolveEventHandler(ScriptResolveEventHandler)
      LoadPluginsInAssembly(asm)
    else:
      Utilities.DebugOutput("Plugin path: '"+pluginPath+"' doesn't exist, no scripts were loaded.")
  
  def ScriptResolveEventHandler(sender as object, args as ResolveEventArgs) as Assembly:
    return _scriptsAsm
  
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
  
  public def RunPluginSetups():
    for plugin as PluginWrapper in _pluginsByName.Values:
      plugin.Setup()
  
  public def RegisterPlugins():
    for plugin as PluginWrapper in _pluginsByName.Values:
      // load some docs
      for kvp in plugin.Documentation:
        Docs.AddDocsFor(kvp.Key, kvp.Value)
      // register all the commands in this plugin
      for wrapper as CommandWrapper in plugin.GetCommands():
        wrapper.PluginId = plugin.PluginId
        if wrapper.CommandType == CommandType.PrivMSGCommand:
          PrivMSGRunner.RegisterCommand(wrapper)
        elif wrapper.CommandType == CommandType.RawMSGCommand:
          RawMSGRunner.RegisterCommand(wrapper)
        elif wrapper.CommandType == CommandType.TimerCommand:
          TimerRunner.RegisterCommand(wrapper)
        elif wrapper.CommandType == CommandType.ComplexCommand:
          PrivMSGRunner.RegisterComplexCommand(wrapper)
        elif wrapper.CommandType == CommandType.PubSubCommand:
          PubSubRunner.RegisterCommand(wrapper)
  
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