///|
pub suberror MiniMLError {
  LexError(String)
  ParseError(String)
  RuntimeError(String)
}

///|
pub impl Show for MiniMLError with output(self, logger) {
  match self {
    LexError(msg) => logger.write_string("Lex error: " + msg)
    ParseError(msg) => logger.write_string("Parse error: " + msg)
    RuntimeError(msg) => logger.write_string("Runtime error: " + msg)
  }
}

///|
pub(all) enum Token {
  IntTok(Int)
  BoolTok(Bool)
  IdentTok(String)
  LetTok
  InTok
  RecTok
  FunTok
  IfTok
  ThenTok
  ElseTok
  LParenTok
  RParenTok
  ArrowTok
  EqTok
  PlusTok
  MinusTok
  StarTok
  SlashTok
  EqEqTok
  NotEqTok
  LtTok
  LeTok
  GtTok
  GeTok
  AndTok
  OrTok
  NotTok
  EOFTok
} derive(Eq)

///|
pub impl Show for Token with output(self, logger) {
  let s = match self {
    IntTok(n) => "Int(\{n})"
    BoolTok(b) => "Bool(\{b})"
    IdentTok(name) => "Ident(\{name})"
    LetTok => "let"
    InTok => "in"
    RecTok => "rec"
    FunTok => "fun"
    IfTok => "if"
    ThenTok => "then"
    ElseTok => "else"
    LParenTok => "("
    RParenTok => ")"
    ArrowTok => "->"
    EqTok => "="
    PlusTok => "+"
    MinusTok => "-"
    StarTok => "*"
    SlashTok => "/"
    EqEqTok => "=="
    NotEqTok => "!="
    LtTok => "<"
    LeTok => "<="
    GtTok => ">"
    GeTok => ">="
    AndTok => "&&"
    OrTok => "||"
    NotTok => "!"
    EOFTok => "<eof>"
  }
  logger.write_string(s)
}

///|
pub(all) enum BinaryOp {
  Add
  Sub
  Mul
  Div
  Eq
  NE
  LT
  LE
  GT
  GE
  And
  Or
}

///|
pub impl Show for BinaryOp with output(self, logger) {
  let s = match self {
    Add => "+"
    Sub => "-"
    Mul => "*"
    Div => "/"
    Eq => "=="
    NE => "!="
    LT => "<"
    LE => "<="
    GT => ">"
    GE => ">="
    And => "&&"
    Or => "||"
  }
  logger.write_string(s)
}

///|
pub(all) enum Expr {
  IntExpr(Int)
  BoolExpr(Bool)
  VarExpr(String)
  IfExpr(Expr, Expr, Expr)
  LetExpr(String, Expr, Expr)
  LetRecExpr(String, String, Expr, Expr)
  FunExpr(String, Expr)
  ApplyExpr(Expr, Expr)
  BinaryExpr(BinaryOp, Expr, Expr)
  NegExpr(Expr)
  NotExpr(Expr)
}

///|
pub impl Show for Expr with output(self, logger) {
  logger.write_string(expr_to_string(self))
}

///|
pub(all) struct Env {
  bindings : Map[String, Ref[Value?]]
  parent : Env?
}

///|
pub(all) enum Value {
  IntValue(Int)
  BoolValue(Bool)
  ClosureValue(String, Expr, Env)
}

///|
pub impl Show for Value with output(self, logger) {
  logger.write_string(value_to_string(self))
}

///|
fn expr_to_string(expr : Expr) -> String {
  match expr {
    IntExpr(n) => n.to_string()
    BoolExpr(b) => b.to_string()
    VarExpr(name) => name
    IfExpr(cond, then_, else_) =>
      "if \{expr_to_string(cond)} then \{expr_to_string(then_)} else \{expr_to_string(else_)}"
    LetExpr(name, bound, body) =>
      "let \{name} = \{expr_to_string(bound)} in \{expr_to_string(body)}"
    LetRecExpr(name, param, fun_body, body) =>
      "let rec \{name} \{param} = \{expr_to_string(fun_body)} in \{expr_to_string(body)}"
    FunExpr(param, body) => "fun \{param} -> \{expr_to_string(body)}"
    ApplyExpr(func, arg) => "(\{expr_to_string(func)} \{expr_to_string(arg)})"
    BinaryExpr(op, lhs, rhs) =>
      "(\{expr_to_string(lhs)} \{op.to_string()} \{expr_to_string(rhs)})"
    NegExpr(inner) => "(-\{expr_to_string(inner)})"
    NotExpr(inner) => "(!\{expr_to_string(inner)})"
  }
}

