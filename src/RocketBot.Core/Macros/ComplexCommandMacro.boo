namespace RocketBot.Core

import System
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro complex_command:
  args = complex_command.Arguments
  raise "command can only have a single argument: a string literal representing a regular expression" if args.Count != 1 or not args[0] isa StringLiteralExpression
  
  commandRegex = args[0] as StringLiteralExpression
  
  method = Method()
  randNum = CommandHelper.Rand.Next()
  method.Name = "complex_command_"+randNum.ToString()
  method.Body = complex_command.Body.Clone()
  
  method.Parameters.Add(ParameterDeclaration("message", [| typeof(IncomingMessage) |].Type))
  method.Parameters.Add(ParameterDeclaration("displayDocs", [| typeof(bool) |].Type))
  
  
  method.Annotate("commandType", "complex")
  method.Annotate("reLiteral", commandRegex)
  
  exp = ExpressionStatement()
  exp.Annotate("command", method)
  
  return exp