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
      None,
      TupleExpr([IntExpr(1), IntExpr(2)]),
      VarExpr("x")
    ),
  )
}

///|
test "parse unit literal" {
  let expr = parse("()")
  assert_true(expr is UnitExpr)
}

///|
test "tokenize type annotation colon" {
  let tokens = tokenize("fun (x : int) -> x")
  assert_eq(tokens[3], ColonTok)
}

///|
test "tokenize string literal" {
  let tokens = tokenize("\"hi\\nmini\"")
  assert_eq(tokens[0], StringTok("hi\nmini"))
}

///|
test "tokenize char literal" {
  let tokens = tokenize("'\\n'")
  assert_eq(tokens[0], CharTok('\n'))
}

///|
test "tokenize semicolon" {
  let tokens = tokenize("(); 1")
  assert_eq(tokens[2], SemiTok)
}

///|
test "tokenize braces" {
  let tokens = tokenize("{ () }")
  assert_eq(tokens[0], LBraceTok)
  assert_eq(tokens[3], RBraceTok)
}

///|
test "tokenize let rec and keyword" {
  let tokens = tokenize("let rec even n = odd n and odd n = even n in even 0")
  assert_eq(tokens[0], LetTok)
  assert_eq(tokens[1], RecTok)
  assert_true(tokens.contains(AndKwTok))
}

///|
test "parse annotated fun binder" {
  let expr = parse("fun (x : int option) -> x")
  assert_true(
    expr is FunExpr("x", Some(OptionDeclType(IntDeclType)), VarExpr("x")),
  )
}

///|
test "parse annotated let rec" {
  let expr = parse("let rec sum (xs : int list) : int = 0 in sum")
  assert_true(
    expr
    is LetRecExpr(
      "sum",
      "xs",
      Some(ListDeclType(IntDeclType)),
      Some(IntDeclType),
      IntExpr(0),
      VarExpr("sum")
    ),
  )
}

///|
test "parse expression ascription" {
  let expr = parse("(Some 1) : int option")
  assert_true(
    expr
    is AscribeExpr(
      ApplyExpr(VarExpr("Some"), IntExpr(1)),
      OptionDeclType(IntDeclType)
    ),
  )
}

///|
test "parse string literal expression" {
  let expr = parse("\"hello\"")
  assert_true(expr is StringExpr("hello"))
}

///|
test "parse char literal expression" {
  let expr = parse("'a'")
  assert_true(expr is CharExpr('a'))
}

///|
test "parse sequence expression" {
  let expr = parse("(); 1")
  assert_true(expr is SeqExpr(UnitExpr, IntExpr(1)))
}

///|
test "parse char annotation" {
  let expr = parse("let c : char = 'x' in c")
  assert_true(
    expr
    is LetExpr(VarPat("c"), Some(CharDeclType), CharExpr('x'), VarExpr("c")),
  )
}

///|
test "parse empty block expression" {
  let expr = parse("{}")
  assert_true(expr is UnitExpr)
}

///|
test "parse block expression as sequence" {
  let expr = parse("{ (); 1 }")
  assert_true(expr is SeqExpr(UnitExpr, IntExpr(1)))
}

///|
test "parse block let desugars to let expression" {
  let expr = parse("{ let x = 1; x }")
  assert_true(expr is LetExpr(VarPat("x"), None, IntExpr(1), VarExpr("x")))
}

///|
test "parse block enum desugars to enum expression" {
  let expr = parse("{ enum Traffic = Red | Green; Green }")
  match expr {
    EnumExpr(decl, VarExpr("Green")) => {
      assert_eq(decl.name, "Traffic")
      assert_eq(decl.variants.length(), 2)
      assert_eq(decl.variants[0].name, "Red")
      assert_eq(decl.variants[1].name, "Green")
    }
    _ => assert_true(false)
  }
}

///|
test "parse block let rec desugars to let rec expression" {
  let expr = parse("{ let rec loop () = 42; loop }")
  match expr {
    LetRecExpr(
      "loop",
      param,
      None,
      None,
      LetExpr(UnitPat, None, VarExpr(arg), IntExpr(42)),
      VarExpr("loop")
    ) => assert_eq(param, arg)
    _ => assert_true(false)
  }
}

///|
test "parse unit annotation" {
  let expr = parse("let x : unit = () in x")
  assert_true(
    expr is LetExpr(VarPat("x"), Some(UnitDeclType), UnitExpr, VarExpr("x")),
  )
}

