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


clc, clear all, close all

% cd '/Users/ehsanelhamifar/Documents/MatlabCode/Hopkins155/';
% addpath '/Users/ehsanelhamifar/Documents/MatlabCode/SSC_motion_face/';

addpath ../common_useage
addpath '../CodeLSA/';
addpath ../CodeLSA/helper_functions/


maxNumGroup = 5;
for i = 1:maxNumGroup
    num(i) = 0;
end

datadir = 'N:\workspace\sub_segmentation\SSC_LRR_Experiment\Hopkins155';
seqs = dir(datadir);
seq3 = seqs(3:end);
%% load the data
data = struct('X',{},'name',{},'ids',{});
for i=1:length(seq3)
    fname = seq3(i).name;
    fdir = [datadir '/' fname];
    if isdir(fdir)
        datai = load([fdir '/' fname '_truth.mat']);
        id = length(data)+1;
        data(id).ids = datai.s;
        data(id).name = lower(fname);
        X = reshape(permute(datai.x(1:2,:,:),[1 3 2]),2*datai.frames,datai.points);
        %data(id).X = [X;ones(1,size(X,2))];
        data(id).X = X;
    end
end

for i = 1:length(data)%
    X = data(i).X;
    gnd = data(i).ids; n = max(gnd);
    
    tic;
    tstart = tic;
    kNeigh = 8;    
    k = 4;
    kappa = 2e-7;kappa2 = 0.1;
    [U,S,V] = svd(X',0);
    WW1 = cnormalize(U(:,1:max(modelselection(diag(S),kappa),2))');
    distance = lsa(WW1,n,kNeigh,k,kappa2);
    time1{n}(num(n)+1) = toc(tstart);
    spectralalg = 'kmeans';
    switch(spectralalg)
        case 'kmeans'
            [diagMat,LMat,XX,Y,group,errorsum]=spectralcluster(distance,n,n);
        case 'normalcuts'
            group=spectralclusternormalcut_recursive(n,distance);
    end
    time2{n}(num(n)+1) = toc(tstart);
    missrate1 = Misclassification(group,gnd);    
    
    
    tic;
    tstart = tic;
    r = 4*n;
    Xp = DataProjection(X,r);
    [U,S,V] = svd(Xp',0);
    WW1 = cnormalize(U(:,1:r)');
    distance = lsa(WW1,n,kNeigh,k,0);
    time3{n}(num(n)+1) = toc(tstart);
    spectralalg = 'kmeans';
    switch(spectralalg)
        case 'kmeans'
            [diagMat,LMat,X,Y,group,errorsum]=spectralcluster(distance,n,n);
        case 'normalcuts'
            group=spectralclusternormalcut_recursive(n,distance);
    end
    time4{n}(num(n)+1) = toc(tstart);
    missrate2 = Misclassification(group,gnd);
    
    num(n) = num(n) + 1;
    missrateTot1{n}(num(n)) = missrate1
    missrateTot2{n}(num(n)) = missrate2
end

L = [2 3];
for i = 1:length(L)
    j = L(i);
    avgmissrate1(j) = mean(missrateTot1{j});
    medmissrate1(j) = median(missrateTot1{j});
    avgmissrate2(j) = mean(missrateTot2{j});
    medmissrate2(j) = median(missrateTot2{j});
    avgtime1(j) = mean(time1{j});
    avgtime2(j) = mean(time2{j});
    avgtime3(j) = mean(time3{j});
    avgtime4(j) = mean(time4{j});
end
avgmissrate1(2)
medmissrate1(2)
avgmissrate1(3)
medmissrate1(3)
avgmissrate2(2)
medmissrate2(2)
avgmissrate2(3)
medmissrate2(3)

avgmissrate1_1 = (sum(missrateTot1{2})+sum(missrateTot1{3}))/155
avgmissrate2_1 = (sum(missrateTot2{2})+sum(missrateTot2{3}))/155
medmissrate1_1 = median([missrateTot1{2},missrateTot1{3}])
medmissrate2_1 = median([missrateTot2{2},missrateTot2{3}])
time1_1 = (sum(time1{2})+sum(time1{3}))/155
time2_1 = (sum(time2{2})+sum(time2{3}))/155
time3_1 = (sum(time3{2})+sum(time3{3}))/155
time4_1 = (sum(time4{2})+sum(time4{3}))/155
save LSA_MS.mat missrateTot1 avgmissrate1 medmissrate1 missrateTot2 avgmissrate2 medmissrate2 time1 time2 time3 time4 avgtime1 avgtime2 avgtime3 avgtime4 avgmissrate1_1 avgmissrate2_1 medmissrate1_1 medmissrate2_1 time1_1 time2_1 time3_1 time4_1


