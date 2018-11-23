function tube_Image=circle_detection(pan_Image)
warning ('OFF','all')
s2=size(pan_Image,2);
tube_Image=false(size(pan_Image));
% h=waitbar(1 / s2,'Finding Circles...');
for cc = [1:s2] %: fix(s2/3) fix(2*s2/3)
%     waitbar(cc / s2,h);
    current_cross=permute(pan_Image(:,cc,:),[3 1 2]);
    current_cross=adapthisteq(current_cross);
    current_cross=imfilter(current_cross,fspecial('disk',3));
    current_cross=medfilt2(current_cross);
    %             current_c_skel=permute(skel_Image(:,cc,:),[3 1 2]);
    %             current_c_skel=imdilate(current_c_skel,strel('disk',8));
    %             current_cross=current_cross.*current_c_skel;
    %     set(sh_cross,'Value',cc);
    [centers] = imfindcircles(current_cross,[2 5],...
        'ObjectPolarity','dark','Sensitivity',.70,'Method','TwoStage','EdgeThreshold',.05);
    centers=round(centers);
    if ~isempty(centers)
        for ccc=1:size(centers,1)
            tube_Image(centers(ccc,1),cc,centers(ccc,2))=true;
        end
    end
end
% close(h)
end