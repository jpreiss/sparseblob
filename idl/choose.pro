;+
; NAME:
;     CHOOSE
;
; PURPOSE:
;     Calculate N choose K: the number of distinct subsets of size K in an
;     N-set.  Also, the coefficient of a^k in (a + b)^n, or the Kth entry
;     in the Nth row of Pascal's triangle, or...
; 
; CATEGORY:
;     Mathematics - Combinatorial.
;
; INPUTS:
;     N, K: explained above.  N and K are converted to integers.
;     
; OUTPUTS:
;     A ULong64 with the value of N choose K.
;
; MODIFICATION HISTORY:
;     Written by James Preiss, Barlow Scientific Inc., July-August 2010.
;-
function choose, n, k

  ;check validity of arguments.
  if k lt 0 or n lt 0 then message, "N and K must be nonnegative."
  
  ;truncate to integers.  The Choose function is only defined for integers.
  k = fix(k)
  n = fix(n)
  
  ;use common block lookup tables for CHOOSE and FACTORIAL.  The idea is, we
  ;strictly want integer output from this function.  Unfortunately, when we use
  ;factorial to calculate the value of N choose K, even a UL64
  ;overflows for N! when N > 20.  However, the value of C(N,K) is many orders
  ;of magnitude smaller than N! for large N.  So, we use a recursive definition
  ;C(n,k) = (n/k)*C(n-1,k-1).  This lets us avoid calculating the factorial
  ;directly except for numbers LE 20, so we keep integer accuracy.  A 2D table
  ;with memoization is used for storing values of C(N,K), and a 1D lookup table
  ;is used for factorial values.  Additionally, the output is very fast
  ;if CHOOSE is called many times in a program with the same arguments.
  
  ;make common blocks if they have not been defined already
  common commonChoose, chooseMemo, facTable
  if n_elements(chooseMemo) lt 1 then chooseMemo = replicate(-1ll, 30, 30)
  if n_elements(facTable) lt 1 then facTable = factorial(indgen(21), /ul64)
  
  ;increase the size of the CHOOSE memoization table if needed
  szvec = size(chooseMemo)
  if n ge szvec[1] then chooseMemo = [chooseMemo, make_array(value=-1ll, size=szvec)]
  szvec = size(chooseMemo)
  if k ge szvec[2] then chooseMemo = [[chooseMemo], [make_array(value=-1ll, size=szvec)]]
  
  ;check the memoization table and return its value if available
  if chooseMemo[n,k] ne -1 then return, chooseMemo[n,k]
  
  ;if the memoization table is empty, we need to actually calculate the value
  case k of
    ;keep it simple for the simplest cases
    0: out = 1
    1: out = n
    else: begin
      ;check for another simple case
      if n eq 0 then begin
        out = 0
      ;if N is big, we can't hold N!, so use the recursive definition
      endif else if n gt 20 then begin
        out = ulong64((double(n)/k)*choose(n-1,k-1))
      ;otherwise, use the factorial LUT
      endif else begin
        out = factable[n]/(factable[k]*factable[n-k])
      endelse
    end
  endcase
  ;memoize the answer before returning
  chooseMemo[n,k] = out
  return, out
end