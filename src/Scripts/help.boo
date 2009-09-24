namespace RocketBot.Scripts

import System
import System.Linq.Enumerable from System.Core
import RocketBot.Core

plugin HelpPlugin:
  name "help"
  desc "provides help for various bot functionality"
  version "0.1"
  author "pfox"
  
  docs help, info, docs:
    """
syntax: !help <topic> (or !info, !docs)
    """
  
  bot_command help, info, docs, doc:
    if message.Args == string.Empty:
      allTopics = string.Empty
      topics = Docs.GetTopics()
      for topic in topics:
        allTopics += topic
        allTopics += ", " unless topic == topics.Last()
      IrcConnection.SendPRIVMSG(message.Nick, "I have documentation on the following topics: "+allTopics)
    else:
      docs = Docs.GetDocsFor(message.Args)
      if docs == null:
        IrcConnection.SendPRIVMSG(message.Nick, "Sorry, there is no documentation for '"+message.Args+"'")
      else:
        for line in docs:
          IrcConnection.SendPRIVMSG(message.Nick, line)