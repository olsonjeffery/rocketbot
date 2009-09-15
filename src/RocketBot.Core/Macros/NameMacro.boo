namespace RocketBot.Core

import System
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

macro name:
  raise "name must have a single argument and it has to be a string" if not name.Arguments.Count == 1 and not name.Arguments[0] isa StringLiteralExpression
  st = ExpressionStatement()
  st.Annotate("name", name.Arguments[0])
  return st