///|
test "tuple destructuring evaluates" {
  let code = "let (x, y) = (20, 22) in x + y"
  assert_eq(@miniml.interpret(code), "42")
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
test "match guard evaluates" {
  let code =
    #| match [1, 2] with
    #| | x :: _ if x == 0 -> 0
    #| | x :: _ if x == 1 -> 42
    #| | _ -> 7
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
