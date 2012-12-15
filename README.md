sparseblob
==========

Sparse blob detection/region-labeling in any number of dimensions for scientific language IDL.


Introduction
------------

Performs connected-components region labeling, or "blob detection",
on binary image arrays with any number of dimensions.
Outputs a distinct integer label for each connected component.
The normal IDL function to do this is `LABEL_REGION`.
However, `LABEL_REGION` looks over the whole array.
This is very inefficient if you already know where the nonzero elements are located, 
and there are relatively few of them.

This program consists of an IDL function, `LABEL_REGION_SPARSE`, and a few small helper functions in IDL.
The workhorse is an external C program, compiled to a DLL, that is called by `LABEL_REGION_SPARSE`
with IDL's `MAKE_DLL` and `CALL_EXTERNAL` capability.


###Calling Signature###

    labels = label_region_sparse(array, indices, [/all_neighbors], [ndiff])


###Inputs###

    ARRAY: the image data to scan for connected components.
	
    INDICES: an array containing indices to the foreground elements in ARRAY, 
        e.g. where(ARRAY).


###Keywords###

    NDIFF: sets the maximum number of dimensions in which a voxel's position
        may be offset to be considered a neighbor. For example, in 3D:
        NDIFF = 1 produces face connectivity.
        NDIFF = 2 produces face and edge.
        DIFF = 3 produces face, edge, and vertex (26-connectivity).

    ALL_NEIGHBORS: switches on full connectivity: equivalent to setting NDIFF 
        equal to the number of dimensions of the array.
        Behavior is exactly the same as IDL's LABEL_REGION.

    If ALL_NEIGHBORS is set, it will override any setting of NDIFF.
    If neither keyword is set, the default is NDIFF = 1.


###Output###

A vector of `ULONG`s, the same size as `INDICES`, containing the region label 
for each element in `INDICES`.  The regions are numbered `1..N` with no gaps for an `N`-region image.
