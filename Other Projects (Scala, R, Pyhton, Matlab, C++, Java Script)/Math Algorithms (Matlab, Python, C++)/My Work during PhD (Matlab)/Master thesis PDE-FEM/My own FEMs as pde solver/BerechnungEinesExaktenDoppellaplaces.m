clear

syms x
syms y

f = exp(-1 / (1 - 4 * (x^2 + y^2)));

lapl = diff(f,x,x)+diff(f,y,y)
lapl = simplify(lapl)

lapllapl = diff(lapl,x,x)+diff(lapl,y,y)
lapllapl = simplify(lapllapl)