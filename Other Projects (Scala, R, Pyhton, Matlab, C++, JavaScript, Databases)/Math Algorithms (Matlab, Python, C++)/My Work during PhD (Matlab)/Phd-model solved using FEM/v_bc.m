function v_D = v_bc(t,c4n,bc_type)
% velocity vector nonzero at fixed boundary points
nC = size(c4n,1);
v_D = zeros(4*nC,1); 
if bc_type == 0
    %
elseif bc_type == 1
    %
elseif bc_type == 2
    %
elseif bc_type == 3
    v_D(2*nC-1) = -.1;
elseif bc_type == 4
    v_D(1) = .1; v_D(4*nC-1) = -.1;
end    