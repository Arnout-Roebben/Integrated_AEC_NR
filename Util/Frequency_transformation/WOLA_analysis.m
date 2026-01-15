function X = WOLA_analysis(x,win,N,shift)
% Weighted overlap add (WOLA) analysis filterbank. Only the positive
% frequencies 0-fs/2 are returned.
% 
% INPUT:
% x         TXM     Vector in time domain of length T samples.
% win       NX1     Window.
% N         1X1     Discrete Fourier transform (DFT) size.
% shift     1X1     Frame shift.
%
% OUTPUT:
% X         MXKXN   Frequency matrix with K number of frames.
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
% If this code has been useful to you, please cite
% A. Roebben, T. van Waterschoot, J. Wouters and M. Moonen, "Integrated 
% Minimum Mean Squared Error Algorithms for Combined Acoustic Echo Cancellation 
% and Noise Reduction," in IEEE Transactions on Audio, Speech and Language 
% Processing, vol. 34, pp. 512-528, 2026, doi: 10.1109/TASLPRO.2025.3648802.

%% Initialisation
M = size(x,2); % Number of microphones
K = floor((length(x)-shift)/(N-shift)); % Number of frames K (See doc STFT)
X = nan(M,K,N/2+1); % Placeholder for the STFT-transformed result

%% Processing
% Convert to STFT domain
for l=1:K
    X_full = fft(x((l-1)*shift+1:(l-1)*shift+N,:).*repmat(win,1,M),N,1);
    X(:,l,:) = X_full(1:N/2+1,:).';
end