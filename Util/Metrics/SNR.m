function SNR = SNR(s,n)
% Calculates the fullband signal to noise ratio (SNR) using the time domain
% signals. 
%
% INPUT:
% s     TX1     Speech signal of length T samples.
% n     TX1     Noise signal of length T samples.
% fs    1X1     Sampling frequency [Hz]
% 
% OUTPUT:
% SNR   1X1     Fullband SNR level.
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

%% Fullband SNR
SNR = snr(s,n);

end