namespace RocketBot.Core

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
  desc = GetDescription(body)
  version = GetVersion(body)
  author = GetAuthor(body)
  setup = GetSetupIfAny(body)
  
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
  
  for command in commands:
    pluginClass.Members.Add(command)
  if setup is not null:
    pluginClass.Members.Add(setup)
  
  yield pluginClass

def GetName(body as Block, className as string) as StringLiteralExpression:
  sle = ScrapeBlockForTextAndReturnContentAsSLE("name", body)
  return sle if sle is not null
  return StringLiteralExpression(className)

def GetDescription(body as Block) as StringLiteralExpression:
  sle = ScrapeBlockForTextAndReturnContentAsSLE("desc", body)
  return sle if sle is not null
  return StringLiteralExpression(string.Empty)

def GetVersion(body as Block) as StringLiteralExpression:
  sle = ScrapeBlockForTextAndReturnContentAsSLE("version", body)
  return sle if sle is not null
  return StringLiteralExpression(string.Empty)

def GetAuthor(body as Block) as StringLiteralExpression:
  sle = ScrapeBlockForTextAndReturnContentAsSLE("author", body)
  return sle if sle is not null
  return StringLiteralExpression(string.Empty)

def ScrapeBlockForTextAndReturnContentAsSLE(text as string, body as Block) as StringLiteralExpression:
  for i as Statement in body.Statements:
    if i isa ExpressionStatement:
      es = i as ExpressionStatement
      if es.ContainsAnnotation(text):
        return es[text] as StringLiteralExpression
  return null

def GetSetupIfAny(body as Block) as Method:
  for i as Statement in body.Statements:
    if i isa ExpressionStatement:
      es = i as ExpressionStatement
      if es.ContainsAnnotation("setup"):
        return es["method"] as Method
  stub = [|
    public def Setup():
      pass
  |]
  return stub

def GetCommands(body as Block) as Method*:
  commands = List[of Method]()

  for i as Statement in body.Statements:
    if i isa ExpressionStatement:
      es = i as ExpressionStatement
      if es.ContainsAnnotation("command"):
        commands.Add(es["command"] as Method)
  
  getCommandsMethod = [|
    public def GetCommands() as System.Collections.Generic.List[of CommandWrapper]:
      list = System.Collections.Generic.List[of CommandWrapper]()
  |]
  
  methods as System.Collections.Generic.List of Method = System.Collections.Generic.List of Method()
  // add commands
  for m as Method in commands:
    
    cmdType = m["commandType"] as string
    if cmdType == "bot":
      commandNames = m["commandNames"] as List[of string]
      raise "null names?" if commandNames is null
      botNamesList = ReferenceExpression("bot_names_list"+PluginHelper.Rand.Next().ToString())
      getCommandsMethod.Body.Statements.Add(ExpressionStatement([| $botNamesList = System.Collections.Generic.List[of string]() |]))
      for name in commandNames:
        nameLiteral = StringLiteralExpression(name)
        getCommandsMethod.Body.Statements.Add(ExpressionStatement([| $botNamesList.Add($nameLiteral) |]))
      
      regexLiteral = m["reLiteral"] as StringLiteralExpression
      raise "null re literal?" if regexLiteral is null
      raise "null method name?" if m.Name is null
      methodName = ReferenceExpression(m.Name)
      
      pattern = regexLiteral
      
      methods.Add(m)
      
      getCommandsMethod.Body.Statements.Add(ExpressionStatement([| list.Add(CommandWrapper($botNamesList, System.Text.RegularExpressions.Regex($pattern), $methodName)) |]))
    elif cmdType == "raw":
      commandName = StringLiteralExpression(m["commandName"] as string)
      raise "null names?" if commandName is null
      regexLiteral = m["reLiteral"] as StringLiteralExpression
      raise "null re literal?" if regexLiteral is null
      raise "null method name?" if m.Name is null
      methodName = ReferenceExpression(m.Name)
      pattern = regexLiteral
      methods.Add(m)
      getCommandsMethod.Body.Statements.Add(ExpressionStatement([| list.Add(CommandWrapper($commandName, System.Text.RegularExpressions.Regex($pattern), $methodName)) |]))
    elif cmdType == "timer":
      pass
    elif cmdType == "complex":
      regexLiteral = m["reLiteral"] as StringLiteralExpression
      raise "null re literal?" if regexLiteral is null
      raise "null method name?" if m.Name is null
      methodName = ReferenceExpression(m.Name)
      pattern = regexLiteral
      methods.Add(m)
      getCommandsMethod.Body.Statements.Add(ExpressionStatement([| list.Add(CommandWrapper(System.Text.RegularExpressions.Regex($pattern), $methodName)) |]))
    else:
      raise "unknown command type in commands for plugin..."
    
    
  getCommandsMethod.Body.Statements.Add([| return list |])
  methods.Add(getCommandsMethod)
  return methods
  
public static class PluginHelper:
  public Rand as Random = Random()