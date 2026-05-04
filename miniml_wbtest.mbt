///|
test "tokenize let rec program" {
  let tokens = tokenize("let rec id x = x in id 3")
  assert_eq(tokens.length() > 0, true)
  assert_eq(tokens[0], LetTok)
  assert_eq(tokens[1], RecTok)
}

///|
test "parse application associates to the left" {
  let expr = parse("f x y")
  assert_true(
    expr is ApplyExpr(ApplyExpr(VarExpr("f"), VarExpr("x")), VarExpr("y")),
  )
}
