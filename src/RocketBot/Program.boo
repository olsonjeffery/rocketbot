
/*
 * This is the Main() containing code for the predibot project. Also where
 * the changelog/todo is located
 *
 * AUTHORS: 
 *  - Original, basic IrcBot class coded by Pasi Havia 
 *  19.11.2001 http://www.c-sharpcorner.com/UploadFile/pasihavia/IrcBot11222005231107PM/IrcBot.aspx
 *  
 *  - Modified heavily and retooled/expanded by jeff olson
 *  circa 2007
*/


namespace Predibot

import System
import PredibotLib

PredibotLib.Configuration.Initialize('./RocketBot.config.xml', 'RocketBotConfiguration')
RegexLibrary.Initialize()
PrivMSGRunner.Initialize()
RawMSGRunner.Initialize()
TimerRunner.Initialize()
ActionQueue.Initialize()
PluginLoader.LoadPlugins(Environment.CurrentDirectory)
CoreCommands.SetupCommands()
predibot = IrcConnection(PredibotLib.Configuration.GetParameter('IRCServer'), Int32.Parse(PredibotLib.Configuration.GetParameter('IRCPort')), PredibotLib.Configuration.GetParameter('Username'), PredibotLib.Configuration.GetParameter('IRCNick'), PredibotLib.Configuration.GetParameter('Channel'), PredibotLib.Configuration.GetParameter('NickservPassword'))
predibot.Connect()