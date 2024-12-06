function [W,V,Q,D,R,Lxx,Lnn]  = updateMWFGEVDMultichannel(Rxx,Rnn,E)
% Calculates a generalised eigenvalue decomposition (GEVD) based
% multichannel Wiener filter (MWF) according to updateMWFGEVD for each
% channel according to [1].
%
% INPUT:
% Rxx      MXMXN      Desired+interference MXM correlation matrix of each 
%                     channel N.
% Rnn      MXMXN      Interference MXM correlation matrix of each 
%                     channel N.
% E        NX1        Number of generalised eigenvalues to retain in
%                     R(:,:,n) for each channel n={1,...,N}. If 
%                     not supplied, the highest rank that yields a positive
%                     semi-definite matrix is used. If E is higher than the
%                     amount of positive eigenvalues, then the highest rank 
%                     that yields a positive semi-defnite matrix is used.
%
% OUTPUT:
% W        MXMXN      MXM multichannel Wiener filter for each channel n={1,...,N}.
% V        MXMXN      V(:,:,n)'*Rxx(:,:,n)*V(:,:,n) = Lxx(:,:,n); 
%                     V(:,:,n)'*Rnn(:,:,n)*V(:,:,n) = Lnn(:,:,n) for each 
%                     channel n={1,...,N}.  The columns of V are sorted according to  
%                     increased eigenvalues.
% Q        MXMXN      Q(:,:,n) = (V(:,:,n)')^(-1) for each
%                     channel n={1,...,N}.
% R        MXMXN      Desired speech correlatinon matrix estimate for each
%                     channel n={1,...,N}.
% Lxx      MXMXN      V(:,:,n)'*Rxx(:,:,n)*V(:,:,n) = Lxx(:,:,n) for each
%                     channel n={1,...,N}.
% Lnn      MXMXN      V(:,:,n)'*Rnn(:,:,n)*V(:,:,n) = Lnn(:,:,n) for each
%                     channel n={1,...,N}.
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

%% Initialisation
M = size(Rxx,1); % Number of microphones
N = size(Rxx,3); % Number of channels
W = nan(M,M,N); % Placeholder for the MWF

% Placeholder for the desired speech correlation matrix estimate
V = nan(M,M,N); % Placeholder for V
Q = nan(M,M,N); % Placeholder for Q
D = nan(M,M,N); % Placeholder for D
R = nan(M,M,N); % Placeholder for R
Lxx = nan(M,M,N); % Placeholder for Lxx
Lnn = nan(M,M,N); % Placeholder for Lnn

%% Processing
for n = 1:N % Loop over bins
    % Call updateMWFGEVD.m
    if nargin == 3
        [W(:,:,n),V(:,:,n),Q(:,:,n),D(:,:,n),R(:,:,n),Lxx(:,:,n),...
            Lnn(:,:,n)] = updateMWFGEVD(Rxx(:,:,n),Rnn(:,:,n),E(n));
    else
        [W(:,:,n),V(:,:,n),Q(:,:,n),D(:,:,n),R(:,:,n),Lxx(:,:,n),...
            Lnn(:,:,n)] =  updateMWFGEVD(Rxx(:,:,n),Rnn(:,:,n));
    end
end

end

