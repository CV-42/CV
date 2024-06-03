function [E, dE] = E_und_dE_von_2d_Funktional_p3Elem(f, c4n)
    ff = @(x,y,dy,ddy, n, dn) f(x,y,dy,ddy);
    [E, dE, ~] = E_und_dE_von_2d_Funktional_p3Elem_und_p1Elem(ff, c4n);
end