% Compares the following filters for combined noise reduction (NR) and
% acoustic echo cancellation (AEC):
% *) MWF:           Multichannel Wiener filter
% *) MWFext:        Extended multichanncel Wiener filter (MWFext)
% *) AEC-NR:        AEC first, NR second
% *) NR-AEC:        NR first, AEC second
% *) NRext-AEC-PF:  Extended noise reduction (NRext) first, AEC second,
%                   postfilter (PF) third.
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

%% Check that current folder corresponds to Integrated_AEC_NR
[~,curr_dir] = fileparts(pwd);
if ~strcmp(curr_dir,"Integrated_AEC_NR")
    error('Current fulder must correspond to ''Integrated_AEC_NR''!')
end

%% Cleanup
clear; close all; clc;
rng(2,"twister"); % Fix random number generator
addpath(genpath('.')); % Add subfolders of directory to path 

%% Load audio
% Audio data consists of the following components
% -m    TXM     M-microphone microphone signal of length T samples.
%               m=s+n+es+en.
% -s    TXM     M-microphone desired speech signal of length T samples.
% -n    TXM     M-microphone near-end room noise signal of length T samples.
% -es   TXM     M-microphone far-end room speech component in the echo 
%               signal of length T samples.
% -en   TXM     M-microphone far-end room noise component in the echo 
%               signal of length T samples.
% -l    TXL     L-loudspeaker loudspeaker signal of length T samples. 
%               l=ls+ln.
% -ls   TXL     L-loudspeaker far-end room speech component in the 
%               loudspeaker signal of length T samples.
% -ln   TXL     L-loudspeaker far-end room noise component in the 
%               loudspeaker signal of length T samples.
% For the desired speech and far-end room speech component in the
% loudspeakers, sentences from the Voice Cloning Toolkit (VCTK) corpus were
% used [1], as also available at [2].
% [1] C. Veaux, J. Yamagishi, K. MacDonald, "CSTR VCTK Corpus:
% English Multi-speaker Corpus for CSTR Voice Cloning Toolkit," http:
% //homepages.inf.ed.ac.uk/jyamagis/page3/page58/page58.html, 2016.
% [2] Dietzen, T., Ali, R., Taseska, M., van Waterschoot, T.: "Data
% Repository for MYRiAD: A Multi-Array Room Acoustic Database,"
% https://zenodo.org/record/7389996, 2023.
load('.\Audio\sig.mat');

%% Processing parameters
p = struct(); % Struct containing processing parameters

% General 
p.fs = fs; % Sampling rate
p.ref = 1; % Reference microphone
p.M = size(sig.m,2); % Amount of microphones
p.L = size(sig.l,2); % Amount of loudspeakers

% Frequency transform (See also WOLA_analysis.m and WOLA_synthesis.m)
p.N = 512; % Discrete Fourier transform (DFT) size N
p.shift = p.N/2; % Frame shift for weighted overlap add (WOLA)
p.win = sqrt(hann(p.N,'periodic')); % Window 

% Voice activity detection (VAD) (See also VAD.m)
p.sensitivity = 1e-5; % Sensitivity of VAD

% Parameters (See also process.m)
% Requested rank of sum of extended desired speech correlation matrix and 
% extended far-end room speech component in the echo correlation matrix 
p.rank_ses = p.L+1; 
p.rank_s = 1; % Requested rank of desired speech correlation matrix 

% Start time [s], after which the data is used to compute the metrics.
p.T_start = 1/p.fs; 

% Flags to select method
p.MWF_flag = 1; % If 1 MWF processing is enabled, if 0 it is disabled.
p.MWFext_flag = 1; % If 1 MWFext processing is enabled, if 0 it is disabled.
p.AECNR_flag = 1; % If 1 AEC-NR processing is enabled, if 0 it is disabled.
p.NRAEC_flag = 1; % If 1 NR-AEC processing is enabled, if 0 it is disabled.
p.NRextAECPF_flag = 1; % If 1 NRext-AEC-PF processing is enabled, if 0 it is disabled.

%% Process
% MWF
if p.MWF_flag
    MWF = process(sig,p,"MWF");
end
% MWFext
if p.MWFext_flag
    MWFext = process(sig,p,"MWFext");
