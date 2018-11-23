function [  ] = outlier_removal( ~ )
global pan_Image tube_Image skel_Image canal_Image PatientName GS_Image
[s1,s2,s3]=size(pan_Image);
canals=or(skel_Image,tube_Image);
% b1=ceil(s1/10); b2=ceil(s2/100); b3=ceil(s3/50);
b1=3;b2=5;b3=6;

%% Aggregating Skeletonisation & Circle Detection
% threshold1=.5*(2*b1+1)*(2*b2+1)*(2*b3+1);
threshold2=convn(ones(b1,b2,b3),ones(b1,b2,b3),'same');
threshold2=.01*sum(threshold2(:));
h=waitbar(0,'Removing Redundant Points...');
for indices = find(canals)'
    [i,j,k]=ind2sub(size(canals),indices);
    box_tube= tube_Image(max(1,i-b1):min(s1,i+b1), max(1,j-b2):min(s2,j+b2), max(1,k-b3):min(s3,k+b3)) ;
%     if sum(box_tube(:)) < threshold1
        box_skel= skel_Image(max(1,i-b1):min(s1,i+b1), max(1,j-b2):min(s2,j+b2), max(1,k-b3):min(s3,k+b3)) ;
        similarity_measure= convn(box_skel,box_tube,'same');
        similarity_measure=sum(similarity_measure(:));
        if similarity_measure < threshold2
            canals(i,j,k)=false;
            %waitbar(k / s3);
        end
%     end
end
close(h)
% canals=GS_Image;
%% Visualisation
slice_projections=permute(mat2gray(sum(pan_Image,1)),[3 2 1]);
canals_projection=permute(mat2gray(sum(canals,1)),[3 2 1]);
skel_projection=permute(mat2gray(sum(skel_Image,1)),[3 2 1]);
figure (3), clf
imshow(slice_projections)
hold all
%spy(canals_projection,'b')

%% Quadratic curve hypothesis
figure(3)
for error = [ 10 5 ]
    quadCurve=permute(mat2gray(sum(canals,1)),[3 2 1]);
    % spy(quadCurve,'y')
    [yy,xx]=find(quadCurve);
    
    % Set up fittype and options.
%     ft = fittype( 'poly2' );
%     ft = fittype( 'a*x^4+b*x^3+c*x+d', 'independent', 'x', 'dependent', 'y' );
    ft = fittype( 'poly4' );
    opts = fitoptions( 'Method', 'LinearLeastSquares' );
    opts.Normalize = 'on';
    opts.Robust = 'LAR';
    opts.Lower = [-60 -20 -10 -10 0];
    opts.Upper = [-30 20 10 10 Inf];
    
    % Fit model to data.
    [fitresult, gof, output] = fit( xx, yy, ft, opts )
    plot(fitresult);
    indices=find(abs(output.residuals)> error );
    canals(:,xx(indices),yy(indices))=false;
    legend('off')
    
    % Recover Removed Skeleton Points
    point_recovery=xor(skel_Image,canals);
    for cc=1: size(point_recovery,1)
      [y_skel,x_skel]=find(permute(point_recovery(cc,:,:),[3 2 1]));  
      yeval=feval(fitresult,x_skel);
      indices=find(abs(yeval-y_skel) >  error);
      point_recovery(cc,x_skel(indices), y_skel(indices))=false;
    end
    canals(point_recovery)=true;
%     indices=find(abs(output.residuals)> error );    
end
%%
canal_Image=canals;
spy(permute(mat2gray(sum(skel_Image,1)),[3 2 1]),'y')
spy(permute(mat2gray(sum(tube_Image,1)),[3 2 1]),'r')
spy(permute(mat2gray(sum(canal_Image,1)),[3 2 1]),'g')
xlabel('')
title(PatientName)
% savefig('result')
end