namespace RocketBot.Core

import System
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

/*
public class PluginMacro(AbstractAstMacro):
  
  public override def Expand(plugin as MacroStatement) as Statement:
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
    
    //commands = GetCommands(body)
    
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
    //pluginClass.Members.Add(commands)
    
    parent as Node = plugin
    while not parent isa Module:
      parent = parent.ParentNode
    
    (parent as Module).Members.Add(pluginClass)
*/

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
  
  // add commands
  for m as Method in commands:
    methods as System.Collections.Generic.List of Method = System.Collections.Generic.List of Method()
    cmdType = m["commandType"] as string
    st as Statement
    if cmdType == "bot":
      commandNames = m["commandNames"] as List[of string]
      raise "null names?" if commandNames is null
      botNamesList = ReferenceExpression("bot_names_list"+PluginHelper.Rand.Next().ToString())
      blk = BlockExpression()
      getCommandsMethod.Body.Statements.Add(ExpressionStatement([| $botNamesList = System.Collections.Generic.List[of string]() |]))
      for name in commandNames:
        nameLiteral = StringLiteralExpression(name)
        getCommandsMethod.Body.Statements.Add(ExpressionStatement([| $botNamesList.Add($nameLiteral) |]))
      
      regexLiteral = m["reLiteral"] as RELiteralExpression
      raise "null re literal?" if regexLiteral is null
      raise "null method name?" if m.Name is null
      methodName = ReferenceExpression(m.Name)
      
      pattern = regexLiteral.ToCodeString().Remove(0, 1).Remove((regexLiteral.ToCodeString().Length-2), 1)
      
      methods.Add(m)
      
      getCommandsMethod.Body.Statements.Add(ExpressionStatement([| list.Add(CommandWrapper($botNamesList, System.Text.RegularExpressions.Regex($pattern), $methodName)) |]))
    elif cmdType == "raw":
      pass
    elif cmdType == "timer":
      pass
    else:
      raise "unknown command type in commands for plugin..."
    
    
  getCommandsMethod.Body.Statements.Add([| return list |])
  methods.Add(getCommandsMethod)
  return methods
  
public static class PluginHelper:
  public static Rand as Random = Random()