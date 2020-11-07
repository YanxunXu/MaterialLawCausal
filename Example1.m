clear all,clc,close all
addpath(genpath(pwd))

alpha = 0.05; % signifcance level of independence test
maxFanIn=2; % maximum number of conditional variables
cond_ind_test='indtest_new_t';
Width = 30; %hyperparamter for infer_nonsta_dir

% The following code is to infer the causal graph from one experiment for learning % traction-separation law. 
T = readtable('History_TractionSeparation.csv'); % read the datset under this directory
X = T(:,[1 3:11]); %remove the column number not needed
% REMEMBER TO PUT THE INPUT VARIABLE AS THE FIRST! DLABEL{1} SHOULD
% ALWAYS BE YOUR INPUT
% dlabel: In the case with multi-dimensional variables, 
% we use dlable to indicat the index of the dimension of each variable.
dlabel{1} = [1,2];dlabel{2} = [3,4]; dlabel{3} = [5]; dlabel{4} =[6];
dlabel{5} =[7,8,9];
i = 8; %the 8th training experiment
rows = X.xCase == i-1;
data = X(rows,:);
data = data{:,2:10};
[gns, g,SP] = nonsta(data,dlabel,cond_ind_test,maxFanIn,alpha,Width); % run main function
gns;
