namespace RocketBot.Core

import System
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro bot_command:
  args = bot_command.Arguments
  raise "command must have at least two arguments: first a string literal consisting of regex to match on and then one or more reference expressions for the command names" if not args.Count >= 2
  
  commandRegex as StringLiteralExpression
  names = List of string()
  for arg in args:
    if arg == args[0]:
      raise "the first argument must be a string literal" if not arg isa StringLiteralExpression
      commandRegex = arg
    else:
      raise "any argument after the first must be a reference expression" if not arg isa ReferenceExpression
      names.Add(arg.ToString())
  
  method = Method()
  randNum = CommandHelper.Rand.Next()
  method.Name = "bot_command_"+randNum.ToString()
  method.Body = bot_command.Body.Clone()
  
  method.Parameters.Add(ParameterDeclaration("message", [| typeof(IncomingMessage) |].Type))
  method.Parameters.Add(ParameterDeclaration("displayDocs", [| typeof(bool) |].Type))
  
  
  method.Annotate("commandType", "bot")
  method.Annotate("commandNames", names)
  method.Annotate("reLiteral", commandRegex)
  
  exp = ExpressionStatement()
  exp.Annotate("command", method)
  
  return exp


public static class CommandHelper:
  public Rand as Random = Random()