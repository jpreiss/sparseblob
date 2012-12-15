;+
; NAME:
;   LABEL_REGION_SPARSE
;
; PURPOSE:
;   Label regions (connected components) in an arbitrary-dimensional array
;   when the indices of foreground (nonzero) elements are already known, and
;   there are few foreground elements compared to the total size of the array.
;
; CALLING SEQUENCE:
;   labels = label_region_sparse(array, indices, [/all_neighbors], [ndiff])
;
; INPUTS:
;   ARRAY: the array containing the regions.  This array is not changed at all,
;     but its dimensions are measured to calculate where to look for neighbors.
;  
;   INDICES: an array containing indices to the foreground elements in ARRAY.
;
; KEYWORDS:
;   NDIFF: sets exactly how many dimensions in which a voxel's position must be
;     offset to be considered a neighbor.  For example, in 3D, NDIFF = 1
;     produces face connectivity, NDIFF = 2 produces face and edge, and
;     NDIFF = 3 produces face, edge, and vertex connectivity (26-connectivity).
;
;   ALL_NEIGHBORS: switches on full connectivity: equivalent to setting NDIFF
;     equal to the number of dimensions of the array.  Behavior is exactly the
;     same as in IDL's LABEL_REGION.
;
;   If ALL_NEIGHBORS is set, it will override any setting of NDIFF.
;   If neither keyword is set, the default is NDIFF = 1.
;
; OUTPUT:
;   A vector of ULONGs, the same size as INDICES, containing the region label
;   for each element in INDICES.  The regions are numbered 1..N with no gaps
;   for an N-region image.
;   
; MODIFICATION HISTORY:
;   Written by James Alan Preiss, Barlow Scientific Inc., Olympia, WA.
;   November 2010: First version.
; 
; LICENSE:
;   This program may be used and redistributed freely for any purpose as long
;   as full attribution is given to the author(s).
;-
function label_region_sparse, array, indices, all_neighbors = all_neighbors, ndiff = ndiff

;directory containing the function DLL, not including the /bin directory
dir = ""
if dir eq "" then message, "Please set the containing directory."

;make sure input is an array
sz = size(array)
ndims = sz[0]
if ndims lt 1 then message, "ARRAY must be an array."

;make sure indices are valid
top = n_elements(array)
if total(indices ge top) ne 0 || total(indices lt 0) ne 0 then begin
  message, "INDICES contains invalid indices to ARRAY."
endif

;convert indices to ulongs and make labels array to hold result
ninds = ulong(n_elements(indices))
ulindices = ulong(indices[sort(indices)])
labels = ulonarr(ninds)

; build the DELTAS array telling the C program where to look for neighbors
;-------------------------------------------------------------------------------
if keyword_set(ndiff) then begin
  if ndiff gt ndims then message, "NDIFF must be <= number of array dimensions"
  if ndiff lt 1 then message, "NDIFF must be at least 1."
endif
if keyword_set(all_neighbors) then ndiff = ndims else ndiff = 1

;build array of offsets for the neighborhood we want
deltas = neighbor_deltas(ndims, ndiff, /leq)

;find out how far away the neighbors are in 1D indices
strides = [1, product(sz[1:ndims-1], /integer, /cumulative)]

;use the deltas array to combine +/- strides in all applicable ways
deltas *= strides # replicate(1, (size(deltas))[2])

;collapse deltas down to calculate the total 1D offset of the neighbors
deltas = long64(total(deltas, 1, /integer))

; only take the negative deltas; these are the places where we look back
deltas = deltas[where(deltas lt 0, count)]
if count eq 0 then message, $
  "Error: no neighbors were calculated."
ndelts = ulong(n_elements(deltas))
;-------------------------------------------------------------------------------
;finished making DELTAS

;make the DLL
files = ["label_region_sparse", "disjoint_set"]
make_dll, files, ["label_region_sparse"], INPUT_DIRECTORY = (dir + '/c'), $
   OUTPUT_DIRECTORY = (dir + '/bin'), extra_cflags = '-O2 -DIDL', /verbose

;call the DLL 
success = call_external(dir + "/bin/label_region_sparse.dll", "label_region_sparse", $
       ulindices, labels, ninds, deltas, ndelts, $
       /cdecl, /auto_glue, /i_value, /unload)
       
if success ne 0 then message, "External DLL returned an error."

return, labels

end
