namespace RocketBot.Core

import System
import Boo.Lang.Compiler.Ast

macro docs:
  raise "the docs macro must have at least one argument. example: 'docs foo' or 'docs foo, bar'" if docs.Arguments.Count < 1
  list = List of ReferenceExpression()
  for arg in docs.Arguments:
    raise "the docs macro must have arguments that are valid reference expressions. example: 'docs foo' or 'docs foo, bar'" if not arg isa ReferenceExpression
    list.Add(arg)
  raise "the contents of a docs macro must only be a multiline string literal" if not docs.Body.Statements.Count == 1 and not docs.Body.Statements[0] isa StringLiteralExpression
  
  st = ExpressionStatement()
  st.Annotate("value", (docs.Body.Statements[0] as ExpressionStatement).Expression as StringLiteralExpression)
  st.Annotate("names", list)
  st.Annotate("docs", true)
  return st