function z = doppellaplaceQuadr(x,y)
   z = 18800*x^4*y^4 + 75200*x^3*y^4*(2*x - 2) + 112800*x^2*y^4*(x - 1)^2 + 338400*x^4*y^2*(x - 1)^2 + 75200*x^4*y^3*(2*y - 2) + 338400*x^2*y^4*(y - 1)^2 + 112800*x^4*y^2*(y - 1)^2 + 56400*x^4*(x - 1)^2*(y - 1)^2 + 56400*y^4*(x - 1)^2*(y - 1)^2 + 225600*x*y^4*(2*x - 2)*(y - 1)^2 + 225600*x^4*y*(2*y - 2)*(x - 1)^2 + 300800*x^3*y^3*(2*x - 2)*(2*y - 2) + 451200*x^2*y^3*(2*y - 2)*(x - 1)^2 + 451200*x^3*y^2*(2*x - 2)*(y - 1)^2 + 676800*x^2*y^2*(x - 1)^2*(y - 1)^2;
end