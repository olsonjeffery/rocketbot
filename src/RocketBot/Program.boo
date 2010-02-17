namespace RocketBot

import System
import RocketBot.Core

class Stub:
	pass

BotConfig.Initialize('./RocketBot.config.xml', 'RocketBotConfiguration')

PluginLoader.LoadPluginsFromScriptsInPath(Environment.CurrentDirectory + System.IO.Path.AltDirectorySeparatorChar + BotConfig.GetParameter('ScriptDirectory'))
PluginLoader.LoadPluginsInAssembly(typeof(Stub).Assembly)
Database.Initialize()

RegexLibrary.Initialize()
PrivMSGRunner.Initialize()
RawMSGRunner.Initialize()
TimerRunner.Initialize()
PubSubRunner.Initialize()
PluginLoader.RegisterPlugins()
PluginLoader.RunPluginSetups()


ActionQueue.Initialize()

predibot = IrcConnection(BotConfig.GetParameter('IRCServer'), Int32.Parse(BotConfig.GetParameter('IRCPort')), BotConfig.GetParameter('Username'), BotConfig.GetParameter('IRCNick'), BotConfig.GetParameter('Channel'), BotConfig.GetParameter('NickservPassword'))
predibot.Connect()