///|
test "sequence is right associative" {
  let expr = parse("(); (); 1")
  assert_true(expr is SeqExpr(UnitExpr, SeqExpr(UnitExpr, IntExpr(1))))
}

///|
test "parse block expression allows trailing semicolon" {
  let expr = parse("{ (); }")
  assert_true(expr is SeqExpr(UnitExpr, UnitExpr))
}

///|
test "parse block expression can mix expr then let" {
  let expr = parse("{ (); let x = 1; x }")
  assert_true(
    expr
    is SeqExpr(UnitExpr, LetExpr(VarPat("x"), None, IntExpr(1), VarExpr("x"))),
  )
}

///|
test "parse block expression can mix expr then enum" {
  let expr = parse("{ (); enum Traffic = Red | Green; Green }")
  match expr {
    SeqExpr(UnitExpr, EnumExpr(decl, VarExpr("Green"))) => {
      assert_eq(decl.name, "Traffic")
      assert_eq(decl.variants.length(), 2)
    }
    _ => assert_true(false)
  }
}

///|
test "ascription has lower precedence than let" {
  let expr = parse("let x = 1 in x : int")
  assert_true(
    expr
    is LetExpr(
      VarPat("x"),
      None,
      IntExpr(1),
      AscribeExpr(VarExpr("x"), IntDeclType)
    ),
  )
}

///|
test "parenthesized let can be ascribed as a whole" {
  let expr = parse("(let x = 1 in x) : int")
  assert_true(
    expr
    is AscribeExpr(
      LetExpr(VarPat("x"), None, IntExpr(1), VarExpr("x")),
      IntDeclType
    ),
  )
}

///|
test "parse multi parameter fun desugars to nested funs" {
  let expr = parse("fun x y -> x")
  assert_true(expr is FunExpr("x", None, FunExpr("y", None, VarExpr("x"))))
}

///|
test "parse fun tuple pattern parameter desugars through let" {
  let expr = parse("fun (x, y) -> x")
  match expr {
    FunExpr(
      param,
      None,
      LetExpr(
        TuplePat([VarPat("x"), VarPat("y")]),
        None,
        VarExpr(arg),
        VarExpr("x")
      )
    ) => assert_eq(param, arg)
    _ => assert_true(false)
  }
}

///|
test "parse let function sugar desugars to nested funs" {
  let expr = parse("let add x y = x + y in add")
  assert_true(
    expr
    is LetExpr(
      VarPat("add"),
      None,
      FunExpr(
        "x",
        None,
        FunExpr("y", None, BinaryExpr(Add, VarExpr("x"), VarExpr("y")))
      ),
      VarExpr("add")
    ),
  )
}

///|
test "parse let function sugar with pattern parameter desugars through let" {
  let expr = parse("let fst (x, _) = x in fst")
  match expr {
    LetExpr(
      VarPat("fst"),
      None,
      FunExpr(
        param,
        None,
        LetExpr(
          TuplePat([VarPat("x"), WildcardPat]),
          None,
          VarExpr(arg),
          VarExpr("x")
        )
      ),
      VarExpr("fst")
    ) => assert_eq(param, arg)
    _ => assert_true(false)
  }
}

///|
test "parse multi parameter let rec with return annotation" {
  let expr = parse("let rec add (x : int) (y : int) : int = x + y in add")
  assert_true(
    expr
    is LetRecExpr(
      "add",
      "x",
      Some(IntDeclType),
      None,
      FunExpr(
        "y",
        Some(IntDeclType),
        AscribeExpr(BinaryExpr(Add, VarExpr("x"), VarExpr("y")), IntDeclType)
      ),
      VarExpr("add")
    ),
  )
}

///|
test "parse string annotation" {
  let expr = parse("let msg : string = \"hi\" in msg")
  assert_true(
    expr
    is LetExpr(
      VarPat("msg"),
      Some(StringDeclType),
      StringExpr("hi"),
      VarExpr("msg")
    ),
  )
}

///|
test "parse let rec tuple pattern parameter desugars through let" {
  let expr = parse("let rec fst (x, _) = x in fst")
  match expr {
    LetRecExpr(
      "fst",
      param,
      None,
      None,
      LetExpr(
        TuplePat([VarPat("x"), WildcardPat]),
        None,
        VarExpr(arg),
        VarExpr("x")
      ),
      VarExpr("fst")
    ) => assert_eq(param, arg)
    _ => assert_true(false)
  }
}

