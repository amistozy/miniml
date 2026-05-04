///|
test "tokenize match and cons" {
  let tokens = tokenize("match xs with | x :: _ -> x")
  assert_eq(tokens[0], MatchTok)
  assert_eq(tokens[2], WithTok)
  assert_eq(tokens[3], BarTok)
  assert_eq(tokens[5], ConsTok)
}

///|
test "parse tuple let pattern" {
  let expr = parse("let (x, y) = (1, 2) in x")
  assert_true(
    expr
    is LetExpr(
      TuplePat([VarPat("x"), VarPat("y")]),
      TupleExpr([IntExpr(1), IntExpr(2)]),
      VarExpr("x")
    ),
  )
}

///|
test "parse list pattern match" {
  let expr = parse("match [1] with | x :: xs -> x | [] -> 0")
  match expr {
    MatchExpr(ListExpr([IntExpr(1)]), arms) => {
      assert_eq(arms.length(), 2)
      assert_true(arms[0].pattern is ConsPat(VarPat("x"), VarPat("xs")))
      assert_true(arms[0].body is VarExpr("x"))
      assert_true(arms[1].pattern is NilPat)
      assert_true(arms[1].body is IntExpr(0))
    }
    _ => assert_true(false)
  }
}
