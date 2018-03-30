


let explode s =
  let rec exp i l =
    if i < 0 then l else exp (i - 1) (s.[i] :: l) in
  exp (String.length s - 1) []

type expr = 
	| App of expr * expr
	| Var of string
	| Num of int
	| Chr of int
	| Ref of expr ref

let rec expr2str e = 
	let rec f e n = 
		match e with
		| Var c -> c
		| Num x -> Printf.sprintf "NUM[%d]" x
		| Chr x -> Printf.sprintf "CHR[%d]" x
		| Ref x -> Printf.sprintf "Ref %x" (Obj.magic x)
		| App(a,b) -> (
			(String.make n ' ') ^ "(\n" ^ 
			(String.make (n+1) ' ') ^ (f a (n+2)) ^ ",\n" ^
			(String.make (n+1) ' ') ^ (f b (n+2)) ^ "\n" ^
			(String.make n ' ') ^ ")" 
		)
	in
		f e 0

let rec expr2size e = 
	match e with
	| Var _ | Num _ | Ref _ | Chr _ -> 1
	| App(a,b) -> (expr2size a) + (expr2size b) + 1


let rec s2t s = 
	let ba = explode s in
	let rec f s = 
		match s with
		| '`' :: rs -> 
			let v1,s1 = f rs in
			let v2,s2 = f s1 in
			(App(v1,v2)),s2
		| c :: rs -> (Var (Char.escaped c)),rs
		| [] -> raise (Failure "hoge")
	in
		let res,_ = f ba
		in res

let rec step v = 
	match v with
	| Var _ | Num _ | Chr _ -> v,false
	
	| Ref x -> (
			let tx,b = step !x in
			x := tx;
			tx,true
		)
	
	| App(Var "i",x) -> x,true
	| App(App(Var "k",x),y) -> x,true
	| App(App(App(Var "s",x),y),z) -> (
			let tz = Ref (ref z) in
			App(App(x,tz),App(y,tz)),true
		)
	
	(* (pair p q) f -> f p q *)
	| App(App(App(Var "pair",p),q),f) -> App(App(f,p),q),true
	
	(* fst, snd *)
	| App(App(Var "fst",x),y) -> x,true
	| App(App(Var "snd",x),y) -> y,true
	
	(* [n] s z -> s^(z) *)
	| App(App(Num n,s),z) -> (
			let ts = Ref (ref s) in
			let tz = Ref (ref z) in
			let rec f x = if x = 0 then tz else App(ts,f (x-1))
			in f n,true
		)
	
	(* eof -> pair [256] eof なので、展開してしまう *)
	
	| App(Var "eof",f) -> (
			Printf.printf "expand eof\n";
			flush_all ();
			let tr = Ref (ref (Var "eof")) in
			App(App(App(Var "pair",Num 256),tr),f),true
		)
	
	(* 出力のためのincrement *)
	| App(Var "inc",Chr n) -> (Chr (n+1)),true
	
	| App(a,b) -> 
		let ta,x = step a in
		if x then App(ta,b),true
		(* 右辺を簡約するの、そんなになさそーですね？ *)
		else if a = Var "inc" then (
			(*
			Printf.printf "reduce_right\n";
			flush_all ();
			*)
			let tb,x = step b in
			App(a,tb),x
		)
		else App(a,b),false




(*
let _ = Printf.printf "%s\n" (expr2str ski)
*)



let rec tonorm a = 
	let ta,b = step a in
	(*
	(let sz = (expr2size ta) in

	Printf.printf "%d\n" sz;
	flush_all ();
	if sz < 0 then (
	Printf.printf "%s\n" (expr2str ta);
	flush_all ()
	) else ());
	*)
	
	if b then tonorm ta else a
	


let tonorm_weak x = 
	let rec f n a = 
		if n <= 0 then a else 
		let ta,b = step a in
		if b then f (n-1) ta else a
	in
		f 1000 x


let rec solve_foo x = 
	(let tx = tonorm_weak (App(App(x,Var "inc"),Num 0)) in
	match tx with
	| Num n -> (
			if n >= 10 then
				Printf.printf "out %c %d\n" (Char.chr n) n
			else ()
		)
	| _ -> ()
	);
	
	match x with
	| App(a,b) -> solve_foo a; solve_foo b;
	| _ -> ()


let rec output x = 
	let tx = tonorm (App(App(App(x,Var "fst"),Var "inc"),Chr 0)) in
	Printf.printf "%s\n" (expr2str tx);
	flush_all ();
	
	match tx with
	| Chr n -> (
			Printf.printf "out %c %d\n" (Char.chr n) n;
			flush_all ();
			output (tonorm (App(x,Var "snd")))
		)
	| _ -> Printf.printf "finished \n"

let ski = s2t prog

(*
let _ = 
	solve_foo ski;
	Printf.printf "try_solved\n"
*)


let ts = App(ski,App(App(Var "pair",Num 256),Ref (ref (Var "eof"))))

let _ = 
	Printf.printf "converted \n";
	flush_all ()

(*
let _ = Printf.printf "%s\n" (expr2str ts)
*)

let _ = output ts


