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

///|
test "non exhaustive list hint is human readable" {
  let msg = try {
    let _ = infer("match [] with | [] -> 0")
    "no error"
  } catch {
    TypeError(msg) => msg
    _ => "wrong error"
  }
  assert_eq(msg, "non-exhaustive match, missing pattern `[_]`")
}

///|
test "non exhaustive tuple hint is human readable" {
  let msg = try {
    let _ = infer("match (true, false) with | (true, _) -> 1")
    "no error"
  } catch {
    TypeError(msg) => msg
    _ => "wrong error"
  }
  assert_eq(msg, "non-exhaustive match, missing pattern `(false, true)`")
}

///|
test "redundant arm after wildcard is rejected" {
  let msg = try {
    let _ = infer("match true with | _ -> 1 | false -> 0")
    "no error"
  } catch {
    TypeError(msg) => msg
    _ => "wrong error"
  }
  assert_eq(msg, "redundant match arm `false`")
}

///|
test "redundant guarded arm after wildcard is rejected" {
  let msg = try {
    let _ = infer("match [1] with | _ -> 1 | x :: _ if x == 1 -> 2")
    "no error"
  } catch {
    TypeError(msg) => msg
    _ => "wrong error"
  }
  assert_eq(msg, "redundant match arm `[x, ...] if (x == 1)`")
}

///|
test "parse guard keeps shadowing pattern name" {
  let expr = parse("match xs with | x :: _ if x == 1 -> x | _ -> 0")
  match expr {
    MatchExpr(VarExpr("xs"), arms) => {
      assert_eq(arms.length(), 2)
      assert_true(arms[0].pattern is ConsPat(VarPat("x"), WildcardPat))
      assert_true(
        arms[0].guard_ is Some(BinaryExpr(Eq, VarExpr("x"), IntExpr(1))),
      )
      assert_true(arms[0].body is VarExpr("x"))
    }
    _ => assert_true(false)
  }
}

///|
test "tokenize constructors" {
  let tokens = tokenize("match Some 1 with | Some x -> x | None -> 0")
  assert_eq(tokens[1], CtorTok("Some"))
  assert_eq(tokens[5], CtorTok("Some"))
  assert_eq(tokens[10], CtorTok("None"))
}

///|
test "parse option match" {
  let expr = parse("match opt with | Some x -> x | None -> 0")
  match expr {
    MatchExpr(VarExpr("opt"), arms) => {
      assert_eq(arms.length(), 2)
      assert_true(arms[0].pattern is CtorPat("Some", [VarPat("x")]))
      assert_true(arms[0].body is VarExpr("x"))
      assert_true(arms[1].pattern is CtorPat("None", []))
      assert_true(arms[1].body is IntExpr(0))
    }
    _ => assert_true(false)
  }
}

///|
test "non exhaustive option hint is human readable" {
  let msg = try {
    let _ = infer("match None with | Some x -> x")
    "no error"
  } catch {
    TypeError(msg) => msg
    _ => "wrong error"
  }
  assert_eq(msg, "non-exhaustive match, missing pattern `None`")
}

///|
test "redundant option arm is rejected" {
  let msg = try {
    let _ = infer("match None with | _ -> 0 | None -> 1")
    "no error"
  } catch {
    TypeError(msg) => msg
    _ => "wrong error"
  }
  assert_eq(msg, "redundant match arm `None`")
}

///|
test "parse local enum expression" {
  let expr = parse(
    "enum Maybe = None | Some(int) in match Some 1 with | Some x -> x | None -> 0",
  )
  match expr {
    EnumExpr(decl, MatchExpr(ApplyExpr(VarExpr("Some"), IntExpr(1)), arms)) => {
      assert_eq(decl.name, "Maybe")
      assert_eq(decl.variants.length(), 2)
      assert_eq(decl.variants[0].name, "None")
      assert_true(decl.variants[0].payload is None)
      assert_eq(decl.variants[1].name, "Some")
      assert_true(decl.variants[1].payload is Some(IntDeclType))
      assert_true(arms[0].pattern is CtorPat("Some", [VarPat("x")]))
      assert_true(arms[1].pattern is CtorPat("None", []))
    }
    _ => assert_true(false)
  }
}

///|
test "non exhaustive user enum hint is human readable" {
  let msg = try {
    let _ = infer(
      "enum Traffic = Red | Yellow | Green in match Red with | Red -> 0 | Yellow -> 1",
    )
    "no error"
  } catch {
    TypeError(msg) => msg
    _ => "wrong error"
  }
  assert_eq(msg, "non-exhaustive match, missing pattern `Green`")
}

///|
test "redundant user enum arm is rejected" {
  let msg = try {
    let _ = infer(
      "enum Traffic = Red | Yellow in match Red with | _ -> 0 | Yellow -> 1",
    )
    "no error"
  } catch {
    TypeError(msg) => msg
    _ => "wrong error"
  }
  assert_eq(msg, "redundant match arm `Yellow`")
}

///|
test "enum constructors are scoped locally" {
  let msg = try {
    let _ = infer("enum Traffic = Red | Yellow in Red")
    let _ = infer("Red")
    "no error"
  } catch {
    TypeError(msg) => msg
    _ => "wrong error"
  }
  assert_eq(msg, "unbound variable `Red`")
}

///|
test "same enum name in different scopes stays nominally distinct" {
  let code =
    #| let f =
    #|   enum Traffic = Red | Yellow | Green in
    #|   fun light ->
    #|     match light with
    #|     | Red -> 0
    #|     | Yellow -> 1
    #|     | Green -> 2
    #| in
    #| enum Traffic = Foo in
    #| f Foo
  let msg = try {
    let _ = infer(code)
    "no error"
  } catch {
    TypeError(msg) => msg
    _ => "wrong error"
  }
  assert_eq(
    msg, "cannot unify distinct enum types `Traffic` and `Traffic` (same name, different scopes)",
  )
}
