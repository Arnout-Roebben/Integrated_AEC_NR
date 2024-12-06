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
% A preprint is available at
% A. Roebben, T. van Waterschoot, J. Wouters, and M. Moonen, "Integrated 
% Minimum Mean Squared Error Algorithms for Combined Acoustic Echo 
% Cancellation and Noise Reduction," 2024, arXiv:2412.04267.


%% Fullband SD
SD = 10*log10(mean(abs(s.^2))/mean(abs(sp.^2)));

end

