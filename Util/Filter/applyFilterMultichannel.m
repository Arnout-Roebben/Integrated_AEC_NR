function y = applyFilterMultichannel(x,w)
% Applies filter w to signal x
%
% INPUT:
% x         MXN     Unfiltered signal of length M, in each channel N.
% w         MXMXN   Filter of size MXM, in each channel N.
%
% OUTPUT:
% y         MXN     Filtered signal of length M, in each channel N
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

% Prealllocate memory
N = size(x,2);
y = nan(size(x));

% Apply filter
for n=1:N % Loop over bins
    y(:,n) = w(:,:,n)'*x(:,n);
end

