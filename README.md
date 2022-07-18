
This is a small regression test for Z3's OCaml bindings.

It tries to reproduce the crash described in [Z3 #6160](https://github.com/Z3Prover/z3/issues/6160).

To run it, you need a recent OCaml and `dune`, then:

```sh
$ ./run.sh
t[gc2; n_solve=12; 0.5s]: gc      
t[gc2; n_solve=24; 1.0s]: gc
t[gc2; n_solve=34; 1.5s]: gc
t[gc2; n_solve=47; 2.0s]: gc
t[gc2; n_solve=60; 2.4s]: gc
t[gc2; n_solve=71; 2.9s]: gc
t[gc2; n_solve=84; 3.4s]: gc
t[gc2; n_solve=96; 3.9s]: gc
t[gc2; n_solve=110; 4.3s]: gc
t[gc2; n_solve=122; 5.0s]: gc
[…]
^ctrl-c
```

