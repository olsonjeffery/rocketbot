namespace RocketBot.Scripts

import System
import RocketBot.Core

plugin HelpPlugin:
  name "help"
  desc "provides help for various bot functionality"
  version "0.1"
  author "pfox"
  bot_command '^(?<command>help)(?<args>.*)$', help, info:
    // if this is true, then instead of running the command, we just output
    // the documentation for this command to the requesting user via privmsg
    if displayDocs:
      // display syntax stuff here
      IrcConnection.SendPRIVMSG(message.Nick, 'Documentation for the \'help\' command:')
      IrcConnection.SendPRIVMSG(message.Nick, 'Syntax: help <command>')
      IrcConnection.SendPRIVMSG(message.Nick, 'Synonyms: none')
      IrcConnection.SendPRIVMSG(message.Nick, 'Alternative Syntax: none')
      IrcConnection.SendPRIVMSG(message.Nick, 'Parameters: command: the bot command for which you would like further help.')
      IrcConnection.SendPRIVMSG(message.Nick, 'Purpose: Provides the requesting user with documentation on the use and purpose of a given bot command.')
      
      return 
    
    args as string = message.Args.Trim()
    
    // check if this was executed with zero args.. if so then let's display
    // a list of commands that we can provide help for...
    if args == '':
      
      commandsString = ''
      
      keys as List[of string] = List[of string](PrivMSGRunner.Lexicon.Keys)
      keys.Sort()
      
      for key as string in keys:
        
        commandsString += (key + ', ')
        
      // chomp off the last two characters
      commandsString = commandsString.Remove((commandsString.Length - 2))
      
      IrcConnection.SendPRIVMSG(message.Nick, 'I have help documentation for the following commands:')
      IrcConnection.SendPRIVMSG(message.Nick, commandsString)
      return 
    
    // check and see if the requested command exists: if it does, then
    if not PrivMSGRunner.DoesCommandExist(args):
      
      IrcConnection.SendPRIVMSG(message.Nick, (('Sorry, the \'' + args) + '\' command does not exist.'))
      return 
      
    
    // since we're here, that means the command DOES EXIST.. so we'll
    // just make message.Command = message.Args .. and call ExecuteCommand()
    // again, but this time with the displayDocs bool set to true
    message.Command = args
    message.DisplayDocs = true
    PrivMSGRunner.ExecuteCommand(message)

