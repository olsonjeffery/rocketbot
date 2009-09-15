namespace RocketBot.Core

import System
import Boo.Lang.Compiler.Ast

macro desc:
  raise "desc must have a single argument and it has to be a string" if not desc.Arguments.Count == 1 and not desc.Arguments[0] isa StringLiteralExpression
  st = ExpressionStatement()
  st.Annotate("desc", desc.Arguments[0])
  return st