;+
; NAME:
;     NEIGHBOR_DELTAS
;
; PURPOSE:
;     Enumerate all the "deltas" or "directions to look" in an N-dimensional
;     array to find other elements that differ in exactly K dimensions
;     by -1 or 1.
; 
; CATEGORY:
;     Mathematics - Combinatorial.
;
; INPUTS: 
;     N: the number of dimensions to look.
;     K: the number of dimensions in which the coordinate of the neighbor
;        must differ.
; 
; KEYWORDS:
;     LEQ: if set, the function returns deltas for elements differing in
;       K or fewer dimensions, instead of exactly K dimensions.
;       For example, NEIGHBOR_DELTAS(3,3) returns the 8 corner-connected
;       neighbors of a cube but NEIGHBOR_DELTAS(3,3,/leq) returns the
;       whole 26-connected neighborhood.
;     
; OUTPUTS:
;     A 2D integer array of size N x (2^K * Chooose(N,K)).  Each N-row
;     contains the direction to look for one neighbor.
;     
; EXAMPLE:
;     To find all the edge-connected neighbors of a cube:
;     Print, NEIGHBOR_DELTAS(3, 2)
;     
;          1       1       0
;         -1       1       0
;          1      -1       0
;         -1      -1       0
;          1       0       1
;         -1       0       1
;          1       0      -1
;         -1       0      -1
;          0       1       1
;          0      -1       1
;          0       1      -1
;          0      -1      -1
;
; MODIFICATION HISTORY:
;     Written by James Alan Preiss, Barlow Scientific, Inc., August 12, 2010
;     Added LEQ keyword: J.A.P., B.S.I., November 27, 2010
;-
function neighbor_deltas, n, k, leq = leq
  ;amount of different combinations of dimensions in which you can look
  ndirs = choose(n,k)
  
  ;all the different ways to choose which dimensions are negative
  nsubsets = 2^k
  
  ;product of these 2 numbers is the total number of ways too look
  dirs = intarr(n, ndirs*nsubsets)
  
  ;make an array containing the positive/negative choices
  negs = bmask_subsets(k)*2 - 1
  
  ;shuffle negs so opposing directions appear consecutively
  shuf = lindgen(nsubsets/2, 2)
  shuf[*,1] = reverse(shuf[*,1])
  shuf = reform(transpose(shuf),nsubsets)
  negs = negs[*,shuf]
  
  ;make an array holding the dimension choices
  dims = bmask_choose(n, k)
  
  ;fill the output array with all the different neg/pos choices
  ;for each dimensions choice
  for i=0, ndirs-1 do dirs[where(dims[*,i]), i*nsubsets:((i+1)*nsubsets - 1)] = negs
  
  if keyword_set(leq) && k gt 1 then begin
    while k gt 1 do dirs = [[dirs],[neighbor_deltas(n, --k)]]
  endif
  return, dirs
end