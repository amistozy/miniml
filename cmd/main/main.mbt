///|
fn load_source(args : Array[String]) -> String {
  if args.length() == 0 {
    return "let rec fact n = if n == 0 then 1 else n * fact (n - 1) in fact 5"
  }
  args.join(" ")
}

///|
fn main {
  let args = @env.args()[1:].to_owned()
  let source = load_source(args)
  println(@miniml.interpret(source)) catch {
    err => {
      println(err)
      panic()
    }
  }
}
