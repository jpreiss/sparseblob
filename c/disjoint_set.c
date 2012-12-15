/* 
	Disjoint Set data structure.
	This data structure organizes items into disjoint sets
	(each element is a member of exactly one set).
	Operations are Insert, Find, and Union.
	These operations are fast: essentially constant time for each operation.
	Storage is in dynamic arrays with geometric resizing.
	This structure is restrictive:
	Items are unsigned long ints and no deletions are allowed.

	Written by James Alan Preiss, Barlow Scientific, Inc. November 2010.
*/


#include <stdlib.h>

/* Disjoint Set structure definition */
typedef struct DisjointSet
{
	unsigned long int *parent;
	unsigned long int *rank;
	unsigned long int top;
	unsigned long int size;
} DisjointSet;

/* Initialize a disjoint set with a specified size
   Returns NULL on failure or a pointer to the set struct on success */
DisjointSet * djs_create (unsigned long int size)
{
	DisjointSet *set;
	set = malloc(sizeof *set);
	if (NULL == set)
		return NULL;
	set->parent = malloc(size * sizeof *set->parent);
	set->rank = malloc(size * sizeof *set->rank);
	/* release all memory if any call to MALLOC failed */
	if (NULL == set->parent || NULL == set->rank) {
		free(set->parent);
		free(set->rank);
		free(set);
		return NULL;
	}
	set->top = 1;
	set->size = size;
	return set;
}

void djs_destroy (DisjointSet * set)
{
	if (NULL != set) {
		free(set->parent);
		free(set->rank);
		free(set);
	}
}

/* Insert a new singleton set into the structure.
   Returns the positive integer representing the set on success.
   Returns 0 on failure.  (No set is ever represented by 0.) */
unsigned long int djs_insert (DisjointSet * set)
{
	unsigned long int *newparent, *newrank;
	/* expand the arrays if necessary */
	if (set->top >= set->size) {
		newparent = realloc(set->parent, set->size * 2 * (sizeof *newparent));
		newrank = realloc(set->rank, set->size * 2 * (sizeof *newrank));
		/* array reallocation failed; the structure cannot expand */
		if (NULL == newparent || NULL == newrank)
			return 0;
		set->parent = newparent;
		set->rank = newrank;
		set->size *= 2;
	}
	set->parent[set->top] = set->top;
	set->rank[set->top] = 0;
	return set->top++;
}

/* Returns the positive integer representing the set containing an item.
   Returns zero if the item does not exist. */
unsigned long int djs_find (DisjointSet *set, unsigned long int x)
{
	if (x >= set->top || x <= 0)
		return 0;
	if (set->parent[x] != x)
		set->parent[x] = djs_find(set, set->parent[x]);
	return set->parent[x];
}

/* Merge (union) two sets.
   Returns 1 if the sets do not exist, 0 on success. */
int djs_merge (DisjointSet *set, unsigned long int x, unsigned long int y)
{
	if (x >= set->top || y >= set->top || x <= 0 || y <= 0)
		return 1;
	x = djs_find(set, x);
	y = djs_find(set, y);
	if (set->rank[x] > set->rank[y])
		set->parent[y] = x;
	else {
		set->parent[x] = y;
		if (set->rank[x] == set->rank[y])
			++(set->rank[y]);
	}
	return 0;
}

unsigned long int djs_size(DisjointSet *set)
{
	return set->top - 1;
}
