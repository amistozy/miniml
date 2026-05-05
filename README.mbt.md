# MiniML

MiniML is a small ML-flavored language implementation written in MoonBit.
It is designed as a compact interpreter and type inference playground rather
than a production compiler, but it already supports a useful core of
functional-language features:

- recursive-descent parsing
- evaluation with lexical closures
- Hindley-Milner type inference
- algebraic pattern matching
- guarded match arms
- exhaustiveness and redundant-arm checking
- locally scoped nominal enums
- parameterized and multi-argument variants

## Overview

MiniML evaluates a single expression. The language is expression-oriented, so
features such as local bindings, recursion, pattern matching, enum declarations,
and sequencing are all expressed within one expression tree.

The current implementation supports:

- primitive values: `int`, `bool`, `string`, and `unit`
- functions, application, and lexical closures
- `if ... then ... else ...`
- `let` and `let rec`
- tuple and list literals
- block expressions: `{ ... }`
- tuple, list, constructor, wildcard, and unit patterns
- match guards: `| pat if cond -> expr`
- sequencing: `expr1; expr2`
- local enum declarations: `enum T = ... in expr`
- parameterized enums: `enum Option[a] = None | Some(a) in expr`
- optional type annotations on binders and let-bindings
- expression type ascription: `expr : type`
- curried multi-parameter function sugar
- non-recursive parallel bindings with `let ... and ...`
- mutually recursive functions with `let rec ... and ...`

## Examples

Identity and polymorphism:

```ml
let id = fun x -> x in
(id 1, id true)
```

Recursive list processing:

```ml
let rec sum xs =
  match xs with
  | [] -> 0
  | x :: rest -> x + sum rest
in
sum [1, 2, 3, 4]
```

Strings:

```ml
let greet : string = "hello" in
if greet == "hello" then greet else "bye"
```

Unit and sequencing:

```ml
let ping : unit = () in
ping;
"done"
```

Blocks:

```ml
{
  ();
  "done"
}
```

Pattern matching with a guard:

```ml
match [1, 2] with
| x :: _ if x == 0 -> 0
| x :: _ if x == 1 -> 42
| _ -> 7
```

Local enum declarations:

```ml
enum Traffic = Red | Yellow | Green in
match Green with
| Red -> 0
| Yellow -> 1
| Green -> 2
```

Parameterized enums:

```ml
enum Result[a, e] = Ok(a) | Err(e) | Pair(a, e) in
match Pair(1, true) with
| Pair(x, y) -> if y then x else 0
| Ok(x) -> x
| Err(_) -> 0
```

Tuple payload versus multiple fields:

```ml
enum Boxed = Box((int * bool)) in
match Box((1, true)) with
| Box((x, y)) -> x
```

`Box((x, y))` means a single tuple payload.
`Box(x, y)` means a constructor with two separate arguments.

Annotated recursion:

```ml
let rec sum (xs : int list) : int =
  match xs with
  | [] -> 0
  | x :: rest -> x + sum rest
in
sum [1, 2, 3]
```

Expression ascription:

```ml
((fun x -> x) : int -> int) 7
```

Curried multi-parameter functions:

```ml
let rec pow base exp =
  if exp == 0 then 1 else base * pow base (exp - 1)
in
pow 2 5
```

Mutual recursion:

```ml
let rec even n =
  if n == 0 then true else odd (n - 1)
and odd n =
  if n == 0 then false else even (n - 1)
in
even 10
```

Parallel non-recursive bindings:

```ml
let add x y = x + y and one = 1 in
add one 41
```

## CLI

Run the demo program:

```bash
moon run cmd/main
```

Interpret an expression:

```bash
moon run cmd/main -- -e "let id = fun x -> x in (id 1, id true)"
```

Print the inferred type before evaluation:

```bash
moon run cmd/main -- -e "enum Option[a] = None | Some(a) in fun x -> Some x" -t
```

Print tokens or AST:

```bash
moon run cmd/main -- -e "match [1] with | x :: _ -> x | [] -> 0" --tokens
moon run cmd/main -- -e "match [1] with | x :: _ -> x | [] -> 0" --ast
```

Read source from a file:

```bash
moon run cmd/main -- --file path/to/program.mml -t
```

## Library API

The package exposes a small public API:

- `@miniml.tokenize(code)`
- `@miniml.parse(code)`
- `@miniml.infer(code)`
- `@miniml.eval(code)`
- `@miniml.interpret(code)`

These functions are useful if you want to embed MiniML inside tests, scripts, or
other MoonBit tools.

## Development

Useful commands:

```bash
moon test
moon info
moon fmt
```

Recommended local workflow:

1. update code and tests
2. run `moon test`
3. run `moon info`
4. run `moon fmt`

## Current Semantics and Limitations

- Enum types are nominal, not structural.
- Two enums with the same name in different scopes are treated as distinct
  types.
- Guarded match arms do not contribute to exhaustiveness coverage.
- Sequencing requires the left-hand side to have type `unit`.
- MiniML currently evaluates one expression at a time rather than a full module
  system or statement-oriented program.
