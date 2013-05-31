function C = LLC(X,B,K)
% INPUT:
% - X: The features that were extracted. A DxN matrix, where N is 
%      the number of features and D is the dimension of the features
% - B: The codebook. A DxM matrix, where D is the dimension of the
%      codewords, and M is the number of entries in the codebook
% - K: The number of nearest neighbors to use as a bases for fast encoding
% OUTPUT:
% - C: A MxN matrix of coded features
fprintf('Beginning LLC encoding...\n')

%Find the K-nearest neighbors of B to X
fprintf('Finding %d nearest neighbors',K)
knn_idx = knnsearch(B',X','K',K)

%Solve the optimization problem for each feature (Eq 7 in the paper)
D = size(X,1)
if D ~= size(B,1)
  error('X and B must have the same number of rows')
end
N = size(X,2)
M = size(B,2)

fprintf('Calculating C')
C = zeros(M,N)
for i=1:N
  Bi = B(:,knn_idx(i,:)) %knn bases: A DxK matrix
  
  %Minimizing the constrained least squares problem with respect to ci:
  %||xi - Bi*ci||^2 s.t. sum(ci) = 1
  ci = lsqlin(Bi,X(:,i),[],[],ones(1,K),1)
  C(knn_idx,i) = ci
end
