namespace RocketBot.Core

import System
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro bot_command:
  args = bot_command.Arguments
  raise "command must have either: a reference expression or a string literal for the first argument and then one or more reference expressions for the command names, if the first arg was a string literal." if not args.Count >= 1
  raise "when having a single argument for a bot command, the argument MUST be a reference expression, example: bot_command foo" if not args[0] isa ReferenceExpression and args.Count == 1
  
  commandRegex as StringLiteralExpression
  names = List of string()
  if args[0] isa StringLiteralExpression:
    for arg in args:
      if arg == args[0]:
        raise "the first argument must be a string literal" if not arg isa StringLiteralExpression
        commandRegex = arg
      else:
        raise "any argument after the first must be a reference expression" if not arg isa ReferenceExpression
        names.Add(arg.ToString())
  else:
    cmds = "("
    for arg in args:
      raise "every arg must be a reference expression if the first argument wasn't a string literal" if not arg isa ReferenceExpression
      names.Add(arg.ToString())
      cmds += arg.ToString() + "|"
    cmds = cmds.Remove(cmds.Length - 1, 1)
    cmds += ')'
    rawRegex = '^(?<command>{template}) (?<args>.*)$'.Replace('{template}', cmds)
    commandRegex = StringLiteralExpression(rawRegex)
  
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