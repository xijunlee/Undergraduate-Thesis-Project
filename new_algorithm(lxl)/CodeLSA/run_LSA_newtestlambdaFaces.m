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

%nSet = [2 3 5 8 10];%[2 3 5 8 10];%
nSet = 2;
kNeigh = [3 4 5 6 7 8 9 10 11 12 13]; 
k = [3 4 5 6 7 8];
operr = zeros(length(kNeigh),length(k));

for i = 1:length(kNeigh)
    for j=1:length(k)
        n = nSet;
        X = [];
        X = [X Y(:,1:n*64)];
        [DD,N] = size(X);
        y = gnd(1,1:n*64);
        y = y';      
        
        distance = lsa(X,n,kNeigh(i),k(j));
        
        spectralalg = 'kmeans';
        switch(spectralalg)
            case 'kmeans'
                [diagMat,LMat,XX,YY,group,errorsum]=spectralcluster(distance,n,n);
            case 'normalcuts'
                group=spectralclusternormalcut_recursive(n,distance);
        end
        
        operr(i,j) = Misclassification(group,y)
    end
end
operr
