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
  StringTok(String)
  IdentTok(String)
  CtorTok(String)
  WildcardTok
  LetTok
  InTok
  RecTok
  AndKwTok
  EnumTok
  FunTok
  IfTok
  ThenTok
  ElseTok
  MatchTok
  WithTok
  LBraceTok
  RBraceTok
  LParenTok
  RParenTok
  LBracketTok
  RBracketTok
  ArrowTok
  ColonTok
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
  SemiTok
  BarTok
  EOFTok
} derive(Eq)

///|
pub impl Show for Token with output(self, logger) {
  let s = match self {
    IntTok(n) => "Int(\{n})"
    BoolTok(b) => "Bool(\{b})"
    StringTok(text) => "String(\{escape_string_literal(text)})"
    IdentTok(name) => "Ident(\{name})"
    CtorTok(name) => "Ctor(\{name})"
    WildcardTok => "_"
    LetTok => "let"
    InTok => "in"
    RecTok => "rec"
    AndKwTok => "and"
    EnumTok => "enum"
    FunTok => "fun"
    IfTok => "if"
    ThenTok => "then"
    ElseTok => "else"
    MatchTok => "match"
    WithTok => "with"
    LBraceTok => "{"
    RBraceTok => "}"
    LParenTok => "("
    RParenTok => ")"
    LBracketTok => "["
    RBracketTok => "]"
    ArrowTok => "->"
    ColonTok => ":"
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
    SemiTok => ";"
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
  UnitPat
  VarPat(String)
  CtorPat(String, Array[Pattern])
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
pub(all) enum DeclType {
  UnitDeclType
  IntDeclType
  BoolDeclType
  StringDeclType
  TypeVarDeclType(String)
  NamedDeclType(String, Array[DeclType])
  TupleDeclType(Array[DeclType])
  ListDeclType(DeclType)
  OptionDeclType(DeclType)
  FunDeclType(DeclType, DeclType)
}

///|
pub(all) struct EnumVariantDecl {
  name : String
  fields : Array[DeclType]
}

///|
pub(all) struct EnumDecl {
  name : String
  type_params : Array[String]
  variants : Array[EnumVariantDecl]
}

///|
pub(all) struct RecBinding {
  name : String
  param : String
  param_annot : DeclType?
  return_annot : DeclType?
  fun_body : Expr
}

///|
pub(all) struct LetBinding {
  pattern : Pattern
  annot : DeclType?
  bound : Expr
}

///|
pub(all) enum Expr {
  UnitExpr
  IntExpr(Int)
  BoolExpr(Bool)
  StringExpr(String)
  VarExpr(String)
  IfExpr(Expr, Expr, Expr)
  EnumExpr(EnumDecl, Expr)
  LetExpr(Pattern, DeclType?, Expr, Expr)
  LetGroupExpr(Array[LetBinding], Expr)
  LetRecExpr(String, String, DeclType?, DeclType?, Expr, Expr)
  LetRecGroupExpr(Array[RecBinding], Expr)
  FunExpr(String, DeclType?, Expr)
  AscribeExpr(Expr, DeclType)
  SeqExpr(Expr, Expr)
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
  UnitValue
  IntValue(Int)
  BoolValue(Bool)
  StringValue(String)
  ClosureValue(String, Expr, Env)
  CtorFuncValue(String, Int, Array[Value])
  VariantValue(String, Array[Value])
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
  UnitType
  IntType
  BoolType
  StringType
  VarType(Int)
  FunType(Type, Type)
  OptionType(Type)
  NamedType(String, Int, Array[Type])
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
  mut next_enum_id : Int
  subst : Map[Int, Type]
  enum_defs : Map[Int, EnumDecl]
  type_name_to_enum : Map[String, Int]
  ctor_to_enum : Map[String, Int]
}

///|
priv struct TypePrinter {
  names : Map[Int, String]
  mut next_id : Int
}

///|
priv struct FnParam {
  pattern : Pattern
  binder : String
  annot : DeclType?
}

///|
fn rec_binding_to_string(binding : RecBinding) -> String {
  let param_s = binder_to_string(binding.param, binding.param_annot)
  let return_s = match binding.return_annot {
    Some(type_) => " : \{decl_type_to_string(type_)}"
    None => ""
  }
  "\{binding.name} \{param_s}\{return_s} = \{expr_to_string(binding.fun_body)}"
}

///|
fn let_binding_to_string(binding : LetBinding) -> String {
  let annot_s = match binding.annot {
    Some(type_) => " : \{decl_type_to_string(type_)}"
    None => ""
  }
  "\{pattern_to_string(binding.pattern)}\{annot_s} = \{expr_to_string(binding.bound)}"
}

///|
priv enum MatchMatrixKind {
  UnitKind
  BoolKind
  OptionKind
  EnumKind(Int)
  TupleKind(Int)
  ListKind
  UniversalKind
}

///|
fn escape_string_char(c : Char) -> String {
  match c {
    '"' => "\\\""
    '\\' => "\\\\"
    '\n' => "\\n"
    '\r' => "\\r"
    '\t' => "\\t"
    _ => c.to_string()
  }
}

///|
fn escape_string_literal(text : String) -> String {
  let parts = []
  for c in text[:] {
    parts.push(escape_string_char(c))
  }
  let escaped = parts.join("")
  "\"\{escaped}\""
}

///|
fn expr_to_string(expr : Expr) -> String {
  match expr {
    UnitExpr => "()"
    IntExpr(n) => n.to_string()
    BoolExpr(b) => b.to_string()
    StringExpr(text) => escape_string_literal(text)
    VarExpr(name) => name
    IfExpr(cond, then_, else_) =>
      "if \{expr_to_string(cond)} then \{expr_to_string(then_)} else \{expr_to_string(else_)}"
    EnumExpr(decl, body) =>
      "enum \{enum_decl_to_string(decl)} in \{expr_to_string(body)}"
    LetExpr(pattern, annot, bound, body) => {
      let annot_s = match annot {
        Some(type_) => " : \{decl_type_to_string(type_)}"
        None => ""
      }
      "let \{pattern_to_string(pattern)}\{annot_s} = \{expr_to_string(bound)} in \{expr_to_string(body)}"
    }
    LetGroupExpr(bindings, body) => {
      let binding_s = bindings
        .map(binding => let_binding_to_string(binding))
        .join(" and ")
      "let \{binding_s} in \{expr_to_string(body)}"
    }
    LetRecExpr(name, param, param_annot, return_annot, fun_body, body) => {
      let param_s = binder_to_string(param, param_annot)
      let return_s = match return_annot {
        Some(type_) => " : \{decl_type_to_string(type_)}"
        None => ""
      }
      "let rec \{name} \{param_s}\{return_s} = \{expr_to_string(fun_body)} in \{expr_to_string(body)}"
    }
    LetRecGroupExpr(bindings, body) => {
      let binding_s = bindings
        .map(binding => rec_binding_to_string(binding))
        .join(" and ")
      "let rec \{binding_s} in \{expr_to_string(body)}"
    }
    FunExpr(param, annot, body) =>
      "fun \{binder_to_string(param, annot)} -> \{expr_to_string(body)}"
    AscribeExpr(expr, type_) =>
      "(\{expr_to_string(expr)} : \{decl_type_to_string(type_)})"
    SeqExpr(lhs, rhs) => "(\{expr_to_string(lhs)}; \{expr_to_string(rhs)})"
    ApplyExpr(func, arg) => "(\{expr_to_string(func)} \{expr_to_string(arg)})"
    BinaryExpr(op, lhs, rhs) =>
      "(\{expr_to_string(lhs)} \{op} \{expr_to_string(rhs)})"
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
fn decl_type_to_string(type_ : DeclType) -> String {
  match type_ {
    UnitDeclType => "unit"
    IntDeclType => "int"
    BoolDeclType => "bool"
    StringDeclType => "string"
    TypeVarDeclType(name) => name
    NamedDeclType(name, args) =>
      if args.is_empty() {
        name
      } else {
        let items = args.map(t => decl_type_to_string(t)).join(", ")
        "\{name}[\{items}]"
      }
    TupleDeclType(types) => {
      let items = types.map(t => decl_type_to_string(t)).join(" * ")
      "(\{items})"
    }
    ListDeclType(elem) => {
      let elem_s = match elem {
        TupleDeclType(_) => "(\{decl_type_to_string(elem)})"
        _ => decl_type_to_string(elem)
      }
      "\{elem_s} list"
    }
    OptionDeclType(elem) => {
      let elem_s = match elem {
        TupleDeclType(_) => "(\{decl_type_to_string(elem)})"
        _ => decl_type_to_string(elem)
      }
      "\{elem_s} option"
    }
    FunDeclType(arg, ret) => {
      let arg_s = match arg {
        FunDeclType(_, _) => "(\{decl_type_to_string(arg)})"
        _ => decl_type_to_string(arg)
      }
      "\{arg_s} -> \{decl_type_to_string(ret)}"
    }
  }
}

///|
fn binder_to_string(name : String, annot : DeclType?) -> String {
  match annot {
    Some(type_) => "(\{name} : \{decl_type_to_string(type_)})"
    None => name
  }
}

///|
fn is_param_start(token : Token) -> Bool {
  is_pattern_atom_start(token)
}

///|
fn param_body(param : FnParam, body : Expr) -> Expr {
  match (param.pattern, param.annot) {
    (VarPat(name), None) if name == param.binder => body
    (VarPat(name), Some(_)) if name == param.binder => body
    _ => LetExpr(param.pattern, None, VarExpr(param.binder), body)
  }
}

///|
fn params_to_expr(params : ArrayView[FnParam], body : Expr) -> Expr {
  params.rev_fold(init=body, (acc, param) => {
    FunExpr(param.binder, param.annot, param_body(param, acc))
  })
}

///|
fn ascribe_if_needed(expr : Expr, annot : DeclType?) -> Expr {
  match annot {
    Some(type_) => AscribeExpr(expr, type_)
    None => expr
  }
}

///|
fn make_rec_binding(
  name : String,
  params : ArrayView[FnParam],
  return_annot : DeclType?,
  fun_body0 : Expr,
) -> RecBinding {
  guard params is [first, .. tail]
  let inner_body = if tail.is_empty() {
    fun_body0
  } else {
    params_to_expr(tail, ascribe_if_needed(fun_body0, return_annot))
  }
  let fun_body = param_body(first, inner_body)
  let outer_return_annot = if tail.is_empty() { return_annot } else { None }
  RecBinding::{
    name,
    param: first.binder,
    param_annot: first.annot,
    return_annot: outer_return_annot,
    fun_body,
  }
}

///|
fn enum_decl_to_string(decl : EnumDecl) -> String {
  let head = if decl.type_params.is_empty() {
    decl.name
  } else {
    let params = decl.type_params.join(", ")
    "\{decl.name}[\{params}]"
  }
  let variants = decl.variants
    .map(variant => {
      if variant.fields.is_empty() {
        variant.name
      } else {
        let items = variant.fields.map(t => decl_type_to_string(t)).join(", ")
        "\{variant.name}(\{items})"
      }
    })
    .join(" | ")
  "\{head} = \{variants}"
}

///|
fn pattern_to_string(pattern : Pattern) -> String {
  match pattern {
    WildcardPat => "_"
    IntPat(n) => n.to_string()
    BoolPat(b) => b.to_string()
    UnitPat => "()"
    VarPat(name) => name
    CtorPat(name, patterns) => ctor_pattern_to_string(name, patterns)
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
fn pattern_hint_string(pattern : Pattern) -> String {
  match pattern {
    WildcardPat => "_"
    IntPat(n) => n.to_string()
    BoolPat(b) => b.to_string()
    UnitPat => "()"
    VarPat(name) => name
    CtorPat(name, patterns) => ctor_pattern_hint_string(name, patterns)
    TuplePat(patterns) => {
      let items = patterns.map(p => pattern_hint_string(p)).join(", ")
      "(\{items})"
    }
    NilPat | ConsPat(_, _) =>
      match list_hint_string(pattern) {
        Some(text) => text
        None => pattern_to_string(pattern)
      }
  }
}

///|
fn list_hint_string(pattern : Pattern) -> String? {
  let items = []
  for current = pattern {
    match current {
      NilPat => {
        let joined = items.join(", ")
        break Some("[\{joined}]")
      }
      ConsPat(head, tail) => {
        items.push(pattern_hint_string(head))
        continue tail
      }
      WildcardPat | VarPat(_) => {
        let body = if items.is_empty() {
          "..."
        } else {
          items.join(", ") + ", ..."
        }
        break Some("[\{body}]")
      }
      _ =>
        if items.is_empty() {
          break None
        } else {
          let joined = items.join(", ")
          let tail = pattern_hint_string(current)
          break Some("[\{joined} | \{tail}]")
        }
    }
  }
}

///|
fn ctor_pattern_to_string(
  name : String,
  patterns : ArrayView[Pattern],
) -> String {
  match patterns.length() {
    0 => name
    1 => "\{name} \{pattern_to_string(patterns[0])}"
    _ => {
      let items = patterns.map(p => pattern_to_string(p)).join(", ")
      "\{name}(\{items})"
    }
  }
}

///|
fn ctor_pattern_hint_string(
  name : String,
  patterns : ArrayView[Pattern],
) -> String {
  match patterns.length() {
    0 => name
    1 => "\{name}(\{pattern_hint_string(patterns[0])})"
    _ => {
      let items = patterns.map(p => pattern_hint_string(p)).join(", ")
      "\{name}(\{items})"
    }
  }
}

///|
fn ctor_value_to_string(name : String, values : ArrayView[Value]) -> String {
  match values.length() {
    0 => name
    1 => "\{name}(\{value_to_string(values[0])})"
    _ => {
      let items = values.map(v => value_to_string(v)).join(", ")
      "\{name}(\{items})"
    }
  }
}

///|
fn list_value_to_string(value : Value) -> String {
  let items = []
  for current = value {
    match current {
      NilValue => break
      ConsValue(head, tail) => {
        items.push(value_to_string(head))
        continue tail
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
    UnitValue => "()"
    IntValue(n) => n.to_string()
    BoolValue(b) => b.to_string()
    StringValue(text) => escape_string_literal(text)
    ClosureValue(_) => "<fun>"
    CtorFuncValue(name, arity, values) =>
      "<ctor \{name}/\{arity - values.length()}>"
    VariantValue(name, values) => ctor_value_to_string(name, values)
    TupleValue(values) => {
      let items = values.map(v => value_to_string(v)).join(", ")
      "(\{items})"
    }
    NilValue => "[]"
    ConsValue(_) => list_value_to_string(value)
  }
}

///|
fn Env::new(parent? : Env? = None) -> Env {
  Env::{ bindings: {}, parent }
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
  TypeEnv::{ bindings: {}, parent }
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
fn base_runtime_env() -> Env {
  Env::new()
  .extend("None", VariantValue("None", []))
  .extend("Some", CtorFuncValue("Some", 1, []))
}

///|
fn base_type_env() -> TypeEnv {
  let option_var = VarType(0)
  TypeEnv::new()
  .extend("None", Scheme::{ vars: [0], ty: OptionType(option_var) })
  .extend("Some", Scheme::{
    vars: [0],
    ty: FunType(option_var, OptionType(option_var)),
  })
}

///|
fn InferCtx::new() -> InferCtx {
  InferCtx::{
    next_id: 0,
    next_enum_id: 0,
    subst: {},
    enum_defs: {},
    type_name_to_enum: {},
    ctor_to_enum: {},
  }
}

///|
fn TypePrinter::new() -> TypePrinter {
  TypePrinter::{ names: {}, next_id: 0 }
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
fn read_string_body(
  code : StringView,
  acc? : String = "",
) -> (String, StringView) raise MiniMLError {
  match code {
    ['"', .. rest] => (acc, rest)
    ['\\', 'n', .. rest] => read_string_body(rest, acc=acc + "\n")
    ['\\', 'r', .. rest] => read_string_body(rest, acc=acc + "\r")
    ['\\', 't', .. rest] => read_string_body(rest, acc=acc + "\t")
    ['\\', '"', .. rest] => read_string_body(rest, acc=acc + "\"")
    ['\\', '\\', .. rest] => read_string_body(rest, acc=acc + "\\")
    ['\\', c, ..] => raise LexError("unsupported string escape `\\\{c}`")
    [c, .. rest] => read_string_body(rest, acc=acc + c.to_string())
    [] => raise LexError("unterminated string literal")
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
pub fn tokenize(code : String) -> ArrayView[Token] raise MiniMLError {
  let tokens = []
  for rest = code[:] {
    match rest {
      [] => {
        tokens.push(EOFTok)
        break
      }
      [' ' | '\t' | '\r' | '\n', .. next] => continue next
      [.. "//", .. next] => continue skip_line_comment(next)
      [.. "->", .. next] => {
        tokens.push(ArrowTok)
        continue next
      }
      [.. "==", .. next] => {
        tokens.push(EqEqTok)
        continue next
      }
      [.. "!=", .. next] => {
        tokens.push(NotEqTok)
        continue next
      }
      [.. "<=", .. next] => {
        tokens.push(LeTok)
        continue next
      }
      [.. ">=", .. next] => {
        tokens.push(GeTok)
        continue next
      }
      [.. "&&", .. next] => {
        tokens.push(AndTok)
        continue next
      }
      [.. "||", .. next] => {
        tokens.push(OrTok)
        continue next
      }
      [.. "::", .. next] => {
        tokens.push(ConsTok)
        continue next
      }
      ['{', .. next] => {
        tokens.push(LBraceTok)
        continue next
      }
      ['}', .. next] => {
        tokens.push(RBraceTok)
        continue next
      }
      ['"', .. next] => {
        let (text, rest2) = read_string_body(next)
        tokens.push(StringTok(text))
        continue rest2
      }
      ['(', .. next] => {
        tokens.push(LParenTok)
        continue next
      }
      [')', .. next] => {
        tokens.push(RParenTok)
        continue next
      }
      ['[', .. next] => {
        tokens.push(LBracketTok)
        continue next
      }
      [':', .. next] => {
        tokens.push(ColonTok)
        continue next
      }
      [']', .. next] => {
        tokens.push(RBracketTok)
        continue next
      }
      [',', .. next] => {
        tokens.push(CommaTok)
        continue next
      }
      [';', .. next] => {
        tokens.push(SemiTok)
        continue next
      }
      ['|', .. next] => {
        tokens.push(BarTok)
        continue next
      }
      ['+', .. next] => {
        tokens.push(PlusTok)
        continue next
      }
      ['-', .. next] => {
        tokens.push(MinusTok)
        continue next
      }
      ['*', .. next] => {
        tokens.push(StarTok)
        continue next
      }
      ['/', .. next] => {
        tokens.push(SlashTok)
        continue next
      }
      ['=', .. next] => {
        tokens.push(EqTok)
        continue next
      }
      ['<', .. next] => {
        tokens.push(LtTok)
        continue next
      }
      ['>', .. next] => {
        tokens.push(GtTok)
        continue next
      }
      ['!', .. next] => {
        tokens.push(NotTok)
        continue next
      }
      [c, ..] if is_digit(c) => {
        let (n, next) = read_number(rest)
        tokens.push(IntTok(n))
        continue next
      }
      [c, ..] if is_alpha(c) || c == '_' => {
        let (ident, next) = read_ident(rest)
        let token = match ident {
          "let" => LetTok
          "in" => InTok
          "rec" => RecTok
          "and" => AndKwTok
          "enum" => EnumTok
          "fun" => FunTok
          "if" => IfTok
          "then" => ThenTok
          "else" => ElseTok
          "match" => MatchTok
          "with" => WithTok
          "true" => BoolTok(true)
          "false" => BoolTok(false)
          "_" => WildcardTok
          _ =>
            if ident.length() > 0 && ident[0] >= 'A' && ident[0] <= 'Z' {
              CtorTok(ident)
            } else {
              IdentTok(ident)
            }
        }
        tokens.push(token)
        continue next
      }
      [c, ..] => raise LexError("unexpected character `\{c}`")
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
    IntTok(_)
    | BoolTok(_)
    | StringTok(_)
    | IdentTok(_)
    | CtorTok(_)
    | LBraceTok
    | LParenTok
    | LBracketTok => true
    _ => false
  }
}

///|
fn is_pattern_atom_start(token : Token) -> Bool {
  match token {
    WildcardTok
    | IntTok(_)
    | BoolTok(_)
    | IdentTok(_)
    | CtorTok(_)
    | LParenTok
    | LBracketTok => true
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
fn expect_ctor_name(
  tokens : ArrayView[Token],
) -> (String, ArrayView[Token]) raise MiniMLError {
  guard tokens is [tok, .. rest] else {
    raise ParseError("expected constructor name, but reached end of input")
  }
  match tok {
    CtorTok(name) => (name, rest)
    _ =>
      raise ParseError("expected constructor name, got \{token_to_string(tok)}")
  }
}

///|
fn parse_ctor_pattern_args(
  name : String,
  tokens : ArrayView[Token],
) -> (Pattern, ArrayView[Token]) raise MiniMLError {
  let patterns = []
  let (first, rest) = parse_pattern(tokens)
  patterns.push(first)
  for current = rest {
    match current {
      [CommaTok, .. rest2] => {
        let (next_pat, rest3) = parse_pattern(rest2)
        patterns.push(next_pat)
        continue rest3
      }
      [RParenTok, .. rest2] => return (CtorPat(name, patterns), rest2)
      [tok, ..] =>
        raise ParseError(
          "expected `,` or `)` in constructor pattern, got \{token_to_string(tok)}",
        )
      [] => raise ParseError("expected `)` to close constructor pattern")
    }
  }
}

///|
fn list_pattern_from_array(patterns : ArrayView[Pattern]) -> Pattern {
  patterns.rev_fold(init=NilPat, (acc, pattern) => ConsPat(pattern, acc))
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
    CtorTok(name) =>
      match rest {
        [LParenTok, .. rest2] => parse_ctor_pattern_args(name, rest2)
        [next, ..] if is_pattern_atom_start(next) => {
          let (sub_pattern, rest2) = parse_pattern_atom(rest)
          (CtorPat(name, [sub_pattern]), rest2)
        }
        _ => (CtorPat(name, []), rest)
      }
    LBracketTok =>
      match rest {
        [RBracketTok, .. rest2] => (NilPat, rest2)
        _ => {
          let patterns = []
          let (first, rest2) = parse_pattern(rest)
          patterns.push(first)
          for current = rest2 {
            match current {
              [CommaTok, .. rest3] => {
                let (next_pat, rest4) = parse_pattern(rest3)
                patterns.push(next_pat)
                continue rest4
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
        }
      }
    LParenTok =>
      match rest {
        [RParenTok, .. rest2] => (UnitPat, rest2)
        _ => {
          let (first, rest2) = parse_pattern(rest)
          match rest2 {
            [CommaTok, .. rest3] => {
              let patterns = []
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
fn apply_args(func : Expr, args : ArrayView[Expr]) -> Expr {
  args.fold(init=func, (acc, arg) => ApplyExpr(acc, arg))
}

///|
fn seq_from_exprs(
  exprs : ArrayView[Expr],
  trailing_unit? : Bool = false,
) -> Expr {
  let body = if trailing_unit { [..exprs, UnitExpr] } else { exprs.to_owned() }
  if body.is_empty() {
    return UnitExpr
  }
  let mut acc = body[body.length() - 1]
  for i = body.length() - 2; i >= 0; i = i - 1 {
    acc = SeqExpr(body[i], acc)
  }
  acc
}

///|
fn parse_ctor_expr_args(
  name : String,
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  let args = []
  let (first, rest) = parse_expr(tokens)
  args.push(first)
  for current = rest {
    match current {
      [CommaTok, .. rest2] => {
        let (next_expr, rest3) = parse_expr(rest2)
        args.push(next_expr)
        continue rest3
      }
      [RParenTok, .. rest2] => return (apply_args(VarExpr(name), args), rest2)
      [tok, ..] =>
        raise ParseError(
          "expected `,` or `)` in constructor arguments, got \{token_to_string(tok)}",
        )
      [] => raise ParseError("expected `)` to close constructor arguments")
    }
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
    StringTok(text) => (StringExpr(text), rest)
    IdentTok(name) => (VarExpr(name), rest)
    CtorTok(name) =>
      match rest {
        [LParenTok, .. rest2] => parse_ctor_expr_args(name, rest2)
        _ => (VarExpr(name), rest)
      }
    LBraceTok => parse_block_expr(rest)
    LBracketTok =>
      match rest {
        [RBracketTok, .. rest2] => (ListExpr([]), rest2)
        _ => {
          let exprs = []
          let (first, rest2) = parse_expr(rest)
          exprs.push(first)
          for current = rest2 {
            match current {
              [CommaTok, .. rest3] => {
                let (next_expr, rest4) = parse_expr(rest3)
                exprs.push(next_expr)
                continue rest4
              }
              [RBracketTok, .. rest3] => return (ListExpr(exprs), rest3)
              [tok2, ..] =>
                raise ParseError(
                  "expected `,` or `]` in list literal, got \{token_to_string(tok2)}",
                )
              [] => raise ParseError("expected `]` to close list literal")
            }
          }
        }
      }
    LParenTok =>
      match rest {
        [RParenTok, .. rest2] => (UnitExpr, rest2)
        _ => {
          let (first, rest2) = parse_expr(rest)
          match rest2 {
            [CommaTok, .. rest3] => {
              let exprs = [first]
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
fn parse_block_expr(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  parse_block_items(tokens)
}

///|
fn block_nonrec_expr(bindings : Array[LetBinding], body : Expr) -> Expr {
  if bindings.length() == 1 {
    let binding = bindings[0]
    LetExpr(binding.pattern, binding.annot, binding.bound, body)
  } else {
    LetGroupExpr(bindings, body)
  }
}

///|
fn block_rec_expr(bindings : Array[RecBinding], body : Expr) -> Expr {
  if bindings.length() == 1 {
    let binding = bindings[0]
    LetRecExpr(
      binding.name,
      binding.param,
      binding.param_annot,
      binding.return_annot,
      binding.fun_body,
      body,
    )
  } else {
    LetRecGroupExpr(bindings, body)
  }
}

///|
fn parse_block_items(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  match tokens {
    [RBraceTok, .. rest] => (UnitExpr, rest)
    [LetTok, .. rest] =>
      match rest {
        [RecTok, .. rest2] => {
          let (name, rest3) = expect_ident(rest2)
          let (first_binding, rest4) = parse_block_rec_binding(name, rest3)
          let bindings = [first_binding]
          let mut current = rest4
          while true {
            match current {
              [AndKwTok, .. rest5] => {
                let (next_name, rest6) = expect_ident(rest5)
                let (binding, rest7) = parse_block_rec_binding(next_name, rest6)
                bindings.push(binding)
                current = rest7
              }
              _ => break
            }
          }
          match current {
            [SemiTok, .. rest5] => {
              let (body, rest6) = parse_block_items(rest5)
              (block_rec_expr(bindings, body), rest6)
            }
            [RBraceTok, .. rest5] => (block_rec_expr(bindings, UnitExpr), rest5)
            [tok, ..] =>
              raise ParseError(
                "expected `;` or `}` after block let rec, got \{token_to_string(tok)}",
              )
            [] => raise ParseError("expected `}` to close block expression")
          }
        }
        _ => {
          let (pattern, rest3) = parse_pattern(rest)
          let (first_binding, rest4) = parse_block_nonrec_binding(
            pattern, rest3,
          )
          let bindings = [first_binding]
          let mut current = rest4
          while true {
            match current {
              [AndKwTok, .. rest5] => {
                let (next_pattern, rest6) = parse_pattern(rest5)
                let (binding, rest7) = parse_block_nonrec_binding(
                  next_pattern, rest6,
                )
                bindings.push(binding)
                current = rest7
              }
              _ => break
            }
          }
          match current {
            [SemiTok, .. rest5] => {
              let (body, rest6) = parse_block_items(rest5)
              (block_nonrec_expr(bindings, body), rest6)
            }
            [RBraceTok, .. rest5] =>
              (block_nonrec_expr(bindings, UnitExpr), rest5)
            [tok, ..] =>
              raise ParseError(
                "expected `;` or `}` after block let, got \{token_to_string(tok)}",
              )
            [] => raise ParseError("expected `}` to close block expression")
          }
        }
      }
    _ => {
      let exprs = []
      let (first, rest0) = parse_expr_no_seq(tokens)
      exprs.push(first)
      let mut trailing_unit = false
      let mut current = rest0
      while true {
        match current {
          [SemiTok, RBraceTok, .. rest] => {
            trailing_unit = true
            return (seq_from_exprs(exprs, trailing_unit~), rest)
          }
          [SemiTok, LetTok, ..] => {
            let (body, rest2) = parse_block_items(current[1:])
            return (SeqExpr(seq_from_exprs(exprs), body), rest2)
          }
          [SemiTok, .. rest] => {
            let (next_expr, rest2) = parse_expr_no_seq(rest)
            exprs.push(next_expr)
            current = rest2
          }
          [RBraceTok, .. rest] => return (seq_from_exprs(exprs), rest)
          [tok, ..] =>
            raise ParseError(
              "expected `;` or `}` in block expression, got \{token_to_string(tok)}",
            )
          [] => raise ParseError("expected `}` to close block expression")
        }
      }
      (UnitExpr, current)
    }
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
  for expr = expr0, rest = rest0 {
    match rest {
      [tok, ..] if is_atom_start(tok) => {
        let (arg, next_rest) = parse_prefix(rest)
        continue ApplyExpr(expr, arg), next_rest
      }
      _ => break (expr, rest)
    }
  }
}

///|
fn parse_mul(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  let (expr0, rest0) = parse_application(tokens)
  for expr = expr0, rest = rest0 {
    match rest {
      [StarTok, .. rest2] => {
        let (rhs, next_rest) = parse_application(rest2)
        continue BinaryExpr(Mul, expr, rhs), next_rest
      }
      [SlashTok, .. rest2] => {
        let (rhs, next_rest) = parse_application(rest2)
        continue BinaryExpr(Div, expr, rhs), next_rest
      }
      _ => break (expr, rest)
    }
  }
}

///|
fn parse_add(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  let (expr0, rest0) = parse_mul(tokens)
  for expr = expr0, rest = rest0 {
    match rest {
      [PlusTok, .. rest2] => {
        let (rhs, next_rest) = parse_mul(rest2)
        continue BinaryExpr(Add, expr, rhs), next_rest
      }
      [MinusTok, .. rest2] => {
        let (rhs, next_rest) = parse_mul(rest2)
        continue BinaryExpr(Sub, expr, rhs), next_rest
      }
      _ => break (expr, rest)
    }
  }
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
  for expr = expr0, rest = rest0 {
    match rest {
      [EqEqTok, .. rest2] => {
        let (rhs, next_rest) = parse_cons(rest2)
        continue BinaryExpr(Eq, expr, rhs), next_rest
      }
      [NotEqTok, .. rest2] => {
        let (rhs, next_rest) = parse_cons(rest2)
        continue BinaryExpr(NE, expr, rhs), next_rest
      }
      [LtTok, .. rest2] => {
        let (rhs, next_rest) = parse_cons(rest2)
        continue BinaryExpr(LT, expr, rhs), next_rest
      }
      [LeTok, .. rest2] => {
        let (rhs, next_rest) = parse_cons(rest2)
        continue BinaryExpr(LE, expr, rhs), next_rest
      }
      [GtTok, .. rest2] => {
        let (rhs, next_rest) = parse_cons(rest2)
        continue BinaryExpr(GT, expr, rhs), next_rest
      }
      [GeTok, .. rest2] => {
        let (rhs, next_rest) = parse_cons(rest2)
        continue BinaryExpr(GE, expr, rhs), next_rest
      }
      _ => break (expr, rest)
    }
  }
}

///|
fn parse_and(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  let (expr0, rest0) = parse_compare(tokens)
  for expr = expr0, rest = rest0 {
    match rest {
      [AndTok, .. rest2] => {
        let (rhs, next_rest) = parse_compare(rest2)
        continue BinaryExpr(And, expr, rhs), next_rest
      }
      _ => break (expr, rest)
    }
  }
}

///|
fn parse_or(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  let (expr0, rest0) = parse_and(tokens)
  for expr = expr0, rest = rest0 {
    match rest {
      [OrTok, .. rest2] => {
        let (rhs, next_rest) = parse_and(rest2)
        continue BinaryExpr(Or, expr, rhs), next_rest
      }
      _ => break (expr, rest)
    }
  }
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
fn parse_match_arm_no_seq(
  tokens : ArrayView[Token],
) -> (MatchArm, ArrayView[Token]) raise MiniMLError {
  let tokens = if tokens is [BarTok, .. rest] { rest } else { tokens }
  let (pattern, rest0) = parse_pattern(tokens)
  let (guard_, rest) = match rest0 {
    [IfTok, .. rest2] => {
      let (guard_expr, rest3) = parse_expr_no_seq(rest2)
      (Some(guard_expr), rest3)
    }
    _ => (None, rest0)
  }
  let rest1 = expect_token(rest, ArrowTok)
  let (body, rest2) = parse_expr_no_seq(rest1)
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
  let arms = []
  let (first_arm, rest4) = parse_match_arm(rest3)
  arms.push(first_arm)
  for current = rest4 {
    match current {
      [BarTok, ..] => {
        let (arm, rest5) = parse_match_arm(current)
        arms.push(arm)
        continue rest5
      }
      _ => break (MatchExpr(scrutinee, arms), current)
    }
  }
}

///|
fn parse_match_no_seq(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  guard tokens is [tok, .. rest] else {
    raise ParseError("expected expression, but reached end of input")
  }
  if tok != MatchTok {
    return parse_or(tokens)
  }
  let (scrutinee, rest2) = parse_expr_no_seq(rest)
  let rest3 = expect_token(rest2, WithTok)
  let arms = []
  let (first_arm, rest4) = parse_match_arm_no_seq(rest3)
  arms.push(first_arm)
  for current = rest4 {
    match current {
      [BarTok, ..] => {
        let (arm, rest5) = parse_match_arm_no_seq(current)
        arms.push(arm)
        continue rest5
      }
      _ => break (MatchExpr(scrutinee, arms), current)
    }
  }
}

///|
fn parse_decl_type_atom(
  tokens : ArrayView[Token],
) -> (DeclType, ArrayView[Token]) raise MiniMLError {
  guard tokens is [tok, .. rest] else {
    raise ParseError("expected type, but reached end of input")
  }
  match tok {
    IdentTok("unit") => (UnitDeclType, rest)
    IdentTok("int") => (IntDeclType, rest)
    IdentTok("bool") => (BoolDeclType, rest)
    IdentTok("string") => (StringDeclType, rest)
    IdentTok(name) => (TypeVarDeclType(name), rest)
    CtorTok(name) =>
      match rest {
        [LBracketTok, .. rest2] => {
          let args = []
          let (first, rest3) = parse_decl_type(rest2)
          args.push(first)
          for current = rest3 {
            match current {
              [CommaTok, .. rest4] => {
                let (next_arg, rest5) = parse_decl_type(rest4)
                args.push(next_arg)
                continue rest5
              }
              [RBracketTok, .. rest4] =>
                return (NamedDeclType(name, args), rest4)
              [tok2, ..] =>
                raise ParseError(
                  "expected `,` or `]` in type arguments, got \{token_to_string(tok2)}",
                )
              [] => raise ParseError("expected `]` to close type arguments")
            }
          }
        }
        _ => (NamedDeclType(name, []), rest)
      }
    LParenTok =>
      match rest {
        [RParenTok, .. rest2] => (UnitDeclType, rest2)
        _ => {
          let (first, rest2) = parse_decl_type(rest)
          match rest2 {
            [StarTok, .. rest3] => {
              let items = []
              items.push(first)
              let mut current = rest3
              while true {
                let (next_type, rest4) = parse_decl_type(current)
                items.push(next_type)
                current = rest4
                match current {
                  [StarTok, .. rest5] => current = rest5
                  [RParenTok, .. rest5] => return (TupleDeclType(items), rest5)
                  [tok2, ..] =>
                    raise ParseError(
                      "expected `*` or `)` in tuple type, got \{token_to_string(tok2)}",
                    )
                  [] => raise ParseError("expected `)` to close tuple type")
                }
              }
              (first, current)
            }
            [RParenTok, .. rest3] => (first, rest3)
            [tok2, ..] =>
              raise ParseError(
                "expected `*` or `)` in parenthesized type, got \{token_to_string(tok2)}",
              )
            [] => raise ParseError("expected `)` to close parenthesized type")
          }
        }
      }
    _ => raise ParseError("expected type, got \{token_to_string(tok)}")
  }
}

///|
fn parse_decl_type(
  tokens : ArrayView[Token],
) -> (DeclType, ArrayView[Token]) raise MiniMLError {
  let (base, rest) = parse_decl_type_atom(tokens)
  for result = base, current = rest {
    match current {
      [IdentTok("list"), .. rest2] => continue ListDeclType(result), rest2
      [IdentTok("option"), .. rest2] => continue OptionDeclType(result), rest2
      _ =>
        break match current {
          [ArrowTok, .. rest2] => {
            let (ret, rest3) = parse_decl_type(rest2)
            (FunDeclType(result, ret), rest3)
          }
          _ => (result, current)
        }
    }
  }
}

///|
fn parse_type_annotation(
  tokens : ArrayView[Token],
) -> (DeclType?, ArrayView[Token]) raise MiniMLError {
  match tokens {
    [ColonTok, .. rest] => {
      let (type_, rest2) = parse_decl_type(rest)
      (Some(type_), rest2)
    }
    _ => (None, tokens)
  }
}

///|
fn parse_binder(
  tokens : ArrayView[Token],
) -> (String, DeclType?, ArrayView[Token]) raise MiniMLError {
  match tokens {
    [LParenTok, .. rest] => {
      let (name, rest2) = expect_ident(rest)
      let (annot, rest3) = parse_type_annotation(rest2)
      guard annot is Some(_) else {
        raise ParseError("expected type annotation in parenthesized binder")
      }
      let rest4 = expect_token(rest3, RParenTok)
      (name, annot, rest4)
    }
    _ => {
      let (name, rest) = expect_ident(tokens)
      let (annot, rest2) = parse_type_annotation(rest)
      (name, annot, rest2)
    }
  }
}

///|
fn fresh_param_name(tokens : ArrayView[Token]) -> String {
  "$param\{tokens.length()}"
}

///|
fn parse_param(
  tokens : ArrayView[Token],
) -> (FnParam, ArrayView[Token]) raise MiniMLError {
  match tokens {
    [LParenTok, IdentTok(_), ColonTok, ..] | [IdentTok(_), ColonTok, ..] => {
      let (name, annot, rest) = parse_binder(tokens)
      (FnParam::{ pattern: VarPat(name), binder: name, annot }, rest)
    }
    _ => {
      let (pattern, rest) = parse_pattern(tokens)
      let binder = match pattern {
        VarPat(name) => name
        _ => fresh_param_name(tokens)
      }
      (FnParam::{ pattern, binder, annot: None }, rest)
    }
  }
}

///|
fn parse_param_list(
  tokens : ArrayView[Token],
) -> (Array[FnParam], ArrayView[Token]) raise MiniMLError {
  let params = []
  for current = tokens {
    match current {
      [tok, ..] if is_param_start(tok) => {
        let (param, rest) = parse_param(current)
        params.push(param)
        continue rest
      }
      _ => {
        if params.is_empty() {
          raise ParseError("expected function parameter")
        }
        break (params, current)
      }
    }
  }
}

///|
fn parse_rec_binding(
  name : String,
  tokens : ArrayView[Token],
) -> (RecBinding, ArrayView[Token]) raise MiniMLError {
  let (params, rest0) = parse_param_list(tokens)
  let (return_annot, rest1) = parse_type_annotation(rest0)
  let rest2 = expect_token(rest1, EqTok)
  let (fun_body0, rest3) = parse_expr(rest2)
  (make_rec_binding(name, params, return_annot, fun_body0), rest3)
}

///|
fn parse_block_rec_binding(
  name : String,
  tokens : ArrayView[Token],
) -> (RecBinding, ArrayView[Token]) raise MiniMLError {
  let (params, rest0) = parse_param_list(tokens)
  let (return_annot, rest1) = parse_type_annotation(rest0)
  let rest2 = expect_token(rest1, EqTok)
  let (fun_body0, rest3) = parse_expr_no_seq(rest2)
  (make_rec_binding(name, params, return_annot, fun_body0), rest3)
}

///|
fn parse_nonrec_binding(
  pattern : Pattern,
  tokens : ArrayView[Token],
) -> (LetBinding, ArrayView[Token]) raise MiniMLError {
  match (pattern, tokens) {
    (VarPat(name), [tok, ..]) if is_param_start(tok) => {
      let (params, rest0) = parse_param_list(tokens)
      let (return_annot, rest1) = parse_type_annotation(rest0)
      let rest2 = expect_token(rest1, EqTok)
      let (fun_body0, rest3) = parse_expr(rest2)
      let bound = params_to_expr(
        params,
        ascribe_if_needed(fun_body0, return_annot),
      )
      (LetBinding::{ pattern: VarPat(name), annot: None, bound }, rest3)
    }
    _ => {
      let (annot, rest0) = parse_type_annotation(tokens)
      let rest1 = expect_token(rest0, EqTok)
      let (bound, rest2) = parse_expr(rest1)
      (LetBinding::{ pattern, annot, bound }, rest2)
    }
  }
}

///|
fn parse_block_nonrec_binding(
  pattern : Pattern,
  tokens : ArrayView[Token],
) -> (LetBinding, ArrayView[Token]) raise MiniMLError {
  match (pattern, tokens) {
    (VarPat(name), [tok, ..]) if is_param_start(tok) => {
      let (params, rest0) = parse_param_list(tokens)
      let (return_annot, rest1) = parse_type_annotation(rest0)
      let rest2 = expect_token(rest1, EqTok)
      let (fun_body0, rest3) = parse_expr_no_seq(rest2)
      let bound = params_to_expr(
        params,
        ascribe_if_needed(fun_body0, return_annot),
      )
      (LetBinding::{ pattern: VarPat(name), annot: None, bound }, rest3)
    }
    _ => {
      let (annot, rest0) = parse_type_annotation(tokens)
      let rest1 = expect_token(rest0, EqTok)
      let (bound, rest2) = parse_expr_no_seq(rest1)
      (LetBinding::{ pattern, annot, bound }, rest2)
    }
  }
}

///|
fn parse_enum_variant_decl(
  tokens : ArrayView[Token],
) -> (EnumVariantDecl, ArrayView[Token]) raise MiniMLError {
  let (name, rest) = expect_ctor_name(tokens)
  match rest {
    [LParenTok, .. rest2] => {
      let fields = []
      let (first, rest3) = parse_decl_type(rest2)
      fields.push(first)
      for current = rest3 {
        match current {
          [CommaTok, .. rest4] => {
            let (next_field, rest5) = parse_decl_type(rest4)
            fields.push(next_field)
            continue rest5
          }
          [RParenTok, .. rest4] =>
            return (EnumVariantDecl::{ name, fields }, rest4)
          [tok, ..] =>
            raise ParseError(
              "expected `,` or `)` in variant fields, got \{token_to_string(tok)}",
            )
          [] => raise ParseError("expected `)` to close variant fields")
        }
      }
    }
    _ => (EnumVariantDecl::{ name, fields: [] }, rest)
  }
}

///|
fn parse_enum_type_params(
  tokens : ArrayView[Token],
) -> (Array[String], ArrayView[Token]) raise MiniMLError {
  match tokens {
    [LBracketTok, .. rest] => {
      let params = []
      let (first, rest2) = expect_ident(rest)
      params.push(first)
      for current = rest2 {
        match current {
          [CommaTok, .. rest3] => {
            let (param, rest4) = expect_ident(rest3)
            params.push(param)
            continue rest4
          }
          [RBracketTok, .. rest3] => return (params, rest3)
          [tok, ..] =>
            raise ParseError(
              "expected `,` or `]` in enum type parameters, got \{token_to_string(tok)}",
            )
          [] => raise ParseError("expected `]` to close enum type parameters")
        }
      }
    }
    _ => ([], tokens)
  }
}

///|
fn parse_enum(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  guard tokens is [tok, .. rest] else {
    raise ParseError("expected expression, but reached end of input")
  }
  if tok != EnumTok {
    return parse_let(tokens)
  }
  let (name, rest2) = expect_ctor_name(rest)
  let (type_params, rest3) = parse_enum_type_params(rest2)
  let rest4 = expect_token(rest3, EqTok)
  let variants = []
  let (first_variant, rest5) = parse_enum_variant_decl(rest4)
  variants.push(first_variant)
  for current = rest5 {
    match current {
      [BarTok, .. rest6] => {
        let (variant, rest7) = parse_enum_variant_decl(rest6)
        variants.push(variant)
        continue rest7
      }
      _ => {
        let rest6 = expect_token(current, InTok)
        let (body, rest7) = parse_expr(rest6)
        break (EnumExpr(EnumDecl::{ name, type_params, variants }, body), rest7)
      }
    }
  }
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
  let (params, rest2) = parse_param_list(rest)
  let rest3 = expect_token(rest2, ArrowTok)
  let (body, rest4) = parse_expr(rest3)
  (params_to_expr(params, body), rest4)
}

///|
fn parse_fun_no_seq(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  guard tokens is [tok, .. rest] else {
    raise ParseError("expected expression, but reached end of input")
  }
  if tok != FunTok {
    return parse_match_no_seq(tokens)
  }
  let (params, rest2) = parse_param_list(rest)
  let rest3 = expect_token(rest2, ArrowTok)
  let (body, rest4) = parse_expr_no_seq(rest3)
  (params_to_expr(params, body), rest4)
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
fn parse_if_no_seq(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  guard tokens is [tok, .. rest] else {
    raise ParseError("expected expression, but reached end of input")
  }
  if tok != IfTok {
    return parse_fun_no_seq(tokens)
  }
  let (cond, rest2) = parse_expr_no_seq(rest)
  let rest3 = expect_token(rest2, ThenTok)
  let (then_, rest4) = parse_expr_no_seq(rest3)
  let rest5 = expect_token(rest4, ElseTok)
  let (else_, rest6) = parse_expr_no_seq(rest5)
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
    let (first_binding, rest4) = parse_rec_binding(name, rest3)
    let bindings = [first_binding]
    let mut current = rest4
    while true {
      match current {
        [AndKwTok, .. rest5] => {
          let (next_name, rest6) = expect_ident(rest5)
          let (binding, rest7) = parse_rec_binding(next_name, rest6)
          bindings.push(binding)
          current = rest7
        }
        _ => break
      }
    }
    let rest8 = expect_token(current, InTok)
    let (body, rest9) = parse_expr(rest8)
    if bindings.length() == 1 {
      let binding = bindings[0]
      (
        LetRecExpr(
          binding.name,
          binding.param,
          binding.param_annot,
          binding.return_annot,
          binding.fun_body,
          body,
        ),
        rest9,
      )
    } else {
      (LetRecGroupExpr(bindings, body), rest9)
    }
  } else {
    let (pattern, rest3) = parse_pattern(rest)
    let (first_binding, rest4) = parse_nonrec_binding(pattern, rest3)
    let bindings = []
    bindings.push(first_binding)
    let mut current = rest4
    while true {
      match current {
        [AndKwTok, .. rest5] => {
          let (next_pattern, rest6) = parse_pattern(rest5)
          let (binding, rest7) = parse_nonrec_binding(next_pattern, rest6)
          bindings.push(binding)
          current = rest7
        }
        _ => break
      }
    }
    let rest5 = expect_token(current, InTok)
    let (body, rest6) = parse_expr(rest5)
    if bindings.length() == 1 {
      let binding = bindings[0]
      (LetExpr(binding.pattern, binding.annot, binding.bound, body), rest6)
    } else {
      (LetGroupExpr(bindings, body), rest6)
    }
  }
}

///|
fn parse_let_no_seq(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  guard tokens is [tok, .. rest] else {
    raise ParseError("expected expression, but reached end of input")
  }
  if tok != LetTok {
    return parse_if_no_seq(tokens)
  }
  guard rest is [tok2, .. rest2] else {
    raise ParseError("incomplete let expression")
  }
  if tok2 == RecTok {
    let (name, rest3) = expect_ident(rest2)
    let (first_binding, rest4) = parse_rec_binding(name, rest3)
    let bindings = [first_binding]
    let mut current = rest4
    while true {
      match current {
        [AndKwTok, .. rest5] => {
          let (next_name, rest6) = expect_ident(rest5)
          let (binding, rest7) = parse_rec_binding(next_name, rest6)
          bindings.push(binding)
          current = rest7
        }
        _ => break
      }
    }
    let rest8 = expect_token(current, InTok)
    let (body, rest9) = parse_expr_no_seq(rest8)
    if bindings.length() == 1 {
      let binding = bindings[0]
      (
        LetRecExpr(
          binding.name,
          binding.param,
          binding.param_annot,
          binding.return_annot,
          binding.fun_body,
          body,
        ),
        rest9,
      )
    } else {
      (LetRecGroupExpr(bindings, body), rest9)
    }
  } else {
    let (pattern, rest3) = parse_pattern(rest)
    let (first_binding, rest4) = parse_nonrec_binding(pattern, rest3)
    let bindings = []
    bindings.push(first_binding)
    let mut current = rest4
    while true {
      match current {
        [AndKwTok, .. rest5] => {
          let (next_pattern, rest6) = parse_pattern(rest5)
          let (binding, rest7) = parse_nonrec_binding(next_pattern, rest6)
          bindings.push(binding)
          current = rest7
        }
        _ => break
      }
    }
    let rest5 = expect_token(current, InTok)
    let (body, rest6) = parse_expr_no_seq(rest5)
    if bindings.length() == 1 {
      let binding = bindings[0]
      (LetExpr(binding.pattern, binding.annot, binding.bound, body), rest6)
    } else {
      (LetGroupExpr(bindings, body), rest6)
    }
  }
}

///|
fn parse_enum_no_seq(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  guard tokens is [tok, .. rest] else {
    raise ParseError("expected expression, but reached end of input")
  }
  if tok != EnumTok {
    return parse_let_no_seq(tokens)
  }
  let (name, rest2) = expect_ctor_name(rest)
  let (type_params, rest3) = parse_enum_type_params(rest2)
  let rest4 = expect_token(rest3, EqTok)
  let variants = []
  let (first_variant, rest5) = parse_enum_variant_decl(rest4)
  variants.push(first_variant)
  for current = rest5 {
    match current {
      [BarTok, .. rest6] => {
        let (variant, rest7) = parse_enum_variant_decl(rest6)
        variants.push(variant)
        continue rest7
      }
      _ => {
        let rest6 = expect_token(current, InTok)
        let (body, rest7) = parse_expr_no_seq(rest6)
        break (EnumExpr(EnumDecl::{ name, type_params, variants }, body), rest7)
      }
    }
  }
}

///|
fn parse_expr_no_seq(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  let (expr0, rest0) = parse_enum_no_seq(tokens)
  for expr = expr0, rest = rest0 {
    match rest {
      [ColonTok, .. rest2] => {
        let (type_, rest3) = parse_decl_type(rest2)
        continue AscribeExpr(expr, type_), rest3
      }
      _ => break (expr, rest)
    }
  }
}

///|
fn parse_expr(
  tokens : ArrayView[Token],
) -> (Expr, ArrayView[Token]) raise MiniMLError {
  let (expr0, rest0) = parse_enum(tokens)
  let (expr1, rest1) = for expr = expr0, rest = rest0 {
    match rest {
      [ColonTok, .. rest2] => {
        let (type_, rest3) = parse_decl_type(rest2)
        continue AscribeExpr(expr, type_), rest3
      }
      _ => break (expr, rest)
    }
  }
  match rest1 {
    [SemiTok, .. rest2] => {
      let (rhs, rest3) = parse_expr(rest2)
      (SeqExpr(expr1, rhs), rest3)
    }
    _ => (expr1, rest1)
  }
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
    (UnitValue, UnitValue) => true
    (IntValue(a), IntValue(b)) => a == b
    (BoolValue(a), BoolValue(b)) => a == b
    (StringValue(a), StringValue(b)) => a == b
    (VariantValue(name1, xs), VariantValue(name2, ys)) => {
      if name1 != name2 || xs.length() != ys.length() {
        return false
      }
      for i = 0; i < xs.length(); i = i + 1 {
        if !value_eq(xs[i], ys[i]) {
          return false
        }
      }
      true
    }
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
    (ClosureValue(_), _) | (_, ClosureValue(_)) =>
      raise RuntimeError("cannot compare function values")
    _ => false
  }
}

///|
fn resolve_decl_type(
  type_ : DeclType,
  enum_name : String,
  enum_id : Int,
  type_params : Map[String, Type],
  ctx : InferCtx,
) -> Type {
  match type_ {
    UnitDeclType => UnitType
    IntDeclType => IntType
    BoolDeclType => BoolType
    StringDeclType => StringType
    TypeVarDeclType(name) =>
      match type_params.get(name) {
        Some(type_) => type_
        None => NamedType(name, -1, [])
      }
    NamedDeclType(name, args) => {
      let resolved_args = args.map(t => {
        resolve_decl_type(t, enum_name, enum_id, type_params, ctx)
      })
      if name == enum_name {
        NamedType(name, enum_id, resolved_args)
      } else {
        match ctx.type_name_to_enum.get(name) {
          Some(found_id) => NamedType(name, found_id, resolved_args)
          None => NamedType(name, -1, resolved_args)
        }
      }
    }
    TupleDeclType(types) =>
      TupleType(
        types.map(t => {
          resolve_decl_type(t, enum_name, enum_id, type_params, ctx)
        }),
      )
    ListDeclType(elem) =>
      ListType(resolve_decl_type(elem, enum_name, enum_id, type_params, ctx))
    OptionDeclType(elem) =>
      OptionType(resolve_decl_type(elem, enum_name, enum_id, type_params, ctx))
    FunDeclType(arg, ret) =>
      FunType(
        resolve_decl_type(arg, enum_name, enum_id, type_params, ctx),
        resolve_decl_type(ret, enum_name, enum_id, type_params, ctx),
      )
  }
}

///|
fn resolve_annotation_type(
  type_ : DeclType,
  ctx : InferCtx,
) -> Type raise MiniMLError {
  match type_ {
    UnitDeclType => UnitType
    IntDeclType => IntType
    BoolDeclType => BoolType
    StringDeclType => StringType
    TypeVarDeclType(name) =>
      raise TypeError("type annotation cannot use free type variable `\{name}`")
    NamedDeclType(name, args) =>
      match ctx.type_name_to_enum.get(name) {
        Some(enum_id) =>
          NamedType(
            name,
            enum_id,
            args.map(arg => resolve_annotation_type(arg, ctx)),
          )
        None => raise TypeError("unknown type `\{name}`")
      }
    TupleDeclType(types) =>
      TupleType(types.map(type_ => resolve_annotation_type(type_, ctx)))
    ListDeclType(elem) => ListType(resolve_annotation_type(elem, ctx))
    OptionDeclType(elem) => OptionType(resolve_annotation_type(elem, ctx))
    FunDeclType(arg, ret) =>
      FunType(
        resolve_annotation_type(arg, ctx),
        resolve_annotation_type(ret, ctx),
      )
  }
}

///|
fn enum_ctor_type(
  enum_name : String,
  enum_id : Int,
  variant : EnumVariantDecl,
  result_args : Array[Type],
  type_params : Map[String, Type],
  ctx : InferCtx,
) -> Type {
  let result_ty = NamedType(enum_name, enum_id, result_args)
  variant.fields.rev_fold(init=result_ty, (acc, field) => {
    let field_ty = resolve_decl_type(
      field, enum_name, enum_id, type_params, ctx,
    )
    FunType(field_ty, acc)
  })
}

///|
fn fresh_enum_id(ctx : InferCtx) -> Int {
  let id = ctx.next_enum_id
  ctx.next_enum_id += 1
  id
}

///|
fn list_from_values(values : Array[Value]) -> Value {
  values.rev_fold(init=NilValue, (acc, value) => ConsValue(value, acc))
}

///|
fn match_pattern(pattern : Pattern, value : Value, env : Env) -> Env? {
  match pattern {
    WildcardPat => Some(env)
    UnitPat =>
      match value {
        UnitValue => Some(env)
        _ => None
      }
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
    CtorPat(name, patterns) =>
      match value {
        VariantValue(actual, values) => {
          if name != actual || patterns.length() != values.length() {
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
fn eval_enum_body(
  decl : EnumDecl,
  env : Env,
  body : Expr,
) -> Value raise MiniMLError {
  for variant in decl.variants; enum_env = env {
    let value = if variant.fields.is_empty() {
      VariantValue(variant.name, [])
    } else {
      CtorFuncValue(variant.name, variant.fields.length(), [])
    }
    continue enum_env.extend(variant.name, value)
  } nobreak {
    eval_expr(body, enum_env)
  }
}

///|
fn eval_rec_group(
  bindings : ArrayView[RecBinding],
  env : Env,
  body : Expr,
) -> Value raise MiniMLError {
  let mut rec_env = env
  let cells = []
  for binding in bindings {
    let cell : Ref[Value?] = @ref.new(None)
    rec_env = rec_env.extend_cell(binding.name, cell)
    cells.push(cell)
  }
  for i = 0; i < bindings.length(); i = i + 1 {
    let binding = bindings[i]
    let closure = ClosureValue(binding.param, binding.fun_body, rec_env)
    cells[i].val = Some(closure)
  }
  eval_expr(body, rec_env)
}

///|
fn eval_let_group(
  bindings : ArrayView[LetBinding],
  env : Env,
  body : Expr,
) -> Value raise MiniMLError {
  let values = []
  for binding in bindings {
    values.push(eval_expr(binding.bound, env))
  }
  let mut body_env = env
  for i = 0; i < bindings.length(); i = i + 1 {
    match match_pattern(bindings[i].pattern, values[i], body_env) {
      Some(next_env) => body_env = next_env
      None => raise RuntimeError("let pattern match failed")
    }
  }
  eval_expr(body, body_env)
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
    _ => raise RuntimeError("type mismatch in binary operation `\{op}`")
  }
}

///|
fn eval_expr(expr : Expr, env : Env) -> Value raise MiniMLError {
  match expr {
    UnitExpr => UnitValue
    IntExpr(n) => IntValue(n)
    BoolExpr(b) => BoolValue(b)
    StringExpr(text) => StringValue(text)
    VarExpr(name) => env.lookup(name)
    IfExpr(cond, then_, else_) =>
      match eval_expr(cond, env) {
        BoolValue(true) => eval_expr(then_, env)
        BoolValue(false) => eval_expr(else_, env)
        _ => raise RuntimeError("if condition must be a bool")
      }
    EnumExpr(decl, body) => eval_enum_body(decl, env, body)
    LetExpr(pattern, _, bound, body) => {
      let value = eval_expr(bound, env)
      match match_pattern(pattern, value, env) {
        Some(next_env) => eval_expr(body, next_env)
        None => raise RuntimeError("let pattern match failed")
      }
    }
    LetGroupExpr(bindings, body) => eval_let_group(bindings, env, body)
    LetRecExpr(name, param, _, _, fun_body, body) => {
      let cell : Ref[Value?] = @ref.new(None)
      let rec_env = env.extend_cell(name, cell)
      let closure = ClosureValue(param, fun_body, rec_env)
      cell.val = Some(closure)
      eval_expr(body, rec_env)
    }
    LetRecGroupExpr(bindings, body) => eval_rec_group(bindings, env, body)
    FunExpr(param, _, body) => ClosureValue(param, body, env)
    AscribeExpr(expr, _) => eval_expr(expr, env)
    SeqExpr(lhs, rhs) => {
      let _ = eval_expr(lhs, env)
      eval_expr(rhs, env)
    }
    ApplyExpr(func, arg) => {
      let func_value = eval_expr(func, env)
      let arg_value = eval_expr(arg, env)
      match func_value {
        ClosureValue(param, body, closure_env) => {
          let call_env = closure_env.extend(param, arg_value)
          eval_expr(body, call_env)
        }
        CtorFuncValue(name, arity, values) => {
          let next_values = [..values, arg_value]
          if next_values.length() == arity {
            VariantValue(name, next_values)
          } else {
            CtorFuncValue(name, arity, next_values)
          }
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
        IntValue(n) => IntValue(-n)
        _ => raise RuntimeError("unary - expects an int")
      }
    NotExpr(inner) =>
      match eval_expr(inner, env) {
        BoolValue(b) => BoolValue(!b)
        _ => raise RuntimeError("unary ! expects a bool")
      }
    TupleExpr(exprs) => {
      let values = exprs.map(expr => eval_expr(expr, env))
      TupleValue(values)
    }
    ListExpr(exprs) => {
      let values = exprs.map(expr => eval_expr(expr, env))
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
      printer.next_id += 1
      printer.names.set(id, name)
      name
    }
  }
}

///|
fn type_to_string_with(type_ : Type, printer : TypePrinter) -> String {
  match type_ {
    UnitType => "unit"
    IntType => "int"
    BoolType => "bool"
    StringType => "string"
    VarType(id) => type_var_name(printer, id)
    FunType(arg, ret) => {
      let arg_s = match arg {
        FunType(_, _) => "(\{type_to_string_with(arg, printer)})"
        _ => type_to_string_with(arg, printer)
      }
      "\{arg_s} -> \{type_to_string_with(ret, printer)}"
    }
    OptionType(elem) => {
      let elem_s = match elem {
        FunType(_, _) | TupleType(_) | OptionType(_) =>
          "(\{type_to_string_with(elem, printer)})"
        _ => type_to_string_with(elem, printer)
      }
      "\{elem_s} option"
    }
    NamedType(name, _, args) =>
      if args.is_empty() {
        name
      } else {
        let items = args.map(t => type_to_string_with(t, printer)).join(", ")
        "\{name}[\{items}]"
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
  ctx.next_id += 1
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
    OptionType(elem) => OptionType(prune_type(elem, ctx))
    NamedType(name, id, args) =>
      NamedType(name, id, args.map(t => prune_type(t, ctx)))
    TupleType(types) => TupleType(types.map(fn(t) { prune_type(t, ctx) }))
    ListType(elem) => ListType(prune_type(elem, ctx))
    _ => type_
  }
}

///|
fn occurs_in(var_id : Int, type_ : Type, ctx : InferCtx) -> Bool {
  match prune_type(type_, ctx) {
    VarType(id) => id == var_id
    UnitType => false
    StringType => false
    FunType(arg, ret) =>
      occurs_in(var_id, arg, ctx) || occurs_in(var_id, ret, ctx)
    OptionType(elem) => occurs_in(var_id, elem, ctx)
    NamedType(_, _, args) => args.any(t => occurs_in(var_id, t, ctx))
    TupleType(types) => types.any(t => occurs_in(var_id, t, ctx))
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
fn named_type_conflict_message(lhs : Type, rhs : Type) -> String {
  match (lhs, rhs) {
    (NamedType(lhs_name, lhs_id, _), NamedType(rhs_name, rhs_id, _)) if lhs_name ==
      rhs_name &&
      lhs_id != rhs_id =>
      "cannot unify distinct enum types `\{type_to_string(lhs)}` and `\{type_to_string(rhs)}` (same name, different scopes)"
    _ => "cannot unify `\{type_to_string(lhs)}` with `\{type_to_string(rhs)}`"
  }
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
    (UnitType, UnitType) => ()
    (IntType, IntType) => ()
    (BoolType, BoolType) => ()
    (StringType, StringType) => ()
    (FunType(arg1, ret1), FunType(arg2, ret2)) => {
      unify(arg1, arg2, ctx)
      unify(ret1, ret2, ctx)
    }
    (OptionType(a), OptionType(b)) => unify(a, b, ctx)
    (NamedType(a, ida, xs), NamedType(b, idb, ys)) if a == b && ida == idb => {
      if xs.length() != ys.length() {
        raise TypeError("type argument lengths do not match")
      }
      for i = 0; i < xs.length(); i = i + 1 {
        unify(xs[i], ys[i], ctx)
      }
    }
    (NamedType(_, _, _), NamedType(_, _, _)) =>
      raise TypeError(named_type_conflict_message(lhs, rhs))
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
  if !vars.contains(value) {
    vars.push(value)
  }
}

///|
fn append_unique(dst : Array[Int], src : Array[Int]) -> Unit {
  for value in src {
    add_unique(dst, value)
  }
}

///|
fn diff_vars(lhs : Array[Int], rhs : Array[Int]) -> Array[Int] {
  let rhs_set = Set::from_array(rhs)
  lhs.filter(x => !rhs_set.contains(x))
}

///|
fn ftv_type(type_ : Type, ctx : InferCtx) -> Array[Int] {
  match prune_type(type_, ctx) {
    UnitType | IntType | BoolType | StringType => []
    VarType(id) => [id]
    FunType(arg, ret) => {
      let vars = ftv_type(arg, ctx)
      append_unique(vars, ftv_type(ret, ctx))
      vars
    }
    OptionType(elem) => ftv_type(elem, ctx)
    NamedType(_, _, args) => {
      let vars = []
      for t in args {
        append_unique(vars, ftv_type(t, ctx))
      }
      vars
    }
    TupleType(types) => {
      let vars = []
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
  let vars = []
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
    UnitType => UnitType
    IntType => IntType
    BoolType => BoolType
    StringType => StringType
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
    OptionType(elem) => OptionType(instantiate_type(elem, mapping, ctx))
    NamedType(name, id, args) =>
      NamedType(name, id, args.map(t => instantiate_type(t, mapping, ctx)))
    TupleType(types) =>
      TupleType(types.map(fn(t) { instantiate_type(t, mapping, ctx) }))
    ListType(elem) => ListType(instantiate_type(elem, mapping, ctx))
  }
}

///|
fn instantiate(scheme : Scheme, ctx : InferCtx) -> Type {
  let mapping = {}
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
fn lookup_enum_variant(
  enum_id : Int,
  ctor_name : String,
  ctx : InferCtx,
) -> EnumVariantDecl? {
  match ctx.enum_defs.get(enum_id) {
    Some(decl) => {
      for variant in decl.variants {
        if variant.name == ctor_name {
          return Some(variant)
        }
      }
      None
    }
    None => None
  }
}

///|
fn make_enum_type_args(decl : EnumDecl, ctx : InferCtx) -> Array[Type] {
  let args = []
  for _ in decl.type_params {
    args.push(fresh_type_var(ctx))
  }
  args
}

///|
fn enum_type_param_map(
  decl : EnumDecl,
  args : ArrayView[Type],
) -> Map[String, Type] {
  let map = {}
  for i = 0; i < decl.type_params.length() && i < args.length(); i = i + 1 {
    map.set(decl.type_params[i], args[i])
  }
  map
}

///|
fn scheme_vars_from_types(types : ArrayView[Type]) -> Array[Int] {
  types.filter_map(type_ => {
    match type_ {
      VarType(id) => Some(id)
      _ => None
    }
  })
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
    UnitPat => {
      unify(expected, UnitType, ctx)
      env
    }
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
    CtorPat(name, patterns) =>
      match ctx.ctor_to_enum.get(name) {
        Some(enum_id) => {
          let decl = match ctx.enum_defs.get(enum_id) {
            Some(decl) => decl
            None => raise TypeError("unknown constructor `\{name}`")
          }
          let enum_args = make_enum_type_args(decl, ctx)
          unify(expected, NamedType(decl.name, enum_id, enum_args), ctx)
          match lookup_enum_variant(enum_id, name, ctx) {
            Some(variant) => {
              if variant.fields.length() != patterns.length() {
                raise TypeError(
                  "constructor `\{name}` expects \{variant.fields.length()} pattern arguments",
                )
              }
              let type_params = enum_type_param_map(decl, enum_args)
              let mut current_env = env
              for i = 0; i < patterns.length(); i = i + 1 {
                let payload_type = resolve_decl_type(
                  variant.fields[i],
                  decl.name,
                  enum_id,
                  type_params,
                  ctx,
                )
                current_env = infer_pattern(
                  patterns[i],
                  payload_type,
                  current_env,
                  ctx,
                )
              }
              current_env
            }
            None => raise TypeError("unknown constructor `\{name}`")
          }
        }
        None =>
          match (name, patterns) {
            ("None", []) => {
              let elem_type = fresh_type_var(ctx)
              unify(expected, OptionType(elem_type), ctx)
              env
            }
            ("Some", [inner]) => {
              let elem_type = fresh_type_var(ctx)
              unify(expected, OptionType(elem_type), ctx)
              infer_pattern(inner, elem_type, env, ctx)
            }
            ("Some", _) =>
              raise TypeError("constructor `Some` expects exactly one pattern")
            ("None", _) =>
              raise TypeError(
                "constructor `None` does not take pattern arguments",
              )
            _ => raise TypeError("unknown constructor `\{name}`")
          }
      }
    TuplePat(patterns) => {
      let element_types = []
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
    WildcardPat | UnitPat | IntPat(_) | BoolPat(_) | NilPat => env
    VarPat(name) => env.extend(name, generalize(base_env, expected, ctx))
    CtorPat(name, patterns) =>
      match ctx.ctor_to_enum.get(name) {
        Some(enum_id) =>
          match ctx.enum_defs.get(enum_id) {
            Some(decl) => {
              let enum_args = match prune_type(expected, ctx) {
                NamedType(_, _, args) => args
                _ => []
              }
              let type_params = enum_type_param_map(decl, enum_args)
              match lookup_enum_variant(enum_id, name, ctx) {
                Some(variant) => {
                  let mut current_env = env
                  for i = 0
                      i < patterns.length() && i < variant.fields.length()
                      i = i + 1 {
                    current_env = bind_generalized_pattern(
                      patterns[i],
                      resolve_decl_type(
                        variant.fields[i],
                        decl.name,
                        enum_id,
                        type_params,
                        ctx,
                      ),
                      base_env,
                      current_env,
                      ctx,
                    )
                  }
                  current_env
                }
                None => env
              }
            }
            None => env
          }
        None =>
          match (name, patterns) {
            ("None", []) => env
            ("Some", [inner]) =>
              match prune_type(expected, ctx) {
                OptionType(elem) =>
                  bind_generalized_pattern(inner, elem, base_env, env, ctx)
                _ => env
              }
            _ => env
          }
      }
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
fn row_is_all_wild(row : ArrayView[Pattern]) -> Bool {
  row.all(pattern_is_wild)
}

///|
fn wildcard_patterns(count : Int) -> Array[Pattern] {
  [WildcardPat].repeat(count)
}

///|
fn match_matrix_kind(ty : Type, ctx : InferCtx) -> MatchMatrixKind {
  match prune_type(ty, ctx) {
    UnitType => UnitKind
    BoolType => BoolKind
    OptionType(_) => OptionKind
    NamedType(_, id, _) =>
      if ctx.enum_defs.get(id) is Some(_) {
        EnumKind(id)
      } else {
        UniversalKind
      }
    TupleType(types) => TupleKind(types.length())
    ListType(_) => ListKind
    _ => UniversalKind
  }
}

///|
fn default_rows(rows : Array[Array[Pattern]]) -> Array[Array[Pattern]] {
  rows.filter_map(row => {
    if row is [head, .. tail] && pattern_is_wild(head) {
      Some(tail.to_owned())
    } else {
      None
    }
  })
}

///|
fn specialize_bool_rows(
  rows : Array[Array[Pattern]],
  target : Bool,
) -> Array[Array[Pattern]] {
  rows.filter_map(row => {
    guard row is [head, .. tail] else { None }
    if pattern_is_wild(head) {
      Some(tail.to_owned())
    } else {
      match head {
        BoolPat(value) if value == target => Some(tail.to_owned())
        _ => None
      }
    }
  })
}

///|
fn specialize_unit_rows(rows : Array[Array[Pattern]]) -> Array[Array[Pattern]] {
  rows.filter_map(row => {
    guard row is [head, .. tail] else { None }
    if pattern_is_wild(head) {
      Some(tail.to_owned())
    } else {
      match head {
        UnitPat => Some(tail.to_owned())
        _ => None
      }
    }
  })
}

///|
fn specialize_none_rows(rows : Array[Array[Pattern]]) -> Array[Array[Pattern]] {
  rows.filter_map(row => {
    guard row is [head, .. tail] else { None }
    if pattern_is_wild(head) {
      Some(tail.to_owned())
    } else {
      match head {
        CtorPat("None", []) => Some(tail.to_owned())
        _ => None
      }
    }
  })
}

///|
fn specialize_some_rows(rows : Array[Array[Pattern]]) -> Array[Array[Pattern]] {
  rows.filter_map(row => {
    guard row is [head, .. tail] else { None }
    if pattern_is_wild(head) {
      Some([WildcardPat, ..tail])
    } else {
      match head {
        CtorPat("Some", [inner]) => Some([inner, ..tail])
        _ => None
      }
    }
  })
}

///|
fn specialize_enum_rows(
  rows : Array[Array[Pattern]],
  ctor_name : String,
  arity : Int,
) -> Array[Array[Pattern]] {
  rows.filter_map(row => {
    guard row is [head, .. tail] else { None }
    if pattern_is_wild(head) {
      Some([..wildcard_patterns(arity), ..tail])
    } else {
      match head {
        CtorPat(name, patterns) if name == ctor_name =>
          if patterns.length() == arity {
            Some([..patterns, ..tail])
          } else if arity == 0 && patterns.is_empty() {
            Some(tail.to_owned())
          } else {
            None
          }
        _ => None
      }
    }
  })
}

///|
fn specialize_int_rows(
  rows : Array[Array[Pattern]],
  target : Int,
) -> Array[Array[Pattern]] {
  rows.filter_map(row => {
    guard row is [head, .. tail] else { None }
    if pattern_is_wild(head) {
      Some(tail.to_owned())
    } else {
      match head {
        IntPat(value) if value == target => Some(tail.to_owned())
        _ => None
      }
    }
  })
}

///|
fn specialize_tuple_rows(
  rows : Array[Array[Pattern]],
  arity : Int,
) -> Array[Array[Pattern]] {
  rows.filter_map(row => {
    guard row is [head, .. tail] else { None }
    if pattern_is_wild(head) {
      Some([..wildcard_patterns(arity), ..tail])
    } else {
      match head {
        TuplePat(parts) if parts.length() == arity => Some([..parts, ..tail])
        _ => None
      }
    }
  })
}

///|
fn specialize_nil_rows(rows : Array[Array[Pattern]]) -> Array[Array[Pattern]] {
  rows.filter_map(row => {
    guard row is [head, .. tail] else { None }
    if pattern_is_wild(head) {
      Some(tail.to_owned())
    } else {
      match head {
        NilPat => Some(tail.to_owned())
        _ => None
      }
    }
  })
}

///|
fn specialize_cons_rows(rows : Array[Array[Pattern]]) -> Array[Array[Pattern]] {
  rows.filter_map(row => {
    guard row is [head, .. tail] else { None }
    if pattern_is_wild(head) {
      Some([WildcardPat, WildcardPat, ..tail])
    } else {
      match head {
        ConsPat(head_pat, tail_pat) => Some([head_pat, tail_pat, ..tail])
        _ => None
      }
    }
  })
}

///|
fn patterns_cover_vector(
  rows : Array[Array[Pattern]],
  types : ArrayView[Type],
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
  let tail_tys = types[1:]
  match match_matrix_kind(head_ty, ctx) {
    UniversalKind => {
      let defaults = default_rows(rows)
      defaults.length() > 0 && patterns_cover_vector(defaults, tail_tys, ctx)
    }
    UnitKind => patterns_cover_vector(specialize_unit_rows(rows), tail_tys, ctx)
    BoolKind =>
      patterns_cover_vector(specialize_bool_rows(rows, true), tail_tys, ctx) &&
      patterns_cover_vector(specialize_bool_rows(rows, false), tail_tys, ctx)
    OptionKind =>
      match head_ty {
        OptionType(elem_ty) => {
          let none_ok = patterns_cover_vector(
            specialize_none_rows(rows),
            tail_tys,
            ctx,
          )
          let some_ok = patterns_cover_vector(
            specialize_some_rows(rows),
            [elem_ty, ..tail_tys],
            ctx,
          )
          none_ok && some_ok
        }
        _ => false
      }
    EnumKind(enum_id) =>
      match ctx.enum_defs.get(enum_id) {
        Some(decl) => {
          for variant in decl.variants {
            let rows2 = specialize_enum_rows(
              rows,
              variant.name,
              variant.fields.length(),
            )
            let type_params = enum_type_param_map(
              decl,
              match head_ty {
                NamedType(_, _, args) => args
                _ => []
              },
            )
            let field_tys = []
            for field in variant.fields {
              field_tys.push(
                resolve_decl_type(field, decl.name, enum_id, type_params, ctx),
              )
            }
            let tys2 = [..field_tys, ..tail_tys]
            if !patterns_cover_vector(rows2, tys2, ctx) {
              return false
            }
          }
          true
        }
        None => false
      }
    TupleKind(arity) =>
      match head_ty {
        TupleType(elem_tys) => {
          let next_rows = specialize_tuple_rows(rows, arity)
          let next_tys = [..elem_tys, ..tail_tys]
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
          let cons_tys = [elem_ty, head_ty, ..tail_tys]
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
fn useful_vector(
  rows : Array[Array[Pattern]],
  vector : ArrayView[Pattern],
  types : ArrayView[Type],
  ctx : InferCtx,
) -> Bool {
  if vector.length() == 0 {
    return rows.length() == 0
  }
  for row in rows {
    if row_is_all_wild(row) {
      return false
    }
  }
  guard vector is [head_pat, .. tail_vec]
  guard types is [head_ty, .. tail_tys]
  let head_ty = prune_type(head_ty, ctx)
  match head_pat {
    WildcardPat | VarPat(_) =>
      match match_matrix_kind(head_ty, ctx) {
        UniversalKind =>
          useful_vector(default_rows(rows), tail_vec, tail_tys, ctx)
        UnitKind =>
          useful_vector(specialize_unit_rows(rows), tail_vec, tail_tys, ctx)
        BoolKind =>
          useful_vector(
            specialize_bool_rows(rows, true),
            [BoolPat(true), ..tail_vec],
            types,
            ctx,
          ) ||
          useful_vector(
            specialize_bool_rows(rows, false),
            [BoolPat(false), ..tail_vec],
            types,
            ctx,
          )
        OptionKind =>
          match head_ty {
            OptionType(elem_ty) =>
              useful_vector(specialize_none_rows(rows), tail_vec, tail_tys, ctx) ||
              useful_vector(
                specialize_some_rows(rows),
                [WildcardPat, ..tail_vec],
                [elem_ty, ..tail_tys],
                ctx,
              )
            _ => false
          }
        EnumKind(enum_id) =>
          match ctx.enum_defs.get(enum_id) {
            Some(decl) => {
              for variant in decl.variants {
                let next_rows = specialize_enum_rows(
                  rows,
                  variant.name,
                  variant.fields.length(),
                )
                let next_vec = [
                  ..wildcard_patterns(variant.fields.length()),
                  ..tail_vec,
                ]
                let type_params = enum_type_param_map(
                  decl,
                  match head_ty {
                    NamedType(_, _, args) => args
                    _ => []
                  },
                )
                let field_tys = []
                for field in variant.fields {
                  field_tys.push(
                    resolve_decl_type(
                      field,
                      decl.name,
                      enum_id,
                      type_params,
                      ctx,
                    ),
                  )
                }
                let next_tys = [..field_tys, ..tail_tys]
                if useful_vector(next_rows, next_vec, next_tys, ctx) {
                  return true
                }
              }
              false
            }
            None => false
          }
        TupleKind(arity) =>
          match head_ty {
            TupleType(elem_tys) =>
              useful_vector(
                specialize_tuple_rows(rows, arity),
                [..wildcard_patterns(arity), ..tail_vec],
                [..elem_tys, ..tail_tys],
                ctx,
              )
            _ => false
          }
        ListKind =>
          match head_ty {
            ListType(elem_ty) =>
              useful_vector(specialize_nil_rows(rows), tail_vec, tail_tys, ctx) ||
              useful_vector(
                specialize_cons_rows(rows),
                [WildcardPat, WildcardPat, ..tail_vec],
                [elem_ty, head_ty, ..tail_tys],
                ctx,
              )
            _ => false
          }
      }
    UnitPat =>
      useful_vector(specialize_unit_rows(rows), tail_vec, tail_tys, ctx)
    IntPat(n) =>
      useful_vector(specialize_int_rows(rows, n), tail_vec, tail_tys, ctx)
    BoolPat(b) =>
      useful_vector(specialize_bool_rows(rows, b), tail_vec, tail_tys, ctx)
    CtorPat(name, patterns) =>
      match ctx.ctor_to_enum.get(name) {
        Some(enum_id) =>
          match ctx.enum_defs.get(enum_id) {
            Some(decl) => {
              let type_params = enum_type_param_map(
                decl,
                match head_ty {
                  NamedType(_, _, args) => args
                  _ => []
                },
              )
              match lookup_enum_variant(enum_id, name, ctx) {
                Some(variant) =>
                  if variant.fields.length() != patterns.length() {
                    false
                  } else {
                    let field_tys = []
                    for field in variant.fields {
                      field_tys.push(
                        resolve_decl_type(
                          field,
                          decl.name,
                          enum_id,
                          type_params,
                          ctx,
                        ),
                      )
                    }
                    useful_vector(
                      specialize_enum_rows(rows, name, variant.fields.length()),
                      [..patterns, ..tail_vec],
                      [..field_tys, ..tail_tys],
                      ctx,
                    )
                  }
                None => false
              }
            }
            None => false
          }
        None =>
          match (name, patterns) {
            ("None", []) =>
              useful_vector(specialize_none_rows(rows), tail_vec, tail_tys, ctx)
            ("Some", [inner]) =>
              match head_ty {
                OptionType(elem_ty) =>
                  useful_vector(
                    specialize_some_rows(rows),
                    [inner, ..tail_vec],
                    [elem_ty, ..tail_tys],
                    ctx,
                  )
                _ => false
              }
            _ => false
          }
      }
    TuplePat(parts) =>
      match head_ty {
        TupleType(elem_tys) =>
          useful_vector(
            specialize_tuple_rows(rows, parts.length()),
            [..parts, ..tail_vec],
            [..elem_tys, ..tail_tys],
            ctx,
          )
        _ => false
      }
    NilPat => useful_vector(specialize_nil_rows(rows), tail_vec, tail_tys, ctx)
    ConsPat(head, tail) =>
      match head_ty {
        ListType(elem_ty) =>
          useful_vector(
            specialize_cons_rows(rows),
            [head, tail, ..tail_vec],
            [elem_ty, head_ty, ..tail_tys],
            ctx,
          )
        _ => false
      }
  }
}

///|
fn find_missing_vector(
  rows : Array[Array[Pattern]],
  types : ArrayView[Type],
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
  guard types is [head_ty, .. tail_tys]
  let head_ty = prune_type(head_ty, ctx)
  match match_matrix_kind(head_ty, ctx) {
    UniversalKind => {
      let missing = find_missing_vector(default_rows(rows), tail_tys, ctx)
      match missing {
        Some(rest) => Some([WildcardPat, ..rest])
        None => None
      }
    }
    UnitKind => {
      let missing = find_missing_vector(
        specialize_unit_rows(rows),
        tail_tys,
        ctx,
      )
      match missing {
        Some(rest) => Some([UnitPat, ..rest])
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
        Some(rest) => Some([BoolPat(true), ..rest])
        None => {
          let missing_false = find_missing_vector(
            specialize_bool_rows(rows, false),
            tail_tys,
            ctx,
          )
          match missing_false {
            Some(rest) => Some([BoolPat(false), ..rest])
            None => None
          }
        }
      }
    }
    OptionKind =>
      match head_ty {
        OptionType(elem_ty) => {
          let missing_none = find_missing_vector(
            specialize_none_rows(rows),
            tail_tys,
            ctx,
          )
          match missing_none {
            Some(rest) => Some([CtorPat("None", []), ..rest])
            None => {
              let missing_some = find_missing_vector(
                specialize_some_rows(rows),
                [elem_ty, ..tail_tys],
                ctx,
              )
              match missing_some {
                Some(vec) => {
                  guard vec is [head, .. rest]
                  Some([CtorPat("Some", [head]), ..rest])
                }
                None => None
              }
            }
          }
        }
        _ => None
      }
    EnumKind(enum_id) =>
      match ctx.enum_defs.get(enum_id) {
        Some(decl) => {
          let type_params = enum_type_param_map(
            decl,
            match head_ty {
              NamedType(_, _, args) => args
              _ => []
            },
          )
          for variant in decl.variants {
            let rows2 = specialize_enum_rows(
              rows,
              variant.name,
              variant.fields.length(),
            )
            let field_tys = variant.fields.map(field => {
              resolve_decl_type(field, decl.name, enum_id, type_params, ctx)
            })
            let tys2 = [..field_tys, ..tail_tys]
            match find_missing_vector(rows2, tys2, ctx) {
              Some(vec) => {
                let rest = vec[variant.fields.length():vec.length()]
                let ctor_args = vec[0:variant.fields.length()]
                return Some(
                  [CtorPat(variant.name, ctor_args.to_owned()), ..rest],
                )
              }
              None => ()
            }
          }
          None
        }
        None => None
      }
    TupleKind(arity) =>
      match head_ty {
        TupleType(elem_tys) => {
          let missing = find_missing_vector(
            specialize_tuple_rows(rows, arity),
            [..elem_tys, ..tail_tys],
            ctx,
          )
          match missing {
            Some(vec) => {
              let tuple_parts = vec[0:arity]
              let rest = vec[arity:vec.length()]
              Some([TuplePat(tuple_parts.to_owned()), ..rest])
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
            Some(rest) => Some([NilPat, ..rest])
            None => {
              let missing_cons = find_missing_vector(
                specialize_cons_rows(rows),
                [elem_ty, head_ty, ..tail_tys],
                ctx,
              )
              match missing_cons {
                Some(vec) => {
                  guard vec is [vec0, vec1, .. rest]
                  Some([ConsPat(vec0, vec1), ..rest])
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
  arms : ArrayView[MatchArm],
  scrutinee_ty : Type,
  ctx : InferCtx,
) -> Unit raise MiniMLError {
  let rows = []
  for arm in arms {
    if arm.guard_ is None {
      rows.push([arm.pattern])
    }
  }
  let tys = [prune_type(scrutinee_ty, ctx)]
  if !patterns_cover_vector(rows, tys, ctx) {
    let missing_vec = find_missing_vector(rows, tys, ctx)
    let missing = match missing_vec {
      Some(patterns) if patterns.length() > 0 =>
        pattern_hint_string(patterns[0])
      _ => "_"
    }
    raise TypeError("non-exhaustive match, missing pattern `\{missing}`")
  }
}

///|
fn infer_enum_body(
  decl : EnumDecl,
  body : Expr,
  env : TypeEnv,
  ctx : InferCtx,
) -> Type raise MiniMLError {
  let enum_id = fresh_enum_id(ctx)
  let type_args = []
  for _ in decl.type_params {
    type_args.push(fresh_type_var(ctx))
  }
  let type_param_map = enum_type_param_map(decl, type_args)
  let old_type_binding = ctx.type_name_to_enum.get(decl.name)
  ctx.enum_defs.set(enum_id, decl)
  ctx.type_name_to_enum.set(decl.name, enum_id)
  let old_ctor_enums = []
  let mut body_env = env
  for variant in decl.variants {
    old_ctor_enums.push((variant.name, ctx.ctor_to_enum.get(variant.name)))
    ctx.ctor_to_enum.set(variant.name, enum_id)
    body_env = body_env.extend(variant.name, Scheme::{
      vars: scheme_vars_from_types(type_args),
      ty: enum_ctor_type(
        decl.name,
        enum_id,
        variant,
        type_args,
        type_param_map,
        ctx,
      ),
    })
  }
  let result = infer_expr(body, body_env, ctx)
  let _ = ctx.enum_defs.remove(enum_id)
  match old_type_binding {
    Some(prev_id) => ctx.type_name_to_enum.set(decl.name, prev_id)
    None => {
      let _ = ctx.type_name_to_enum.remove(decl.name)
    }
  }
  for entry in old_ctor_enums {
    match entry {
      (ctor_name, prev_enum) =>
        match prev_enum {
          Some(enum_name) => ctx.ctor_to_enum.set(ctor_name, enum_name)
          None => {
            let _ = ctx.ctor_to_enum.remove(ctor_name)
          }
        }
    }
  }
  result
}

///|
fn rec_binding_func_type(
  binding : RecBinding,
  ctx : InferCtx,
) -> Type raise MiniMLError {
  let arg_type = match binding.param_annot {
    Some(type_) => resolve_annotation_type(type_, ctx)
    None => fresh_type_var(ctx)
  }
  let ret_type = match binding.return_annot {
    Some(type_) => resolve_annotation_type(type_, ctx)
    None => fresh_type_var(ctx)
  }
  FunType(arg_type, ret_type)
}

///|
fn infer_rec_group_body(
  bindings : Array[RecBinding],
  body : Expr,
  env : TypeEnv,
  ctx : InferCtx,
) -> Type raise MiniMLError {
  let func_types = []
  let mut env1 = env
  for binding in bindings {
    let func_type = rec_binding_func_type(binding, ctx)
    func_types.push(func_type)
    env1 = env1.extend(binding.name, Scheme::{ vars: [], ty: func_type })
  }
  for i = 0; i < bindings.length(); i = i + 1 {
    let binding = bindings[i]
    let func_type = prune_type(func_types[i], ctx)
    let (arg_type, ret_type) = match func_type {
      FunType(arg_type, ret_type) => (arg_type, ret_type)
      _ =>
        raise TypeError("internal error: recursive binding is not a function")
    }
    let env2 = env1.extend(binding.param, Scheme::{ vars: [], ty: arg_type })
    let body_type = infer_expr(binding.fun_body, env2, ctx)
    unify(ret_type, body_type, ctx)
  }
  let mut env3 = env
  for i = 0; i < bindings.length(); i = i + 1 {
    let final_type = prune_type(func_types[i], ctx)
    let scheme = generalize(env, final_type, ctx)
    env3 = env3.extend(bindings[i].name, scheme)
  }
  infer_expr(body, env3, ctx)
}

///|
fn infer_let_group_body(
  bindings : Array[LetBinding],
  body : Expr,
  env : TypeEnv,
  ctx : InferCtx,
) -> Type raise MiniMLError {
  let bound_types = []
  for binding in bindings {
    let bound_type = infer_expr(binding.bound, env, ctx)
    match binding.annot {
      Some(type_) => {
        let expected = resolve_annotation_type(type_, ctx)
        unify(bound_type, expected, ctx)
      }
      None => ()
    }
    bound_types.push(prune_type(bound_type, ctx))
  }
  for i = 0; i < bindings.length(); i = i + 1 {
    let _ = infer_pattern(bindings[i].pattern, bound_types[i], env, ctx)
  }
  let mut body_env = env
  for i = 0; i < bindings.length(); i = i + 1 {
    body_env = bind_generalized_pattern(
      bindings[i].pattern,
      bound_types[i],
      env,
      body_env,
      ctx,
    )
  }
  infer_expr(body, body_env, ctx)
}

///|
fn infer_expr(
  expr : Expr,
  env : TypeEnv,
  ctx : InferCtx,
) -> Type raise MiniMLError {
  match expr {
    UnitExpr => UnitType
    IntExpr(_) => IntType
    BoolExpr(_) => BoolType
    StringExpr(_) => StringType
    VarExpr(name) => instantiate(env.lookup(name), ctx)
    IfExpr(cond, then_, else_) => {
      let cond_type = infer_expr(cond, env, ctx)
      unify(cond_type, BoolType, ctx)
      let then_type = infer_expr(then_, env, ctx)
      let else_type = infer_expr(else_, env, ctx)
      unify(then_type, else_type, ctx)
      prune_type(then_type, ctx)
    }
    EnumExpr(decl, body) => infer_enum_body(decl, body, env, ctx)
    LetExpr(pattern, annot, bound, body) => {
      let bound_type = infer_expr(bound, env, ctx)
      match annot {
        Some(type_) => {
          let expected = resolve_annotation_type(type_, ctx)
          unify(bound_type, expected, ctx)
        }
        None => ()
      }
      let checked_type = prune_type(bound_type, ctx)
      let _ = infer_pattern(pattern, checked_type, env, ctx)
      let body_env = bind_generalized_pattern(
        pattern, checked_type, env, env, ctx,
      )
      infer_expr(body, body_env, ctx)
    }
    LetGroupExpr(bindings, body) =>
      infer_let_group_body(bindings, body, env, ctx)
    LetRecExpr(name, param, param_annot, return_annot, fun_body, body) => {
      let arg_type = match param_annot {
        Some(type_) => resolve_annotation_type(type_, ctx)
        None => fresh_type_var(ctx)
      }
      let ret_type = match return_annot {
        Some(type_) => resolve_annotation_type(type_, ctx)
        None => fresh_type_var(ctx)
      }
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
    LetRecGroupExpr(bindings, body) =>
      infer_rec_group_body(bindings, body, env, ctx)
    FunExpr(param, annot, body) => {
      let arg_type = match annot {
        Some(type_) => resolve_annotation_type(type_, ctx)
        None => fresh_type_var(ctx)
      }
      let env2 = env.extend(param, Scheme::{ vars: [], ty: arg_type })
      let body_type = infer_expr(body, env2, ctx)
      FunType(prune_type(arg_type, ctx), prune_type(body_type, ctx))
    }
    AscribeExpr(expr, annot) => {
      let expr_type = infer_expr(expr, env, ctx)
      let expected = resolve_annotation_type(annot, ctx)
      unify(expr_type, expected, ctx)
      prune_type(expected, ctx)
    }
    SeqExpr(lhs, rhs) => {
      let lhs_type = infer_expr(lhs, env, ctx)
      unify(lhs_type, UnitType, ctx)
      infer_expr(rhs, env, ctx)
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
      let types = []
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
      let covered_rows = []
      for arm in arms {
        let arm_env = infer_pattern(arm.pattern, scrutinee_type, env, ctx)
        let checked_scrutinee_type = prune_type(scrutinee_type, ctx)
        let is_useful = useful_vector(
          covered_rows,
          [arm.pattern],
          [checked_scrutinee_type],
          ctx,
        )
        if !is_useful {
          let guard_text = match arm.guard_ {
            Some(expr) => " if \{expr_to_string(expr)}"
            None => ""
          }
          raise TypeError(
            "redundant match arm `\{pattern_hint_string(arm.pattern)}\{guard_text}`",
          )
        }
        match arm.guard_ {
          Some(guard_expr) => {
            let guard_type = infer_expr(guard_expr, arm_env, ctx)
            unify(guard_type, BoolType, ctx)
          }
          None => ()
        }
        let body_type = infer_expr(arm.body, arm_env, ctx)
        unify(result_type, body_type, ctx)
        if arm.guard_ is None {
          covered_rows.push([arm.pattern])
        }
      }
      check_match_exhaustiveness(arms, scrutinee_type, ctx)
      prune_type(result_type, ctx)
    }
  }
}

///|
fn infer_ast(expr : Expr) -> Type raise MiniMLError {
  let ctx = InferCtx::new()
  let type_ = infer_expr(expr, base_type_env(), ctx)
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
  eval_expr(expr, base_runtime_env())
}

///|
pub fn interpret(code : String) -> String raise MiniMLError {
  value_to_string(eval(code))
}
