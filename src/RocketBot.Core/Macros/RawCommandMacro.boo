namespace RocketBot.Core

import System
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro raw_command:
  args = raw_command.Arguments
  raise "command must only one arguments: a string literal of regex to determine what it matches on" if not args.Count == 1 or not args[0] isa StringLiteralExpression
  
  commandRegex as StringLiteralExpression = args[0]
  
  method = Method()
  randNum = CommandHelper.Rand.Next()
  method.Name = "raw_command_"+randNum.ToString()
  method.Body = raw_command.Body.Clone()
  
  method.Parameters.Add(ParameterDeclaration("message", [| typeof(IncomingMessage) |].Type))
  
  
  method.Annotate("commandType", "raw")
  method.Annotate("commandName", method.Name)
  method.Annotate("reLiteral", commandRegex)
  
  exp = ExpressionStatement()
  exp.Annotate("command", method)
  
  return exp