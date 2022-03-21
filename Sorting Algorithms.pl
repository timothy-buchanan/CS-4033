/* Decreasing is true if the numbers input are decreasing (X>Y), increasing is true if the numbers are increasing (Y>X). */
decreasing(X, Y):- Y =< X.
increasing(X, Y):- X =< Y.

/* swap the first two elements if they are not in order */
 swap([X, Y|T], [Y, X | T], increasing):-
        	decreasing(X, Y).
/* swap elements in the tail */
 swap([H|T], [H|T1], increasing):-
          	swap(T, T1, increasing).
 swap([X, Y|T], [Y, X | T], decreasing):-
        	increasing(X, Y).
 swap([H|T], [H|T1], decreasing):-
          	swap(T, T1, decreasing).

/* bubbleSort swaps adjacent elements of a list if they are in the wrong order. It keeps running through the list, by recursively calling itself, until there are no more swaps needed. */
bubbleSort(L,SL, ORDER):-
        	swap(L, L1, ORDER), % at least one swap is needed
         	!,
         	bubbleSort(L1, SL, ORDER).
bubbleSort(L, L, _ORDER). % here, the list is already sorted


/* It checks if the list is ordered */
ordered([],_).
ordered([_X], _).
ordered([H1, H2|T], increasing):-
	increasing(H1, H2),
	ordered([H2|T], increasing).
ordered([H1, H2|T], decreasing):-
	decreasing(H1, H2),
	ordered([H2|T], decreasing).


/* Insert takes an element and puts it into a sorted list into the correct position if increasing then prior to the first number greater than the element and if decreasing then prior the first number less than the element */

insert(X, [],[X], _).
insert(E, [H|T], [E,H|T], increasing):-
                    	ordered(T,increasing),
                    	increasing(E, H),
                    	!.

insert(E, [H|T], [H|T1], increasing):-
        	ordered(T,increasing),
        	insert(E, T, T1, increasing).

insert(E, [H|T], [E,H|T], decreasing):-
                    	ordered(T,decreasing),
                    	decreasing(E, H),
                    	!.
insert(E, [H|T], [H|T1], decreasing):-
        	ordered(T,decreasing),
        	insert(E, T, T1, decreasing).
 


/*insertionSort  recursively goes down to empty list then inserts elements into the correct location*/
insertionSort([], [], _).
insertionSort([H|T], SORTED, increasing) :-
      	insertionSort(T, T1, increasing),
      	insert(H, T1, SORTED, increasing).

insertionSort([H|T], SORTED, decreasing) :-
      	insertionSort(T, T1, decreasing),
      	insert(H, T1, SORTED, decreasing).

/* Merge sort uses the merge operation to recursively sort the list. First going to single element lists and then building them up into the larger list by merging them.*/
mergeSort([], [], _).	%the empty list is sorted
mergeSort([X], [X], _):-!.
mergeSort(L, SL, increasing):-
         	split_in_half(L, L1, L2),
         	mergeSort(L1, S1, increasing),
         	mergeSort(L2, S2, increasing),
         	merge(S1, S2, SL, increasing).
mergeSort(L, SL, decreasing):-
         	split_in_half(L, L1, L2),
         	mergeSort(L1, S1, decreasing),
         	mergeSort(L2, S2, decreasing),
         	merge(S1, S2, SL, decreasing).

/* split_in_half splits a given list in half*/
intDiv(N,N1, R):- R is div(N,N1).
split_in_half([], _, _):-!, fail.
split_in_half([X],[],[X]).
split_in_half(L, L1, L2):-
         	length(L,N),
         	intDiv(N,2,N1),
         	length(L1, N1),
         	append(L1, L2, L).

/* Merge takes two ordered lists and combines them into one larger ordered list */
merge([], L, L, _).
merge(L, [],L, _).
merge([H1|T1],[H2|T2],[H1| T], increasing):-
    increasing(H1,H2),
    merge(T1,[H2|T2],T, increasing).

merge([H1|T1], [H2|T2], [H2|T], increasing):-
    decreasing(H1, H2),
    merge([H1|T1],T2, T , increasing).
   
merge([H1|T1],[H2|T2],[H1|T], decreasing):-
    decreasing(H1,H2),
    merge(T1,[H2|T2],T, decreasing).

merge([H1|T1], [H2|T2], [H2|T], decreasing):-
    increasing(H1, H2),
    merge([H1|T1], T2, T, decreasing).


/* Splits the given list into two, one which is greater than the given element and one which is smaller*/

split(_, [],[],[]).
 split(X, [H|T], [H|SMALL], BIG):-
    H =< X,
	split(X, T, SMALL, BIG).    

 split(X, [H|T], SMALL, [H|BIG]):-
	X =< H,
	split(X, T, SMALL, BIG).

/* Quick sort picks an element in the list, and splits the list into 2, greater than that element, and smaller than that element. It then recursively sorts these lists, while appending the split out element at the end of each call*/
quickSort([], [], _).
quickSort([H|T], LS, increasing):-
    	split(H, T, SMALL, BIG),
    	quickSort(SMALL, S, increasing),
    	quickSort(BIG, B, increasing),
    	append(S, [H|B], LS).

quickSort([H|T], LS, decreasing):-
    	split(H, T, SMALL, BIG),
    	quickSort(SMALL, S, decreasing),
    	quickSort(BIG, B, decreasing),  
    	append(B, [H], AUX),
    	append(AUX, S, LS).

/* It either uses the BIGALG or the SMALL sorting algorithms depending on if the list is greater or less than T in length */
hybridSort(LIST, bubbleSort, BIGALG, T, SLIST, ORDER):-
    length(LIST, N), N=<T, 	 
	bubbleSort(LIST, SLIST, ORDER).

hybridSort(LIST, insertionSort, BIGALG, T, SLIST, ORDER):-
    length(LIST, N), N=<T,
	insertionSort(LIST, SLIST, ORDER).

hybridSort(LIST, SMALL, mergeSort, T, SLIST, ORDER):-
    length(LIST, N), N>T, 	 
    split_in_half(LIST, L1, L2),
	hybridSort(L1, SMALL, mergeSort, T, S1, ORDER),
	hybridSort(L2, SMALL, mergeSort, T, S2, ORDER),
	merge(S1,S2, SLIST, ORDER).

hybridSort(LIST, SMALL, quickSort, T, SLIST, increasing):-
    length(LIST, N), N>T,
	LIST = [H|T2],
	split(H,T2,L1,L2),
	hybridSort(L1,SMALL,quickSort,T,S1,increasing),
	hybridSort(L2,SMALL,quickSort,T,S2,increasing),
	append(S1, [H|S2], SLIST).

hybridSort(LIST, SMALL, quickSort, T, SLIST, decreasing):-
    length(LIST, N), N>T,
	LIST = [H|T2],
    split(H, T2, L1, L2),
	hybridSort(L1,SMALL,quickSort,T,S1,decreasing),
	hybridSort(L2,SMALL,quickSort,T,S2,decreasing),
	append(S2, [H], AUX),
	append(AUX, S1, SLIST).
