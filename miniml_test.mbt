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
