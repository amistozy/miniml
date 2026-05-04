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
      assert_true(arms[0].guard_ is None)
      assert_true(arms[0].body is VarExpr("x"))
      assert_true(arms[1].pattern is NilPat)
      assert_true(arms[1].guard_ is None)
      assert_true(arms[1].body is IntExpr(0))
    }
    _ => assert_true(false)
  }
}

///|
test "parse match guard" {
  let expr = parse("match xs with | x :: _ if x == 1 -> x | _ -> 0")
  match expr {
    MatchExpr(VarExpr("xs"), arms) => {
      assert_eq(arms.length(), 2)
      assert_true(arms[0].pattern is ConsPat(VarPat("x"), WildcardPat))
      assert_true(
        arms[0].guard_ is Some(BinaryExpr(Eq, VarExpr("x"), IntExpr(1))),
      )
      assert_true(arms[1].guard_ is None)
    }
    _ => assert_true(false)
  }
}

///|
test "infer rejects non exhaustive bool match" {
  let msg = try {
    let _ = infer("match true with | false -> 0")
    "no error"
  } catch {
    TypeError(msg) => msg
    _ => "wrong error"
  }
  assert_eq(msg, "non-exhaustive match, missing pattern `true`")
}

///|
test "guarded arm does not make match exhaustive" {
  let msg = try {
    let _ = infer("match [] with | _ if true -> 1")
    "no error"
  } catch {
    TypeError(msg) => msg
    _ => "wrong error"
  }
  assert_eq(msg, "non-exhaustive match, missing pattern `[]`")
}
