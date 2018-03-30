
type tyvar = string

type var = string

type ty =
	| TyV of tyvar
	| TyFun of ty * ty 
	| TyAll of tyvar * ty

let rec ty2str = 
	function
	| TyV(v) -> v
	| TyFun(p,q) -> (ty2str_pa p) ^ " -> " ^ (ty2str q)
	| TyAll(v,p) -> "∀" ^ v ^ "." ^ (ty2str p)
and ty2str_pa t = 
	match t with
	| TyV _ -> (ty2str t)
	| _ -> "(" ^ (ty2str t) ^ ")"

(* s中のaをtで置換する *)
let rec ty_subst s a t = 
	match s with
	| TyV(b) -> if a = b then t else s
	| TyFun(p,q) -> TyFun(ty_subst p a t,ty_subst q a t)
	| TyAll(v,x) -> if v = a then s else TyAll(v,ty_subst x a t)

let rec free_tyv t = 
	match t with
	| TyV(a) -> [a]
	| TyFun(p,q) -> (free_tyv p) @ (free_tyv q)
	| TyAll(a,p) -> List.filter (fun x -> x <> a) (free_tyv p)

type expr = 
	| Var of var
	| App of expr * expr
	| La of var * ty * expr
	| TyApp of expr * ty
	| TLa of tyvar * expr

let rec expr2str =
	function
	| Var(a) -> a
	| App(p,q) -> (expr2str p) ^ " " ^ (expr2str_pa q)
	| La(v,t,p) -> "λ" ^ v ^ ":" ^ (ty2str t) ^ "." ^ (expr2str p)
	| TyApp(p,t) -> (expr2str p) ^ " " ^ (ty2str_pa t)
	| TLa(v,p) -> "Λ" ^ v ^ "." ^ (expr2str p)
and expr2str_pa ex = 
	match ex with
	| Var _ -> (expr2str ex)
	| _ -> "(" ^ (expr2str ex) ^ ")"

let env2str env = 
	env |> (List.map (fun (v,t) -> "(" ^ v ^ ":" ^ (ty2str t) ^ ")")) |> (String.concat ",")

let rec infer ex env = 
	let res = 
		match ex with
		| Var(x) -> List.assoc x env
		| App(x,y) -> (
				let ab = infer x env in
				let a = infer y env in
				match ab with
				| TyFun(p,q) when p = a -> q
				| _ -> raise (Failure "App failure")
			)
		| La(x,t,y) -> TyFun(t,infer y ((x,t) :: env))
		| TyApp(x,t) -> (
				let fa = infer x env in
				match fa with
				| TyAll(a,s) -> ty_subst s a t
				| _ -> raise (Failure "tyApp failure")
			)
		| TLa(v,x) -> (
				let t = infer x env in
				if List.mem v (env |> (List.map (fun (_,t) -> free_tyv t)) |> List.concat)
				then raise (Failure "TLa failure")
				else TyAll(v,t)
			)
	in
		Printf.printf "%s ├ %s : %s\n" (env2str env) (expr2str ex) (ty2str res);
		res

let pair = 
	TLa("A",TLa("B",La("a",TyV("A"),La("b",TyV("B"),
		TLa("C",La("f",TyFun(TyV("A"),TyFun(TyV("B"),TyV("C"))),
			App(App(Var("f"),Var("a")),Var("b"))
		))
	))))

let fst = 
	TLa("A",TLa("B",La("p",TyAll("C",TyFun(TyFun(TyV("A"),TyFun(TyV("B"),TyV("C"))),TyV("C"))),
		App(TyApp(Var("p"),TyV("A")),
			La("x",TyV("A"),La("y",TyV("B"),Var("x")))
		)
	)))

let _ = 
	Printf.printf "type %s\n" (ty2str (infer pair []));
	Printf.printf "type %s\n" (ty2str (infer fst []));
