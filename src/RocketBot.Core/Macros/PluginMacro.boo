namespace RocketBot.Core.Macros

import System
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro plugin:
  args = plugin.Arguments
  raise "plugin must have an identifier!" if args.Count == 0
  raise "plugin must have a 'safe' identifier for its identifier, example: plugin FooPlugin" if not args[0] isa ReferenceExpression
  raise "plugin takse only a single argument, its identifier. example: plguin FooPlugin" if args.Count > 1
  
  className = args[0].ToString()
  
  body = plugin.Body
  name = GetName(body, className)
  desc = StringLiteralExpression("")
  version = StringLiteralExpression("")
  author = StringLiteralExpression("")
  
  commands = GetCommands(body)
  
  pluginClass = [|
    public class $(ReferenceExpression(className))(IPlugin):
      Name as string:
        get:
          return $name
      Description as string:
        get:
          return $desc
      Version as string:
        get:
          return $version
      Author as string:
        get:
          return $author
  |]
  pluginClass.Members.Add(commands)
  yield pluginClass

def GetName(body as Block, className as string) as StringLiteralExpression:
  for i as Statement in body.Statements:
    if i isa MacroStatement:
      ms = i as MacroStatement
      if ms.Name == "name":
        return ms.Arguments[0] as StringLiteralExpression
  return StringLiteralExpression(className)

def GetCommands(body as Block) as Method:
  return null