namespace RocketBot.Core

import System
import Boo.Lang.Compiler.Ast

macro author:
  raise "author must have a single argument and it has to be a string" if not author.Arguments.Count == 1 and not author.Arguments[0] isa StringLiteralExpression
  st = ExpressionStatement()
  st.Annotate("author", author.Arguments[0])
  return st