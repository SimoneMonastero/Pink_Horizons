function [YI, sens, spec,thresh]=computeYoudenIndex(X,Y,T)
%X,Y must be a single column, as output of perfcurve or similar
%sens spec thresh related to optimal YI 

%sens+spec-1
%X,Y outputs of perfcurve or similar (AUC)

if size(X,2)>1 || size(Y,2)>1
    error('col vectors as input');
end
YI=-1;
for i=1:size(X,1)
    currYI=Y(i,1)+1-X(i,1)-1;
    
    if currYI>YI(1)
        YI=currYI;
        sens=Y(i);
        spec=1-X(i);
        thresh=T(i);
        
    end
end
