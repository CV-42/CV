import numpy as np 

def test(A, uebertrag, n_plus_ges):
    n_ges = sum(A)
    ziffer = 9 - (len(A) - 1)
    n_minus_ges = n_ges - n_plus_ges
    
    res = False
    for n_plus in range(max(A[0] - n_minus_ges, 0), min(n_plus_ges + 1, A[0] + 1)):
        n_minus = A[0] - n_plus
        beitrag = ((n_plus % 11) * ziffer - (n_minus % 11) * ziffer) % 11
        if len(A) == 1:
            alt_q_sum = (uebertrag + beitrag) % 11
            if alt_q_sum == 0:
                res = True
        elif test(A[1:], (uebertrag + beitrag) % 11, n_plus_ges - n_plus):
            res = True
        if res == True:
            break
    return res