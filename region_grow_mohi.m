function current_canal= region_grow_mohi(curren_pan,current_mask)
image=curren_pan;
image_initial=image;
mask=current_mask;

image=medfilt2(image);
image= imfilter(image,fspecial('gaussian'));
for cnt=1:2
    image=adapthisteq(image);
end
image=imfilter(image,fspecial('disk',3));

h=fspecial('average');
SE = strel('diamond', 5) ;
% h=fliplr(tril(fliplr(h)));
%h=ones(2,2)/4;
iter =1;
oldmask=zeros(size(mask));
while (iter<50) && any(mask(:) ~= oldmask(:))
    oldmask=mask;
    temp=imfilter(double(mask),h);
    index=find(temp~=0 & temp~=1);
    %     threshold=imfilter(im.*mask,ones(5,5)/25);
    %     threshold=median(image(mask==1));
    %     mask_OUT=imdilate(mask==1,SE)-mask==1;
    %     threshold_OUT=median(image(mask_OUT==1));
    %     for ind=index
    %         [I,J]=ind2sub(size(mask),index);
    %         threshold=mean(mean(image(I-2:I+2, J-2:J+2)));
    threshold=mean(image(mask==1));
    index=index(image(index)<1.2*threshold  &  image(index)>.8*threshold);
    mask(index)=true;
    %     end
    
    cla reset
    imshow(image)
    hold on
    spy(mask,1,'c'),xlabel('')
    shg
    drawnow
    iter=iter+1;
end

imshow(image_initial)
% mask=imfilter(mask,fspecial('disk',2));
% Fill holes
mask = imfill(mask, 'holes');
current_canal=mask;
end