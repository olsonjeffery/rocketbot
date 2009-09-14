namespace RocketBot

import System
import RocketBot.Core

BotConfig.Initialize('./RocketBot.config.xml', 'RocketBotConfiguration')
RegexLibrary.Initialize()
PrivMSGRunner.Initialize()
RawMSGRunner.Initialize()
TimerRunner.Initialize()
ActionQueue.Initialize()
PluginLoader.LoadPlugins(Environment.CurrentDirectory)
CoreCommands.SetupCommands()
predibot = IrcConnection(BotConfig.GetParameter('IRCServer'), Int32.Parse(BotConfig.GetParameter('IRCPort')), BotConfig.GetParameter('Username'), BotConfig.GetParameter('IRCNick'), BotConfig.GetParameter('Channel'), BotConfig.GetParameter('NickservPassword'))
predibot.Connect()