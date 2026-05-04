///|
pub suberror MiniMLError {
  LexError(String)
  ParseError(String)
  RuntimeError(String)
  TypeError(String)
}

///|
pub impl Show for MiniMLError with output(self, logger) {
  match self {
    LexError(msg) => logger.write_string("Lex error: " + msg)
    ParseError(msg) => logger.write_string("Parse error: " + msg)
    RuntimeError(msg) => logger.write_string("Runtime error: " + msg)
    TypeError(msg) => logger.write_string("Type error: " + msg)
  }
}

///|
pub(all) enum Token {
  IntTok(Int)
  BoolTok(Bool)
  IdentTok(String)
  WildcardTok
  LetTok
  InTok
  RecTok
  FunTok
  IfTok
  ThenTok
  ElseTok
  MatchTok
  WithTok
  LParenTok
  RParenTok
  LBracketTok
  RBracketTok
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
  ConsTok
  CommaTok
  BarTok
  EOFTok
} derive(Eq)

///|
pub impl Show for Token with output(self, logger) {
  let s = match self {
    IntTok(n) => "Int(\{n})"
    BoolTok(b) => "Bool(\{b})"
    IdentTok(name) => "Ident(\{name})"
    WildcardTok => "_"
    LetTok => "let"
    InTok => "in"
    RecTok => "rec"
    FunTok => "fun"
    IfTok => "if"
    ThenTok => "then"
    ElseTok => "else"
    MatchTok => "match"
    WithTok => "with"
    LParenTok => "("
    RParenTok => ")"
    LBracketTok => "["
    RBracketTok => "]"
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
    ConsTok => "::"
    CommaTok => ","
    BarTok => "|"
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
pub(all) enum Pattern {
  WildcardPat
  IntPat(Int)
  BoolPat(Bool)
  VarPat(String)
  TuplePat(Array[Pattern])
  NilPat
  ConsPat(Pattern, Pattern)
}

///|
pub impl Show for Pattern with output(self, logger) {
  logger.write_string(pattern_to_string(self))
}

///|
pub(all) struct MatchArm {
  pattern : Pattern
  guard_ : Expr?
  body : Expr
}

///|
pub(all) enum Expr {
  IntExpr(Int)
  BoolExpr(Bool)
  VarExpr(String)
  IfExpr(Expr, Expr, Expr)
  LetExpr(Pattern, Expr, Expr)
  LetRecExpr(String, String, Expr, Expr)
  FunExpr(String, Expr)
  ApplyExpr(Expr, Expr)
  BinaryExpr(BinaryOp, Expr, Expr)
  NegExpr(Expr)
  NotExpr(Expr)
  TupleExpr(Array[Expr])
  ListExpr(Array[Expr])
  ConsExpr(Expr, Expr)
  MatchExpr(Expr, Array[MatchArm])
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
  TupleValue(Array[Value])
  NilValue
  ConsValue(Value, Value)
}

///|
pub impl Show for Value with output(self, logger) {
  logger.write_string(value_to_string(self))
}

///|
pub(all) enum Type {
  IntType
  BoolType
  VarType(Int)
  FunType(Type, Type)
  TupleType(Array[Type])
  ListType(Type)
} derive(Eq)

///|
pub(all) struct Scheme {
  vars : Array[Int]
  ty : Type
}

///|
pub(all) struct TypeEnv {
  bindings : Map[String, Scheme]
  parent : TypeEnv?
}

///|
priv struct InferCtx {
  mut next_id : Int
  subst : Map[Int, Type]
}

///|
priv struct TypePrinter {
  names : Map[Int, String]
  mut next_id : Int
}

///|
priv enum MatchMatrixKind {
  BoolKind
  TupleKind(Int)
  ListKind
  UniversalKind
}

///|
fn expr_to_string(expr : Expr) -> String {
  match expr {
    IntExpr(n) => n.to_string()
    BoolExpr(b) => b.to_string()
    VarExpr(name) => name
    IfExpr(cond, then_, else_) =>
      "if \{expr_to_string(cond)} then \{expr_to_string(then_)} else \{expr_to_string(else_)}"
    LetExpr(pattern, bound, body) =>
      "let \{pattern_to_string(pattern)} = \{expr_to_string(bound)} in \{expr_to_string(body)}"
    LetRecExpr(name, param, fun_body, body) =>
      "let rec \{name} \{param} = \{expr_to_string(fun_body)} in \{expr_to_string(body)}"
    FunExpr(param, body) => "fun \{param} -> \{expr_to_string(body)}"
    ApplyExpr(func, arg) => "(\{expr_to_string(func)} \{expr_to_string(arg)})"
    BinaryExpr(op, lhs, rhs) =>
      "(\{expr_to_string(lhs)} \{op.to_string()} \{expr_to_string(rhs)})"
    NegExpr(inner) => "(-\{expr_to_string(inner)})"
    NotExpr(inner) => "(!\{expr_to_string(inner)})"
    TupleExpr(exprs) => {
      let items = exprs.map(expr => expr_to_string(expr)).join(", ")
      "(\{items})"
    }
    ListExpr(exprs) => {
      let items = exprs.map(expr => expr_to_string(expr)).join(", ")
      "[\{items}]"
    }
    ConsExpr(head, tail) =>
      "(\{expr_to_string(head)} :: \{expr_to_string(tail)})"
    MatchExpr(scrutinee, arms) => {
      let arm_text = arms
        .map(arm => {
          let guard_text = match arm.guard_ {
            Some(expr) => " if \{expr_to_string(expr)}"
            None => ""
          }
          " | \{pattern_to_string(arm.pattern)}\{guard_text} -> \{expr_to_string(arm.body)}"
        })
        .join("")
      "match \{expr_to_string(scrutinee)} with\{arm_text}"
    }
  }
}

///|
fn pattern_to_string(pattern : Pattern) -> String {
  match pattern {
    WildcardPat => "_"
    IntPat(n) => n.to_string()
    BoolPat(b) => b.to_string()
    VarPat(name) => name
    TuplePat(patterns) => {
      let items = patterns.map(p => pattern_to_string(p)).join(", ")
      "(\{items})"
    }
    NilPat => "[]"
    ConsPat(head, tail) =>
      "\{pattern_to_string(head)} :: \{pattern_to_string(tail)}"
  }
}

///|
fn list_value_to_string(value : Value) -> String {
  let items = Array::new()
  let mut current = value
  while true {
    match current {
      NilValue => break
      ConsValue(head, tail) => {
        items.push(value_to_string(head))
        current = tail
      }
      _ => {
        items.push("| " + value_to_string(current))
        break
      }
    }
  }
  let text = items.join(", ")
  "[\{text}]"
}

///|
fn value_to_string(value : Value) -> String {
  match value {
    IntValue(n) => n.to_string()
    BoolValue(b) => b.to_string()
    ClosureValue(_, _, _) => "<fun>"
    TupleValue(values) => {
      let items = values.map(v => value_to_string(v)).join(", ")
      "(\{items})"
    }
    NilValue => "[]"
    ConsValue(_, _) => list_value_to_string(value)
  }
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
fn TypeEnv::new(parent? : TypeEnv? = None) -> TypeEnv {
  TypeEnv::{ bindings: Map::new(), parent }
}

///|
fn TypeEnv::extend(self : TypeEnv, name : String, scheme : Scheme) -> TypeEnv {
  let env = TypeEnv::new(parent=Some(self))
  env.bindings.set(name, scheme)
  env
}

///|
fn TypeEnv::lookup(self : TypeEnv, name : String) -> Scheme raise MiniMLError {
  match self.bindings.get(name) {
    Some(scheme) => scheme
    None =>
      match self.parent {
        Some(parent) => parent.lookup(name)
        None => raise TypeError("unbound variable `\{name}`")
      }
  }
}

///|
fn InferCtx::new() -> InferCtx {
  InferCtx::{ next_id: 0, subst: Map::new() }
}

///|
fn TypePrinter::new() -> TypePrinter {
  TypePrinter::{ names: Map::new(), next_id: 0 }
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
      [.. "::", .. next] => {
        tokens.push(ConsTok)
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
      ['[', .. next] => {
        tokens.push(LBracketTok)
        rest = next
      }
      [']', .. next] => {
        tokens.push(RBracketTok)
        rest = next
      }
      [',', .. next] => {
        tokens.push(CommaTok)
        rest = next
      }
      ['|', .. next] => {
        tokens.push(BarTok)
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
          "match" => MatchTok
          "with" => WithTok
          "true" => BoolTok(true)
          "false" => BoolTok(false)
          "_" => WildcardTok
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
fn token_to_string(token : Token) -> String {
  token.to_string()
}

///|
fn is_atom_start(token : Token) -> Bool {
  match token {
    IntTok(_) | BoolTok(_) | IdentTok(_) | LParenTok | LBracketTok => true
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
fn list_pattern_from_array(patterns : Array[Pattern]) -> Pattern {
  let mut result = NilPat
  let mut idx = patterns.length()
  while idx > 0 {
    idx = idx - 1
    result = ConsPat(patterns[idx], result)
  }
  result
}

///|
fn parse_pattern_atom(
  tokens : ArrayView[Token],
) -> (Pattern, ArrayView[Token]) raise MiniMLError {
  guard tokens is [tok, .. rest] else {
    raise ParseError("expected pattern, but reached end of input")
  }
  match tok {
    WildcardTok => (WildcardPat, rest)
    IntTok(n) => (IntPat(n), rest)
    BoolTok(b) => (BoolPat(b), rest)
    IdentTok(name) => (VarPat(name), rest)
    LBracketTok =>
      match rest {
        [RBracketTok, .. rest2] => (NilPat, rest2)
        _ => {
          let patterns = Array::new()
          let (first, rest2) = parse_pattern(rest)
          patterns.push(first)
          let mut current = rest2
          while true {
            match current {
              [CommaTok, .. rest3] => {
                let (next_pat, rest4) = parse_pattern(rest3)
                patterns.push(next_pat)
                current = rest4
              }
              [RBracketTok, .. rest3] =>
                return (list_pattern_from_array(patterns), rest3)
              [tok2, ..] =>
                raise ParseError(
                  "expected `,` or `]` in list pattern, got \{token_to_string(tok2)}",
                )
              [] => raise ParseError("expected `]` to close list pattern")
            }
          }
          (NilPat, current)
        }
      }
    LParenTok =>
      match rest {
        [RParenTok, ..] =>
          raise ParseError("empty tuple pattern is not supported")
        _ => {
          let (first, rest2) = parse_pattern(rest)
          match rest2 {
            [CommaTok, .. rest3] => {
              let patterns = Array::new()
              patterns.push(first)
              let mut current = rest3
              while true {
                let (next_pat, rest4) = parse_pattern(current)
                patterns.push(next_pat)
                current = rest4
                match current {
                  [CommaTok, .. rest5] => current = rest5
                  [RParenTok, .. rest5] => return (TuplePat(patterns), rest5)
                  [tok2, ..] =>
                    raise ParseError(
                      "expected `,` or `)` in tuple pattern, got \{token_to_string(tok2)}",
                    )
                  [] => raise ParseError("expected `)` to close tuple pattern")
                }
              }
              (WildcardPat, current)
            }
            [RParenTok, .. rest3] => (first, rest3)
            [tok2, ..] =>
              raise ParseError(
                "expected `,` or `)` in parenthesized pattern, got \{token_to_string(tok2)}",
              )
            [] =>
              raise ParseError("expected `)` to close parenthesized pattern")
          }
        }
      }
    _ => raise ParseError("expected pattern, got \{token_to_string(tok)}")
  }
}

///|
fn parse_pattern(
  tokens : ArrayView[Token],
) -> (Pattern, ArrayView[Token]) raise MiniMLError {
  let (head, rest) = parse_pattern_atom(tokens)
  match rest {
    [ConsTok, .. rest2] => {
      let (tail, rest3) = parse_pattern(rest2)
      (ConsPat(head, tail), rest3)
    }
    _ => (head, rest)
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
    LBracketTok =>
      match rest {
        [RBracketTok, .. rest2] => (ListExpr([]), rest2)
        _ => {
          let exprs = Array::new()
          let (first, rest2) = parse_expr(rest)
          exprs.push(first)
          let mut current = rest2
          while true {
            match current {
              [CommaTok, .. rest3] => {
                let (next_expr, rest4) = parse_expr(rest3)
                exprs.push(next_expr)
                current = rest4
              }
              [RBracketTok, .. rest3] => return (ListExpr(exprs), rest3)
              [tok2, ..] =>
                raise ParseError(
                  "expected `,` or `]` in list literal, got \{token_to_string(tok2)}",
                )
              [] => raise ParseError("expected `]` to close list literal")
            }
          }
          (ListExpr(exprs), current)
        }
      }
    LParenTok =>
      match rest {
        [RParenTok, ..] =>
          raise ParseError("empty tuple literal is not supported")
        _ => {
          let (first, rest2) = parse_expr(rest)
          match rest2 {
            [CommaTok, .. rest3] => {
              let exprs = Array::new()
              exprs.push(first)
              let mut current = rest3
              while true {
                let (next_expr, rest4) = parse_expr(current)
                exprs.push(next_expr)
                current = rest4
                match current {
                  [CommaTok, .. rest5] => current = rest5
                  [RParenTok, .. rest5] => return (TupleExpr(exprs), rest5)
                  [tok2, ..] =>
                    raise ParseError(
                      "expected `,` or `)` in tuple literal, got \{token_to_string(tok2)}",
                    )
                  [] => raise ParseError("expected `)` to close tuple literal")
                }
              }
              (TupleExpr(exprs), current)
            }
            [RParenTok, .. rest3] => (first, rest3)
            [tok2, ..] =>
              raise ParseError(
                "expected `,` or `)` in parenthesized expression, got \{token_to_string(tok2)}",
              )
            [] =>
              raise ParseError("expected `)` to close parenthesized expression")
          }
        }
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
      let (expr, rest2) = parse_prefix(rest)
      (NegExpr(expr), rest2)
    }
    NotTok => {
      let (expr, rest2) = parse_prefix(rest)
      (NotExpr(expr), rest2)
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
fn parse_cons(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  let (head, rest) = parse_add(tokens)
  match rest {
    [ConsTok, .. rest2] => {
      let (tail, rest3) = parse_cons(rest2)
      (ConsExpr(head, tail), rest3)
    }
    _ => (head, rest)
  }
}

///|
fn parse_compare(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  let (expr0, rest0) = parse_cons(tokens)
  let mut expr = expr0
  let mut rest = rest0
  while true {
    match rest {
      [EqEqTok, .. rest2] => {
        let (rhs, next_rest) = parse_cons(rest2)
        expr = BinaryExpr(Eq, expr, rhs)
        rest = next_rest
      }
      [NotEqTok, .. rest2] => {
        let (rhs, next_rest) = parse_cons(rest2)
        expr = BinaryExpr(NE, expr, rhs)
        rest = next_rest
      }
      [LtTok, .. rest2] => {
        let (rhs, next_rest) = parse_cons(rest2)
        expr = BinaryExpr(LT, expr, rhs)
        rest = next_rest
      }
      [LeTok, .. rest2] => {
        let (rhs, next_rest) = parse_cons(rest2)
        expr = BinaryExpr(LE, expr, rhs)
        rest = next_rest
      }
      [GtTok, .. rest2] => {
        let (rhs, next_rest) = parse_cons(rest2)
        expr = BinaryExpr(GT, expr, rhs)
        rest = next_rest
      }
      [GeTok, .. rest2] => {
        let (rhs, next_rest) = parse_cons(rest2)
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
fn parse_match_arm(
  tokens : ArrayView[Token],
) -> (MatchArm, ArrayView[Token]) raise MiniMLError {
  let tokens = if tokens is [BarTok, .. rest] { rest } else { tokens }
  let (pattern, rest) = parse_pattern(tokens)
  let (guard_, rest) = match rest {
    [IfTok, .. rest2] => {
      let (guard_expr, rest3) = parse_expr(rest2)
      (Some(guard_expr), rest3)
    }
    _ => (None, rest)
  }
  let rest = expect_token(rest, ArrowTok)
  let (body, rest2) = parse_expr(rest)
  (MatchArm::{ pattern, guard_, body }, rest2)
}

///|
fn parse_match(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  guard tokens is [tok, .. rest] else {
    raise ParseError("expected expression, but reached end of input")
  }
  if tok != MatchTok {
    return parse_or(tokens)
  }
  let (scrutinee, rest2) = parse_expr(rest)
  let rest3 = expect_token(rest2, WithTok)
  let arms = Array::new()
  let mut current = rest3
  let (first_arm, rest4) = parse_match_arm(current)
  arms.push(first_arm)
  current = rest4
  while true {
    match current {
      [BarTok, ..] => {
        let (arm, rest5) = parse_match_arm(current)
        arms.push(arm)
        current = rest5
      }
      _ => break
    }
  }
  (MatchExpr(scrutinee, arms), current)
}

///|
fn parse_fun(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  guard tokens is [tok, .. rest] else {
    raise ParseError("expected expression, but reached end of input")
  }
  if tok != FunTok {
    return parse_match(tokens)
  }
  let (param, rest2) = expect_ident(rest)
  let rest3 = expect_token(rest2, ArrowTok)
  let (body, rest4) = parse_expr(rest3)
  (FunExpr(param, body), rest4)
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
  let (cond, rest2) = parse_expr(rest)
  let rest3 = expect_token(rest2, ThenTok)
  let (then_, rest4) = parse_expr(rest3)
  let rest5 = expect_token(rest4, ElseTok)
  let (else_, rest6) = parse_expr(rest5)
  (IfExpr(cond, then_, else_), rest6)
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
    let (pattern, rest3) = parse_pattern(rest)
    let rest4 = expect_token(rest3, EqTok)
    let (bound, rest5) = parse_expr(rest4)
    let rest6 = expect_token(rest5, InTok)
    let (body, rest7) = parse_expr(rest6)
    (LetExpr(pattern, bound, body), rest7)
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
fn value_eq(lhs : Value, rhs : Value) -> Bool raise MiniMLError {
  match (lhs, rhs) {
    (IntValue(a), IntValue(b)) => a == b
    (BoolValue(a), BoolValue(b)) => a == b
    (NilValue, NilValue) => true
    (ConsValue(h1, t1), ConsValue(h2, t2)) =>
      value_eq(h1, h2) && value_eq(t1, t2)
    (TupleValue(xs), TupleValue(ys)) => {
      if xs.length() != ys.length() {
        return false
      }
      for i = 0; i < xs.length(); i = i + 1 {
        if !value_eq(xs[i], ys[i]) {
          return false
        }
      }
      true
    }
    (ClosureValue(_, _, _), _) | (_, ClosureValue(_, _, _)) =>
      raise RuntimeError("cannot compare function values")
    _ => false
  }
}

///|
fn list_from_values(values : Array[Value]) -> Value {
  let mut result = NilValue
  let mut idx = values.length()
  while idx > 0 {
    idx = idx - 1
    result = ConsValue(values[idx], result)
  }
  result
}

///|
fn match_pattern(pattern : Pattern, value : Value, env : Env) -> Env? {
  match pattern {
    WildcardPat => Some(env)
    IntPat(n) =>
      match value {
        IntValue(m) if n == m => Some(env)
        _ => None
      }
    BoolPat(expected) =>
      match value {
        BoolValue(actual) if expected == actual => Some(env)
        _ => None
      }
    VarPat(name) => Some(env.extend(name, value))
    TuplePat(patterns) =>
      match value {
        TupleValue(values) => {
          if patterns.length() != values.length() {
            return None
          }
          let mut current_env = Some(env)
          for i = 0; i < patterns.length(); i = i + 1 {
            match current_env {
              Some(found_env) =>
                current_env = match_pattern(patterns[i], values[i], found_env)
              None => ()
            }
          }
          current_env
        }
        _ => None
      }
    NilPat =>
      match value {
        NilValue => Some(env)
        _ => None
      }
    ConsPat(head, tail) =>
      match value {
        ConsValue(head_value, tail_value) =>
          match match_pattern(head, head_value, env) {
            Some(next_env) => match_pattern(tail, tail_value, next_env)
            None => None
          }
        _ => None
      }
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
    (Eq, left, right) => BoolValue(value_eq(left, right))
    (NE, left, right) => BoolValue(!value_eq(left, right))
    (LT, IntValue(a), IntValue(b)) => BoolValue(a < b)
    (LE, IntValue(a), IntValue(b)) => BoolValue(a <= b)
    (GT, IntValue(a), IntValue(b)) => BoolValue(a > b)
    (GE, IntValue(a), IntValue(b)) => BoolValue(a >= b)
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
    LetExpr(pattern, bound, body) => {
      let value = eval_expr(bound, env)
      match match_pattern(pattern, value, env) {
        Some(next_env) => eval_expr(body, next_env)
        None => raise RuntimeError("let pattern match failed")
      }
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
    TupleExpr(exprs) => {
      let values = Array::new()
      for expr in exprs {
        values.push(eval_expr(expr, env))
      }
      TupleValue(values)
    }
    ListExpr(exprs) => {
      let values = Array::new()
      for expr in exprs {
        values.push(eval_expr(expr, env))
      }
      list_from_values(values)
    }
    ConsExpr(head, tail) => {
      let head_value = eval_expr(head, env)
      let tail_value = eval_expr(tail, env)
      match tail_value {
        NilValue | ConsValue(_, _) => ConsValue(head_value, tail_value)
        _ => raise RuntimeError("right-hand side of :: must be a list")
      }
    }
    MatchExpr(scrutinee, arms) => {
      let value = eval_expr(scrutinee, env)
      for arm in arms {
        match match_pattern(arm.pattern, value, env) {
          Some(next_env) =>
            match arm.guard_ {
              Some(guard_expr) =>
                match eval_expr(guard_expr, next_env) {
                  BoolValue(true) => return eval_expr(arm.body, next_env)
                  BoolValue(false) => ()
                  _ => raise RuntimeError("match guard must be a bool")
                }
              None => return eval_expr(arm.body, next_env)
            }
          None => ()
        }
      }
      raise RuntimeError("match failure")
    }
  }
}

///|
fn type_var_name(printer : TypePrinter, id : Int) -> String {
  match printer.names.get(id) {
    Some(name) => name
    None => {
      let name = "'t\{printer.next_id}"
      printer.next_id = printer.next_id + 1
      printer.names.set(id, name)
      name
    }
  }
}

///|
fn type_to_string_with(type_ : Type, printer : TypePrinter) -> String {
  match type_ {
    IntType => "int"
    BoolType => "bool"
    VarType(id) => type_var_name(printer, id)
    FunType(arg, ret) => {
      let arg_s = match arg {
        FunType(_, _) => "(\{type_to_string_with(arg, printer)})"
        _ => type_to_string_with(arg, printer)
      }
      "\{arg_s} -> \{type_to_string_with(ret, printer)}"
    }
    TupleType(types) => {
      let items = types.map(t => type_to_string_with(t, printer)).join(" * ")
      "(\{items})"
    }
    ListType(elem) => {
      let elem_s = match elem {
        FunType(_, _) | TupleType(_) =>
          "(\{type_to_string_with(elem, printer)})"
        _ => type_to_string_with(elem, printer)
      }
      "\{elem_s} list"
    }
  }
}

///|
fn type_to_string(type_ : Type) -> String {
  type_to_string_with(type_, TypePrinter::new())
}

///|
fn fresh_type_var(ctx : InferCtx) -> Type {
  let id = ctx.next_id
  ctx.next_id = ctx.next_id + 1
  VarType(id)
}

///|
fn prune_type(type_ : Type, ctx : InferCtx) -> Type {
  match type_ {
    VarType(id) =>
      match ctx.subst.get(id) {
        Some(inner) => {
          let pruned = prune_type(inner, ctx)
          ctx.subst.set(id, pruned)
          pruned
        }
        None => VarType(id)
      }
    FunType(arg, ret) => FunType(prune_type(arg, ctx), prune_type(ret, ctx))
    TupleType(types) => TupleType(types.map(fn(t) { prune_type(t, ctx) }))
    ListType(elem) => ListType(prune_type(elem, ctx))
    _ => type_
  }
}

///|
fn occurs_in(var_id : Int, type_ : Type, ctx : InferCtx) -> Bool {
  match prune_type(type_, ctx) {
    VarType(id) => id == var_id
    FunType(arg, ret) =>
      occurs_in(var_id, arg, ctx) || occurs_in(var_id, ret, ctx)
    TupleType(types) => {
      for t in types {
        if occurs_in(var_id, t, ctx) {
          return true
        }
      }
      false
    }
    ListType(elem) => occurs_in(var_id, elem, ctx)
    _ => false
  }
}

///|
fn bind_type_var(
  var_id : Int,
  type_ : Type,
  ctx : InferCtx,
) -> Unit raise MiniMLError {
  let type_ = prune_type(type_, ctx)
  if type_ == VarType(var_id) {
    return
  }
  if occurs_in(var_id, type_, ctx) {
    raise TypeError("occurs check failed")
  }
  ctx.subst.set(var_id, type_)
}

///|
fn unify(
  type_a : Type,
  type_b : Type,
  ctx : InferCtx,
) -> Unit raise MiniMLError {
  let lhs = prune_type(type_a, ctx)
  let rhs = prune_type(type_b, ctx)
  match (lhs, rhs) {
    (VarType(a), t) => bind_type_var(a, t, ctx)
    (t, VarType(b)) => bind_type_var(b, t, ctx)
    (IntType, IntType) => ()
    (BoolType, BoolType) => ()
    (FunType(arg1, ret1), FunType(arg2, ret2)) => {
      unify(arg1, arg2, ctx)
      unify(ret1, ret2, ctx)
    }
    (TupleType(xs), TupleType(ys)) => {
      if xs.length() != ys.length() {
        raise TypeError("tuple lengths do not match")
      }
      for i = 0; i < xs.length(); i = i + 1 {
        unify(xs[i], ys[i], ctx)
      }
    }
    (ListType(a), ListType(b)) => unify(a, b, ctx)
    _ =>
      raise TypeError(
        "cannot unify \{type_to_string(lhs)} with \{type_to_string(rhs)}",
      )
  }
}

///|
fn add_unique(vars : Array[Int], value : Int) -> Unit {
  for existing in vars {
    if existing == value {
      return
    }
  }
  vars.push(value)
}

///|
fn append_unique(dst : Array[Int], src : Array[Int]) -> Unit {
  for value in src {
    add_unique(dst, value)
  }
}

///|
fn diff_vars(lhs : Array[Int], rhs : Array[Int]) -> Array[Int] {
  let result = Array::new()
  for value in lhs {
    let mut found = false
    for other in rhs {
      if value == other {
        found = true
      }
    }
    if !found {
      result.push(value)
    }
  }
  result
}

///|
fn ftv_type(type_ : Type, ctx : InferCtx) -> Array[Int] {
  match prune_type(type_, ctx) {
    IntType | BoolType => []
    VarType(id) => [id]
    FunType(arg, ret) => {
      let vars = ftv_type(arg, ctx)
      append_unique(vars, ftv_type(ret, ctx))
      vars
    }
    TupleType(types) => {
      let vars = Array::new()
      for t in types {
        append_unique(vars, ftv_type(t, ctx))
      }
      vars
    }
    ListType(elem) => ftv_type(elem, ctx)
  }
}

///|
fn ftv_scheme(scheme : Scheme, ctx : InferCtx) -> Array[Int] {
  diff_vars(ftv_type(scheme.ty, ctx), scheme.vars)
}

///|
fn ftv_type_env(env : TypeEnv, ctx : InferCtx) -> Array[Int] {
  let vars = Array::new()
  for scheme in env.bindings.values() {
    append_unique(vars, ftv_scheme(scheme, ctx))
  }
  match env.parent {
    Some(parent) => {
      append_unique(vars, ftv_type_env(parent, ctx))
      vars
    }
    None => vars
  }
}

///|
fn instantiate_type(
  type_ : Type,
  mapping : Map[Int, Type],
  ctx : InferCtx,
) -> Type {
  match prune_type(type_, ctx) {
    IntType => IntType
    BoolType => BoolType
    VarType(id) =>
      match mapping.get(id) {
        Some(t) => t
        None => VarType(id)
      }
    FunType(arg, ret) =>
      FunType(
        instantiate_type(arg, mapping, ctx),
        instantiate_type(ret, mapping, ctx),
      )
    TupleType(types) =>
      TupleType(types.map(fn(t) { instantiate_type(t, mapping, ctx) }))
    ListType(elem) => ListType(instantiate_type(elem, mapping, ctx))
  }
}

///|
fn instantiate(scheme : Scheme, ctx : InferCtx) -> Type {
  let mapping = Map::new()
  for id in scheme.vars {
    mapping.set(id, fresh_type_var(ctx))
  }
  instantiate_type(scheme.ty, mapping, ctx)
}

///|
fn generalize(env : TypeEnv, type_ : Type, ctx : InferCtx) -> Scheme {
  let type_vars = ftv_type(type_, ctx)
  let env_vars = ftv_type_env(env, ctx)
  Scheme::{ vars: diff_vars(type_vars, env_vars), ty: prune_type(type_, ctx) }
}

///|
fn infer_pattern(
  pattern : Pattern,
  expected : Type,
  env : TypeEnv,
  ctx : InferCtx,
) -> TypeEnv raise MiniMLError {
  match pattern {
    WildcardPat => env
    IntPat(_) => {
      unify(expected, IntType, ctx)
      env
    }
    BoolPat(_) => {
      unify(expected, BoolType, ctx)
      env
    }
    VarPat(name) =>
      env.extend(name, Scheme::{ vars: [], ty: prune_type(expected, ctx) })
    TuplePat(patterns) => {
      let element_types = Array::new()
      for _ in patterns {
        element_types.push(fresh_type_var(ctx))
      }
      unify(expected, TupleType(element_types), ctx)
      let mut current_env = env
      for i = 0; i < patterns.length(); i = i + 1 {
        current_env = infer_pattern(
          patterns[i],
          element_types[i],
          current_env,
          ctx,
        )
      }
      current_env
    }
    NilPat => {
      let elem_type = fresh_type_var(ctx)
      unify(expected, ListType(elem_type), ctx)
      env
    }
    ConsPat(head, tail) => {
      let elem_type = fresh_type_var(ctx)
      let list_type = ListType(elem_type)
      unify(expected, list_type, ctx)
      let env2 = infer_pattern(head, elem_type, env, ctx)
      infer_pattern(tail, list_type, env2, ctx)
    }
  }
}

///|
fn bind_generalized_pattern(
  pattern : Pattern,
  expected : Type,
  base_env : TypeEnv,
  env : TypeEnv,
  ctx : InferCtx,
) -> TypeEnv {
  match pattern {
    WildcardPat | IntPat(_) | BoolPat(_) | NilPat => env
    VarPat(name) => env.extend(name, generalize(base_env, expected, ctx))
    TuplePat(patterns) =>
      match prune_type(expected, ctx) {
        TupleType(types) => {
          let mut current_env = env
          for i = 0; i < patterns.length(); i = i + 1 {
            current_env = bind_generalized_pattern(
              patterns[i],
              types[i],
              base_env,
              current_env,
              ctx,
            )
          }
          current_env
        }
        _ => env
      }
    ConsPat(head, tail) =>
      match prune_type(expected, ctx) {
        ListType(elem) => {
          let env2 = bind_generalized_pattern(head, elem, base_env, env, ctx)
          bind_generalized_pattern(tail, ListType(elem), base_env, env2, ctx)
        }
        _ => env
      }
  }
}

///|
fn pattern_is_wild(pattern : Pattern) -> Bool {
  match pattern {
    WildcardPat | VarPat(_) => true
    _ => false
  }
}

///|
fn row_is_all_wild(row : Array[Pattern]) -> Bool {
  for pattern in row {
    if !pattern_is_wild(pattern) {
      return false
    }
  }
  true
}

///|
fn drop_first_pattern(row : Array[Pattern]) -> Array[Pattern] {
  let rest = Array::new()
  for i = 1; i < row.length(); i = i + 1 {
    rest.push(row[i])
  }
  rest
}

///|
fn prepend_pattern(pattern : Pattern, rest : Array[Pattern]) -> Array[Pattern] {
  let result = Array::new()
  result.push(pattern)
  for pat in rest {
    result.push(pat)
  }
  result
}

///|
fn array_slice_patterns(
  patterns : Array[Pattern],
  start : Int,
  end_ : Int,
) -> Array[Pattern] {
  let result = Array::new()
  for i = start; i < end_; i = i + 1 {
    result.push(patterns[i])
  }
  result
}

///|
fn array_slice_types(types : Array[Type], start : Int) -> Array[Type] {
  let result = Array::new()
  for i = start; i < types.length(); i = i + 1 {
    result.push(types[i])
  }
  result
}

///|
fn concat_patterns(
  left : Array[Pattern],
  right : Array[Pattern],
) -> Array[Pattern] {
  let result = Array::new()
  for pat in left {
    result.push(pat)
  }
  for pat in right {
    result.push(pat)
  }
  result
}

///|
fn concat_types(left : Array[Type], right : Array[Type]) -> Array[Type] {
  let result = Array::new()
  for ty in left {
    result.push(ty)
  }
  for ty in right {
    result.push(ty)
  }
  result
}

///|
fn wildcard_patterns(count : Int) -> Array[Pattern] {
  let result = Array::new()
  let mut i = 0
  while i < count {
    result.push(WildcardPat)
    i = i + 1
  }
  result
}

///|
fn match_matrix_kind(ty : Type, ctx : InferCtx) -> MatchMatrixKind {
  match prune_type(ty, ctx) {
    BoolType => BoolKind
    TupleType(types) => TupleKind(types.length())
    ListType(_) => ListKind
    _ => UniversalKind
  }
}

///|
fn default_rows(rows : Array[Array[Pattern]]) -> Array[Array[Pattern]] {
  let result = Array::new()
  for row in rows {
    if row.length() > 0 && pattern_is_wild(row[0]) {
      result.push(drop_first_pattern(row))
    }
  }
  result
}

///|
fn specialize_bool_rows(
  rows : Array[Array[Pattern]],
  target : Bool,
) -> Array[Array[Pattern]] {
  let result = Array::new()
  for row in rows {
    guard row.length() > 0 else { continue }
    let head = row[0]
    let tail = drop_first_pattern(row)
    if pattern_is_wild(head) {
      result.push(tail)
    } else {
      match head {
        BoolPat(value) if value == target => result.push(tail)
        _ => ()
      }
    }
  }
  result
}

///|
fn specialize_tuple_rows(
  rows : Array[Array[Pattern]],
  arity : Int,
) -> Array[Array[Pattern]] {
  let result = Array::new()
  for row in rows {
    guard row.length() > 0 else { continue }
    let head = row[0]
    let tail = drop_first_pattern(row)
    if pattern_is_wild(head) {
      result.push(concat_patterns(wildcard_patterns(arity), tail))
    } else {
      match head {
        TuplePat(parts) if parts.length() == arity =>
          result.push(concat_patterns(parts, tail))
        _ => ()
      }
    }
  }
  result
}

///|
fn specialize_nil_rows(rows : Array[Array[Pattern]]) -> Array[Array[Pattern]] {
  let result = Array::new()
  for row in rows {
    guard row.length() > 0 else { continue }
    let head = row[0]
    let tail = drop_first_pattern(row)
    if pattern_is_wild(head) {
      result.push(tail)
    } else {
      match head {
        NilPat => result.push(tail)
        _ => ()
      }
    }
  }
  result
}

///|
fn specialize_cons_rows(rows : Array[Array[Pattern]]) -> Array[Array[Pattern]] {
  let result = Array::new()
  for row in rows {
    guard row.length() > 0 else { continue }
    let head = row[0]
    let tail = drop_first_pattern(row)
    if pattern_is_wild(head) {
      result.push(concat_patterns([WildcardPat, WildcardPat], tail))
    } else {
      match head {
        ConsPat(head_pat, tail_pat) =>
          result.push(concat_patterns([head_pat, tail_pat], tail))
        _ => ()
      }
    }
  }
  result
}

///|
fn patterns_cover_vector(
  rows : Array[Array[Pattern]],
  types : Array[Type],
  ctx : InferCtx,
) -> Bool {
  if types.length() == 0 {
    return rows.length() > 0
  }
  for row in rows {
    if row_is_all_wild(row) {
      return true
    }
  }
  let head_ty = prune_type(types[0], ctx)
  let tail_tys = array_slice_types(types, 1)
  match match_matrix_kind(head_ty, ctx) {
    UniversalKind => {
      let defaults = default_rows(rows)
      defaults.length() > 0 && patterns_cover_vector(defaults, tail_tys, ctx)
    }
    BoolKind =>
      patterns_cover_vector(specialize_bool_rows(rows, true), tail_tys, ctx) &&
      patterns_cover_vector(specialize_bool_rows(rows, false), tail_tys, ctx)
    TupleKind(arity) =>
      match head_ty {
        TupleType(elem_tys) => {
          let next_rows = specialize_tuple_rows(rows, arity)
          let next_tys = concat_types(elem_tys, tail_tys)
          patterns_cover_vector(next_rows, next_tys, ctx)
        }
        _ => false
      }
    ListKind =>
      match head_ty {
        ListType(elem_ty) => {
          let nil_ok = patterns_cover_vector(
            specialize_nil_rows(rows),
            tail_tys,
            ctx,
          )
          let cons_tys = concat_types([elem_ty, head_ty], tail_tys)
          let cons_ok = patterns_cover_vector(
            specialize_cons_rows(rows),
            cons_tys,
            ctx,
          )
          nil_ok && cons_ok
        }
        _ => false
      }
  }
}

///|
fn find_missing_vector(
  rows : Array[Array[Pattern]],
  types : Array[Type],
  ctx : InferCtx,
) -> Array[Pattern]? {
  if types.length() == 0 {
    if rows.length() == 0 {
      return Some([])
    } else {
      return None
    }
  }
  for row in rows {
    if row_is_all_wild(row) {
      return None
    }
  }
  let head_ty = prune_type(types[0], ctx)
  let tail_tys = array_slice_types(types, 1)
  match match_matrix_kind(head_ty, ctx) {
    UniversalKind => {
      let missing = find_missing_vector(default_rows(rows), tail_tys, ctx)
      match missing {
        Some(rest) => Some(prepend_pattern(WildcardPat, rest))
        None => None
      }
    }
    BoolKind => {
      let missing_true = find_missing_vector(
        specialize_bool_rows(rows, true),
        tail_tys,
        ctx,
      )
      match missing_true {
        Some(rest) => Some(prepend_pattern(BoolPat(true), rest))
        None => {
          let missing_false = find_missing_vector(
            specialize_bool_rows(rows, false),
            tail_tys,
            ctx,
          )
          match missing_false {
            Some(rest) => Some(prepend_pattern(BoolPat(false), rest))
            None => None
          }
        }
      }
    }
    TupleKind(arity) =>
      match head_ty {
        TupleType(elem_tys) => {
          let missing = find_missing_vector(
            specialize_tuple_rows(rows, arity),
            concat_types(elem_tys, tail_tys),
            ctx,
          )
          match missing {
            Some(vec) => {
              let tuple_parts = array_slice_patterns(vec, 0, arity)
              let rest = array_slice_patterns(vec, arity, vec.length())
              Some(prepend_pattern(TuplePat(tuple_parts), rest))
            }
            None => None
          }
        }
        _ => None
      }
    ListKind =>
      match head_ty {
        ListType(elem_ty) => {
          let missing_nil = find_missing_vector(
            specialize_nil_rows(rows),
            tail_tys,
            ctx,
          )
          match missing_nil {
            Some(rest) => Some(prepend_pattern(NilPat, rest))
            None => {
              let missing_cons = find_missing_vector(
                specialize_cons_rows(rows),
                concat_types([elem_ty, head_ty], tail_tys),
                ctx,
              )
              match missing_cons {
                Some(vec) => {
                  let rest = array_slice_patterns(vec, 2, vec.length())
                  Some(prepend_pattern(ConsPat(vec[0], vec[1]), rest))
                }
                None => None
              }
            }
          }
        }
        _ => None
      }
  }
}

///|
fn check_match_exhaustiveness(
  arms : Array[MatchArm],
  scrutinee_ty : Type,
  ctx : InferCtx,
) -> Unit raise MiniMLError {
  let rows = Array::new()
  for arm in arms {
    if arm.guard_ is None {
      rows.push([arm.pattern])
    }
  }
  let tys = [prune_type(scrutinee_ty, ctx)]
  if !patterns_cover_vector(rows, tys, ctx) {
    let missing_vec = find_missing_vector(rows, tys, ctx)
    let missing = match missing_vec {
      Some(patterns) if patterns.length() > 0 => pattern_to_string(patterns[0])
      _ => "_"
    }
    raise TypeError("non-exhaustive match, missing pattern `\{missing}`")
  }
}

///|
fn infer_expr(
  expr : Expr,
  env : TypeEnv,
  ctx : InferCtx,
) -> Type raise MiniMLError {
  match expr {
    IntExpr(_) => IntType
    BoolExpr(_) => BoolType
    VarExpr(name) => instantiate(env.lookup(name), ctx)
    IfExpr(cond, then_, else_) => {
      let cond_type = infer_expr(cond, env, ctx)
      unify(cond_type, BoolType, ctx)
      let then_type = infer_expr(then_, env, ctx)
      let else_type = infer_expr(else_, env, ctx)
      unify(then_type, else_type, ctx)
      prune_type(then_type, ctx)
    }
    LetExpr(pattern, bound, body) => {
      let bound_type = infer_expr(bound, env, ctx)
      let checked_type = prune_type(bound_type, ctx)
      let _ = infer_pattern(pattern, checked_type, env, ctx)
      let body_env = bind_generalized_pattern(
        pattern, checked_type, env, env, ctx,
      )
      infer_expr(body, body_env, ctx)
    }
    LetRecExpr(name, param, fun_body, body) => {
      let arg_type = fresh_type_var(ctx)
      let ret_type = fresh_type_var(ctx)
      let func_type = FunType(arg_type, ret_type)
      let env1 = env.extend(name, Scheme::{ vars: [], ty: func_type })
      let env2 = env1.extend(param, Scheme::{ vars: [], ty: arg_type })
      let body_type = infer_expr(fun_body, env2, ctx)
      unify(ret_type, body_type, ctx)
      let final_type = prune_type(func_type, ctx)
      let scheme = generalize(env, final_type, ctx)
      let env3 = env.extend(name, scheme)
      infer_expr(body, env3, ctx)
    }
    FunExpr(param, body) => {
      let arg_type = fresh_type_var(ctx)
      let env2 = env.extend(param, Scheme::{ vars: [], ty: arg_type })
      let body_type = infer_expr(body, env2, ctx)
      FunType(prune_type(arg_type, ctx), prune_type(body_type, ctx))
    }
    ApplyExpr(func, arg) => {
      let func_type = infer_expr(func, env, ctx)
      let arg_type = infer_expr(arg, env, ctx)
      let result_type = fresh_type_var(ctx)
      unify(func_type, FunType(arg_type, result_type), ctx)
      prune_type(result_type, ctx)
    }
    BinaryExpr(And, lhs, rhs) | BinaryExpr(Or, lhs, rhs) => {
      let left_type = infer_expr(lhs, env, ctx)
      let right_type = infer_expr(rhs, env, ctx)
      unify(left_type, BoolType, ctx)
      unify(right_type, BoolType, ctx)
      BoolType
    }
    BinaryExpr(Add, lhs, rhs)
    | BinaryExpr(Sub, lhs, rhs)
    | BinaryExpr(Mul, lhs, rhs)
    | BinaryExpr(Div, lhs, rhs) => {
      let left_type = infer_expr(lhs, env, ctx)
      let right_type = infer_expr(rhs, env, ctx)
      unify(left_type, IntType, ctx)
      unify(right_type, IntType, ctx)
      IntType
    }
    BinaryExpr(LT, lhs, rhs)
    | BinaryExpr(LE, lhs, rhs)
    | BinaryExpr(GT, lhs, rhs)
    | BinaryExpr(GE, lhs, rhs) => {
      let left_type = infer_expr(lhs, env, ctx)
      let right_type = infer_expr(rhs, env, ctx)
      unify(left_type, IntType, ctx)
      unify(right_type, IntType, ctx)
      BoolType
    }
    BinaryExpr(Eq, lhs, rhs) | BinaryExpr(NE, lhs, rhs) => {
      let left_type = infer_expr(lhs, env, ctx)
      let right_type = infer_expr(rhs, env, ctx)
      unify(left_type, right_type, ctx)
      BoolType
    }
    NegExpr(inner) => {
      let inner_type = infer_expr(inner, env, ctx)
      unify(inner_type, IntType, ctx)
      IntType
    }
    NotExpr(inner) => {
      let inner_type = infer_expr(inner, env, ctx)
      unify(inner_type, BoolType, ctx)
      BoolType
    }
    TupleExpr(exprs) => {
      let types = Array::new()
      for expr in exprs {
        types.push(infer_expr(expr, env, ctx))
      }
      TupleType(types)
    }
    ListExpr(exprs) => {
      let elem_type = fresh_type_var(ctx)
      for expr in exprs {
        let current = infer_expr(expr, env, ctx)
        unify(elem_type, current, ctx)
      }
      ListType(prune_type(elem_type, ctx))
    }
    ConsExpr(head, tail) => {
      let head_type = infer_expr(head, env, ctx)
      let tail_type = infer_expr(tail, env, ctx)
      unify(tail_type, ListType(head_type), ctx)
      ListType(prune_type(head_type, ctx))
    }
    MatchExpr(scrutinee, arms) => {
      if arms.is_empty() {
        raise TypeError("match expression must have at least one arm")
      }
      let scrutinee_type = infer_expr(scrutinee, env, ctx)
      let result_type = fresh_type_var(ctx)
      for arm in arms {
        let arm_env = infer_pattern(arm.pattern, scrutinee_type, env, ctx)
        match arm.guard_ {
          Some(guard_expr) => {
            let guard_type = infer_expr(guard_expr, arm_env, ctx)
            unify(guard_type, BoolType, ctx)
          }
          None => ()
        }
        let body_type = infer_expr(arm.body, arm_env, ctx)
        unify(result_type, body_type, ctx)
      }
      check_match_exhaustiveness(arms, scrutinee_type, ctx)
      prune_type(result_type, ctx)
    }
  }
}

///|
fn infer_ast(expr : Expr) -> Type raise MiniMLError {
  let ctx = InferCtx::new()
  let type_ = infer_expr(expr, TypeEnv::new(), ctx)
  prune_type(type_, ctx)
}

///|
pub fn infer(code : String) -> String raise MiniMLError {
  type_to_string(infer_ast(parse(code)))
}

///|
pub fn eval(code : String) -> Value raise MiniMLError {
  let expr = parse(code)
  let _ = infer_ast(expr)
  eval_expr(expr, Env::new())
}

///|
pub fn interpret(code : String) -> String raise MiniMLError {
  value_to_string(eval(code))
}
