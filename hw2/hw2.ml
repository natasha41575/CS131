type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

type ('nonterminal, 'terminal) parse_tree =
  | Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
  | Leaf of 'terminal

(* (1)
 * To warm up, notice that the format of grammars is different in this 
 * assignment, versus Homework 1. Write a function convert_grammar gram1 
 * that returns a Homework 2-style grammar, which is converted from the 
 * Homework 1-style grammar gram1. Test your implementation of convert_grammar 
 * on the test grammars given in Homework 1. For example, the top-level 
 * definition let awksub_grammar_2 = convert_grammar awksub_grammar should 
 * bind awksub_grammar_2 to a Homework 2-style grammar that is equivalent to 
 * the Homework 1-style grammar awksub_grammar. 
 *)

(* returns a function that takes a nonterminal value *)
let rec hh r li nt = 
	match r with
		[] -> li
		| (l, r)::t -> 
			if l = nt 
			then 
				let x = (li@[r]) in 
				hh t x nt  
			else 
				hh t li nt 

let convert_grammar gram1 = match gram1 with (e, r) -> (e, hh r [])

(* (2)
 * As another warmup, write a function parse_tree_leaves tree that traverses 
 * the parse tree tree left to right and yields a list of the leaves encountered. 
 * eg (Node ("+", [Leaf 3; Node ("*", [Leaf 4; Leaf 5])]))
 *)
let rec get_leaves = function
	(Leaf a)::t -> [a] @ (get_leaves t)
	| (Node (a, b))::t -> (get_leaves b) @ (get_leaves t)
	| [] -> []

let parse_tree_leaves tree = get_leaves [tree]


(* (3)
 * Write a function make_matcher gram that returns a matcher for the grammar 
 * gram. When applied to an acceptor accept and a fragment frag, the matcher 
 * must try the grammar rules in order and return the result of calling accept 
 * on the suffix corresponding to the first acceptable matching prefix of frag; 
 * this is not necessarily the shortest or the longest acceptable match. A match 
 * is considered to be acceptable if accept succeeds when given the suffix fragment 
 * that immediately follows the matching prefix. When this happens, the matcher 
 * returns whatever the acceptor returned. If no acceptable match is found, the 
 * matcher returns None.
 *)

let make_matcher gram accept frag = 
	match gram with 
		(a, b) -> 
	let rec h1 li = function
		[] -> None
		| (h::t) -> 
	match li with
		(a, b, c, d) -> let x = h2 (b, h, c) d in
	match x with
			Some _ -> x
			| None -> let y = (a, b, c, d) in
				h1 y t
	and h2 li m = 
		match li with 
			(a, b, c) -> 
	match b with
		[] -> c m	
		| num -> 
	match m with
		[] -> None
		| (h::t) -> 
	match b with
		[] -> None
		| (T f)::tt -> 
			if f <> h 
			then None
			else let x = (a, tt, c) in h2 x t
		| (N nf)::tnt -> 
			let x = (h2 (a, tnt, c)) in 
			let y = (nf, a, x, m) in
					h1 y (a nf) in
	let x = (a, b, accept, frag) in
		h1 x (b a)


(* (4)
 * Write a function make_parser gram that returns a parser for the grammar gram. 
 * When applied to a fragment frag, the parser returns an optional parse tree. 
 * If frag cannot be parsed entirely (that is, from beginning to end), the parser 
 * returns None. Otherwise, it returns Some tree where tree is the parse tree 
 * corresponding to the input fragment. Your parser should try grammar rules in the 
 * same order as make_matcher.
 *)
let rec hf1 li t ru frag = 
	match t with
		(a, b) -> 
	match a with
        [] -> b ru frag
        | h::t -> 
    match frag with
        [] -> None
        | h1::h2 -> 
    match h with
    	T h_ter -> 
    		if h1 <> h_ter 
    		then None
            else hf1 li (t, b) ru h2
        | N nh_ter -> hf2 nh_ter li (hf1 li (t, b)) ru frag (li nh_ter)

and hf2 fi li accept ru frag = function
    [] -> None
    | h::t -> let (a, b) = (hf1 li (h, accept) (ru @ [fi, h]) frag, hf2 fi li accept ru frag t) in
		match a with
	    	None -> b
	        | Some _ -> a

let rec get_rst = function
    [] -> 0
    | h::t -> match h with
        N x -> (get_rst t)+1
        | T x -> (get_rst t)

let rec get_num li acc =
	match acc with
		0 -> acc
		| _ -> 
	match li with
		h::t -> (get_num t (acc-1+(get_rst h)))+1
		| [] -> 0

let rst acc_r = 
	let rec push = function (a, b) -> 
		match b with
			0 -> a
			| _ -> 
	    match a with
		    [] -> []
		    | h::t -> let x = b-1 in 
		    	push (t, x)
    in 
 		let y = (acc_r, get_num acc_r 1) in push y

let rec sm_tr_a acc_r = function
    [] -> []
    | h::t -> match h with
        T h_ter -> ([Leaf h_ter] @ (sm_tr_a acc_r t))
        | N nh_ter -> match acc_r with  
            h2::t2 -> 
            	let (x, y) = (sm_tr_a t2 h2, sm_tr_a (rst acc_r) t) in 
            		[Node (nh_ter, x)] @ y
            | [] -> []

let trb li = 
	let rec find = function
	    [] -> []
	    | h::t -> match h with 
	    	(a, b) -> [b] @ (find t) 
    in
		let x = find li in 
		let (tl_x, hd_x, hd_li) = (List.tl x, List.hd x, fst (List.hd li)) in
		let y = Node(hd_li, sm_tr_a tl_x hd_x) in 
	Some(y)

let mtchk h_ter frag = function
	(a, b) -> hf2 a b h_ter [] frag (b a)

let make_parser gram frag =
	let my_acc ru li_term = Some(ru, li_term) in 
		match (mtchk my_acc frag gram) with
			Some (a, b) -> trb a
			| None -> None
