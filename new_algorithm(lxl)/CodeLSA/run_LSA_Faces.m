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

load YaleBCrop025.mat

nSet = [2 3 5 8 10];%[2 3 5 8 10];%
nSet = 10;
for i = 1:length(nSet)
    i
    n = nSet(i);
    idx = Ind{n};   
    for j =1:min(40,size(idx,1))
        j
        X = [];
        for p = 1:n
            X = [X Y(:,:,idx(j,p))];
        end
        [DD,N] = size(X);        
       
%         for ii = 1:N
%             D(:,ii) = X(:,ii) ./ max(1e-12,norm(X(:,ii)));
%         end
%         clear X
        
        maxValue = max(max(X));
        D = X/maxValue;  % Scale the features (pixel values) to [0,1]
        clear X 
        
        kNeigh = 7; k = 5;
        tic
        tstart = tic;       
        distance = lsa(D,n,kNeigh,k);       
                
        spectralalg = 'kmeans';
        switch(spectralalg)
            case 'kmeans'
                [diagMat,LMat,XX,YY,group,errorsum]=spectralcluster(distance,n,n);
            case 'normalcuts'
                group=spectralclusternormalcut_recursive(n,distance);
        end
        time{n}(j) = toc(tstart);        

        missrateTot{n}(j) = Misclassification(group,s{n});
        missrateTot{n}(j)
        time{n}(j)
    end
    avgmissrate(n) = mean(missrateTot{n});
    avgtime(n) = mean(time{n});
    missrateTot{n}
    avgmissrate   
end

save LSA_Faces.mat missrateTot avgmissrate time avgtime
avgmissrate
avgtime
