namespace RocketBot.Core

import System
import Boo.Lang.Compiler.Ast
import Boo.Lang.PatternMatching

macro timer_command(target as IntegerLiteralExpression):
  method = Method()
  randNum = CommandHelper.Rand.Next()
  method.Name = "timer_command_"+randNum.ToString()
  method.Body = timer_command.Body.Clone()
  
  method.Annotate("commandType", "timer")
  method.Annotate("interval", target)
  
  exp = ExpressionStatement()
  exp.Annotate("command", method)
  
  return exp