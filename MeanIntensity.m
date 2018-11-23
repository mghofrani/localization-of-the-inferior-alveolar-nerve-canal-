function m=MeanIntensity(label,im,width)
SE = strel('square', width);
label=imdilate(label,SE);
m=regionprops(label,im,'MeanIntensity');
m=m.MeanIntensity;
end