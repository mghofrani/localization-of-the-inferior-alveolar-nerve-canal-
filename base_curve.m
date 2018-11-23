function [xys] = base_curve ()
hold on
% Initially, the list of points is empty.
% Loop, picking up the points.
% disp('Left mouse button picks points.')
% disp('Right mouse button picks last point.')
xy = [];
n = 0;
h=[];
but = 1;
while but == 1
    [xi,yi,but] = ginput(1);
    h(end+1)=plot(xi,yi,'mx');
    n = n+1;
    xy(:,n) = [xi;yi];
end

% delete (h);
k=convhull(xy(1,:), xy(2,:));
k(end)=[];
k=sort(k);
plot(xy(1,k),xy(2,k),'yo')
xy=xy(:,k);
n=length(xy);

steps=abs(diff(xy,1,2)); % first difference over columns
[steps,I]=max(steps);
xys=[];

for i = 1: n-1
    head=max(1,i);
    tail=min(n,i+1);
    switch I(i)
        case 1 % larger steps for x (rows)
            if xy(1,i) < xy(1,i+1)
                xi=xy(1,i) : 1 : xy(1,i+1);
            else
                xi=xy(1,i) : -1 : xy(1,i+1);
            end
            yi = pchip(xy(1, head:tail),xy(2, head:tail),xi);
        case 2 % larger steps for y (columns)
            if xy(2,i) < xy(2,i+1);
                yi=xy(2,i) : 1 : xy(2,i+1);
            else
                yi=xy(2,i) : -1 : xy(2,i+1);
            end
            xi=  pchip(xy(2, head:tail),xy(1, head:tail),yi);
    end
    xys=[xys [xi;yi]];
end

% xys=round(xys);
%% Smoothing the Points
ft = fittype( 'gauss4' );
%ft = fittype('a*x^2+b*x+c', 'independent', 'x', 'dependent', 'y' );
[fitresult] = fit( xys(1,:)', xys(2,:)', ft );
Xpath=xys(1,:);
Ypath=feval(fitresult,Xpath);
%plot(Xpath,Ypath,'b.');
xys=[Xpath;Ypath'];
xys=unique(xys','rows','stable')';
plot(xys(1,:),xys(2,:),'r.');