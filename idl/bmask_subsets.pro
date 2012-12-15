;+
; NAME:
;     BMASK_SUBSET
;
; PURPOSE:
;     Enumerate all the different subsets of a N-set in the form of a bit mask.
; 
; CATEGORY:
;     Mathematics - Combinatorial.
;
; INPUTS: 
;     N: the size of the set from which to take subsets.
;     
; OUTPUTS:
;     A 2D byte array of size N x 2^N.  Each N-column contains one
;     of the possible subsets.  For example, the bit mask [1,0,0,1,0]
;     means 'select elements 1 and 4 out of a 5-set.'
;     
; EXAMPLE:
;     print, bmask_subsets(3)
;     
;          1   1   1
;          0   1   
;          1   0   1
;          0   0   1
;          1   1   0
;          0   1   0
;          1   0   0
;          0   0   0
;
; MODIFICATION HISTORY:
;     Written by James Alan Preiss, Barlow Scientific, Inc., August 12, 2010
;-
function bmask_subsets, n
  on_error, 2
  ;mighty big array there cowboy!!!
  inds = rebin(transpose(ul64indgen(2ull^n)), [n, 2ull^n], /sample)
  mods = rebin(2ull^(indgen(n) + 1), [n, 2ull^n], /sample)
  return, (inds mod mods) lt mods/2
end