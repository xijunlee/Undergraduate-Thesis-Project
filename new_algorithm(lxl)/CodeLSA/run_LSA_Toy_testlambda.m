
clear all, close all

addpath ../data     
addpath ../common_useage  % common .m files
addpath helper_functions

corrupt_rate = 0.1;
cc = length(corrupt_rate);
time1 = zeros(1,cc);
time2 = zeros(1,cc);
missrate = zeros(1,cc);
Noiselever = 0.3; % noise level
kNeigh = [3 4 5 6 7 8 9 10 11 12 13 14 15];
re = 5;

%produce data
d = 200; % dimension of data
r = 5;   % intrinsic dimension of each subspace
vector_num = 200;  % number of each subspace
s = 3;   % number of subspaces

dd = 8;

for i = 1 : length(kNeigh)
    kNeigh(i)
    
    timee1 = zeros(1,re);
    timee2 = zeros(1,re);
    missratee = zeros(1,re);
    for j = 1 : re
        j
        
        [X, RefGrps] = GenToyData(d, r, vector_num, s);
        [NoiseData ] = AddNoise( X, corrupt_rate, Noiselever);
        
        tic;
        tstart = tic;
        distance = lsa(NoiseData,s,kNeigh(i),dd);        
        timee1(j) = toc(tstart);
        
        %spectral clustering
        spectralalg = 'kmeans';
        switch(spectralalg)
            case 'kmeans'
                [diagMat,LMat,X,Y,group,errorsum]=spectralcluster(distance,s,s);
            case 'normalcuts'
                group=spectralclusternormalcut_recursive(s,distance);
        end        
        timee2(j) = toc(tstart);
        
        missratee(j) = Misclassification(group,RefGrps)        
    end    
    time1(i) = mean(timee1);
    time2(i) = mean(timee2);
    missrate(i) = mean(missratee)
end

[minmissrate, index] = min(missrate)
kNeigh(index)




