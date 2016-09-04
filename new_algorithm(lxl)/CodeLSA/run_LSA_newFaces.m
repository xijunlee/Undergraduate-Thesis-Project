%--------------------------------------------------------------------------
% This is the main function to run the SSC algorithm for the face 
% clustering problem on the Extended Yale B dataset.
% avgmissrate: the n-th element contains the average clustering error for 
% n subjects
% medmissrate: the n-th element contains the median clustering error for 
% n subjects
% nSet: the set of the different number of subjects to run the algorithm on
%--------------------------------------------------------------------------
% Copyright @ Ehsan Elhamifar, 2012
%--------------------------------------------------------------------------

clear all, close all

addpath ../data
addpath ../common_useage
addpath helper_functions

data = loadmatfile('yaleb10.mat');
Y = data.X;

%This X is a 2016*640 matrix containing 640 images. A total of 10 class
%each having 64 images.
%The size of the image is shrinked by 3 times into width=42, height=48
%The following three lines display the first image of the dataset.
%img=X(:,1);
%pp=reshape(img,[48,42,1]);
%imshow(pp)
%

gnd = data.cids;% 1*640
%K = max(gnd); % k group


nSet = [2 3 5 8 10];%[2 3 5 8 10];%
%nSet = 3;
missrateTot = zeros(1,length(nSet));
for i = 1:length(nSet)
    i
    n = nSet(i);    
    X = [];
    X = [X Y(:,1:n*64)];
    [DD,N] = size(X);
    y = gnd(1,1:n*64);
    y = y';
       
%         
%         maxValue = max(max(X));
%         D = X/maxValue;  % Scale the features (pixel values) to [0,1]
%         clear X 
        
        kNeigh = 7; k = 3;
        tic
        tstart = tic;       
        distance = lsa(X,n,kNeigh,k);       
        time1(i) = toc(tstart);
        
        spectralalg = 'kmeans';
        switch(spectralalg)
            case 'kmeans'
                [diagMat,LMat,XX,YY,group,errorsum]=spectralcluster(distance,n,n);
            case 'normalcuts'
                group=spectralclusternormalcut_recursive(n,distance);
        end
        time2(i) = toc(tstart);        

        missrateTot(i) = Misclassification(group,y)             
end

save LSA_Faces.mat missrateTot time1 time2 kNeigh k
missrateTot 
time1 
time2
