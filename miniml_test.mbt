///|
test "tuple destructuring evaluates" {
  let code = "let (x, y) = (20, 22) in x + y"
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "unit literal evaluates" {
  assert_eq(@miniml.interpret("()"), "()")
}

///|
test "list pattern match evaluates" {
  let code =
    #| let xs = [1, 2, 3] in
    #| match xs with | [] -> 0 | x :: rest -> x
  assert_eq(@miniml.interpret(code), "1")
}

///|
test "recursive list function evaluates" {
  let code =
    #| let rec sum xs =
    #|   match xs with
    #|   | [] -> 0
    #|   | x :: rest -> x + sum rest
    #| in sum [1, 2, 3, 4]
  assert_eq(@miniml.interpret(code), "10")
}

///|
test "polymorphic let infers identity across tuple" {
  let code = "let id = fun x -> x in (id 1, id true)"
  assert_eq(@miniml.interpret(code), "(1, true)")
}

///|
test "infer tuple list and match types" {
  let code =
    #| let head = fun xs -> match xs with | x :: _ -> x | [] -> 0 in
    #| (head [1, 2], head [])
  assert_eq(@miniml.infer(code), "(int * int)")
}

///|
test "infer polymorphic identity" {
  assert_eq(@miniml.infer("fun x -> x"), "'t0 -> 't0")
}

///|
test "unit literal infers unit type" {
  assert_eq(@miniml.infer("()"), "unit")
}

///|
test "char literal evaluates" {
  assert_eq(@miniml.interpret("'a'"), "'a'")
}

///|
test "char literal infers char type" {
  assert_eq(@miniml.infer("'a'"), "char")
}

///|
test "sequence evaluates in order and returns rhs" {
  let code = "(); 42"
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "sequence infers rhs type" {
  assert_eq(@miniml.infer("(); \"ok\""), "string")
}

///|
test "empty block evaluates to unit" {
  assert_eq(@miniml.interpret("{}"), "()")
}

///|
test "block expression evaluates to final value" {
  assert_eq(@miniml.interpret("{ (); 42 }"), "42")
}

///|
test "block expression with trailing semicolon evaluates to unit" {
  assert_eq(@miniml.interpret("{ (); }"), "()")
}

///|
test "block expression infers final type" {
  assert_eq(@miniml.infer("{ (); \"done\" }"), "string")
}

///|
test "block let introduces local scope" {
  assert_eq(@miniml.interpret("{ let x = 40; x + 2 }"), "42")
}

///|
test "block enum introduces local constructors" {
  let code =
    #| {
    #|   enum Traffic = Red | Green;
    #|   match Green with
    #|   | Red -> 0
    #|   | Green -> 42
    #| }
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "block let rec supports local recursion" {
  let code =
    #| {
    #|   let rec fact n =
    #|     if n == 0 then 1 else n * fact (n - 1);
    #|   fact 5
    #| }
  assert_eq(@miniml.interpret(code), "120")
}

///|
test "block can mix expression then let" {
  let code = "{ (); let x = 41; x + 1 }"
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "block can mix expression then enum" {
  let code =
    #| {
    #|   ();
    #|   enum Answer = Answer(int);
    #|   match Answer(42) with
    #|   | Answer(x) -> x
    #| }
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "block let can end with declaration and produce unit" {
  let code = "{ let x = 1 }"
  assert_eq(@miniml.interpret(code), "()")
}

///|
test "block enum can end with declaration and produce unit" {
  let code = "{ enum Traffic = Red | Green }"
  assert_eq(@miniml.interpret(code), "()")
}

///|
test "string literal evaluates and prints escaped" {
  let code = "\"hi\\nmini\""
  assert_eq(@miniml.interpret(code), "\"hi\\nmini\"")
}

///|
test "string literal infers string type" {
  assert_eq(@miniml.infer("\"hello\""), "string")
}

///|
test "match guard evaluates" {
  let code =
    #| match [1, 2] with
    #| | x :: _ if x == 0 -> 0
    #| | x :: _ if x == 1 -> 42
    #| | _ -> 7
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "unit pattern match evaluates" {
  let code = "match () with | () -> 42"
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "char pattern match evaluates" {
  let code = "match 'x' with | 'x' -> 42 | _ -> 0"
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "match guard pattern binding shadows outer name" {
  let code =
    #| let x = 100 in
    #| match [1] with
    #| | x :: _ if x == 1 -> x
    #| | _ -> 0
  assert_eq(@miniml.interpret(code), "1")
}

///|
test "failed match guard does not leak shadowed binding" {
  let code =
    #| let x = 100 in
    #| match [1] with
    #| | x :: _ if x == 2 -> x
    #| | _ -> x
  assert_eq(@miniml.interpret(code), "100")
}

///|
test "match guard can use both outer and pattern scoped names" {
  let code =
    #| let target = 3 in
    #| match (3, 4) with
    #| | (target, y) if y == 4 -> target
    #| | _ -> 0
  assert_eq(@miniml.interpret(code), "3")
}

///|
test "infer match guard with shadowed name keeps inner type" {
  let code =
    #| let x = true in
    #| match [1] with
    #| | x :: _ if x == 1 -> x
    #| | _ -> 0
  assert_eq(@miniml.infer(code), "int")
}

///|
test "option constructor match evaluates" {
  let code = "match Some 1 with | Some x -> x | None -> 0"
  assert_eq(@miniml.interpret(code), "1")
}

///|
test "option constructor survives let binding" {
  let code =
    #| let wrap = fun x -> Some x in
    #| match wrap 42 with
    #| | Some y -> y
    #| | None -> 0
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "infer some constructor type" {
  assert_eq(@miniml.infer("fun x -> Some x"), "'t0 -> 't0 option")
}

///|
test "infer option match type" {
  let code =
    #| let get_or = fun opt ->
    #|   match opt with
    #|   | Some x -> x
    #|   | None -> 0
    #| in get_or
  assert_eq(@miniml.infer(code), "int option -> int")
}

///|
test "user defined enum match evaluates" {
  let code =
    #| enum Maybe = None | Some(int) in
    #| match Some 42 with
    #| | Some x -> x
    #| | None -> 0
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "user defined enum type inference works" {
  let code =
    #| enum Traffic = Red | Yellow | Green in
    #| fun light ->
    #|   match light with
    #|   | Red -> 0
    #|   | Yellow -> 1
    #|   | Green -> 2
  assert_eq(@miniml.infer(code), "Traffic -> int")
}

///|
test "user defined enum constructor can carry tuple payload" {
  let code =
    #| enum PairBox = Box((int * bool)) in
    #| match Box((1, true)) with
    #| | Box((x, y)) -> if y then x else 0
  assert_eq(@miniml.interpret(code), "1")
}

///|
test "multi argument variant direct syntax evaluates" {
  let code =
    #| enum Rgb = RGB(int, int, int) in
    #| match RGB(1, 2, 3) with
    #| | RGB(r, g, b) -> r + g + b
  assert_eq(@miniml.interpret(code), "6")
}

///|
test "parameterized enum constructors infer polymorphically" {
  let code =
    #| enum Option[a] = None | Some(a) in
    #| fun x -> Some x
  assert_eq(@miniml.infer(code), "'t0 -> Option['t0]")
}

///|
test "parameterized enum match evaluates" {
  let code =
    #| enum Result[a, e] = Ok(a) | Err(e) in
    #| match Ok(42) with
    #| | Ok(x) -> x
    #| | Err(_) -> 0
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "recursive parameterized enum evaluates" {
  let code =
    #| enum List[a] = Nil | Cons(a, List[a]) in
    #| let rec sum xs =
    #|   match xs with
    #|   | Nil -> 0
    #|   | Cons(x, rest) -> x + sum rest
    #| in
    #| sum (Cons(1, Cons(2, Cons(3, Nil))))
  assert_eq(@miniml.interpret(code), "6")
}

///|
test "recursive parameterized enum infers recursive function type" {
  let code =
    #| enum List[a] = Nil | Cons(a, List[a]) in
    #| let rec length xs =
    #|   match xs with
    #|   | Nil -> 0
    #|   | Cons(_, rest) -> 1 + length rest
    #| in
    #| length
  assert_eq(@miniml.infer(code), "List['t0] -> int")
}

///|
test "annotated let binding evaluates" {
  let code = "let answer : int = 42 in answer"
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "annotated function parameter constrains inference" {
  let code = "fun (x : int option) -> match x with | Some y -> y | None -> 0"
  assert_eq(@miniml.infer(code), "int option -> int")
}

///|
test "annotated recursive function evaluates" {
  let code =
    #| let rec sum (xs : int list) : int =
    #|   match xs with
    #|   | [] -> 0
    #|   | x :: rest -> x + sum rest
    #| in
    #| sum [1, 2, 3, 4]
  assert_eq(@miniml.interpret(code), "10")
}

///|
test "annotation mismatch is rejected" {
  let msg = try {
    let _ = @miniml.infer("let x : bool = 1 in x")
    "no error"
  } catch {
    TypeError(msg) => msg
    _ => "wrong error"
  }
  assert_eq(msg, "cannot unify int with bool")
}

///|
test "unit annotation evaluates" {
  let code = "let done : unit = () in done"
  assert_eq(@miniml.interpret(code), "()")
}

///|
test "char annotation evaluates" {
  let code = "let c : char = 'z' in c"
  assert_eq(@miniml.interpret(code), "'z'")
}

///|
test "string annotation evaluates" {
  let code = "let greet : string = \"hello\" in greet"
  assert_eq(@miniml.interpret(code), "\"hello\"")
}

///|
test "free type variable annotation is rejected" {
  let msg = try {
    let _ = @miniml.infer("fun (x : a) -> x")
    "no error"
  } catch {
    TypeError(msg) => msg
    _ => "wrong error"
  }
  assert_eq(msg, "type annotation cannot use free type variable `a`")
}

///|
test "expression ascription evaluates" {
  let code = "(Some 42 : int option)"
  assert_eq(@miniml.interpret(code), "Some(42)")
}

///|
test "expression ascription constrains type" {
  let code = "((fun x -> x) : int -> int) 7"
  assert_eq(@miniml.interpret(code), "7")
}

///|
test "expression ascription inferred type is preserved" {
  assert_eq(@miniml.infer("(Some 1 : int option)"), "int option")
}

///|
test "string equality works" {
  let code = "if \"mini\" == \"mini\" then 42 else 0"
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "unit equality works" {
  let code = "if () == () then 42 else 0"
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "char equality works" {
  let code = "if 'a' == 'a' then 42 else 0"
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "sequence rejects non unit lhs" {
  let msg = try {
    let _ = @miniml.infer("1; 2")
    "no error"
  } catch {
    TypeError(msg) => msg
    _ => "wrong error"
  }
  assert_eq(msg, "cannot unify int with unit")
}

///|
test "expression ascription mismatch is rejected" {
  let msg = try {
    let _ = @miniml.infer("(1 : bool)")
    "no error"
  } catch {
    TypeError(msg) => msg
    _ => "wrong error"
  }
  assert_eq(msg, "cannot unify int with bool")
}

///|
test "expression ascription can wrap let expression" {
  let code = "(let id = fun x -> x in id 1) : int"
  assert_eq(@miniml.interpret(code), "1")
}

///|
test "multi parameter fun evaluates by currying" {
  let code = "(fun x y -> x + y) 20 22"
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "multi parameter fun inference nests arrows" {
  assert_eq(@miniml.infer("fun x y -> x"), "'t0 -> 't1 -> 't0")
}

///|
test "fun pattern parameter evaluates via let destructuring" {
  let code = "(fun (x, y) -> x + y) (20, 22)"
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "fun pattern parameter infers from tuple argument" {
  assert_eq(@miniml.infer("fun (x, _) -> x"), "('t0 * 't1) -> 't0")
}

///|
test "let function sugar evaluates" {
  let code = "let add x y = x + y in add 19 23"
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "let function sugar supports pattern parameter" {
  let code = "let fst (x, _) = x in fst (42, false)"
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "let function sugar pattern parameter constrains function type" {
  let code = "let swap ((x, y), z) = (z, x, y) in swap"
  assert_eq(@miniml.infer(code), "(('t0 * 't1) * 't2) -> ('t2 * 't0 * 't1)")
}

///|
test "enum can carry string payload" {
  let code =
    #| enum Message = Text(string) in
    #| match Text("hello") with
    #| | Text(msg) -> msg
  assert_eq(@miniml.interpret(code), "\"hello\"")
}

///|
test "let function sugar with parameter annotations constrains type" {
  let code = "let pick (x : int) (y : bool) = if y then x else 0 in pick"
  assert_eq(@miniml.infer(code), "int -> bool -> int")
}

///|
test "multi parameter let rec evaluates" {
  let code =
    #| let rec pow base exp =
    #|   if exp == 0 then 1 else base * pow base (exp - 1)
    #| in
    #| pow 2 5
  assert_eq(@miniml.interpret(code), "32")
}

///|
test "let rec supports pattern parameter" {
  let code =
    #| let rec sum_pair (x, y) =
    #|   if y == 0 then x else sum_pair (x + 1, y - 1)
    #| in
    #| sum_pair (20, 22)
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "let rec pattern parameter infers from tuple argument" {
  let code = "let rec fst_pair (x, _) = x in fst_pair"
  assert_eq(@miniml.infer(code), "('t0 * 't1) -> 't0")
}

///|
test "fun unit parameter infers unit domain" {
  let code = "fun () -> 42"
  assert_eq(@miniml.infer(code), "unit -> int")
}

///|
test "multi parameter let rec return annotation constrains result" {
  let code = "let rec add (x : int) (y : int) : int = x + y in add"
  assert_eq(@miniml.infer(code), "int -> int -> int")
}

///|
test "mutually recursive even odd evaluates" {
  let code =
    #| let rec even n =
    #|   if n == 0 then true else odd (n - 1)
    #| and odd n =
    #|   if n == 0 then false else even (n - 1)
    #| in
    #| even 10
  assert_eq(@miniml.interpret(code), "true")
}

///|
test "mutually recursive functions infer types" {
  let code =
    #| let rec even n =
    #|   if n == 0 then true else odd (n - 1)
    #| and odd n =
    #|   if n == 0 then false else even (n - 1)
    #| in
    #| (even, odd)
  assert_eq(@miniml.infer(code), "(int -> bool * int -> bool)")
}

///|
test "mutually recursive annotations constrain both bindings" {
  let code =
    #| let rec even (n : int) : bool =
    #|   if n == 0 then true else odd (n - 1)
    #| and odd (n : int) : bool =
    #|   if n == 0 then false else even (n - 1)
    #| in
    #| odd
  assert_eq(@miniml.infer(code), "int -> bool")
}

///|
test "let and group evaluates" {
  let code = "let x = 20 and y = 22 in x + y"
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "let and group supports function sugar" {
  let code = "let add x y = x + y and one = 1 in add one 41"
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "let and group is simultaneous not sequential" {
  let msg = try {
    let _ = @miniml.infer("let x = 1 and y = x in y")
    "no error"
  } catch {
    TypeError(msg) => msg
    _ => "wrong error"
  }
  assert_eq(msg, "unbound variable `x`")
}

///|
test "let and group body sees all bindings" {
  let code = "let x = 1 and y = 2 in (x, y)"
  assert_eq(@miniml.interpret(code), "(1, 2)")
}

///|
test "let and group generalizes independently" {
  let code = "let id = fun x -> x and k = 1 in (id true, id k)"
  assert_eq(@miniml.interpret(code), "(true, 1)")
}
