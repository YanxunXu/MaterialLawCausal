function [gns,g,SP] = nonsta(X,dlabel,cond_ind_test,maxFanIn,alpha,Width)

T = size(X,1); % number of samples

% t as an additional variables to capture nonstationarity; one may replace t with others, 
% such as conditions or domains
% t = [1:T]';
% X=[X,t]; 
X=X-repmat(mean(X),size(X,1),1);
X=X*diag(1./std(X));

n = length(dlabel);% number of variables
% dlabel{n} = size(X,2);

% construct complete (fully connected) graph
g = eye(n) - ones(n,n);

% witness set
witness = zeros(n,n,n);

pars.pairwise = false;
pars.bonferroni = false;
pars.width = 0;

count =0;
% find graph skeleton by CPC
for s=0:maxFanIn % iteratively increase size of conditioning set
    for i=1:n
        % nodes adjacent to i
        adjSet = find(g(i,:)~=0);
        if (length(adjSet)<=s)
            continue;
        end
        % test whether i ind j | s
        for j=adjSet
            % unconditional test
            
            if (s==0)
                p_val = feval(cond_ind_test, X(:,dlabel{i}), X(:,dlabel{j}), [], pars);
                count=count+1;
                SP{count}=strcat('i=', int2str(i),', j=',int2str(j),', pval=',num2str(p_val));
                if  p_val > alpha
                    fprintf('%d ind %d with p-value %d\n', i,j,p_val);
                    g(i,j)=0;
                    g(j,i)=0;
                else
                    fprintf('%d notind %d with p-value %d\n', i,j,p_val);
                end
                continue;
            end
            
            % conditional independence test
            middleNodes = adjSet(adjSet~=j);
            if (s == 2)
                p = AllPath(g,i,j);
                np = cellfun(@(x) unique(x(:)), p, 'UniformOutput' , false);
                npp = unique(cat(1, np{:}));
                middleNodes = setdiff(npp,[i,j]);
                if (length(middleNodes) <=s)
                    continue;
                end
            end
            combs = nchoosek(middleNodes,s);
            for k=1:size(combs,1)
                condSet = combs(k,:);
                % if independent
                condSet_string='{';
                for i2=1:(length(condSet)-1)
                    condSet_string=[condSet_string,int2str(condSet(i2)),', '];
                end
                condSet_label = [];
                for i2 = 1:length(condSet)
                   condSet_label = [condSet_label, dlabel{condSet}];
                end
                condSet_string=[condSet_string,int2str(condSet(length(condSet))),'}'];
                p_val = feval(cond_ind_test, X(:,dlabel{i}), X(:,dlabel{j}), X(:,condSet_label), pars);
                count=count+1;
                SP{count}=strcat('i=',int2str(i),', j=',int2str(j),', condSet_string=',condSet_string,', pval=',num2str(p_val));
                if p_val > alpha
                    fprintf('%d ind %d | %s with p-value %d\n', i,j,condSet_string, p_val);
                    witness(i,j,condSet) = ones(1,s);
                    witness(j,i,condSet) = ones(1,s);
                    g(i,j)=0;
                    g(j,i)=0;
                else
                    fprintf('%d notind %d | %s with p-value %d\n', i,j,condSet_string, p_val);
                end
            end
        end
    end
end


% Algorithm 2 starts from here. 
% infer causal direction: C - X => C -> X
g(1,find(g(1,:)~=0)) = 1;
g(find(g(:,1)~=0),1) = 0;

% infer V-structures: X - Y - Z  => X -> Y <- Z
adjMatrix = g;
for i=2:n
    adj = find(adjMatrix(:,i)~=0);
    c = length(adj);
    for j=1:(c-1)
        for k=(j+1):c
            
            % check if moral
            if (adjMatrix(adj(j), adj(k))~=0 | adjMatrix(adj(k), adj(j))~=0)
                continue;
            end
            
            % check to see if in witness set
            if (witness(adj(j), adj(k), i)==1 | witness(adj(k), adj(j), i)==1)
                continue;
            end
            
            % orient immorality
            g(adj(j),i) = 1;
            g(i,adj(j)) = 0;
            g(adj(k),i) = 1;
            g(i,adj(k)) = 0;
            
        end
    end
end

% meeks rules to learn the Markov equivalence class
g = meeks(-g,-adjMatrix);
g = -g;
% infer the causal directions between two connected variables whose causal
% modules are both nonstationary
% see paper : "Behind Distribution Shift: Mining Driving Forces of Changes
% and Causal Arrows"
% You may comment out the following code, if you are only interested in the
% Markov equivalence class
Vns = find(g(1,:)==1); % find nodes with nonstationary causal modules
Vns_un = []; % nodes with nonstationary causal modules and undirected edges
for i = 1:length(Vns)
    if(~isempty(find(g(Vns(i),:)==-1)))
        Vns_un = [Vns_un,Vns(i)];
    end
end
Vns = Vns_un;
gns = g; 

while(length(Vns)>1)
    score = [];
    hypo_eff = [];
    hypo_cau = [];
    for i = 1:length(Vns)
        hypo_eff{i} = Vns(i);
        hypo_cau{i} = union(find(gns(Vns(i),1:end-1)==-1),find(gns(1:end-1,Vns(i))==1)');
        score(i) = infer_nonsta_dir(X(:,hypo_cau{i}),X(:,hypo_eff{i}),0.1,Width);
    end
    [~, id] = min(score);
    sink = Vns(id); % looking for the sink of the current graph
    gns(hypo_cau{id},hypo_eff{id}) = 1;
    gns(hypo_eff{id},hypo_cau{id}) = 0;
    Vns = setdiff(Vns,sink);
end
gns = meeks(-gns,-adjMatrix);
gns = -gns;
disp(gns);
