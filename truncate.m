function  [volume_o,ymin,ymax,xmin,xmax,zmin,zmax] = truncate( volume_i , dname )
volume_o = volume_i;
[m n p]= size(volume_o);
xf=[1;n];xa=[1;n]; ya=[1;m]; ys=[1;m]; zf=[1;p];zs=[1;p];

fh= figure('Visible','on','Name',['Truncate planes, ' dname]); % figure handle

fro=sum(volume_o,1)/2^16/m;fro=permute(fro,[ 2 3 1]);
h(1)=subplot(131);
imshow(fro,[])
title('frontal')

sag=sum(volume_o,2)/2^16/n;sag=permute(sag,[ 1 3 2]);
h(2)=subplot(132);
imshow(sag,[]),
title('sagittal')

axi=sum(volume_o,3)/2^16/p;
h(3)=subplot(133);
imshow(axi,[]),
title('axial')

bh(1) = uicontrol(fh,'Position',[105 80 50 20],...
    'String','Truncate',...
    'Callback',@trun_front);
bh(2) = uicontrol(fh,'Position',[270 80 50 20],...
    'String','Truncate',...
    'Callback',@trun_sagitt);
bh(3) = uicontrol(fh,'Position',[430 80 50 20],...
    'String','Truncate',...
    'Callback',@trun_axi);

bh(4) = uicontrol(fh,'Position',[295 30 35 20],...
    'String','Done!',...
    'Callback',@done);

bh(5) = uicontrol(fh,'Position',[260 30 35 20],...
    'String','Preview',...
    'Callback',@previews);

bh(6) = uicontrol(fh,'Position',[10 30 35 20],...
    'String','Reload',...
    'Callback',@reload);

th=uicontrol(fh, 'Style','text',...
        'Position',[190 350 200 10],...
        'String','Truncate at least two planes');

set([fh,bh,h,th],'Units','normalized');
maxfig(fh,1)    

    function reload(~,~)
        [m n p]= size(volume_i);
        xf=[1;n];xa=[1;n]; ya=[1;m]; ys=[1;m]; zf=[1;p];zs=[1;p];
        previews
    end

    function done(~,~)        
        previews
        disp(['Truncation results: ' num2str([ymin,ymax,xmin,xmax,zmin,zmax])])
        delete(fh)
    end

    function previews(~,~)
        if ~isempty([zf xf ys zs xa ya])
            xmin=ceil(min([xf(:);xa(:)]));xmax=floor(max([xf(:);xa(:)]));
            ymin=ceil(min([ys(:);ya(:)]));ymax=floor(max([ys(:);ya(:)]));
            zmin=ceil(min([zf(:);zs(:)]));zmax=floor(max([zf(:);zs(:)]));
            volume_o = volume_i(ymin:ymax,xmin:xmax,zmin:zmax);
        else
            error('');
        end
        [m n p]= size(volume_o);
        fro=sum(volume_o,1)/2^16/m;fro=permute(fro,[ 2 3 1]);
        subplot(131); hold off,axis equal
        imshow(fro,[]),title('frontal'), hold on
        
        sag=sum(volume_o,2)/2^16/n;sag=permute(sag,[ 1 3 2]);
        subplot(132);hold off,axis equal
        imshow(sag,[]),title('sagittal'),hold on
        
        axi=sum(volume_o,3)/2^16/p;
        subplot(133);hold off,axis equal
        imshow(axi,[]),title('axial'), hold on
    end

    function trun_front (~,~)
        subplot(131), hold on
        imshow(fro,[])
        for i = 1 : 2
            [zf(i),xf(i)] = ginput(1);
            plot(zf(i),xf(i),'mv');
        end
        rectangle('Position',[min(zf),min(xf),abs(diff(zf)),abs(diff(xf))])
        hold off
    end

    function trun_sagitt (~,~)
        subplot(132), hold on
        imshow(sag,[])
        for i = 1 : 2
            [zs(i) , ys(i)] = ginput(1);
            plot(zs(i),ys(i),'mv');
        end
        rectangle('Position',[min(zs),min(ys),abs(diff(zs)),abs(diff(ys))])
        hold off
    end

    function trun_axi (~,~)
        subplot(133), hold on
        imshow(axi,[])
        for i = 1 : 2
            [xa(i),ya(i)] = ginput(1);
            plot(xa(i),ya(i),'mv');
        end
        rectangle('Position',[min(xa),min(ya),abs(diff(xa)),abs(diff(ya))])
        hold off
    end
waitfor(fh);
end