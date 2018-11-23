function teeth_mask=teeth_removal
global pan_Image
[s1 ,s2 ,s3]= size(pan_Image);
slice_projections=permute(mat2gray(sum(pan_Image,1)),[3 2 1]);
thickness=40;
ribbons=[];
fh3=figure('WindowScrollWheelFcn',@scroll_wheel); clf
sh_ribbon = uicontrol(fh3,'Style','slider',...
    'Position',[35 10 10 400],...
    'Callback',@show_ribbons);
bh = uicontrol(fh3,'Position',[275 20 50 20],...
    'String','Remove Teeth',...
    'Callback',@apply_ribbon);
rib_ax=axes('Parent',fh3,'Position', [0.1 .1 .8 .8]);
set(fh3,'CurrentAxes',rib_ax)
imshow(slice_projections);
set([fh3,rib_ax,sh_ribbon,bh],'Units','normalized');
maxfig(fh3,1);

for c= [0: s3/30: s3/6]
    for p1 =  [-0.002: -0.0001 :-0.003]
        p2= (-p1*s2);        
        x=1:s2;
        y= round(polyval([p1 p2 c],x));
        intercept=repmat([-thickness:thickness]',1,s2);
        y=repmat(y,2*thickness+1,1);
        x=repmat(x,2*thickness+1,1);
        y=y+intercept;
        %
        x(or(y>s3 , y<1))=[]; y(or(y>s3 , y<1))=[];        
        if ~isempty(y)
            ribbons(end+1,:)=[p1 p2 c];
        end
    end
end
%%
% ribbons=sortrows(ribbons,1);
x=1:s2;
set(sh_ribbon,'Max',size(ribbons,1),'Min',1,'Value',1)%,'Visible','on')
waitfor(fh3)
    function show_ribbons(~,~)
        set(fh3,'CurrentAxes',rib_ax)
        current_ribbon=ceil(get(sh_ribbon,'Value'));
        p1=ribbons(current_ribbon,1);p2=ribbons(current_ribbon,2); c=ribbons(current_ribbon,3);
        y= round(polyval([p1 p2 c],x));
        imshow(slice_projections); hold on
        plot(x,y,'b.')
    end
    function apply_ribbon(~,~)
        current_ribbon=ceil(get(sh_ribbon,'Value'));
        p1=ribbons(current_ribbon,1);p2=ribbons(current_ribbon,2); c=ribbons(current_ribbon,3);
        y= round(polyval([p1 p2 c],x));
        y=min(s3,y);
        teeth_mask=ones(size(slice_projections));
        for i =1: s2
            teeth_mask(1:y(i),i)=0;
        end
        imshow(teeth_mask.*slice_projections)
        disp(['teeth removal results:' num2str([p1 p2 c])])
        pause(.1)
        close (fh3)
    end
    function scroll_wheel(~,eventData)
        current_value=ceil(get(sh_ribbon,'Value'));
        set(sh_ribbon,'Value',min(max(1,current_value-eventData.VerticalScrollCount),size(ribbons,1)));
        show_ribbons;
    end
end