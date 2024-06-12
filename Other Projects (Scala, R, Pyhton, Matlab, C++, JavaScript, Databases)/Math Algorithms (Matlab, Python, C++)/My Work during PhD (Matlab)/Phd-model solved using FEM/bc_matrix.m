function [BC,elim_cons] = bc_matrix(c4n,bc_type)
nC = size(c4n,1);
switch bc_type
    case 0
        elim_cons = [1 nC]; % Die Ableitungen sind am Rand fest: Müssen dort nich die Tangentialraumbedingung erfüllen.
        nr_BC = 8;
        I_BC = 1:8;
        J_BC = [1, 2, 2*nC-1, 2*nC, 2*nC+1, 2*nC+2, 4*nC-1, 4*nC];
        X_BC = ones(1,8);
end
% if bc_type == 0  
%     elim_cons = 1; nr_BC = 6;
%     I_BC = [1,2,3,1,2,3,4,5,6,4,5,6]; 
%     J_BC = [(0:2)*2*nC+1,(1:3)*2*nC-1,(0:2)*2*nC+2,(1:3)*2*nC];
%     X_BC = [1,1,1,-1,-1,-1,1,1,1,-1,-1,-1];
% elseif bc_type == 1 
%     elim_cons = 1; nr_BC = 6;
%     I_BC = 1:6; J_BC = [(0:2)*2*nC+1,(0:2)*2*nC+2];
%     X_BC = ones(1,6);
% elseif bc_type == 2 
%     elim_cons = 1; nr_BC = 9;
%     I_BC = 1:9; J_BC = [(0:2)*2*nC+1,(0:2)*2*nC+2,(1:3)*2*nC-1];
%     X_BC = ones(1,9);
% elseif bc_type == 3             
%     elim_cons = [1,nC]; nr_BC = 12;
%     I_BC = 1:12; J_BC = [(0:2)*2*nC+1,(0:2)*2*nC+2,(1:3)*2*nC-1,(1:3)*2*nC];
%     X_BC = ones(1,12);
% elseif bc_type == 4
%     elim_cons = []; nr_BC = 6;
%     I_BC = 1:6; J_BC = [(0:2)*2*nC+1,(1:3)*2*nC-1];
%     X_BC = ones(6,1);
% end
BC = sparse(I_BC,J_BC,X_BC,nr_BC,4*nC);
end