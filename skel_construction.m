function skel_Image=skel_construction(pan_Image)
s1=size(pan_Image,1);
skel_Image=false(size(pan_Image));
% h=waitbar(1 / s1,'Constructing Skeletons...');
for cc = 1:s1
%     waitbar(cc / s1,h);
    current_pan=permute(pan_Image(cc,:,:),[3 2 1]);
    skel_Image(cc,:,:) = skel_out(current_pan)';
end
% close(h)
end