end
% AEC-NR
if p.AECNR_flag
    AECNR = process(sig,p,"AECNR");
end
% NR-AEC
if p.NRAEC_flag
    NRAEC = process(sig,p,"NRAEC");
end
% NRext-AEC-PF
if p.NRextAECPF_flag
    NRextAECPF = process(sig,p,"NRextAECPF");
end

%% Metrics
% MWF
if p.MWF_flag
    [metrics_ref,MWF.metrics] = calculateMetrics(sig,MWF,p);  
end
% MWFext
if p.MWFext_flag
    [metrics_ref,MWFext.metrics] = calculateMetrics(sig,MWFext,p);
end
% AEC-NR
if p.AECNR_flag
    [metrics_ref,AECNR.metrics] = calculateMetrics(sig,AECNR,p);
end
% NR-AEC
if p.NRAEC_flag
    [metrics_ref,NRAEC.metrics] = calculateMetrics(sig,NRAEC,p);
end
% NRext-AEC-PF
if p.NRextAECPF_flag
    [metrics_ref,NRextAECPF.metrics] = calculateMetrics(sig,NRextAECPF,p);
end

%% Visualisation
% Metrics
% MWF
if p.MWF_flag
    fprintf('MWF:\n')
    fprintf('\t SNR improvement: %f\n',MWF.metrics.snr - metrics_ref.snr);
    fprintf('\t SER improvement: %f\n',MWF.metrics.ser - metrics_ref.ser);
    fprintf('\t SD: %f\n\n',MWF.metrics.sd);    
end
% MWFext
if p.MWFext_flag
    fprintf('MWFext:\n')
    fprintf('\t SNR improvement: %f\n',MWFext.metrics.snr - metrics_ref.snr);
    fprintf('\t SER improvement: %f\n',MWFext.metrics.ser - metrics_ref.ser);
    fprintf('\t SD: %f\n\n',MWFext.metrics.sd);    
end
% AEC-NR
if p.AECNR_flag
    fprintf('AEC-NR:\n')
    fprintf('\t SNR improvement: %f\n',AECNR.metrics.snr - metrics_ref.snr);
    fprintf('\t SER improvement: %f\n',AECNR.metrics.ser - metrics_ref.ser);
    fprintf('\t SD: %f\n\n',AECNR.metrics.sd);    
end
% NR-AEC
if p.NRAEC_flag
    fprintf('NR-AEC:\n')
    fprintf('\t SNR improvement: %f\n',NRAEC.metrics.snr - metrics_ref.snr);
    fprintf('\t SER improvement: %f\n',NRAEC.metrics.ser - metrics_ref.ser);
    fprintf('\t SD: %f\n\n',NRAEC.metrics.sd);    
end
% NRext-AEC-PF
if p.NRextAECPF_flag
    fprintf('NRext-AEC-PF:\n')
    fprintf('\t SNR improvement: %f\n',NRextAECPF.metrics.snr - metrics_ref.snr);
    fprintf('\t SER improvement: %f\n',NRextAECPF.metrics.ser - metrics_ref.ser);
    fprintf('\t SD: %f\n\n',NRextAECPF.metrics.sd);    
end
    

% Signals
% MWF
if p.MWF_flag
    figure; hold on
    t = tiledlayout(3,1);
    ax = nexttile; hold on; plot(sig.s(:,p.ref)); plot(MWF.s(:,p.ref)); 
    title('Desired speech'); xlabel('Time [Samples]'); ylabel('Amplitude [Arb. unit]');
    nexttile; hold on; plot(sig.n(:,p.ref)); plot(MWF.n(:,p.ref)); 
    title('Noise'); xlabel('Time [Samples]'); ylabel('Amplitude [Arb. unit]');
    nexttile; hold on; plot(sig.es(:,p.ref) + sig.en(:,p.ref)); plot(MWF.es(:,p.ref) + MWF.en(:,p.ref)); 
    title('Echo'); xlabel('Time [Samples]'); ylabel('Amplitude [Arb. unit]');
    title(t,'MWF');
    lg  = legend(ax,["Input" "Output"],'Orientation','Horizontal'); 
    lg.Layout.Tile = 'South'; hold off;
