let accept_all string = Some string
let accept_empty_suffix = function
	| _::_ -> None
    | x -> Some x

type my_nonterminals =
  | Expr | Term | Num

let my_grammar =
  (Expr,
   function
     | Expr -> [[N Term]]
     | Term -> [[N Num]];
     | Num ->
		 [[T"0"]; [T"1"]; [T"2"]; [T"3"]; [T"4"];
		  [T"5"]; [T"6"]; [T"7"]; [T"8"]; [T"9"]])

(* (5)
 * Write one good, nontrivial test case for your make_matcher function. 
 * It should be in the style of the test cases given below, but should 
 * cover different problem areas. Your test case should be named 
 * make_matcher_test. Your test case should test a grammar of your own.
 *)
let make_matcher_test = (
	((make_matcher my_grammar accept_empty_suffix ["9"])
	= Some [])
&&
	((make_matcher my_grammar accept_empty_suffix ["9"; "0"])
	= None)
&&
	((make_matcher my_grammar accept_all ["9"; "0"])
	= Some ["0"])
)

(* (6)
 * Similarly, write a good test case make_parser_test for your make_parser 
 * function using your same test grammar. This test should check that 
 * parse_tree_leaves is in some sense the inverse of make_parser gram, 
 * in that when make_parser gram frag returns Some tree, then 
 * parse_tree_leaves tree equals frag.
 *)
let small_frag = ["9"]
let make_parser_test =
  match make_parser my_grammar small_frag with
    | Some tree -> parse_tree_leaves tree = small_frag
    | _ -> false