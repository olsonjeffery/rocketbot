namespace RocketBot.Core

import System
import Boo.Lang.Compiler.Ast

macro version:
  raise "version must have a single argument and it has to be a string" if not version.Arguments.Count == 1 and not version.Arguments[0] isa StringLiteralExpression
  st = ExpressionStatement()
  st.Annotate("version", version.Arguments[0])
  return st