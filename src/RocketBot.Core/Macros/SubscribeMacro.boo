namespace RocketBot.Core

import System
import Boo.Lang.Compiler.Ast
import Boo.Lang.PatternMatching

macro subscribe(target as ReferenceExpression):
  method = Method()
  randNum = CommandHelper.Rand.Next()
  method.Name = "subscribe_command_"+randNum.ToString()
  method.Body = subscribe.Body.Clone()
  
  method.Parameters.Add(ParameterDeclaration("message", [| typeof(IncomingMessage) |].Type))
  
  method.Annotate("commandType", "subscribe")
  method.Annotate("messageName", target)
  
  exp = ExpressionStatement()
  exp.Annotate("command", method)
  
  return exp