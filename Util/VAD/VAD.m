function VADs = VAD(x_f,sens,ref)
% Creates a binary voice activity detector (VAD) for each channel as
% abs(squeeze(s_f(ref,:,n)))> std(s_f(ref,:,n))*sens). 
%
% INPUT:
% x_f    MXKXN     M-microphone signal of K frames and N channels.
% sens   1X1       Sensitivity of the standard deviation in the VAD 
%                  formula.
% ref    1X1       Reference channel
%
% OUTPUT:
% VADs   KXN       1 denotes voice activity and 0 denotes no voice
%                  activity.
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
[~,K,N] = size(x_f); % K number of frames and N channels

%% Processing
VADs = nan(K,N); % Placeholder for VAD
for n=1:N % Loop over bins
    % Power-based VAD estimation
    VADs(:,n) = abs(squeeze(x_f(ref,:,n))) > std(x_f(ref,:,n))*sens;
end

end