///|
fn value_to_string(value : Value) -> String {
  match value {
    IntValue(n) => n.to_string()
    BoolValue(b) => b.to_string()
    ClosureValue(_, _, _) => "<fun>"
  }
}

///|
fn token_to_string(token : Token) -> String {
  token.to_string()
}

///|
fn Env::new(parent? : Env? = None) -> Env {
  Env::{ bindings: Map::new(), parent }
}

///|
fn Env::extend(self : Env, name : String, value : Value) -> Env {
  let env = Env::new(parent=Some(self))
  env.bindings.set(name, @ref.new(Some(value)))
  env
}

///|
fn Env::extend_cell(self : Env, name : String, cell : Ref[Value?]) -> Env {
  let env = Env::new(parent=Some(self))
  env.bindings.set(name, cell)
  env
}

///|
fn Env::lookup(self : Env, name : String) -> Value raise MiniMLError {
  match self.bindings.get(name) {
    Some(cell) =>
      match cell.val {
        Some(value) => value
        None =>
          raise RuntimeError("recursive binding `\{name}` is not initialized")
      }
    None =>
      match self.parent {
        Some(parent) => parent.lookup(name)
        None => raise RuntimeError("unbound variable `\{name}`")
      }
  }
}

///|
fn is_digit(c : Char) -> Bool {
  c >= '0' && c <= '9'
}

