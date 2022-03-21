/* cities(L) holds when L is the list of cities on the road map */
cities(["Arad", "Zerind", "Oradea", "Sibiu", "Timisoara", "Fagaras", "Rimnicu Vlicea", "Lugoj", "Mehadia",  "Drobeta", "Craiova", "Pitesti", "Bucharest", "Giurgiu", "Urziceni", "Hirsova", "Eforie", "Vaslui", "Iasi", "Neamt"]).

/* from(C1,C2, D) holds true  when there is a direct link from city C1 to city C2 and the distance between them is D.  Note that the predicate from is NOT symmetric. Thus, based on the map we have */
from("Arad", "Zerind", 75).
from("Arad", "Sibiu", 140).
from("Arad", "Timisoara", 118).
from("Zerind", "Oradea", 71).
from("Sibiu", "Oradea", 151).
from("Timisoara", "Lugoj", 111).
from("Lugoj", "Mehadia", 70).
from("Drobeta", "Mehadia", 75).
from("Drobeta", "Craiova", 120).
from("Rimnicu Vilcea", "Craiova", 146).
from("Pitesti", "Craiova", 138).
from("Fagaras", "Sibiu", 99).
from("Rimnicu Vilcea", "Sibiu", 80).
from("Rimnicu Vilcea", "Pitesti", 97).
from("Fagaras", "Bucharest", 211).
from("Pitesti", "Bucharest", 101).
from("Giugiu", "Bucharest", 90).
from("Urziceni", "Bucharest", 85).
from("Urziceni", "Hirsova", 98).
from("Eforie", "Hirsova", 86).
from("Urziceni", "Vaslui", 142).
from("Iasi", "Vaslui", 92).
from("Iasi", "Neamt", 87).

% c(C1, C2, D): symmetric version of from. Thus
c(C1, C2, D):-from(C1, C2, D).
c(C1, C2, D):- from(C2, C1, D).
c(C1,C2):- from(C1,C2,_).
c(C1,C2):- from(C2,C1,_).

/* sld(C1, C2, D) is the estimate of the straight line distance between cities C1 and C2.  Note that if C1 and C2 are linked directly, then sld(C1, C2, D) is actually c(C1, C2, D).  Otherwise, we can use the ideas described in this assignment:
*/

% From the table above, we have:
sld("Arad", "Bucharest",366).
sld("Oradea", "Bucharest",380).
sld("Sibiu", "Bucharest", 253).
sld("Timisoara", "Bucharest", 329).
sld("Zerind", "Bucharest", 374).
sld("Lugoj", "Bucharest", 244).
sld("Craiova", "Bucharest", 160).
sld("Drobeta", "Bucharest", 242).
sld("Eforie", "Bucharest", 161).
sld("Fagaras", "Bucharest", 176).
sld("Giurgiu", "Bucharest", 77).
sld("Hirsova", "Bucharest", 151).
sld("Iasi", "Bucharest", 226).
sld("Mehadia", "Bucharest", 241).
sld("Neamt", "Bucharest", 234).
sld("Pitesti", "Bucharest", 100).
sld("Rimnicu Vilcea", "Bucharest", 193).
sld("Urziceni", "Bucharest", 80).
sld("Vaslui", "Bucharest", 199).
sld("Bucharest", "Bucharest", 0).


% From Start node to Goal node
% Start: determined upon call.
% Goal: determined in a clause.
% Utilizes the depth search mechanism of Prolog

% Trivial: if X is the goal return X as the path from X to X.
dfs(X, [X],_):-
    goal(X).
% else expand X by Y and find path from Y
dfs(X, [X|Ypath], VISITED):-
	 connected(X, Y),
	negmember(Y, VISITED),
      dfs(Y, Ypath, [Y|VISITED]).

% utility : negation of member
negmember(X, [X|_]):-
	!,fail.
negmember(X, [_|T]):-
   member(X,T),!,fail.
negmember(_, _).

% Undirected graph:
connected(X, Y):-
  c(X, Y).
connected(X, Y):-
  c(Y, X).
% Directed graph:
c(a, b).
c(a, h).
c(b, c).
c(b, i).
c(c, d).
c(d, e).
c(d, i).
c(e, f).
c(f, g).
c(f, h).
c(f, i).
c(g, h).
c(h, i).

% Specify the goal before querying the go predicate.
goal(e).

% Specify the goal before querying the go predicate.
goal("Bucharest").

/* The stopping rule for this condition is obtained when  the current path to be expanded starts with the goal node, that is:*/

bfs([[X |T]|_PATHS], [X|T]):-
           	goal(X).

