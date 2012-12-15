/* 
	disjoint set data structure
	very special case: items are unsigned long ints and no deletions allowed
*/

#ifndef DISJOINT_SET
#define DISJOINT_SET

typedef struct DisjointSet
{
	unsigned long int *parent;
	unsigned long int *rank;
	unsigned long int top;
	unsigned long int size;
} DisjointSet;

DisjointSet * djs_create (unsigned long int size);

unsigned long int djs_insert (DisjointSet * set);

unsigned long int djs_find (DisjointSet *set, unsigned long int x);

int djs_merge (DisjointSet *set, unsigned long int x, unsigned long int y);

unsigned long int djs_size(DisjointSet * set);

#endif //DISJOINT_SET
