///|
test "arithmetic and precedence" {
  assert_eq(@miniml.interpret("1 + 2 * 3"), "7")
}

///|
test "let binding" {
  assert_eq(@miniml.interpret("let x = 41 in x + 1"), "42")
}

///|
test "closure capture" {
  let code = "let add = fun x -> fun y -> x + y in " +
    "let inc = add 1 in inc 41"
  assert_eq(@miniml.interpret(code), "42")
}

///|
test "recursive function" {
  let code = "let rec fact n = if n == 0 then 1 else n * fact (n - 1) in fact 5"
  assert_eq(@miniml.interpret(code), "120")
}

///|
test "boolean control flow" {
  let code = "if true && false then 0 else if 3 < 4 then 1 else 2"
  assert_eq(@miniml.interpret(code), "1")
}
