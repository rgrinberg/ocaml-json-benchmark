Benchmarking OCaml Json Implementations
--------------------------------

To run:

### If using esy

```
esy install
esy build
esy bench:read
esy bench:write
```

### If using opam

```
opam install core core_bench ezjsonm yojson
dune build @all --profile=release
dune exec -- ./src/bench_read.exe
dune exec -- ./src/bench_write.exe
```

My results are available at my blog:

<http://rgrinberg.com/posts/ocaml-json-benchmark/>

TL;DR: yojson is faster
