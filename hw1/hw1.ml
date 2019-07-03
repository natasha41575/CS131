(* Write a function subset a b that returns true iff a⊆b, i.e., if the set 
 * represented by the list a is a subset of the set represented by the list
 * b. Every set is a subset of itself. This function should be generic to
 * lists of any type: that is, the type of subset should be a generalization 
 * of 'a list -> 'a list -> bool.
 *)
let rec subset a b = 
	match a with 
		[] -> true 
		| head::tail -> 
			if List.exists (fun bi -> head = bi) b 
			then subset tail b
			else false ;;

(* Write a function equal_sets a b that returns true iff the represented 
 * sets are equal.
 *)
let equal_sets a b = subset a b && subset b a;;

(* Write a function set_union a b that returns a list representing a∪b. 
 *)
let rec set_union a b = 
	match a with
		[] -> b
		| head::tail ->
			if subset [head] b  (* if element from a is in b *)
			then set_union tail b (* ignore the element from a, it's already in b *)
			else set_union tail (head::b) ;; (* add the element from a to the answer *)

(* Write a function set_intersection a b that returns a list representing 
 * a∩b.
 * Keep all elements of b that are also in a.
 *)
let set_intersection a b = List.filter (fun bi -> subset [bi] a) b;;

(* Write a function set_diff a b that returns a list representing a−b, 
 * that is, the set of all members of a that are not also members of b.
 * Keep all elements of a that are not in b.
 *)
let rec helper_diff l a b =
	match a with
	    [] -> l
	    | head::tail -> 
	    	if (List.exists(fun bi -> head = bi) b) || (List.exists(fun li -> head = li) l) 
	    	then helper_diff l tail b
	    	else helper_diff (head::l) tail b

let set_diff a b = helper_diff [] a b ;;

(*let set_diff a b = List.filter (fun ai -> not (subset [ai] b) ) a;; *)

(* Write a function computed_fixed_point eq f x that returns the computed 
 * fixed point for f with respect to x, assuming that eq is the equality 
 * predicate for f's domain. A common case is that eq will be (=), that is, 
 * the builtin equality predicate of OCaml; but any predicate can be used. 
 * If there is no computed fixed point, your implementation can do whatever 
 * it wants: for example, it can print a diagnostic, or go into a loop, or 
 * send nasty email messages to the user's relatives.
 *)
let rec computed_fixed_point eq f x =
 	if eq (f x) x
 	then x
 	else computed_fixed_point eq f (f x) ;;

(* OK, now for the real work. Write a function filter_reachable g that 
 * returns a copy of the grammar g with all unreachable rules removed. 
 * This function should preserve the order of rules: that is, all rules 
 * that are returned should be in the same order as the rules in g.
 *)
type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal ;;

let nt = 
	function 
    	T a -> []
    	| N a -> a::[] ;;

let rec ter l res = 
	match l with 
    	[] -> res
    	| head::tail -> ter tail (res @ (nt head)) ;;

let rec h_ter v r = 
	match r with
		[] -> []
		| head::tail -> 
			match head with
    			| (a, r2) -> 
    				if a = v 
    				then head::[] 
    				else h_ter v tail ;;

let rec fr_h l1 l2 = 
	match l1 with 
    [] -> l2
    | head::tail -> 
        let res = h_ter head l2 in
	        match res with 
	            [] -> fr_h tail l2
	            | head2::tail2 -> 
	            	match head2 with
	                	(_, b) -> (fr_h (l1 @ (ter b [])) (set_diff l2 res)) ;;

let rec rev l result = 
	match l with 
	    [] -> result
	    | head::tail -> rev tail (head::result) ;;

let filter_reachable = function (a, b) -> (a, rev (set_diff b (fr_h (a::[]) b)) [] ) ;;
