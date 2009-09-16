namespace RocketBot.Core

import System
import System.Collections.Generic
import System.Reflection
import System.IO

public static class PluginLoader:

  private _plugins as Dictionary[of string, PluginWrapper]

  public Plugins as Dictionary[of string, PluginWrapper]:
    get:
      return _plugins

  
  public def InitializePluginsDict():
    _plugins = Dictionary[of string, PluginWrapper]() if _plugins is null
  
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
  
  public def LoadPluginsInAssembly(asm as Assembly):
    Utilities.DebugOutput('Full assembly name: \'' + asm.FullName + '\'')
    if asm is not null:
      for type as Type in asm.GetTypes():    
        if type.IsAbstract:
          continue 

        implementsIPlugin = typeof(IPlugin).IsAssignableFrom(type)
        if implementsIPlugin:
          print "here?"
          PluginClass = type
          rawPlugin = (Activator.CreateInstance(PluginClass) as IPlugin)
          
          Utilities.DebugOutput(('Found plugin: ' + rawPlugin.Name))
          
          // add code here to deal with plugins with the same name... ?
          plugin = PluginWrapper(rawPlugin)
          _plugins.Add(plugin.Name, plugin)
          
          // register all the commands in this plugin
          for wrapper as CommandWrapper in plugin.GetCommands():
            if wrapper.CommandType == CommandType.PrivMSGCommand:
              PrivMSGRunner.RegisterCommand(wrapper)
            elif wrapper.CommandType == CommandType.RawMSGCommand:
              RawMSGRunner.RegisterCommand(wrapper)
            elif wrapper.CommandType == CommandType.TimerCommand:
              TimerRunner.RegisterCommand(wrapper)