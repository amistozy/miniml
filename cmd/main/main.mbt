///|
fn empty_env() -> Map[String, String] {
  {}
}

///|
fn usage_command() -> @argparse.Command {
  @argparse.Command(
    "miniml",
    about="MiniML interpreter with HM type inference",
    version="0.1.0",
    flags=[
      FlagArg("type", short='t', long="type", about="Print inferred type."),
      FlagArg(
        "tokens",
        long="tokens",
        about="Print tokens before parsing/interpreting.",
      ),
      FlagArg("ast", long="ast", about="Print parsed AST before interpreting."),
    ],
    options=[
      OptionArg(
        "expr",
        short='e',
        long="expr",
        about="Interpret the given expression string.",
      ),
      OptionArg(
        "file",
        short='f',
        long="file",
        about="Read source code from a file.",
      ),
    ],
    positionals=[
      PositionArg(
        "code",
        about="Expression text when --expr/--file is not used.",
        num_args=ValueRange(lower=0),
      ),
    ],
    groups=[ArgGroup("input", args=["expr", "file"], multiple=false)],
  )
}

///|
fn first_value(matches : @argparse.Matches, key : String) -> String? {
  match matches.values.get(key) {
    Some([value, ..]) => Some(value)
    _ => None
  }
}

///|
fn load_source(matches : @argparse.Matches) -> String raise {
  match first_value(matches, "expr") {
    Some(expr) => expr
    None =>
      match first_value(matches, "file") {
        Some(path) => @fs.read_file_to_string(path)
        None =>
          match matches.values.get("code") {
            Some(parts) if !parts.is_empty() => parts.join(" ")
            _ =>
              "let rec fact n = if n == 0 then 1 else n * fact (n - 1) in fact 5"
          }
      }
  }
}

///|
fn run_cli() -> Unit raise {
  let cmd = usage_command()
  let matches = cmd.parse(argv=@env.args()[1:], env=empty_env())
  let source = load_source(matches)
  if matches.flags.get("tokens") is Some(true) {
    for token in @miniml.tokenize(source) {
      println(token)
    }
  }
  if matches.flags.get("ast") is Some(true) {
    println(@miniml.parse(source))
  }
  if matches.flags.get("type") is Some(true) {
    println(@miniml.infer(source))
  }
  println(@miniml.interpret(source))
}

///|
fn main {
  try {
    run_cli()
  } catch {
    err => println(err)
  }
}
