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
public final class PredibotPluginAttribute(Attribute):
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

	
	private _dllPath as string

	public DllPath as string:
		get:
			return _dllPath

	
	public def constructor(pluginPath as string, plugin as IPlugin):
		
		_dllPath = pluginPath
		_internalPlugin = plugin
		
	
	#endregion



public static class PluginLoader:

	private static _plugins as Dictionary[of string, Plugin]

	public static Plugins as Dictionary[of string, Plugin]:
		static get:
			return _plugins

	
	public static def LoadPlugins(pluginPath as string):
		
		// we're basically going to run through the directory
		// provided and load every dll there into memory. along
		// the way, we'll get an instance of every class in those
		// dll's that happen to have the PredibotPlugin attribute.
		// The reason that we load every dll is also so that we can
		// cover deps. yay!!! I wonder what happens with interdependencies?
		_plugins = Dictionary[of string, Plugin]()
		
		asm as Assembly
		PluginClass as Type = null
		files as (FileInfo) = DirectoryInfo(pluginPath).GetFiles('*.dll')
		Utilities.DebugOutput(((('Plugins found in dir \'' + pluginPath) + '\': ') + files.Length))
		
		for file as FileInfo in files:
			
			
			asm = Assembly.LoadFile(file.FullName)
			
			Utilities.DebugOutput((('Full assembly name: \'' + asm.FullName) + '\''))
			
			
			if asm is not null:
				
				for type as Type in asm.GetTypes():
					
					
					if type.IsAbstract:
						continue 
					attrs as (object) = type.GetCustomAttributes(typeof(PredibotPluginAttribute), true)
					// if true, we have plugin, yay!
					if attrs.Length > 0:
						
						
						
						PluginClass = type
						rawPlugin = (Activator.CreateInstance(PluginClass) as IPlugin)
						
						Utilities.DebugOutput(('Found plugin: ' + rawPlugin.Name))
						
						// add code here to deal with plugins with the same name... ?
						plugin = Plugin(file.FullName, rawPlugin)
						_plugins.Add(plugin.Name, plugin)
						
						// register all the commands in this plugin
						for wrapper as CommandWrapper in plugin.GetCommands():
							if wrapper.CommandType == CommandType.PrivMSGCommand:
								PrivMSGRunner.RegisterCommand(wrapper)
							elif wrapper.CommandType == CommandType.RawMSGCommand:
								RawMSGRunner.RegisterCommand(wrapper)
							elif wrapper.CommandType == CommandType.TimerCommand:
								TimerRunner.RegisterCommand(wrapper)
						
					
				
			
		
	
	


