function z= testfunktion(x,y)
    nor = sqrt( x.^2 + y.^2 );
    hilf = nor >= 1/2;
    z = nor * 0;
    z(hilf==0) = exp(-1./(1-4*nor(hilf==0).^2));
end

