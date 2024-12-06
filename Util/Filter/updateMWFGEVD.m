function [W,V,Q,D,R,Lxx,Lnn] = updateMWFGEVD(Rxx,Rnn,E)
% Calculates a multichannel Wiener filter (MWF) using the generalised  
% eigenvalue decomposition (GEVD) approximation according to [1].
%
% INPUT:
% Rxx      MXM      Desired+interference correlation matrix.
% Rnn      MXM      Interference correlation matrix.
% E        1X1      Number of generalised eigenvalues to retain in R. If 
%                   not supplied, the highest rank that yields a positive
%                   semi-definite matrix is used. If E is higher than the
%                   amount of positive eigenvalues, then the highest rank 
%                   that yields a positive semi-defnite matrix is used.
%
% OUTPUT:
% W        MXM      Multichannel Wiener filter.
% V        MXM      V'*Rxx*V = Lxx; V'*Rnn*V = Lnn. The columns of V are
%                   sorted according to increased eigenvalues.
% D        MXM      Diagonal matrix, computed as
%                   diag([(Lxx(1,1)-Lnn(1,1))/Lxx(1,1)...
%                   Lxx(E,E)-Lnn(E,E))/...
%                   Lxx(E,E) 0...0]).
% R        MXM      Desired correlation matrix estimate.
% Q        MXM      Q = (V')^(-1)
% Lxx      MXM      V'*Rxx*V = Lxx
% Lnn      MXM      V'*Rnn*V = Lnn
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

M = size(Rxx,1); % Number of microphones

% Get GEVD parameters
[R,V,Q,Lxx,Lnn] = updateDifferenceCorrelation(Rxx,Rnn,E);

% Compute the diagonal matrix D
lxx = diag(Lxx); lnn = diag(Lnn);
D = diag([(lxx(1:min(E,rank(R)))-lnn(1:min(E,rank(R))))./...
    lxx(1:min(E,rank(R))); zeros(M-min(E,rank(R)),1)]);

% Compute the MWF 
W = V*D*Q';

end