///|
fn is_alpha(c : Char) -> Bool {
  (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
}

///|
fn is_ident_char(c : Char) -> Bool {
  is_alpha(c) || is_digit(c) || c == '_'
}

///|
fn read_number(code : StringView, acc? : Int = 0) -> (Int, StringView) {
  match code {
    [c, .. rest] if is_digit(c) =>
      read_number(rest, acc=acc * 10 + c.to_int() - '0'.to_int())
    _ => (acc, code)
  }
}

///|
fn read_ident(code : StringView, acc? : String = "") -> (String, StringView) {
  match code {
    [c, .. rest] if is_ident_char(c) =>
      read_ident(rest, acc=acc + c.to_string())
    _ => (acc, code)
  }
}

///|
fn skip_line_comment(code : StringView) -> StringView {
  match code {
    ['\n', .. rest] => rest
    [_, .. rest] => skip_line_comment(rest)
    [] => code
  }
}

///|
pub fn tokenize(code : String) -> Array[Token] raise MiniMLError {
  let tokens = Array::new()
  let mut rest = code[:]
  while true {
    match rest {
      [] => {
        tokens.push(EOFTok)
        break
      }
      [' ' | '\t' | '\r' | '\n', .. next] => rest = next
      [.. "//", .. next] => rest = skip_line_comment(next)
      [.. "->", .. next] => {
        tokens.push(ArrowTok)
        rest = next
      }
      [.. "==", .. next] => {
        tokens.push(EqEqTok)
        rest = next
      }
      [.. "!=", .. next] => {
        tokens.push(NotEqTok)
        rest = next
      }
      [.. "<=", .. next] => {
        tokens.push(LeTok)
        rest = next
      }
      [.. ">=", .. next] => {
        tokens.push(GeTok)
        rest = next
      }
      [.. "&&", .. next] => {
        tokens.push(AndTok)
        rest = next
      }
      [.. "||", .. next] => {
        tokens.push(OrTok)
        rest = next
      }
      ['(', .. next] => {
        tokens.push(LParenTok)
        rest = next
      }
      [')', .. next] => {
        tokens.push(RParenTok)
        rest = next
      }
      ['+', .. next] => {
        tokens.push(PlusTok)
        rest = next
      }
      ['-', .. next] => {
        tokens.push(MinusTok)
        rest = next
      }
      ['*', .. next] => {
        tokens.push(StarTok)
        rest = next
      }
      ['/', .. next] => {
        tokens.push(SlashTok)
        rest = next
      }
      ['=', .. next] => {
        tokens.push(EqTok)
        rest = next
      }
      ['<', .. next] => {
        tokens.push(LtTok)
        rest = next
      }
      ['>', .. next] => {
        tokens.push(GtTok)
        rest = next
      }
      ['!', .. next] => {
        tokens.push(NotTok)
        rest = next
      }
      [c, ..] if is_digit(c) => {
        let (n, next) = read_number(rest)
        tokens.push(IntTok(n))
        rest = next
      }
      [c, ..] if is_alpha(c) || c == '_' => {
        let (ident, next) = read_ident(rest)
        let token = match ident {
          "let" => LetTok
          "in" => InTok
          "rec" => RecTok
          "fun" => FunTok
          "if" => IfTok
          "then" => ThenTok
          "else" => ElseTok
          "true" => BoolTok(true)
          "false" => BoolTok(false)
          _ => IdentTok(ident)
        }
        tokens.push(token)
        rest = next
      }
      [c, ..] => raise LexError("unexpected character `\{c.to_string()}`")
    }
  }
  tokens
}

///|
fn is_atom_start(token : Token) -> Bool {
  match token {
    IntTok(_) | BoolTok(_) | IdentTok(_) | LParenTok => true
    _ => false
  }
}

///|
fn expect_token(
  tokens : ArrayView[Token],
  expected : Token,
) -> ArrayView[Token] raise MiniMLError {
  guard tokens is [tok, .. rest] else {
    raise ParseError(
      "expected \{token_to_string(expected)}, but reached end of input",
    )
  }
  if tok == expected {
    rest
  } else {
    raise ParseError(
      "expected \{token_to_string(expected)}, got \{token_to_string(tok)}",
    )
  }
}

///|
fn expect_ident(
  tokens : ArrayView[Token],
) -> (String, ArrayView[Token]) raise MiniMLError {
  guard tokens is [tok, .. rest] else {
    raise ParseError("expected identifier, but reached end of input")
  }
  match tok {
    IdentTok(name) => (name, rest)
    _ => raise ParseError("expected identifier, got \{token_to_string(tok)}")
  }
}

///|
fn parse_atom(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  guard tokens is [tok, .. rest] else {
    raise ParseError("expected expression, but reached end of input")
  }
  match tok {
    IntTok(n) => (IntExpr(n), rest)
    BoolTok(b) => (BoolExpr(b), rest)
    IdentTok(name) => (VarExpr(name), rest)
    LParenTok => {
      let (expr, rest) = parse_expr(rest)
      let rest = expect_token(rest, RParenTok)
      (expr, rest)
    }
    _ => raise ParseError("expected atom, got \{token_to_string(tok)}")
  }
}

///|
fn parse_prefix(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  guard tokens is [tok, .. rest] else {
    raise ParseError("expected expression, but reached end of input")
  }
  match tok {
    MinusTok => {
      let (expr, rest) = parse_prefix(rest)
      (NegExpr(expr), rest)
    }
    NotTok => {
      let (expr, rest) = parse_prefix(rest)
      (NotExpr(expr), rest)
    }
    _ => parse_atom(tokens)
  }
}

///|
fn parse_application(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  let (expr0, rest0) = parse_prefix(tokens)
  let mut expr = expr0
  let mut rest = rest0
  while true {
    match rest {
      [tok, ..] if is_atom_start(tok) => {
        let (arg, next_rest) = parse_prefix(rest)
        expr = ApplyExpr(expr, arg)
        rest = next_rest
      }
      _ => break
    }
  }
  (expr, rest)
}

///|
fn parse_mul(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  let (expr0, rest0) = parse_application(tokens)
  let mut expr = expr0
  let mut rest = rest0
  while true {
    match rest {
      [StarTok, .. rest2] => {
        let (rhs, next_rest) = parse_application(rest2)
        expr = BinaryExpr(Mul, expr, rhs)
        rest = next_rest
      }
      [SlashTok, .. rest2] => {
        let (rhs, next_rest) = parse_application(rest2)
        expr = BinaryExpr(Div, expr, rhs)
        rest = next_rest
      }
      _ => break
    }
  }
  (expr, rest)
}

///|
fn parse_add(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  let (expr0, rest0) = parse_mul(tokens)
  let mut expr = expr0
  let mut rest = rest0
  while true {
    match rest {
      [PlusTok, .. rest2] => {
        let (rhs, next_rest) = parse_mul(rest2)
        expr = BinaryExpr(Add, expr, rhs)
        rest = next_rest
      }
      [MinusTok, .. rest2] => {
        let (rhs, next_rest) = parse_mul(rest2)
        expr = BinaryExpr(Sub, expr, rhs)
        rest = next_rest
      }
      _ => break
    }
  }
  (expr, rest)
}

///|
fn parse_compare(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  let (expr0, rest0) = parse_add(tokens)
  let mut expr = expr0
  let mut rest = rest0
  while true {
    match rest {
      [EqEqTok, .. rest2] => {
        let (rhs, next_rest) = parse_add(rest2)
        expr = BinaryExpr(Eq, expr, rhs)
        rest = next_rest
      }
      [NotEqTok, .. rest2] => {
        let (rhs, next_rest) = parse_add(rest2)
        expr = BinaryExpr(NE, expr, rhs)
        rest = next_rest
      }
      [LtTok, .. rest2] => {
        let (rhs, next_rest) = parse_add(rest2)
        expr = BinaryExpr(LT, expr, rhs)
        rest = next_rest
      }
      [LeTok, .. rest2] => {
        let (rhs, next_rest) = parse_add(rest2)
        expr = BinaryExpr(LE, expr, rhs)
        rest = next_rest
      }
      [GtTok, .. rest2] => {
        let (rhs, next_rest) = parse_add(rest2)
        expr = BinaryExpr(GT, expr, rhs)
        rest = next_rest
      }
      [GeTok, .. rest2] => {
        let (rhs, next_rest) = parse_add(rest2)
        expr = BinaryExpr(GE, expr, rhs)
        rest = next_rest
      }
      _ => break
    }
  }
  (expr, rest)
}

///|
fn parse_and(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  let (expr0, rest0) = parse_compare(tokens)
  let mut expr = expr0
  let mut rest = rest0
  while true {
    match rest {
      [AndTok, .. rest2] => {
        let (rhs, next_rest) = parse_compare(rest2)
        expr = BinaryExpr(And, expr, rhs)
        rest = next_rest
      }
      _ => break
    }
  }
  (expr, rest)
}

///|
fn parse_or(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  let (expr0, rest0) = parse_and(tokens)
  let mut expr = expr0
  let mut rest = rest0
  while true {
    match rest {
      [OrTok, .. rest2] => {
        let (rhs, next_rest) = parse_and(rest2)
        expr = BinaryExpr(Or, expr, rhs)
        rest = next_rest
      }
      _ => break
    }
  }
  (expr, rest)
}

///|
fn parse_fun(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  guard tokens is [tok, .. rest] else {
    raise ParseError("expected expression, but reached end of input")
  }
  if tok != FunTok {
    return parse_or(tokens)
  }
  let (param, rest) = expect_ident(rest)
  let rest = expect_token(rest, ArrowTok)
  let (body, rest) = parse_expr(rest)
  (FunExpr(param, body), rest)
}

///|
fn parse_if(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  guard tokens is [tok, .. rest] else {
    raise ParseError("expected expression, but reached end of input")
  }
  if tok != IfTok {
    return parse_fun(tokens)
  }
  let (cond, rest) = parse_expr(rest)
  let rest = expect_token(rest, ThenTok)
  let (then_, rest) = parse_expr(rest)
  let rest = expect_token(rest, ElseTok)
  let (else_, rest) = parse_expr(rest)
  (IfExpr(cond, then_, else_), rest)
}

///|
fn parse_let(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  guard tokens is [tok, .. rest] else {
    raise ParseError("expected expression, but reached end of input")
  }
  if tok != LetTok {
    return parse_if(tokens)
  }
  guard rest is [tok2, .. rest2] else {
    raise ParseError("incomplete let expression")
  }
  if tok2 == RecTok {
    let (name, rest3) = expect_ident(rest2)
    let (param, rest4) = expect_ident(rest3)
    let rest5 = expect_token(rest4, EqTok)
    let (fun_body, rest6) = parse_expr(rest5)
    let rest7 = expect_token(rest6, InTok)
    let (body, rest8) = parse_expr(rest7)
    (LetRecExpr(name, param, fun_body, body), rest8)
  } else {
    let (name, rest3) = expect_ident(rest)
    let rest4 = expect_token(rest3, EqTok)
    let (bound, rest5) = parse_expr(rest4)
    let rest6 = expect_token(rest5, InTok)
    let (body, rest7) = parse_expr(rest6)
    (LetExpr(name, bound, body), rest7)
  }
}

///|
fn parse_expr(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  parse_let(tokens)
}

///|
pub fn parse(code : String) -> Expr raise MiniMLError {
  let tokens = tokenize(code)
  let (expr, rest) = parse_expr(tokens[:])
  match rest {
    [EOFTok, ..] => expr
    [tok, ..] =>
      raise ParseError("unexpected trailing token \{token_to_string(tok)}")
    [] => expr
  }
}

///|
fn eval_binary(
  op : BinaryOp,
  lhs : Value,
  rhs : Value,
) -> Value raise MiniMLError {
  match (op, lhs, rhs) {
    (Add, IntValue(a), IntValue(b)) => IntValue(a + b)
    (Sub, IntValue(a), IntValue(b)) => IntValue(a - b)
    (Mul, IntValue(a), IntValue(b)) => IntValue(a * b)
    (Div, IntValue(a), IntValue(b)) => {
      if b == 0 {
        raise RuntimeError("division by zero")
      }
      IntValue(a / b)
    }
    (Eq, IntValue(a), IntValue(b)) => BoolValue(a == b)
    (NE, IntValue(a), IntValue(b)) => BoolValue(a != b)
    (LT, IntValue(a), IntValue(b)) => BoolValue(a < b)
    (LE, IntValue(a), IntValue(b)) => BoolValue(a <= b)
    (GT, IntValue(a), IntValue(b)) => BoolValue(a > b)
    (GE, IntValue(a), IntValue(b)) => BoolValue(a >= b)
    (Eq, BoolValue(a), BoolValue(b)) => BoolValue(a == b)
    (NE, BoolValue(a), BoolValue(b)) => BoolValue(a != b)
    (And, BoolValue(a), BoolValue(b)) => BoolValue(a && b)
    (Or, BoolValue(a), BoolValue(b)) => BoolValue(a || b)
    _ =>
      raise RuntimeError(
        "type mismatch in binary operation `\{op.to_string()}`",
      )
  }
}

///|
fn eval_expr(expr : Expr, env : Env) -> Value raise MiniMLError {
  match expr {
    IntExpr(n) => IntValue(n)
    BoolExpr(b) => BoolValue(b)
    VarExpr(name) => env.lookup(name)
    IfExpr(cond, then_, else_) =>
      match eval_expr(cond, env) {
        BoolValue(true) => eval_expr(then_, env)
        BoolValue(false) => eval_expr(else_, env)
        _ => raise RuntimeError("if condition must be a bool")
      }
    LetExpr(name, bound, body) => {
      let value = eval_expr(bound, env)
      let next_env = env.extend(name, value)
      eval_expr(body, next_env)
    }
    LetRecExpr(name, param, fun_body, body) => {
      let cell : Ref[Value?] = @ref.new(None)
      let rec_env = env.extend_cell(name, cell)
      let closure = ClosureValue(param, fun_body, rec_env)
      cell.val = Some(closure)
      eval_expr(body, rec_env)
    }
    FunExpr(param, body) => ClosureValue(param, body, env)
    ApplyExpr(func, arg) => {
      let func_value = eval_expr(func, env)
      let arg_value = eval_expr(arg, env)
      match func_value {
        ClosureValue(param, body, closure_env) => {
          let call_env = closure_env.extend(param, arg_value)
          eval_expr(body, call_env)
        }
        _ => raise RuntimeError("attempted to call a non-function value")
      }
    }
    BinaryExpr(And, lhs, rhs) =>
      match eval_expr(lhs, env) {
        BoolValue(false) => BoolValue(false)
        BoolValue(true) =>
          match eval_expr(rhs, env) {
            BoolValue(b) => BoolValue(b)
            _ => raise RuntimeError("right-hand side of && must be a bool")
          }
        _ => raise RuntimeError("left-hand side of && must be a bool")
      }
    BinaryExpr(Or, lhs, rhs) =>
      match eval_expr(lhs, env) {
        BoolValue(true) => BoolValue(true)
        BoolValue(false) =>
          match eval_expr(rhs, env) {
            BoolValue(b) => BoolValue(b)
            _ => raise RuntimeError("right-hand side of || must be a bool")
          }
        _ => raise RuntimeError("left-hand side of || must be a bool")
      }
    BinaryExpr(op, lhs, rhs) => {
      let left_value = eval_expr(lhs, env)
      let right_value = eval_expr(rhs, env)
      eval_binary(op, left_value, right_value)
    }
    NegExpr(inner) =>
      match eval_expr(inner, env) {
        IntValue(n) => IntValue(0 - n)
        _ => raise RuntimeError("unary - expects an int")
      }
    NotExpr(inner) =>
      match eval_expr(inner, env) {
        BoolValue(b) => BoolValue(!b)
        _ => raise RuntimeError("unary ! expects a bool")
      }
  }
}

///|
pub fn eval(code : String) -> Value raise MiniMLError {
  let expr = parse(code)
  eval_expr(expr, Env::new())
}

///|
pub fn interpret(code : String) -> String raise MiniMLError {
  value_to_string(eval(code))
}
