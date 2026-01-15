function x = WOLA_synthesis(X,win,N,shift)
% Weighted overlap add (WOLA) synthesis filterbank. 
% 
% INPUT:
% X         MXKXN   Frequency matrix with K number of frames.
% win       NX1     Window.
% N         1X1     DFT size.
% shift     1X1     Frame shift.
%
% OUTPUT:
% x         TXM     Vector in time domain of length T samples.
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
M = size(X,1); % Number of microphones
% Placeholder for the output, Length of x calculated using reverse formula
% in doc STFT
x = zeros((size(X,2)-1)*shift+N,M);

%% Processing
X = cat(3,X,flip(conj(X(:,:,2:end-1)),3)); % Restore full spectrum
% Inverse discrete Fourier transform + apply window
x_full = ifft(X,N,3,'symmetric').*repmat(permute(win,[3 2 1]),...
    [M size(X,2) 1]);

% Synthesis
for l=1:size(X,2)
    x((l-1)*shift+1:(l-1)*shift+N,:) = x((l-1)*shift+1:(l-1)*shift+N,:)+...
        permute(x_full(:,l,:),[3 1 2]);
end