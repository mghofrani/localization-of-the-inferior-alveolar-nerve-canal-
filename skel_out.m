function im_out=skel_out(im_in)
% imtool close all
%% contrast enhancment
% im_in=im_in+edge(im_in,'canny');
im_in= imfilter(im_in,fspecial('gaussian'),'conv');
for cnt=1:2
    im_in=adapthisteq(im_in);
end
im_in=imfilter(im_in,fspecial('disk',3));
im_in=medfilt2(im_in);
size_im=size(im_in);

% im_in(im_in>graythresh(im_in))=.5*im_in(im_in>graythresh(im_in));
% imshow(im_in)
%% right bone
im_r=im_in(:,1:round(size_im(2)/2));
% im_r=tril(im_r);
%% left bone
im_l=im_in(:,end-round(size_im(2)/2):end);
% im_l=fliplr(tril(fliplr(im_l)));
%%
seg_imr = adaptivethresh(im_r, 20, 20, 'median', 'relative');% segmentation with adaptivethresholding
% seg_imr = im2bw(im_r,graythresh(im_r));
seg_imr = imfilter(seg_imr,ones(3,3)/3^2); % filtering to removimg speckles
%% segmentation (left)
seg_iml =  adaptivethresh(im_l, 20, 20, 'median', 'relative');% segmentation with adaptivethresholding
% seg_iml =  im2bw(im_l);
seg_iml = imfilter(seg_iml,ones(3,3)/3^2); % filtering to removimg speckles
% imtool(seg_imr)
%% skeletoning (right)
clean_r = bwmorph(1-double(seg_imr) ,'clean',inf);%Removes isolated pixels
skeleton_r = bwmorph(clean_r,'skel',10);%removes pixels on the boundaries of objects
spur_r = bwmorph(skeleton_r,'spur',10);%Removes spur pixels
clean2_r=bwmorph(spur_r ,'clean');%Removes isolated pixels
clean2_r(:,1:20)=0;
clean2_r(:,end-2:end)=0;
fill_r=imfill(clean2_r,'holes');
skel2_r=bwmorph(fill_r,'skel',10);
[Label_r,num_r]= bwlabel(skel2_r, 8);

for cnt1=1:num_r% num_r is the numbers of label_r
    l_r=(Label_r==cnt1);
    %     imtool(l_r)
    if sum(l_r(:)) >300 || sum(l_r(:))<10
        Label_r(l_r)=0;
        continue
    end
    if MeanIntensity(l_r,im_r,3)  < .1 || MeanIntensity(l_r,im_r,10)  > .4
        Label_r(l_r)=0;
        continue
    end
    R=radon(l_r);
    [M,slop_lab_r]= max(max(R));
    if  slop_lab_r < 15 || slop_lab_r > 90
        Label_r(l_r)=0;
    end
end
%% skeletoning (left)
clean_l = bwmorph(1-double(seg_iml) ,'clean',inf);%Removes isolated pixels
skeleton_l = bwmorph(clean_l ,'skel',10);%removes pixels on the boundaries of objects
spur_l = bwmorph(skeleton_l,'spur',10);%Removes spur pixels
clean2_l=bwmorph(spur_l ,'clean');%Removes isolated pixels
clean2_l(:,1:2)=0;
clean2_l(:,end-20:end)=0;
fill_l=imfill(clean2_l,'holes');
skel2_l=bwmorph(fill_l,'skel',10);
[Label_l,num_l]= bwlabel(skel2_l, 8);
for cnt2=1:num_l% num_r is the numbers of label_r
    
    l_l=(Label_l==cnt2);
    %     imtool(l_l)
    if sum(l_l(:)) >300 || sum(l_l(:))<10
        Label_l(l_l)=0;
        continue
    end
    if MeanIntensity(l_l,im_l,3) < .1 || MeanIntensity(l_l,im_l,10)  > .4
        Label_l(l_l)=0;
        continue
    end
    R=radon(l_l);
    [M,slop_lab_l]= max(max(R));
    if  slop_lab_l < 90  || slop_lab_l > 165
        Label_l(l_l)=0;
    end
end
%%
im_out=zeros(size(im_in));
im_out(1:size(Label_r,1),1:size(Label_r,2))=Label_r;
im_out(end-size(Label_l,1)+1:end,end-size(Label_l,2)+1:end)=Label_l;
end