bfs([PATH|TPaths], SOL):-
      	expand(PATH,  NPaths),
      	append(TPaths, NPaths, NEWPATHS),
      	bfs(NEWPATHS, SOL).
 
expand([HPath|TPath], NPaths):-
	findall([NEXT, HPath|TPath],
   	(connected(HPath, NEXT),negmember(NEXT, [HPath|TPath])),
    	NPaths).

% We next wrap this in a predicate solve_BF as follows:
solve_BFS(S, SOL):-
     	bfs([[S]], S1),
     	reverse(S1,SOL).

% tail of pair gets the tail of a list of pairs, and returns a list of the tails of each pair
tailofpair([],[]).

tailofpair([(D-Y)|T], YLIST):-
	tailofpair(T, TAILYLIST),
	append([Y],TAILYLIST,YLIST).

% bestfs is the implementation of best first search using sld as the heuristic, so it is the same as % depth-first search but it sorts the list of paths to try next by the heuristic
bestfs(X, [X],_):-
    goal(X).

bestfs(X, [X|Ypath], VISITED):-
	findall((D-Z), (c(X,Z,_), sld(Z, "Bucharest", D)), QUEUE),
	keysort(QUEUE, SORTED),
      tailofpair(SORTED, YLIST),
	member(Y,YLIST),
    negmember(Y, VISITED),
      bestfs(Y, Ypath, [Y|VISITED]).

start("Arad").

% Define a dynamic function best_known with 3 parameters, this will be used to store and update the best known path to a given node
:- dynamic best_known/3.

% Finds the cost of traveling along a given path, but recursively
path_cost([_],0).

path_cost([H,H2|T],COST):-
    c(H,H2,C),!,
    path_cost([H2|T],C2),!,
	COST is C+C2,!,
    maybe_assert(COST,[H,H2|T],_M).

% Helper to possibly assert the given fact into the knowledge base if it is better than the current % best_known or there is no best known
maybe_assert(Test_Cost,[H|T],_):-
	\+ best_known(H,_,_),!,
	asserta(best_known(H,[H|T],Test_Cost)).

maybe_assert(Test_Cost,[H|T],Test_Cost):-
	best_known(H,_PATH,C),
	Test_Cost<C,
	retract(best_known(H,_,_)),
	asserta(best_known(H,[H|T],Test_Cost)).


maybe_assert(Test_Cost,[H|_T],C):-
	best_known(H,_PATH,C),
	Test_Cost>=C.

% The best known path to the given node from the start
best_known(X, _, 0):-
	start(X).

% f(n) = h(n)+g(n) where h(n) is sld, g(n) is the actual cost to get to that not (best_known)
% assuming best_known has been asserted for this node
f([N|T],F):-
	best_known(N,_PATH,D),!,
	sld(N,"Bucharest",C),!,
      F is C+D.

% if best_known has not been asserted for this node, do it now
f([N|T],F):-
    \+ best_known(N,_,_),
	path_cost([N|T],D),!,
	asserta(best_known(N,[N|T],D)),!,
	sld(N,"Bucharest",C),!,
      F is C+D.

    
% A* is a modified breadth-first search that uses ‘f’ to sort the list of paths to test where f is 
% defined by a heuristic and the best known actual cost to get to that node
astar([C-[X |T]|_PAIRS], [X|T]):-
           	goal(X).
% Here we use list_to_set to avoid the MANY duplicates that were arising in the early stages of % writing this function
astar([C-Path|TPairs],SOL):-
	 cost_expand(Path,NPairs),!,
	append(TPairs, NPairs, Unsorted),!,
	list_to_set(Unsorted, Set),!,
	keysort(Set,Sorted_Pairs),!,
	astar(Sorted_Pairs, SOL).

astar([Path|TPairs],SOL):-
	 cost_expand(Path,NPairs),!,
	append(TPairs, NPairs, Unsorted),!,
	keysort(Unsorted,Sorted_Pairs),!,
	astar(Sorted_Pairs, SOL).


% We next wrap this in a predicate solve_ASTAR to return the list in the same order as DFS:
solve_ASTAR(S, SOL):-
     	astar([[S]], S1),!,
     	reverse(S1,SOL).

% Expands but returns a list of pairs where the key in each pair is the heuristic function value for the path in the value
cost_expand([HPath|TPath], NPairs):-
	findall(C-[NEXT, HPath|TPath],
   	(c(HPath, NEXT),negmember(NEXT, [HPath|TPath]),f([NEXT,HPath|TPath],C)),
    	GROSS),
	list_to_set(GROSS, NPairs).


