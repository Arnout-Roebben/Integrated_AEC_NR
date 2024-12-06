function [R,V,Q,L1,L2] = updateDifferenceCorrelation(R1,R2,E)
% Calculate the rank-E approximation of R1-R2 using a generalised
% eigenvalue decomposition (GEVD) according to [1].
%
% INPUT:
% R1    MXM     Correlation matrix 1.
% R2    MXM     Correlation matrix 2.
% E     1X1     [optional] Rank of the R1-R2 approximation. If not
%               supplied, the highest rank that yields a positive
%               semi-definite matrix is used. If E is higher than the
%               amount of positive eigenvalues, then the highest rank that
%               yields a positive semi-definite matrix is used.
%
% OUTPUT:
% R     MXM     Rank E approximation of R1-R2. If E not specified, then the
%               eigenvalues are chosen as max(l1-l2,0) with l1 and l2 the
%               generalised eigenvalues of (R1,R2). If E is larger than the 
%               amount of non-zero eigenvalues max(l1-l2,0), then 
%               max(l1-l2,0) are chosen as eigenvalues to ensure positive-
%               semidefiniteness.
% V     MXM     V'*R1*V = L1; V'*R2*V = L2. The columns of V are
%               sorted according to increased eigenvalues.
% Q     MXM     Q = (V')^(-1)
% L1    MXM     V'*R1*V = L1
% L2    MXM     V'*R2*V = L2
%
% [1] R. Serizel, M. Moonen, B. Van Dijk, and J. Wouters, “Low-rank
% Approximation Based Multichannel Wiener Filter Algorithms for Noise
% Reduction with Application in Cochlear Implants,” IEEE/ACM Transactions
% on Audio, Speech, and Language Processing, vol. 22, no. 4, pp.
% 785–799, Apr. 2014.
%
% v1.0
% LICENSE: This software is distributed under the terms of the MIT license (See LICENSE.md).
% AUTHOR:  Arnout Roebben
% CONTACT: arnout.roebben@esat.kuleuven.be
% 
% This code is available at 
% A. Roebben, “Github repository: Integrated minimum mean squared error
% algorithms for combined acoustic echo cancellation and noise reduction,"
% https://github.com/Arnout-Roebben/Integrated_AEC_NR, 2024.
%
% A preprint is available at
% A. Roebben, T. van Waterschoot, J. Wouters, and M. Moonen, "Integrated 
% Minimum Mean Squared Error Algorithms for Combined Acoustic Echo 
% Cancellation and Noise Reduction," 2024, arXiv:2412.04267.

%% Calculate and sort eigenvectors
% Enforce the diagonal of the correlation matrices to be real
R1(1:size(R1,1)+1:end) = real(R1(1:size(R1,1)+1:end));
R2(1:size(R2,1)+1:end) = real(R2(1:size(R2,1)+1:end)); 
% Enforce the diagonal of the correlation matrices to be Hermitian
R1 = triu(R1) + triu(R1,1)'; R2 = triu(R2) + triu(R2,1)'; 
[V,~]=eig(R1,R2); % Calculate the generalised eigenvectors
% Get the generalised eigenvalues 
l1 = diag(V'*R1*V); 
l2 = diag(V'*R2*V);
% Get the modes with the best SNR, sorting nan values at end.
% Herein, enforce the eigenvalues of hermitian matrix to be real. 
[~,I] = sort(real(l1)./real(l2),'descend','MissingPlacement','last');
% Enforce the eigenvalues of the hermitian matrices to be real
l1 = real(l1(I)); 
l2 = real(l2(I)); 
V = V(:,I); % Sort the eigenvectors according to increased SNR values
Q = inv(V'); %  Q = (V')^(-1)

% Correct for the fact that the eigenvalue ratio might be positive 
% if both elements are negative.
% Find the elements for which the eigenvalue ratio is positive, but for
% which both eigenvalues are negative.
In = find(l1./l2 > 0 & l1<0 & l2<0); 
% If this set is non-empty, place these modes at the end.
if ~isempty(In)
    l1 = [l1(~ismember((1:length(I)),In)); l1(In)];
    l2 = [l2(~ismember((1:length(I)),In)); l2(In)];
    V = [V(:,~ismember((1:length(I)),In)) V(:,In)];
    Q = [Q(:,~ismember((1:length(I)),In)) Q(:,In)];
end    

%% Calculate the eigenvalues
% Convert the vectors to diagonal matrices.
L1 = diag(l1);
L2 = diag(l2);

% Enforce the eigenvalues of hermitian matrix to be real
l = real(max(l1-l2,0)); 
% If a rank E estimate is requested, set the E+1..M eigenvalues to 0.
if nargin == 3
    l(E+1:end) = 0;
end

%% Construct the desired speech correlation matrix estimate R
R = Q*diag(l)*Q';

%% Enforce a real diagonal and hermiticity of R
R = triu(R) + triu(R,1)';
R(1:size(R,1)+1:end) = real(diag(R));

end