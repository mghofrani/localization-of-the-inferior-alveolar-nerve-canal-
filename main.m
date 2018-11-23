function main()
clc
clear
close all
imtool close all
global pan_Image tube_Image skel_Image canal_Image P_current_pan P_current_cross P_current_tube P_current_canal P_current_GS PatientName GS_Image
thickness=35;
nmask=20;
%% New or old Session 
choice = questdlg('Do you want a new session?', ...
	'Question', ...
	'Previous Session','New Session','New Session');
% Handle response
switch choice
    case 'Previous Session'
        disp([choice ' coming right up.'])
        newSession = false;
    case 'New Session'
        disp([choice ' coming right up.'])
        newSession = true;    
end
%% dicom import
dname = getFolder;
dicoms = dir ([dname '\*.dcm']);
str = {dicoms.name};
[m,n]= size(dicomread([dname '\' str{1}]));
p=length (str); %number of slices
volume_Image = zeros(m,n,p,'uint16');
tube_Image=[];
skel_Image=[];
canal_Image=[];
mask=[];
xys=[];
datainfo=dicominfo([dname '\' str{1}]);
PatientName=struct2array(datainfo.PatientName)
%% volume generation
h = waitbar(0,'Loading slices...');
for k = 1 : p
    volume_Image(:,:,k)=dicomread([dname '\' str{k}]);
    waitbar(k / (1.01*p))
end
if newSession
    [volume_Image,ymin,ymax,xmin,xmax,zmin,zmax] = truncate( volume_Image , dname );
else
    [FileName,PathName] = uigetfile('*.mat',['Select data info for ' PatientName]);
    gsinfo=load([PathName, FileName]);
    ymin=gsinfo.ymin; ymax=gsinfo.ymax; xmin=gsinfo.xmin; xmax=gsinfo.xmax; zmin=gsinfo.zmin;
    zmax=gsinfo.zmax; 
    xys=gsinfo.xys; thickness=gsinfo.thickness;
    volume_Image = volume_Image(ymin:ymax,xmin:xmax,zmin:zmax);    
end
volume_Image=mat2gray(volume_Image);
close (h)
[m,n,p]=size(volume_Image);
mark1=[]; mark2=[]; mark3=[];
pan_Image=[];
[s1,s2,s3]=size(pan_Image);

%% GUI
fh1= figure('Visible','on','Name',['Panoramics Generation ' 'for dataset: ' dname ' .:. ' PatientName],'Toolbar','figure');
axialh = axes('Parent',fh1,'Position', [0.1 .1 .8 .8]); imshow(volume_Image(:,:,end))
sh_axial = uicontrol(fh1,'Style','slider',...
    'Max',p,'Min',1,'Value',p,...
    'SliderStep',[1/(p-1) 1],...
    'Position',[50 10 10 400],...
    'Callback',@slider_callback_ax);
bh1 = uicontrol(fh1,'Position',[240 20 45 20],...
    'String','Generate Panoramic',...
    'Callback',@newpano_callback);
bh8 = uicontrol(fh1,'Position',[285 20 45 20],...
    'String','Save GS Info',...
    'Callback',@saveGSinfo);
set([fh1,sh_axial,axialh,bh1,bh8],'Units','normalized');
maxfig(fh1,1);

fh2= figure('Visible','off','Name',['Panoramic View ' 'for dataset: ' dname ' .:. ' PatientName],...
    'Toolbar','figure','WindowScrollWheelFcn',@scroll_wheel);
crossh= axes('Parent',fh2,'Position',[0.05 .1 .1 .8]);
panoramh= axes('Parent',fh2,'Position',[0.15 .1 .8 .8]);
sh_cross = uicontrol(fh2,'Style','slider',...
    'Position',[15 10 10 400],...
    'Callback',@slider_refresh);
sh_pano = uicontrol(fh2,'Style','slider',...
    'Max',thickness,'Min',1,'Value',1,...
    'SliderStep',[1/(thickness) 1],...
    'Position',[540 10 10 400],...
    'Callback',@slider_refresh);
sh_mask = uicontrol(fh2,'Style','slider',...
    'Max',nmask,'Min',1,'Value',1,...
    'SliderStep',[1/(nmask) 1],...
    'Position',[200 400 200 15],...
    'Callback', @show_mask);
bh2 = uicontrol(fh2,'Position',[thickness 5 40 20],...
    'String','Set Marker',...
    'Callback',{@marker_callback,2});
bh3 = uicontrol(fh2,'Position',[260 5 40 20],...
    'String','Set Marker',...
    'Callback',{@marker_callback,3});
bh4 = uicontrol(fh2,'Position',[300 5 40 20],...
    'String','Export&Apply',...
    'Callback',@export_to_Global);
bh5 = uicontrol(fh2,'Position',[400 400 30 15],...
    'String','Apply Mask',...
    'Callback',@apply_mask);
bh6 = uicontrol(fh2,'Position',[275 25 50 15],...
    'String','Traverse',...
    'Callback',@traverse);
bh7 = uicontrol(fh2,'Position',[thickness+40 5 40 20],...
    'String','Load GS',...
    'Callback',@loadGS);
bh9=uicontrol(fh2,'Position',[490 5 40 20],...
    'String','Save Results',...
    'Callback',@save_results);
bh10=uicontrol(fh2,'Position',[450 5 40 20],...
    'String','Load Results',...
    'Callback',@load_results);


%%
    function  slider_callback_ax(hObject,~)
        set(fh1,'CurrentAxes',axialh)
        cla reset
        imshow(volume_Image(:,:,ceil(get(hObject,'Value'))))% ,'Parent',axialh)
        title(['axial ' num2str(ceil(get(hObject,'Value'))) '/' num2str(p)])
    end

    function newpano_callback (~,~)
        set(fh1,'CurrentAxes',axialh)
        hold on
        if newSession, [xys] = base_curve ();end
        pan_Image=zeros(thickness+1,length(xys),p,'double');
        for d= -floor(thickness/2):ceil(thickness/2)
            [xysd] = curve_offset( xys,d ); % offset curve generation
            xysd=round(xysd);
            plot(xysd(1,:),xysd(2,:),'g.');drawnow
            for j = 1:p
                slice_temp = volume_Image(:,:,j);
                %                 pan_Image(sub2ind(size(pan_Image),d+1+floor(thickness/2)...
                %                    *ones(1,length(xysd)),1: length(xysd) ,j*ones(1,length(xysd))))...
                %                     =improfile(slice_temp,xysd(2,:),xysd(1,:),length(xysd));
                for ind= 1: length(xysd)
                    if xysd(1,ind)<n && xysd(2,ind)<m && xysd(1,ind)>0 && xysd(2,ind)>0
                        pan_Image(d+1+floor(thickness/2),ind,p-j+1) = slice_temp(xysd(2,ind),xysd(1,ind));
                    end
                end
            end
        end
        plot(xys(1,:),xys(2,:),'r.');
        pan_Image=mat2gray(pan_Image);
        tube_Image=false(size(pan_Image));
        skel_Image=false(size(pan_Image));
        canal_Image=false(size(pan_Image));
        GS_Image=false(size(pan_Image));
        [s1,s2,s3]=size(pan_Image);
        mask=zeros(s1,s2,s3);
        set(0,'CurrentFigure',fh2);
        set(sh_cross,'Max',s2,'Min',1,'Value',1,'SliderStep',[1/(s2-1) 1])
        set([fh2,sh_pano,sh_cross,sh_mask,panoramh,crossh,bh2,bh3,bh4,bh5,bh6,bh7,bh9,bh10],'Units','normalized');
        set(fh2,'Visible','on'),set(sh_mask,'Visible','on'),set(bh5,'Visible','on')
        maxfig(fh2,1)
        slider_refresh([],[]);
        mask_generation;
        waitfor(bh5,'Visible','off')
    end

    function traverse(~,~)        
        PAR_task=parpool(2,'AttachedFiles',{'skel_construction','circle_detection'})        
        tic
        PAR_pan=distributed(permute(pan_Image,[2 3 1]));        
        spmd
            PAR_skel=skel_construction(permute(getLocalPart(PAR_pan),[3 1 2]));            
        end        
        skel_Image=cat(1,PAR_skel{1},PAR_skel{2});%,PAR_skel{3},PAR_skel{4});

        PAR_pan=distributed(permute(pan_Image,[1 3 2]));
        spmd
            PAR_tube=circle_detection(permute(getLocalPart(PAR_pan),[1 3 2]));
        end
         tube_Image=cat(2,PAR_tube{1},PAR_tube{2});%,PAR_tube{3},PAR_tube{4});
        toc       
        
        delete(PAR_task)
        slider_refresh;
        outlier_removal;
        %canal_construction
    end

    function [current_pan,current_cross,current_tube,current_canal,current_GS]= slider_refresh(~,~)
        set(0,'CurrentFigure',fh2);
        panom_slider_value=ceil(get(sh_pano,'Value'));
        cross_slider_value=ceil(get(sh_cross,'Value'));
        set(fh2,'CurrentAxes',panoramh)
        hold off
        current_pan=permute(pan_Image(panom_slider_value,:,:),[3 2 1]);
        current_tube=permute(tube_Image(panom_slider_value,:,:),[3 2 1]);
        current_skel=permute(skel_Image(panom_slider_value,:,:),[3 2 1]);
        current_canal=permute(canal_Image(panom_slider_value,:,:),[3 2 1]);
        current_GS=permute(GS_Image(panom_slider_value,:,:),[3 2 1]);
        imshow(current_pan)
        hold on
%         spy(current_skel,7,'y.');xlabel('')
%         spy(current_tube,7,'r.');xlabel('')
        spy(current_GS,7,'c.');xlabel('')
        spy(current_canal,7,'g.');xlabel('')
        title(['Panoramic ' num2str(panom_slider_value) '/' num2str(thickness+1)])
        plot([cross_slider_value cross_slider_value],[1 s3],'LineStyle','-.','Color','c')
        
        set(fh2,'CurrentAxes',crossh)
        hold off
        current_cross=permute(pan_Image(:,cross_slider_value,:),[3 1 2]);
        current_c_tube=permute(tube_Image(:,cross_slider_value,:),[3 1 2]);
        current_c_canal=permute(canal_Image(:,cross_slider_value,:),[3 1 2]);
        title(['Cross ' num2str(cross_slider_value) '/' num2str(s2)])
        imshow(current_cross)
        hold on
        circle_plot(current_cross);        
        title(['xSection ' num2str(cross_slider_value) '/' num2str(s2)])
        spy(current_c_tube,7);xlabel('');
        spy(current_c_canal,7,'g.');xlabel('');
        plot([panom_slider_value panom_slider_value],[1 s3],'LineStyle','-.','Color','c')
    end

    function marker_callback(~,~,which_axes)
        button=2;
        while button>1
            switch which_axes
                case 2
                    [mark1,mark3,button] = ginput(1);
                    mark1=max(min(mark1,s1),1); mark3=max(min(mark3,s3),1);
                    mark2=get(sh_cross,'Value');
                    set(0,'CurrentFigure',fh2);
                    set(sh_pano,'Value',ceil(mark1));
                    slider_refresh([],[]);
                    plot(crossh,mark1,mark3,'ch','MarkerSize',10,'LineWidth',1);
                    plot(panoramh,mark2,mark3,'ms','MarkerSize',10,'LineWidth',1);
                case 3
                    [mark2,mark3,button] = ginput(1);
                    mark2=max(min(mark2,s2),1); mark3=max(min(mark3,s3),1);
                    mark1=get(sh_pano,'Value');
                    set(0,'CurrentFigure',fh2);
                    set(sh_cross,'Value',ceil(mark2));
                    slider_refresh([],[]);
                    plot(crossh,mark1,mark3,'ch','MarkerSize',10,'LineWidth',1);
                    plot(panoramh,mark2,mark3,'ms','MarkerSize',10,'LineWidth',1);
            end
        end
    end

    function export_to_Global(~,~)
        [current_pan,current_cross,current_tube,current_canal,current_GS]= slider_refresh();
        P_current_cross=current_cross;
        P_current_pan=current_pan;
        P_current_tube=current_tube;
        P_current_canal=current_canal;
        P_current_GS=current_GS;
        set(fh2,'CurrentAxes',panoramh)
        hold on
%         spy(P_current_canal,7,'g');xlabel('')
%         im_out=skel_out(P_current_pan);
%         spy(im_out,7,'b.');
%         P_current_canal=region_grow_mohi(P_current_pan,P_current_canal);
%         P_current_canal= segmentImage(P_current_pan,P_current_canal);
%         spy(P_current_canal,7);xlabel('')
%         spy(bwmorph(P_current_canal ,'skel',10),'m');
%         canal_construction
        distance_calc
    end
    function save_results(~,~)
        warning off;
        mkdir Results
        save (['Results\ResultsAuto_' PatientName],'canal_Image')
    end
    function load_results(~,~)                
        [FName,PName] = uigetfile('*.mat',['Select Saved Results Data for ' PatientName]);
        resultdata=load([PName, FName]);
        canal_Image=resultdata.canal_Image;
    end
    function saveGSinfo(~,~)
        warning off;
        mkdir info
        save(['info\info' PatientName],'ymin','ymax','xmin','xmax','zmin','zmax','xys','thickness','PatientName')
    end
    function loadGS(~,~)
        [FName,PName] = uigetfile('*.mat',['Select Gold Standard Data for ' PatientName]);
        gsdata=load([PName, FName]);
        GS_Image=gsdata.GS_Image;
    end
    function circle_plot(current_cross)      
        warning off;
        [centers, radii] = imfindcircles(current_cross,[2 5],...
            'ObjectPolarity','dark','Sensitivity',.70,'Method','TwoStage','EdgeThreshold',.05);
        centers=round(centers);
        viscircles(centers,radii,'LineWidth',1);
    end
    function mask_generation
        im=mat2gray(permute(sum(pan_Image,1),[3 2 1]));
        mask(1,:,:)=ones(size(im'));
        h=waitbar(1 / nmask,'Generating Masks...');
        for i=2:nmask
            last_mask=permute(mask(i-1,:,:), [3 2 1]);
            mask(i,:,:)=activecontour(im, last_mask, 50, 'Chan-Vese')';
            waitbar(i / nmask,h);
        end
        close(h)
    end
    function show_mask(hObject,~)
        im=mat2gray(permute(sum(pan_Image,1),[3 2 1]));
        mask_slider_value=ceil(get(hObject,'Value'));
        set(fh2,'CurrentAxes',panoramh);
        current_mask=permute(mask(mask_slider_value,:,:),[3 2 1]);
        imshow(current_mask.*im)
    end
    function apply_mask (~,~)
        teeth_mask=teeth_removal;
        h=waitbar(1 / nmask,'Removing Redundant Data...');
        mask= permute(mask(ceil(get(sh_mask,'Value')),:,:),[3 2 1])>0;
        mask=mask.*teeth_mask;
        for ii = 1 : s1
            pan_Image(ii,:,:)= (mask.* permute(pan_Image(ii,:,:),[3 2 1]))';
            waitbar(ii / nmask,h);
        end
        close(h)
        clear mask
        set(sh_mask,'Visible','off')
        set(bh5,'Visible','off')
    end
    function scroll_wheel(~,eventData)
        current_value=ceil(get(sh_pano,'Value'));
        set(sh_pano,'Value',min(max(1,current_value-eventData.VerticalScrollCount),thickness));
        slider_refresh;
    end
    function canal_construction
        h=waitbar(1 / s1,'Growing Seeds...');
        for cc = [1: s1]
            waitbar(cc / s1,h);
            current_pan=permute(pan_Image(cc,:,:),[3 2 1]);
            current_canal=permute(canal_Image(cc,:,:),[3 2 1]);
            canal_Image(cc,:,:)= region_grow_mohi(current_pan,current_canal)';
        end
        close(h)
        slider_refresh;
    end
end