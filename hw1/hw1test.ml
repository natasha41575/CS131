(* Supply at least one test case for each of the above functions in the style 
 * shown in the sample test cases below. When testing the function F call the 
 * test cases my_F_test0, my_F_test1, etc. For example, for subset your first 
 * test case should be called my_subset_test0. Your test cases should exercise 
 * all the above functions, even though the sample test cases do not.
 *)

let my_subset_test0 = subset [1;2;3] [1;2;3;4;5]
let my_subset_test1 = not (subset [3;1;4] [1;2;3])

let my_equal_sets_test0 = equal_sets [3;1;4] [1;4;3]
let my_equal_sets_test1 = not (equal_sets [] [1;4;3]) 

let my_set_union_test0 = equal_sets (set_union [4] [5]) [4;5]
let my_set_union_test1 = equal_sets (set_union [2;3] [2;3]) [2;3]

let my_set_intersection_test0 = equal_sets (set_intersection [4;3;2] [4;1;3]) [4;3]
let my_set_intersection_test1 = equal_sets (set_intersection [] [1;2]) []

let my_set_diff_test0 = equal_sets (set_diff [1] [1]) []
let my_set_diff_test1 = equal_sets (set_diff [4;3] [3]) [4]

let my_computed_fixed_point_test0 = computed_fixed_point (=) (fun x -> x) 5 = 5
let my_computed_fixed_point_test0 = computed_fixed_point (=) (fun x -> x*x) 1 = 1

type my_nonterminals =
  | Expr | Lvalue | Incrop | Binop

let my_rules =
   [Expr, [T"("; N Expr; T")"];
    Expr, [N Expr; N Binop; N Expr];
    Expr, [N Lvalue];
    Expr, [N Incrop; N Lvalue];
    Expr, [N Lvalue; N Incrop];
    Lvalue, [T"$"; N Expr];
    Incrop, [T"++"];
    Incrop, [T"--"];
    Binop, [T"+"];
    Binop, [T"-"]]

let my_grammar = Expr, my_rules

let my_filter_reachable_test0 = filter_reachable my_grammar = my_grammar

