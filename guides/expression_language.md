# Trento Checks Expression Language Reference

A small, fast, easy-to-use scripting language and evaluation engine

- [Introduction](#introduction)
- [Types](#corosync)
- [Keywords](#keywords)
- [Statements](#statements)
- [Variables](#variables)
- [Logic Operators](#logic-operators)
- [If Statement](#logic-operators)
- [Rhai]
## Introduction

[NameToBeDefined] is an embedded scripting language and evaluation engine for Trento Checks Expressions that gives a safe and easy way to script specific steps during Checks Execution.

## Types
TBD

## Keywords
TBD

## Statements
TBD

## Variables
TBD

## Logic Operators

| Operator | Description<br/>(`x` _operator_ `y`) | `x`, `y` same type or are numeric | `x`, `y` different types |
| :------: | ------------------------------------ | :-------------------------------: | :----------------------: |
|   `==`   | `x` is equals to `y`                 |       error if not defined        |  `false` if not defined  |
|   `!=`   | `x` is not equals to `y`             |       error if not defined        |  `true` if not defined   |
|   `>`    | `x` is greater than `y`              |       error if not defined        |  `false` if not defined  |
|   `>=`   | `x` is greater than or equals to `y` |       error if not defined        |  `false` if not defined  |
|   `<`    | `x` is less than `y`                 |       error if not defined        |  `false` if not defined  |
|   `<=`   | `x` is less than or equals to `y`    |       error if not defined        |  `false` if not defined  |

Comparison operators between most values of the same type are built in for all [standard types].

Others are defined in the [`LogicPackage`][built-in packages] but excluded if using a [raw `Engine`].


### Floating-point numbers interoperate with integers

Comparing a floating-point number (`FLOAT`) with an integer is also supported.

```rust
42 == 42.0;         // true
42.0 == 42;         // true
42.0 > 42;          // false
42 >= 42.0;         // true
42.0 < 42;          // false
```

### Strings interoperate with characters

Comparing a [string] with a [character] is also supported, with the character first turned into a
[string] before performing the comparison.

```rust
'x' == "x";         // true
"" < 'a';           // true
'x' > "hello";      // false
```

### Comparing different types defaults to `false`

Comparing two values of _different_ data types defaults to `false`.

The exception is `!=` (not equals) which defaults to `true`. This is in line with intuition.

```rust
42 > "42";          // false: i64 cannot be compared with string
42 <= "42";         // false: i64 cannot be compared with string
let ts = new_ts();  // custom type
ts == 42;           // false: different types cannot be compared
ts != 42;           // true: different types cannot be compared
ts == ts;           // error: '==' not defined for the custom type
```

### Boolean Operators

|     Operator      | Description | Arity  | Short-circuits? |
| :---------------: | :---------: | :----: | :-------------: |
|  `!` _(prefix)_   |    _NOT_    | unary  |       no        |
|       `&&`        |    _AND_    | binary |       yes       |
|        `&`        |    _AND_    | binary |       no        |
| <code>\|\|</code> |    _OR_     | binary |       yes       |
|  <code>\|</code>  |    _OR_     | binary |       no        |

Double boolean operators `&&` and `||` _short-circuit_ &ndash; meaning that the second operand will not be evaluated
if the first one already proves the condition wrong.

Single boolean operators `&` and `|` always evaluate both operands.

```rust
a() || b();         // b() is not evaluated if a() is true
a() && b();         // b() is not evaluated if a() is false
a() | b();          // both a() and b() are evaluated
a() & b();          // both a() and b() are evaluated
```


Null-Coalescing Operator
------------------------

| Operator |  Description  | Arity  | Short-circuits? |
| :------: | :-----------: | :----: | :-------------: |
|   `??`   | Null-coalesce | binary |       yes       |

The null-coalescing operator (`??`) returns the first operand if it is not [`()`], or the second
operand if the first operand is [`()`].

It _short-circuits_  &ndash; meaning that the second operand will not be evaluated if the first
operand is not [`()`].

```rust
a ?? b              // returns 'a' if it is not (), otherwise 'b'
a() ?? b();         // b() is only evaluated if a() is ()
```

## If Statement

`if` statements follow C syntax.

```rust
if foo(x) {
    print("It's true!");
} else if bar == baz {
    print("It's true again!");
} else if baz.is_foo() {
    print("Yet again true.");
} else if foo(bar - baz) {
    print("True again... this is getting boring.");
} else {
    print("It's finally false!");
}
```


> Unlike C, the condition expression does _not_ need to be enclosed in parentheses `(`...`)`, but all
> branches of the `if` statement must be enclosed within braces `{`...`}`, even when there is only
> one statement inside the branch.
> Like Rust, there is no ambiguity regarding which `if` clause a branch belongs to.
> 
> ```rust
> // not C!
> if (decision) print(42);
> //            ^ syntax error, expecting '{'
> ```



### If Expression

`if` statements can also be used as _expressions_, replacing the `? :` conditional
operators in other C-like languages.

```rust
// The following is equivalent to C: int x = 1 + (decision ? 42 : 123) / 2;
let x = 1 + if decision { 42 } else { 123 } / 2;
x == 22;
let x = if decision { 42 }; // no else branch defaults to '()'
x == ();
```

### Rhai

For extra information about the underlying scripting language see [Rhai](https://rhai.rs/book/language/).