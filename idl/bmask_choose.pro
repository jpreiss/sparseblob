;+
; NAME:
;     BMASK_CHOOSE
;
; PURPOSE:
;     Enumerate all the different ways to choose K elements from an N-set.
;     Answer is given in the form of a bit mask array.
; 
; CATEGORY:
;     Mathematics - Combinatorial.
;
; INPUTS: 
;     N: the size of the set from which to choose.
;     
;     K: the number of elements to choose.
;     
; OUTPUTS:
;     A 2D byte array of size N x Choose(N, K).  Each N-row contains one
;     of the possible K-bit masks for selecting K elements of an N-set.
;     
; EXAMPLE:
;     print, bmask_choose(4,2)
;     
;       1   1   0   0
;       1   0   1   0
;       1   0   0   1
;       0   1   1   0
;       0   1   0   1
;       0   0   1   1 
;
; MODIFICATION HISTORY:
;     Written by James Alan Preiss, Barlow Scientific, Inc., August 10, 2010
;-
function bmask_choose, n, k

  ;check that arguments make sense
  if n lt 0 then message, "n must be nonnegative"
  if k lt 0 then message, "k must be nonnegative"
  if k gt n then message, "k must be <= n"
  
  ;make array for results
  out = bytarr(n, choose(n,k))
  
  ;answer base cases 
  if k eq 0 then return, out
  if n eq k then return, out + 1
  if k eq 1 then return, byte(identity(n))
  
  ;loop across, fill table with recursive calls
  start = 0
  for i=0, n-k do begin
    amt = choose(n-i-1, k-1)
    if amt gt 0 then out[i,start:start+amt-1] = 1
    if i+1 lt n then out[i+1,start] += bmask_choose(n-i-1, k-1)
    start += amt
  end
  return, out
end