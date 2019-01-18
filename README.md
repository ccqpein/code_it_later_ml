# code_it_later_ml

Same stuff as [code-it-later](https://github.com/ccqpein/code-it-later). The reasons I re-write this tool are:

1. clojure version startup a bit slow.
2. try to practice ocaml

How to build:
`dune build`

**README copy from clojure version, but not implement all features. Also I focus on [haskell version](https://github.com/ccqpein/code_it_later_hs), this repo may not update future**

## Summary
Make flags in source code where may have problems or can be optimized. codeitlater help you track this flags and fix them in future.

Write code as usual. The comment line that you want to leave mark in, left `:=` symbol after comment symbol.

For example:

**Golang**:

```golang
// /user/src/main.go
// test codeitlater
//:= this line can be read by codeitlater
//:= MARK: you can left keyword to marked comment line
/* mutil lines comments
*/

```

then run `codeitlater` in code root path 

You will get:

```
|-- /user/src/main.go
  |-- Line 3: "this line can be read by codeitlater"
  |-- Line 4: "MARK: you can left keyword to marked comment line"
  |-- Line 5: "mutil lines comments"
```

**Python**:

```python
# /src/main.py
# this line wont be read
#:= this line for codeitlater
print("aaa") ###:= this line can be read again
```

Run `codeitlater`

You will get:

```
|-- /src/main.py
  |-- Line 3: "this line for codeitlater"
  |-- Line 4: "this line can be read again"
```


#### Specific path ####

Run `codeitlater -d /user/src/` let codeitlater just scan specific path.

#### Filter keyword ####

Keyword format is `Keyword:` with a space after.

Filter keyword (use -k be keyword flag, check out more flags by -h):
`codeitlater -k MARK`

You will get:

```
|-- /user/src/main.go
  |-- (4 "MARK: you can left keyword to marked comment line")
```

`ln -sfv $(PWD)/_build/default/core.exe /usr/local/bin/codeitlater`
