function distance_calc
global P_current_canal P_current_GS
maskC=zeros(size(P_current_canal));
maskG=zeros(size(P_current_GS));
[x,y]=ginput(2);
x=round(x);y=round(y);
rectangle('Position',[min(x),min(y),abs(diff(x)),abs(diff(y))])

maskC (min(y):max(y),min(x):max(x)) = 1;
maskG (min(y):max(y),min(x):max(x)) = 1;
P_current_GS=logical(P_current_GS .* maskG);
P_current_canal=logical(P_current_canal .* maskC);
hold on
spy(P_current_GS,25,'c');xlabel('')
spy(P_current_canal,25,'g');xlabel('')

coverage=100*sum(P_current_canal(:))/sum(P_current_GS(:))

Pc=sum(struct2array(regionprops(P_current_canal,'Perimeter')));
Pg=sum(struct2array(regionprops(P_current_GS,'Perimeter')));
coverage=100*Pc/Pg

distance=0;
[rowC,colC]=find(P_current_canal);
[rowG,colG]=find(P_current_GS);
for i=1:length(colC)    
    dist=abs(rowC(i)-mean(rowG(colC(i)==colG)));
    if ~isnan(dist), distance=distance+dist; end
end
distance=.25*distance/length(rowC);

h=msgbox({['Coverage (%) = ' num2str(coverage)]...
    ['Distance (mm) = ' num2str(distance)]});
end
