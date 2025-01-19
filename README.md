# Task tracker

First project from [**https://roadmap.sh**](https://roadmap.sh/projects/task-tracker)

## Caveats

One point that I changed from roadmap's description in my implementation is:

> Do not use any external libraries or frameworks to build this project.

OCaml tends to be the language where, if you don't write your own standard library, you are not really programming.
Therefore I settled on using
- [yojson](https://github.com/ocaml-community/yojson) for parsing JSON file
- [core](https://opensource.janestreet.com/core/) standard library from Jane Street

## Installation

Make sure you have OCaml installed on your machine [Instructions](https://ocaml.org/install)

Install deps:\
```sh
opam install --deps-only --yes .
```

Build project:\

```sh
opam exec -- dune build
```