///|
test "parse mutually recursive let rec group" {
  let expr = parse("let rec even n = odd n and odd n = even n in even")
  match expr {
    LetRecGroupExpr(bindings, VarExpr("even")) => {
      assert_eq(bindings.length(), 2)
      assert_eq(bindings[0].name, "even")
      assert_eq(bindings[0].param, "n")
      assert_true(
        bindings[0].fun_body is ApplyExpr(VarExpr("odd"), VarExpr("n")),
      )
      assert_eq(bindings[1].name, "odd")
      assert_eq(bindings[1].param, "n")
      assert_true(
        bindings[1].fun_body is ApplyExpr(VarExpr("even"), VarExpr("n")),
      )
    }
    _ => assert_true(false)
  }
}

///|
test "parse let and group" {
  let expr = parse("let x = 1 and y = 2 in (x, y)")
  match expr {
    LetGroupExpr(bindings, TupleExpr([VarExpr("x"), VarExpr("y")])) => {
      assert_eq(bindings.length(), 2)
      assert_true(bindings[0].pattern is VarPat("x"))
      assert_true(bindings[0].annot is None)
      assert_true(bindings[0].bound is IntExpr(1))
      assert_true(bindings[1].pattern is VarPat("y"))
      assert_true(bindings[1].bound is IntExpr(2))
    }
    _ => assert_true(false)
  }
}

///|
test "parse let and function sugar" {
  let expr = parse("let add x y = x + y and one = 1 in add")
  match expr {
    LetGroupExpr(bindings, VarExpr("add")) => {
      assert_eq(bindings.length(), 2)
      assert_true(
        bindings[0].bound
        is FunExpr(
          "x",
          None,
          FunExpr("y", None, BinaryExpr(Add, VarExpr("x"), VarExpr("y")))
        ),
      )
      assert_true(bindings[1].bound is IntExpr(1))
    }
    _ => assert_true(false)
  }
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
test "parse unit pattern match" {
  let expr = parse("match () with | () -> 1")
  match expr {
    MatchExpr(UnitExpr, arms) => {
      assert_eq(arms.length(), 1)
      assert_true(arms[0].pattern is UnitPat)
      assert_true(arms[0].body is IntExpr(1))
    }
    _ => assert_true(false)
  }
}

///|
test "parse char pattern match" {
  let expr = parse("match 'x' with | 'x' -> 1 | _ -> 0")
  match expr {
    MatchExpr(CharExpr('x'), arms) => {
      assert_eq(arms.length(), 2)
      assert_true(arms[0].pattern is CharPat('x'))
      assert_true(arms[1].pattern is WildcardPat)
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
      assert_eq(decl.type_params.length(), 0)
      assert_eq(decl.variants.length(), 2)
      assert_eq(decl.variants[0].name, "None")
      assert_eq(decl.variants[0].fields.length(), 0)
      assert_eq(decl.variants[1].name, "Some")
      assert_eq(decl.variants[1].fields.length(), 1)
      assert_true(decl.variants[1].fields[0] is IntDeclType)
      assert_true(arms[0].pattern is CtorPat("Some", [VarPat("x")]))
      assert_true(arms[1].pattern is CtorPat("None", []))
    }
    _ => assert_true(false)
  }
}

///|
test "parse parameterized enum and multi arg constructor" {
  let expr = parse(
    "enum Result[a, e] = Ok(a) | Err(e) | Pair(a, e) in Pair(1, true)",
  )
  match expr {
    EnumExpr(
      decl,
      ApplyExpr(ApplyExpr(VarExpr("Pair"), IntExpr(1)), BoolExpr(true))
    ) => {
      assert_eq(decl.name, "Result")
      assert_eq(decl.type_params, ["a", "e"])
      assert_eq(decl.variants.length(), 3)
      assert_eq(decl.variants[2].name, "Pair")
      assert_eq(decl.variants[2].fields.length(), 2)
      assert_true(decl.variants[2].fields[0] is TypeVarDeclType("a"))
      assert_true(decl.variants[2].fields[1] is TypeVarDeclType("e"))
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

///|
test "parameterized enum conflict mentions type arguments" {
  let code =
    #| let f =
    #|   enum Box[a] = Box(a) in
    #|   fun x ->
    #|     match x with
    #|     | Box(v) -> v
    #| in
    #| enum Box[a] = Box(a) in
    #| f (Box(1))
  let msg = try {
    let _ = infer(code)
    "no error"
  } catch {
    TypeError(msg) => msg
    _ => "wrong error"
  }
  assert_eq(
    msg, "cannot unify distinct enum types `Box['t0]` and `Box[int]` (same name, different scopes)",
  )
}
