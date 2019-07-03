list_lengths(_, []).
list_lengths(N, [H | T]) :- length(H, N), list_lengths(N, T).


in_range(_, []).
in_range(N, [H | T]) :-
	fd_domain(H, 1, N),
	in_range(N, T).

tr_helper([L | Ls], L, Ls).

mtrx([], []).
mtrx([H | T], X) :-
	mtrx(H, [H| T], X).

mtrx([], _, []).
mtrx([_ | G], LI, [Fs | E]) :-
	maplist(tr_helper, LI, Fs, Lists),
	mtrx(G, Lists, E).


reverse_lists([], []).
reverse_lists([H | T], [H2 | T2]) :-
	reverse(H, H2),
	reverse_lists(T, T2).


check_last([H | T], Z) :- check_last(T, H, 1, Z).
check_last([], _, C, C).
check_last([H | T], X, C, Z) :- H > X, C1 is C+1, check_last(T, H, C1, Z).
check_last([H | T], X, C, Z) :- H < X, check_last(T, X, C, Z).


check([], []).
check([[H | X] | T], [C | V]) :-
	check_last([H | X], C),
	check(T, V).


get_range(N, D) :- 
	findall(X, between(1, N, X), D).


get_answers([], _).
get_answers([H | T], N) :-
	get_range(N, Bottom),
	permutation(Bottom, H),
	get_answers(T, N).


check_lengths(L) :-
	sort(L, Sorted),
	length(L, L1),
	length(Sorted, L2),
	L1 == L2.


tower(N, T, C) :-
	C = counts(A, B, E, F),
	length(A, N),
	length(B, N),
	length(E, N),
	length(F, N),
	length(T, N),
	list_lengths(N, T),
	in_range(N, T),
	maplist(fd_all_different, T),
	mtrx(T, T_transposed),
	maplist(fd_all_different, T_transposed),
	maplist(fd_labeling, T),
	reverse_lists(T, T_reversed),
	reverse_lists(T_transposed, T_transposed_reverse),
	check(T_transposed, A),
	check(T_transposed_reverse, B),
	check(T, E),
	check(T_reversed, F).


plain_tower(N, T, C) :-
	C = counts(A, B, E, F),
	length(A, N),
	length(B, N),
	length(E, N),
	length(R, N),
	length(T, N),
	list_lengths(N, T),
	get_answers(T, N),	
	mtrx(T, T_transposed),
	maplist(check_lengths, T_transposed),
	reverse_lists(T, T_reversed),
	reverse_lists(T_transposed, T_transposed_reverse),
	check(T_transposed, A),
	check(T_transposed_reverse, B),
	check(T, E),
	check(T_reversed, F).


speedup(R) :-
	statistics(cpu_time, [_, _]),
	tower(5, T1, counts([5,3,3,2,1],[1,2,3,3,2],[5,3,3,2,1],[1,2,2,3,2])),

	statistics(cpu_time, [_ , Time1]),
	plain_tower(5, T2, counts([5,3,3,2,1],[1,2,3,3,2],[5,3,3,2,1],[1,2,2,3,2])),

	statistics(cpu_time, [_ , Time2]),
	Plain_Tower is 1.0*(Time2+1),
	Tower is 1.0*(Time1+1),
	write(Time1), nl, write(Time2), nl,
	R is Plain_Tower/Tower.


ambiguous(N, C, T1, T2) :- tower(N, T1, C), tower(N, T2, C), T1 \= T2.