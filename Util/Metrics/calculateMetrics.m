function [metrics_ref,metrics_processed] = calculateMetrics(sig,processed,param)
% Computes the metrics to evaluate the signals in sig.
%
% INPUT: 
% sig           Struct      Struct containing the following input signals:
% -m            TXM         M-microphone microphone signal of length T samples.
%                           m=s+n+es+en.
% -s            TXM         M-microphone desired speech signal of length T samples.
% -n            TXM         M-microphone noise signal of length T samples.
% -es           TXM         M-microphone far-end room speech component in the echo signal of length T samples.
% -en           TXM         M-microphone far-end room noise component in the echo signal of length T samples.
% processed     Struct      Struct containing the following procssed signals:
% -m            TXM         M-microphone microphone signal of length T samples.
%                           m=s+n+es+en.
% -s            TXM         M-microphone desired speech signal of length T samples.
% -n            TXM         M-microphone noise signal of length T samples.
% -es           TXM         M-microphone far-end room speech component in the echo signal of length T samples.
% -en           TXM         M-microphone far-end room noise component in the echo signal of length T samples.
% param         Struct      Struct containing the processing parameters:
% -T_start      1X1         Start time [s], after which the data is used to compute the metrics.
% -fs           1X1         Sampling frequency [Hz].
% -ref          1X1         Reference microphone number.
% -sensitivity  1X1         Sensitivity of VAD (see VAD.m).
%
% OUTPUT:
% res           Struct      Struct containing the computed metrics:
% -snr          1X1         Signal to noise ratio.
% -sd           1X1         Speech distortion
% -ser          1X1         Signal to echo ratio.
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
% Throw error if start time exceeds signal length
if size(sig.s,1)/param.fs < param.T_start
    error('The signals end before the supplied ''T_start''!');
end

% Adjust starting and end time of...
% ... Input signals
sm = sig.s(floor(param.T_start*param.fs):end,:);
mm = sig.m(floor(param.T_start*param.fs):end,:);
nm = sig.n(floor(param.T_start*param.fs):end,:);
em = sig.es(floor(param.T_start*param.fs):end,:) + sig.en(floor(param.T_start*param.fs):end,:);

% ... Output signals
s = processed.s(floor(param.T_start*param.fs):end,:);
m = processed.m(floor(param.T_start*param.fs):end,:);
n = processed.n(floor(param.T_start*param.fs):end,:);
e = processed.es(floor(param.T_start*param.fs):end,:) + processed.en(floor(param.T_start*param.fs):end,:);


% Select frames where speech is active of...
VADs_time = abs(sm(:,param.ref)) > std(sm(:,param.ref))*param.sensitivity;
% ... Input signals
sm = sm(VADs_time,param.ref);
nm = nm(VADs_time,param.ref);
em = em(VADs_time,param.ref);

% ... Output signals
s = s(VADs_time,param.ref);
n = n(VADs_time,param.ref);
e = e(VADs_time,param.ref);

%% Reference metric: without processing
metrics_ref = struct();
metrics_ref.snr = SNR(sm(:,param.ref),nm(:,param.ref));
metrics_ref.ser = SNR(sm(:,param.ref),em(:,param.ref));

%% Metrics: after processing
metrics_processed = struct();
metrics_processed.snr = SNR(s,n);
metrics_processed.sd = SD(sm,s);
metrics_processed.ser = SNR(s, e);
end