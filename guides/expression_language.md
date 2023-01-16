# Expression Language

A small, fast, easy-to-use scripting language and evaluation engine.

## Introduction

An embedded scripting language and evaluation engine for Trento Checks Expressions that gives a safe and easy way to script specific steps during Checks Execution.

## Types

| Type                           | Example                  |
| ------------------------------ | ------------------------ |
| **Nothing/void/nil/null/Unit** | `()`                     |
| **Integer**                    | `42`, `123`              |
| **Float**                      | `123.4567`               |
| **Boolean**                    | `true` or `false`        |
| **String**                     | `"hello"`                |
| **Array**                      | `[ 1, 2, 3, "foobar" ]`  |
| **Map**                        | `#{ "a": 1, "b": true }` |

## Logic Operators and Boolean

| Operator | Description<br/>(`x` _operator_ `y`) | `x`, `y` same type or are numeric | `x`, `y` different types |
| :------: | ------------------------------------ | :-------------------------------: | :----------------------: |
|   `==`   | `x` is equals to `y`                 |       error if not defined        |  `false` if not defined  |
|   `!=`   | `x` is not equals to `y`             |       error if not defined        |  `true` if not defined   |
|   `>`    | `x` is greater than `y`              |       error if not defined        |  `false` if not defined  |
|   `>=`   | `x` is greater than or equals to `y` |       error if not defined        |  `false` if not defined  |
|   `<`    | `x` is less than `y`                 |       error if not defined        |  `false` if not defined  |
|   `<=`   | `x` is less than or equals to `y`    |       error if not defined        |  `false` if not defined  |

### Comparing different types defaults to `false`

Comparing two values of _different_ data types defaults to `false`.

The exception is `!=` (not equals) which defaults to `true`. This is in line with intuition.

```ts
42 > "42";          // false: i64 cannot be compared with string
42 <= "42";         // false: i64 cannot be compared with string
ts == 42;           // false: different types cannot be compared
ts != 42;           // true: different types cannot be compared
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

```ts
a() || b();         // b() is not evaluated if a() is true
a() && b();         // b() is not evaluated if a() is false
a() | b();          // both a() and b() are evaluated
a() & b();          // both a() and b() are evaluated
```

## If Statement

`if` statements follow C syntax.

```ts
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
> ```ts
> // not C!
> if (decision) print(42);
> //            ^ syntax error, expecting '{'
> ```

### If Expression

`if` statements can also be used as _expressions_, replacing the `? :` conditional
operators in other C-like languages.

```ts
// The following is equivalent to C: int x = 1 + (decision ? 42 : 123) / 2;
let x = 1 + if decision { 42 } else { 123 } / 2;
x == 22;
let x = if decision { 42 }; // no else branch defaults to '()'
x == ();
```

## Arrays

All elements stored in an array are dynamic, and the array can freely grow or shrink with elements
added or removed.

Array literals are built within square brackets `[` ... `]` and separated by commas `,`:

> `[` _value_`,` _value_`,` ... `,` _value_ `]`
>
> `[` _value_`,` _value_`,` ... `,` _value_ `,` `]` `// trailing comma is OK`

```ts
let some_list = [1, 2, 3];

let another_list = ["foo", "bar", 42];
```

### Access Element From beginning

Like C, arrays are accessed with zero-based, non-negative integer indices:

> _array_ `[` _index position from 0 to length−1_ `]`

```ts
let some_list = ["foo", "bar", 42];

let second_element = some_list[1];

// second_element is "bar"
```

### Access Element From end

A _negative_ position accesses an element in the array counting from the _end_, with −1 being the
_last_ element.

> _array_ `[` _index position from −1 to −length_ `]`

```ts
let some_list = ["foo", "bar", 42];

let second_element = some_list[-2];
let last_element = some_list[-1];

// second_element is "bar"
// last_element is 42
```

| Function | Parameter(s)                       | Description                                                                                                                                                                                        |
| -------- | ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `get`    | position, counting from end if < 0 | gets a copy of the element at a certain position (`()` if the position is not valid)                                                                                                               |
| `len`    | _none_                             | returns the number of elements                                                                                                                                                                     |
| `filter` | predicate (usually a closure)      | constructs a new array with all items that return `true` when called with the predicate function taking the following parameters:<ol><li>array item</li><li>_(optional)_ offset position</li></ol> |
| `all`    | predicate (usually a closure)      | returns `true` if all items return `true` when called with the predicate function taking the following parameters:<ol><li>array item</li><li>_(optional)_ offset position</li></ol>                |

Examples

```ts
let some_list = [1, 2, 3, 4, "foo", "bar"];

let foo = some_list.get(4); // "foo"

let items_count = some_list.len(); // 6

let only_foo_and_bar = some_list.filter(|item| item == "foo" || item == "bar"); // ["foo", "bar"]
// let only_foo_and_bar = some_list.filter(|item, idex_in_array| item == "foo" || item == "bar");

let another_list = [3, 5, 7, 9, 10, 20, 30];

let all_greater_than_2 = another_list.all(|item| item > 2); // true
let all_greater_than_10 = another_list.all(|item| item > 10); // false
// let all_greater_than_10 = another_list.all(|item, idex_in_array| item > 10);
```

## Maps

Maps are hash dictionaries. Properties are all dynamic values and can be freely added and retrieved.

Map literals are built within braces `#{` ... `}` with _name_`:`_value_ pairs separated by
commas `,`:

> `#{` _property_ `:` _value_`,` ... `,` _property_ `:` _value_ `}`
>
> `#{` _property_ `:` _value_`,` ... `,` _property_ `:` _value_ `,` `}` `// trailing comma is OK`

```ts
let some_map = #{              // map literal with 2 properties
    foo: 42,
    bar: "hello",
};
```

### Dot notation

The _dot notation_ allows to access properties by name.

> _object_ `.` _property_

```ts
let some_map = #{              // map literal with 2 properties
    foo: 42,
    bar: "hello",
};

some_map.foo // 42
some_map.bar // "hello"

```

### Non-existing property

Trying to read a non-existing property returns an error.

```ts
let some_map = #{              // map literal with 2 properties
    foo: 42,
    bar: "hello",
};

some_map.another_property      // returns "Property not found: another_property (line X, position Y)"
```

### A more complex example

```ts
let some_map = #{              // map literal with 2 properties
    foo: 42,
    bar: "hello",
    rabbits: [
        #{
            name: "wanda",
            power: 9001
        },
        #{
            name: "tonio",
            power: 9002
        },
        #{
            name: "weak_rabbit",
            power: 8999
        }
    ]
};

// Tell me how many strong rabbits are there
let strong_rabbits = some_map.rabbits.filter(|rabbit| rabbit.power > 9000).len() // 2

let rabbits = some_map.rabbits

let all_rabbits_are_strong = rabbits.all(|rabbit| rabbit.power > 9000) // false, unfortunately

```

## Rhai

For extra information about the underlying scripting language see [Rhai](https://rhai.rs/book/language/).
