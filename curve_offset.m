function [ xysd ] = curve_offset( xys,d )
if d==0
    xysd=xys;
else
    for i = 1 : length(xys)-1
        m=(xys(2,i+1)-xys(2,i))/(xys(1,i+1)-xys(1,i));        
        if m == 0
            xysd(1,i)=xys(1,i);
            xysd(2,i)=xys(2,i)-d*sign((xys(1,i+1)-xys(1,i)));
        elseif abs(m) == Inf
            xysd(1,i)=xys(1,i)+d*sign((xys(2,i+1)-xys(2,i)));
            xysd(2,i)=xys(2,i);
        else
            xysd(1,i)=xys(1,i)+d*m/sqrt(1+m^2);
            xysd(2,i)=xys(2,i)-d/sqrt(1+m^2);
        end
    end
    xysd(:,end+1)=xysd(:,end);
end
% for i = 1 : length(xysd)
%     if isnan(xysd(1,i))  || isnan(xysd(2,i))
%         xysd(:,i)=0.5*(xysd(:,i-1)+xysd(:,i+1));
%     end
% end
% xysd=round(xysd);