end
% MWFext
if p.MWFext_flag
    figure; hold on
    t = tiledlayout(3,1);
    ax = nexttile; hold on; plot(sig.s(:,p.ref)); plot(MWFext.s(:,p.ref)); 
    title('Desired speech'); xlabel('Time [Samples]'); ylabel('Amplitude [Arb. unit]');
    nexttile; hold on; plot(sig.n(:,p.ref)); plot(MWFext.n(:,p.ref)); 
    title('Noise'); xlabel('Time [Samples]'); ylabel('Amplitude [Arb. unit]');
    nexttile; hold on; plot(sig.es(:,p.ref) + sig.en(:,p.ref)); plot(MWFext.es(:,p.ref) + MWFext.en(:,p.ref)); 
    title('Echo'); xlabel('Time [Samples]'); ylabel('Amplitude [Arb. unit]');
    title(t,'MWFext');
    lg  = legend(ax,["Input" "Output"],'Orientation','Horizontal'); 
    lg.Layout.Tile = 'South'; hold off;    
end
% AEC-NR
if p.AECNR_flag
    figure; hold on
    t = tiledlayout(3,1);
    ax = nexttile; hold on; plot(sig.s(:,p.ref)); plot(AECNR.s(:,p.ref)); 
    title('Desired speech'); xlabel('Time [Samples]'); ylabel('Amplitude [Arb. unit]');
    nexttile; hold on; plot(sig.n(:,p.ref)); plot(AECNR.n(:,p.ref)); 
    title('Noise'); xlabel('Time [Samples]'); ylabel('Amplitude [Arb. unit]');
    nexttile; hold on; plot(sig.es(:,p.ref) + sig.en(:,p.ref)); plot(AECNR.es(:,p.ref) + AECNR.en(:,p.ref)); 
    title('Echo'); xlabel('Time [Samples]'); ylabel('Amplitude [Arb. unit]');
    title(t,'AEC-NR');
    lg  = legend(ax,["Input" "Output"],'Orientation','Horizontal'); 
    lg.Layout.Tile = 'South'; hold off;    
end
% NR-AEC
if p.NRAEC_flag
    figure; hold on
    t = tiledlayout(3,1);
    ax = nexttile; hold on; plot(sig.s(:,p.ref)); plot(NRAEC.s(:,p.ref)); 
    title('Desired speech'); xlabel('Time [Samples]'); ylabel('Amplitude [Arb. unit]');
    nexttile; hold on; plot(sig.n(:,p.ref)); plot(NRAEC.n(:,p.ref)); 
    title('Noise'); xlabel('Time [Samples]'); ylabel('Amplitude [Arb. unit]');
    nexttile; hold on; plot(sig.es(:,p.ref) + sig.en(:,p.ref)); plot(NRAEC.es(:,p.ref) + NRAEC.en(:,p.ref)); 
    title('Echo'); xlabel('Time [Samples]'); ylabel('Amplitude [Arb. unit]');
    title(t,'NR-AEC');
    lg  = legend(ax,["Input" "Output"],'Orientation','Horizontal'); 
    lg.Layout.Tile = 'South'; hold off;    
end
% NRext-AEC-PF
if p.NRextAECPF_flag
    figure; hold on
    t = tiledlayout(3,1);
    ax = nexttile; hold on; plot(sig.s(:,p.ref)); plot(NRextAECPF.s(:,p.ref)); 
    title('Desired speech'); xlabel('Time [Samples]'); ylabel('Amplitude [Arb. unit]');
    nexttile; hold on; plot(sig.n(:,p.ref)); plot(NRextAECPF.n(:,p.ref)); 
    title('Noise'); xlabel('Time [Samples]'); ylabel('Amplitude [Arb. unit]');
    nexttile; hold on; plot(sig.es(:,p.ref) + sig.en(:,p.ref)); plot(NRextAECPF.es(:,p.ref) + NRextAECPF.en(:,p.ref)); 
    title('Echo'); xlabel('Time [Samples]'); ylabel('Amplitude [Arb. unit]');
    title(t,'NRext-AEC-PF');
    lg  = legend(ax,["Input" "Output"],'Orientation','Horizontal'); 
    lg.Layout.Tile = 'South'; hold off;    
end