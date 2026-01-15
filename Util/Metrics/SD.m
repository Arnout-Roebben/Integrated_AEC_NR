function SD = SD(s,sp)
% Calculates the fullband signal distortion (SD) using the time domain
% signals.
%
% INPUT:
% s     TX1     Speech signal of length T samples.
% sp    TX1     Processed speech signal of length T samples.
% fs    1X1     Sampling frequency [Hz]
% 
% OUTPUT:
% SD    1X1     Fullband SD level.
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


%% Fullband SD
SD = 10*log10(mean(abs(s.^2))/mean(abs(sp.^2)));

end

