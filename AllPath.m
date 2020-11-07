function p = AllPath(A, s, t)
% Find all paths from node #s to node #t
% INPUTS:
%   A is (n x n) symmetric ajadcent matrix
%   s, t are node number, in (1:n)
% OUTPUT
%   p is M x 1 cell array, each contains array of
%   nodes of the path, (it starts with s ends with t)
%   nodes are visited at most once.
if s == t
    p =  {s};
    return
end
p = {};
As = A(:,s)';
As(s) = 0;
neig = find(As);
if isempty(neig)
    return
end
A(:,s) = [];
A(s,:) = [];
neig = neig-(neig>=s);
t = t-(t>=s); 
for n=neig
    p = [p; AllPath(A,n,t)]; %#ok
end
p = cellfun(@(a) [s, a+(a>=s)], p, 'unif', 0);
end %AllPath