/*
	NAME: label_regions_sparse

	PURPOSE: label connected components in an array whose size
		is much greater than the number of foreground elements.  Instead of
		supplying the whole array, a list of indices identifies the foreground.

	PARAMETERS:
		INDICES: a __sorted__ array containing the (1D) indices of all
			foreground elements in the array.

		LABELS: an array, allocated by the user, to store the region labels
			for each foreground element.  Must be the same size as INDICES.

		NINDS: the number of elements in INDICES (and LABELS).

		DELTAS: an array of the index offsets to look for when checking if an
			element's neighbors are in the foreground.  The choice depends
			on the size and dimensionality of the array.  Since processing moves
			through a sorted array, all DELTAS should be negative since we can
			only look back at already-processed elements.

		NDELTS: the number of elements in DELTAS.

	RETURNS:
		0 on success, 1 on error.

	SIDE EFFECTS:
		LABELS will be filled with the labels for each element's region.

	MODIFICATION HISTORY:
		Written by James Alan Preiss, Barlow Scientific, Inc. November 2010.
*/	

#include <stdlib.h>
#include <stdio.h>

#include "disjoint_set.h"

//default number of sets to start with
#define N_SETS 32

//make typedefs depending on compilation with IDL or not
#ifdef IDL
	#include "idl_export.h"
	typedef IDL_ULONG slr_ulong;
	typedef IDL_LONG64 slr_longlong;
	#define printerr(x) IDL_Message(IDL_M_GENERIC, IDL_MSG_LONGJMP, x)
#else
	typedef unsigned long int slr_ulong;
	typedef long long int slr_longlong;
	#define printerr(x) printf(x)
#endif

/* prototype of helper function: binary search on an array of ULONGs 
   returns the index of the element, or -1 if the element is not found */
slr_longlong binsearch (slr_ulong * arr, slr_ulong find, slr_ulong size);

/* main function */
int label_region_sparse (slr_ulong * indices, slr_ulong * labels,
                        slr_ulong * ninds, slr_longlong * deltas, slr_ulong * ndelts)
{
	slr_ulong i, j, counter, *hood, *map;
	slr_longlong search, index;
	DisjointSet * sets;
	char buf[100];
	
	/* Allocate Disjoint Set structure, neighborhood array, and label packing map */
	sets = djs_create(N_SETS);
	hood = malloc(*ndelts * sizeof(*hood));
	if (NULL == sets || NULL == hood) {
		printerr("Failed to allocate memory.\n");
		return 1;
	}
	
	//loop over all indices and label regions. indices must be ascending
	for (i = 0; i < *ninds; ++i) {
		index = indices[i];
		counter = 0;
		/* find regions of all neighbors that exist. */
		for (j = 0; j < *ndelts; ++j)
			if (index >= deltas[j] && (search = binsearch(indices, index + deltas[j], *ninds)) != -1)
				hood[counter++] = labels[search];
		/* now elements [0..counter) of HOOD are filled with neighbor regions.
		   so if counter > 0 then there are some neighbor regions. */
		if (counter > 0) {
			labels[i] = hood[0];
			/* if more than one neighbor existed, merge the regions together
			   note that this loop will never execute if counter == 1 */
			for (j = 1; j < counter; ++j)
				if (1 == djs_merge(sets, hood[0], hood[j])) {
					printerr("Illegal merging sets\n");
					return -1;
				}
		}
		//no neighbors exist; make a new region for this voxel
		else {
			if ((labels[i] = djs_insert(sets)) == 0) {
				printerr("Failed to add a disjoint set\n");
				return 1;
			}
		}
	}

	//done with the neighborhood holder
	free(hood);

	/* second pass; reassign labels to the "representative" label
	   also collapse gaps so the regions are 1,2,3,...,n */
	/* allocate a zeroed array that maps regions to labels for gap compression */
	map = calloc(djs_size(sets) + 1, sizeof *map);
	if (NULL == map) {
		printerr("Failed to allocate memory.\n");
		return 1;
	}

	/* map representative elements to 1,2,3,...,n range and label
	   each element with its mapped representative */
	counter = 1;
	for (i = 0; i < *ninds; ++i) {
		j = djs_find(sets, labels[i]);
		if (0 == map[j]) {
			map[j] = counter++;
		}
		labels[i] = map[j];
	}

	//done, clear out all heap memory and return no-error
	djs_destroy(sets);
	free(map);
	return 0;
}

slr_longlong binsearch (slr_ulong * arr, slr_ulong find, slr_ulong size)
{
	slr_longlong low, mid, high;
	low = 0;
	high = size - 1;
	while (low <= high) {
		mid = (low + high) / 2;
		if (arr[mid] == find)
			return mid;
		if (arr[mid] > find)
			high = mid - 1;
		else
			low = mid + 1;
	}
	return -1;
}
