namespace RocketBot.Core

import System
import Boo.Lang.Compiler.Ast
import Boo.Lang.PatternMatching

macro publish(target as ReferenceExpression):
  targetStr = StringLiteralExpression(target.ToString())
  return  ExpressionStatement([| PubSubRunner.RaiseCommand($targetStr, message) |])