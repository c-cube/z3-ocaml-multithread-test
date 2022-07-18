let start = Unix.gettimeofday ()
let stop = Atomic.make false
let n_solve = Atomic.make 0

let t_z3 () =
  let _tid = Thread.id @@ Thread.self () in
  let ctx = Z3.mk_context [] in

  let n = 1_000 in
  let ps = Array.init n (fun i -> Z3.Symbol.mk_int ctx i) in
  let qs = Array.init n (fun i -> Z3.Symbol.mk_int ctx (n + i)) in
  let solver = Z3.Solver.mk_simple_solver ctx in

  while not @@ Atomic.get stop do
    Z3.Solver.reset solver;
    let p_prev = ref @@ Z3.Boolean.mk_const ctx ps.(0) in
    let q_prev = ref @@ Z3.Boolean.mk_const ctx qs.(0) in
    for i = 1 to n - 1 do
      let p = Z3.Boolean.mk_const ctx ps.(i) in
      let q = Z3.Boolean.mk_const ctx qs.(i) in
      Z3.Solver.add solver [ Z3.Boolean.mk_xor ctx p q ];
      Z3.Solver.add solver [ Z3.Boolean.mk_implies ctx p !p_prev ];
      Z3.Solver.add solver [ Z3.Boolean.mk_implies ctx q !q_prev ];
      p_prev := p;
      q_prev := q
    done;

    Thread.yield ();
    (*Printf.printf "t[z3%d]: solve\n%!" _tid;*)
    let _st = Sys.opaque_identity (Z3.Solver.check solver [ !p_prev ]) in
    Atomic.incr n_solve;
    ()
  done;
  ()

let t_gc () =
  Sys.catch_break true;
  let tid = Thread.id @@ Thread.self () in
  try
    while not @@ Atomic.get stop do
      for _i = 1 to 100 do
        let _a = Sys.opaque_identity (Array.make (2 * 1024 * 1024) 1.) in
        Thread.yield ();
        ()
      done;
      Thread.yield ();
      Gc.compact ();
      let t = Unix.gettimeofday () -. start in
      Printf.printf "t[gc%d; n_solve=%d; %.1fs]: gc\n%!" tid
        (Atomic.get n_solve) t
    done
  with Sys.Break -> Atomic.set stop true

let () =
  let tr_z3 = Array.init 1 (fun _ -> Thread.create t_z3 ()) in
  let tr_gc = Array.init 1 (fun _ -> Thread.create t_gc ()) in

  try
    Array.iter Thread.join tr_z3;
    Array.iter Thread.join tr_gc
  with Sys.Break -> Atomic.set stop true
