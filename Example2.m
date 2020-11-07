clear all,clc,close all
addpath(genpath(pwd))

alpha = 0.05; % signifcance level of independence test
maxFanIn=2; % maximum number of conditional variables
cond_ind_test='indtest_new_t';
Width = 20; %hyperparamter for infer_nonsta_dir

% This is for tractionseparation problem, select the 5 known variables for
% recovery test
T = readtable('History_TractionSeparation.csv'); % read the datset under this directory
X = T(:,[1 3:11]); %remove the column number not needed
% REMEMBER TO PUT THE INPUT VARIABLE AS THE FIRST! DLABEL{1} SHOULD
% ALWAYS BE YOUR INPUT
% dlabel: In the case with multi-dimensional variables, 
% we use dlable to indicat the index of the dimension of each variable,
for i = 1:50
    if i == 1  %since the poro is a constant vector, we have to delete it first
       dlabel{1} = [2]; dlabel{2} = [3,4]; dlabel{3} =[6];
       dlabel{4} =[7,8,9];

    elseif i == 2
       dlabel{1} = [1];dlabel{2} = [3,4]; dlabel{3} = [5]; dlabel{4} =[6];
       dlabel{5} = [7,8,9];

    else
        dlabel{1} = [1,2];dlabel{2} = [3,4]; dlabel{3} = [5]; dlabel{4} =[6];
        dlabel{5} =[7,8,9];

    end
    rows = X.xCase == i-1;
    data = X(rows,:);
    data = data{:,2:10};
   try
    [gns, g,SP] = nonsta(data,dlabel,cond_ind_test,maxFanIn,alpha,Width); % run main function
   catch 
        fileID = fopen('missed_cases.txt','at');
        fprintf(fileID, "Miss the case: %d, try to change the hyperparameter\n",i);
        fclose(fileID);
        continue;
   end
  writematrix(gns, sprintf('traction_graph_%d.csv',i));
end

% The output from the above code generates 50 causal graphs from 50 training experiments. To reproduce the final causal graph with edge inclusion probabilties (Figure 2 of the manuscript), the readers need to run the generate_causal_graph.ipynb in Python. 
