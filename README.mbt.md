# amistozy/miniml

`amistozy/miniml` is a small ML-like interpreter written in MoonBit.

It includes:

- recursive-descent parsing
- evaluation with lexical closures
- Hindley-Milner type inference
- pattern matching with guards
- exhaustiveness and redundant-arm checking
- user-defined local enums with nominal typing
- multi-argument variants and parameterized enums

## Language Features

The current language supports:

- integers and booleans
- variables, `if`, `fun`, application
- `let` and `let rec`
- tuples and lists
- pattern matching
- match guards: `| pat if cond -> expr`
- local enum declarations: `enum T = ... in expr`
- parameterized enums: `enum Option[a] = None | Some(a) in ...`
- direct multi-argument variants: `RGB(1, 2, 3)`
- optional type annotations on `let`, `let rec`, and `fun`
- expression-level type ascription: `expr : type`
- multi-parameter `fun`, `let`, and `let rec` via curried syntax sugar

## Examples

Identity and polymorphism:

```ml
let id = fun x -> x in (id 1, id true)
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

Match guards:

```ml
match [1, 2] with
| x :: _ if x == 0 -> 0
| x :: _ if x == 1 -> 42
| _ -> 7
```

Local enums:

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
`Box(x, y)` means a variant with two separate fields.

Type annotations:

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

The package exposes these main entry points:

- `@miniml.tokenize(code)`
- `@miniml.parse(code)`
- `@miniml.infer(code)`
- `@miniml.eval(code)`
- `@miniml.interpret(code)`

## Development

Useful commands:

```bash
moon test
moon info
moon fmt
```

## Notes

- Enum types are nominal, not structural.
- Two enums with the same name in different scopes are treated as distinct types.
- Exhaustiveness checking ignores guarded arms when computing coverage.
