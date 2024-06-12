function [E, dEu, dEn, dEu_lin_coeff, dEn_lin_coeff] = E_und_dE_von_2d_Funktional_p3Elem_und_p1Elem(f, c4n, interpol)
    % wie E_und_dE_von_2d_Funktional_p3Elem aber mit Direktor:
    % EEu(u,m) gibt dann Ableitung nach u von \int_{c4n(1)}^{c4n(ende)} f(x, y(x),y'(x),y''(x),n(x),n'(x)) dx, als
    % Zeilenvektor bezüglich der Basis von p3-Funktionen mit
    % Knotenpunkten c4n.
    % EEn(u,n) das gleiche aber in Richtung n bzgl. Basis der
    % p1-Funktionen.
    % Dabei ist u die p3-Repräsentation von y. (u=[y(c4n(1)), y'(c4n(1),
    % ..., y'(c4n(ende))
    % Und m ist die p1-Repräsentation von n.
    % f ist eine Funktion von (y,y',y'',n,n'), wobei x\in\RR und y:\RR-->
    % \RR^2 und "n=n_hut'" : \RR --> \RR^2.
    % Es müssen u, m, c4n Spaltenvektoren sein.
    % Wenn interpol == true, dann werden Werte und erste Ableitungen der p3-Elemente
    % linear interpoliert
    % dEu_lin_coeff sind die Koeffizienten von dEu, mit denen u selbst
    % linear drin steht
    
    nC = length(c4n);
    
    syms u_x u_y [4 1] 'real';        % reelle Parameter der Werte und Ableitung links und rechts eines Intervalls (die Ableitungen sind noch nicht durch "...*1/h" zum Referenzelement umskaliert)
    syms n_x n_y [2 1] 'real';  % Parameter der Werte vom n_hut (d.h. bzgl. der Tangentialbasis von y)
    syms h 'real';              % Breite des Referenzelementes
    syms xi 'real';             % Linke Ecke des Referenzelementes
    syms x 'real';              % Variable für Referenzelement
    
    fak = [1 h 1 h; 1 h 1 h]';   % Faktoren für Ableitungen durch Integraltrafo zum Referenzelement
    uu = fak .* [u_x, u_y];
    y_ref = [1-3*x.^2+2*x.^3, x-2*x.^2+x.^3, 3*x.^2-2*x.^3, -x.^2+x.^3] * uu;
    y_ref = y_ref';
    n_ref = [1-x, x] * [n_x, n_y];
    n_ref = n_ref';
    
    dy_ref = diff(y_ref, x);
    ddy_ref = diff(dy_ref, x);
    dn_ref = diff(n_ref, x);
    
    if interpol
        dy_ref = [0, 1-x, 0, x] * uu;
        y_ref = [1-x, 0, x, 0] * uu;
    end
    
    f_ref = simplify(h * f(h*x+xi, y_ref, dy_ref / h, ddy_ref / h^2, n_ref, dn_ref / h));        % simplify scheint wichtig, damit das 'real' beachtet wird.
    e_elem = simplify(int(f_ref, x, 0, 1));               % Energie jetzt unabhängig von Referenzelement, deshalb ohne _ref, aber _elem für "einzelnes Element"
    de_u_elem = gradient(e_elem, [u_x; u_y])';
    de_n_elem = gradient(e_elem, [n_x; n_y])';
    de_elem = [de_u_elem, de_n_elem]; % size = [1 (4*2+2*2)]
    if any(size(de_elem) ~= [1 12])
        error("Size!!")
    end
    
    % Funktionale Darstellung von e:
    % kann vllt. (wie bei dEn, dEu) noch durch simplifys an den richtigen Stellen verschnellert
    % werden. (Damit nicht alle Vereinfachungen immer wieder ausgerechnet
    % werden müssen.    
    syms u_syms [4*nC 1] 'real'
    syms n_syms [2*nC 1] 'real'
    e = @(i) ...
        subs( ...
            subs( ...
                e_elem, ...
                [u_x; u_y; n_x; n_y], ...
                [u_syms(2*(i-1)+1 : 2*(i-1)+4); u_syms(2*(nC+i-1)+1 : 2*(nC+i-1)+4); n_syms(i:i+1); n_syms(nC+i:nC+i+1)]) ...
            , [xi, h], ...
            [c4n(i), c4n(i+1)-c4n(i)]);

    disp('A')
    % und jetzt e(i) zu E zusammenzählen:
    E_syms = sum( ...
                arrayfun(@(i) e(i) ...
                    , (1 : nC-1)' ...
                    ) ...
            );
    E_syms = simplify(E_syms);
    E = matlabFunction(E_syms, 'Vars', {u_syms;n_syms});

    % dEu berechnen:
    disp('B')
    dEu_syms = gradient(E_syms, u_syms)';
    dEu_syms = simplify(dEu_syms);
%     dEu = @(u, n) double(subs(dEu_syms, [u_syms;n_syms], [u;n]));
    dEu = matlabFunction(dEu_syms, 'Vars', {u_syms, n_syms});

    % dEn berechnen:
    disp('C')
    dEn_syms = gradient(E_syms, n_syms)';
    dEn_syms = simplify(dEn_syms);
    dEn = @(u, n) double(subs(dEn_syms, [u_syms;n_syms], [u;n]));

    % dEn_lin_coeff berechnen:
    tic;
    disp('D')
    % dauert ziemlich lange:
%     dEn_syms_lin_coeff = coeff_lin(dEn_syms, n_syms);
%     dEn_lin_coeff = @(u) double(subs(dEn_syms_lin_coeff, u_syms, u));
%     dEn_syms_nonlin = simplify(dEn_syms - n_syms' * dEn_syms_lin_coeff);
%     dEn_nonlin = @(u, n) double(subs(dEn_syms_nonlin, [u_syms; n_syms], [u;n]));
    % geht schneller:
    syms dEn_syms_lin_coeff [2*nC, 2*nC];
    dEn_syms_lin_coeff = 0 * dEn_syms_lin_coeff;
    g = coeff_lin(de_n_elem, [n_x; n_y]);
    int_2_n_ids = @(i) [i, i+1, i + nC, i+ 1 + nC];
    for i = 1:(nC-1)
        dEn_syms_lin_coeff(int_2_n_ids(i), int_2_n_ids(i)) = dEn_syms_lin_coeff(int_2_n_ids(i), int_2_n_ids(i)) + ...
            simplify( ...
                subs( ...
                    subs(g, [u_x; u_y; n_x; n_y], [u_syms(2*(i-1)+1 : 2*(i-1)+4); u_syms(2*(nC+i-1)+1 : 2*(nC+i-1)+4); n_syms(i:i+1); n_syms(nC+i:nC+i+1)]) ...
                    , [xi, h], [c4n(i), c4n(i+1)-c4n(i)]) ...
            );
    end
    dEn_syms_lin_coeff = simplify(dEn_syms_lin_coeff);
    dEn_lin_coeff = matlabFunction(dEn_syms_lin_coeff, 'Vars', {u_syms});
    toc;

    % dEu_lin_coeff berechnen:
    disp('C')
    tic;
    % dauert sehr lange:
%     dEu_syms_lin_coeff = coeff_lin(dEu_syms, u_syms);
%     dEu_lin_coeff = @(n) double(subs(dEu_syms_lin_coeff, n_syms, n));
    % geht schneller: (da coeff_lin nur einmal auf ein einzelnes
    % Referenzelement angewendet werden muss)
    syms dEu_syms_lin_coeff [4*nC, 4*nC];
    dEu_syms_lin_coeff = 0 * dEu_syms_lin_coeff;
    g = coeff_lin(de_u_elem, [u_x; u_y]);
    int_2_u_ids = @(i) [(2*i-1) : (2*i+2), (2*i-1+2*nC) : (2*i+2+2*nC)];
    for i = 1:(nC-1)
        dEu_syms_lin_coeff(int_2_u_ids(i), int_2_u_ids(i)) = dEu_syms_lin_coeff(int_2_u_ids(i), int_2_u_ids(i)) + ...
            simplify( ...
                subs( ...
                    subs(g, [u_x; u_y; n_x; n_y], [u_syms(2*(i-1)+1 : 2*(i-1)+4); u_syms(2*(nC+i-1)+1 : 2*(nC+i-1)+4); n_syms(i:i+1); n_syms(nC+i:nC+i+1)]) ...
                    , [xi, h], [c4n(i), c4n(i+1)-c4n(i)]) ...
            );
    end
    dEu_syms_lin_coeff = simplify(dEu_syms_lin_coeff);
    dEu_lin_coeff = matlabFunction(dEu_syms_lin_coeff, 'Vars', {n_syms});
    toc;

% alte Version, wo ich alle (auch die für E, dEu, dEn) Rechnungen auf die Referenzelemente runterziehen
% wollte. Hat aber zeitlich nicht so viel gebracht, auch wenn das richtige
% Rauskommt:

% %      "explizite" Scala/R/Matlab-Darstellung von EE (funktioniert in Matlab nicht??):
% %     EE = @(u){
% %      res = zeros(1, 4*nC);
% %       for i = 1 : nC-1
% %           de = subs(de_elem, u, 
% %           res(2*(i-1) + 1 : 2*(i-1) + 4) = res(2*(i-1) + 1 : 2*(i-1) + 4) +
% %               + subs(de_elem(1:4), [u_x; u_y; h], [u(2*(i-1)+1 : 2*(i-1)+4);
% %                                           u(2*(nC+i-1)+1: 2*(nC+i-1)+4);
% %                                           c4n(i+1)-c4n(i)])
% %           res(2*nC + 2*(i-1) + 1 : 2*nC + 2*(i-1) + 4) = res(2*(i-1) + 1 : 2*(i-1) + 4) +
% %               + subs(de_elem(5:8), [u_x; u_y; h], [u(2*(i-1)+1 : 2*(i-1)+4);
% %                                           u(2*(nC+i-1)+1: 2*(nC+i-1)+4);
% %                                           c4n(i+1)-c4n(i)])
% %       end
% %       res
% %     }
%     
% 
%     % funktionierende, "funktionale" Darstellung von EE:
%     % Und erstmal symbolisch, damit vorher Vereinfachungen gemacht werden
%     % können:
% %     syms u_syms [4*nC 1] 'real'
% %     syms n_syms [2*nC 1] 'real'
%     % Die Referenzwerte auf die einzelnen Elemente holen:
%     % Erst für Ableitung bzgl. "x-Richtungen" 
%     anwenden_u_x = @(i)...
%             simplify(...
%                 subs( ...
%                     subs(de_elem(1:4), [u_x; u_y; n_x; n_y], [u_syms(2*(i-1)+1 : 2*(i-1)+4); u_syms(2*(nC+i-1)+1 : 2*(nC+i-1)+4); n_syms(i:i+1); n_syms(nC+i:nC+i+1)]) ...
%                     , [xi, h], [c4n(i), c4n(i+1)-c4n(i)] ...
%                 ) ...
%             );
%     % Dann für Ableitung bzgl. "y-Richtungen"
%     anwenden_u_y = @(i) ...
%             simplify(...
%                 subs( ...
%                     subs(de_elem(5:8), [u_x; u_y; n_x; n_y], [u_syms(2*(i-1)+1 : 2*(i-1)+4); u_syms(2*(nC+i-1)+1 : 2*(nC+i-1)+4); n_syms(i:i+1); n_syms(nC+i:nC+i+1)]) ...
%                     , [xi, h], [c4n(i), c4n(i+1)-c4n(i)] ...
%                 ) ...          
%             );
%     % Jetzt einzelnen Element-Lösungen in die Reihe bzgl. aller Dofs
%     % einbetten:
%     einbetten_u = @(i) ...
%                     simplify( ...
%                     [ ...
%                         zeros(1, 2*(i-1)), ...
%                         anwenden_u_x(i) ...
%                         zeros(1, 2 * nC - 4), ...
%                         anwenden_u_y(i), ...
%                         zeros(1, 4*nC - (2*nC - 4 + 8 + 2*(i-1))) ...
%                     ] ...
%                     );
%     % Und jetzt alles zusammenzählen:
%     disp('A')
%     dEu_syms = ...
%         sum( ...
%             vpa( ...    % um aus cell-Array ein normales Array zu machen
%                 arrayfun(@(i) einbetten_u(i) ...
%                     , (1 : nC-1)' ...
%                     , 'UniformOutput', false ...
%                     ) ...
%                 ) ...
%             , 1 ...
%             );
%     disp('B')
%     dEu_syms = simplify(dEu_syms);
%     dEu = @(u, n) double(subs(dEu_syms, [u_syms; n_syms], [u;n]));
    

    
    %     
%     disp('D')
    % Das Gleiche jetzt nochmal für n:
%     anwenden_n_x = @(i) ...
%         simplify( ...
%         subs( ...
%             subs(de_elem(9:10), [u_x; u_y; n_x; n_y], [u_syms(2*(i-1)+1 : 2*(i-1)+4); u_syms(2*(nC+i-1)+1 : 2*(nC+i-1)+4); n_syms(i:i+1); n_syms(nC+i:nC+i+1)]) ...
%             , [xi, h], [c4n(i), c4n(i+1)-c4n(i)]) ...
%         );
%     anwenden_n_y = @(i) ...
%         simplify( ...
%         subs( ...
%             subs(de_elem(11:12), [u_x; u_y; n_x; n_y], [u_syms(2*(i-1)+1 : 2*(i-1)+4); u_syms(2*(nC+i-1)+1 : 2*(nC+i-1)+4); n_syms(i:i+1); n_syms(nC+i:nC+i+1)]) ...
%             , [xi, h], [c4n(i), c4n(i+1)-c4n(i)]) ...
%         );
%     einbetten_n = @(i) ...
%                     simplify( ...
%                     [ ...
%                         zeros(1, (i-1)), ...
%                         anwenden_n_x(i), ...
%                         zeros(1, nC - 2), ...
%                         anwenden_n_y(i), ...
%                         zeros(1, 2*nC - (i-1 + 2 + nC - 2 + 2)) ...
%                     ] ...
%                     );
%     dEn_syms = ...
%         sum( ...
%             vpa( ...
%                 arrayfun(@(i) einbetten_n(i) ...
%                     , (1 : nC-1)' ...
%                     , 'UniformOutput', false ...
%                     ) ...
%                 ) ...
%             , 1 ...
%             );
%     dEn_syms = simplify(dEn_syms);
%     dEn = @(u, n) double(subs(dEn_syms, [u_syms; n_syms], [u;n]));
       
end

function res =  coeff_lin(f, args)  % sollte noch sparse gemacht werden!? Geht nicht mit syms!
%     f = f(args) : R^n --> R^N
%     size(args) = [n 1]
    n = length(args);
    N = length(f);
    syms res [N n];
    for i = 1:N
        for j = 1:n
            res(i, j) = subs(diff(f(i),args(j)), args, zeros(n, 1));
        end
    end
end