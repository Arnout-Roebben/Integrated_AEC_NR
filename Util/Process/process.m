function res = process(sig,p,mode)
% Processing using one of following methods:
% *) MWF:           Multichannel Wiener filter
% *) MWFext:        Extended multichanncel Wiener filter (MWFext)
% *) AEC-NR:        AEC first, NR second
% *) NR-AEC:        NR first, AEC second
% *) NRext-AEC-PF:  Extended noise reduction (NRext) first, AEC second,
%                   postfilter (PF) third.
%
% INPUT: 
% sig           Struct      Struct containing the following input signals:
% -m            TXM         M-microphone microphone signal of length T samples.
%                           m=s+n+es+en.
% -s            TXM         M-microphone desired speech signal of length T samples.
% -n            TXM         M-microphone near-end room noise signal of length T samples.
% -es           TXM         M-microphone far-end room speech component in the echo signal of length T samples.
% -en           TXM         M-microphone far-end room noise component in the echo signal of length T samples.
% -ls           TXL         L-loudspeaker far-end room speech component in the loudspeaker signal of length T samples. 
% -ln           TXL         L-loudspeaker far-end room noise component in the loudspeaker signal of length T samples. 
% p             Struct      Struct containing the following parameters:
% -ref          1X1         Reference microphone.
% -sensitivity  String      Sensitivity of the standard deviation in the 
%                           voice acitivity detector (VAD) formula, 
%                           see VAD.m.
% -fs           1X1         Sampling rate [Hz].
% -M            1X1         Number of microphones.
% -L            1X1         Number of loudspeakers.
% -N            1X1         Discrete Fourier transform (DFT) size. 
%                           See WOLA_analysis.m  and WOLA_synthesis.m
% -win          NX1         Window. See WOLA_analysis.m and WOLA_synthesis.m
% -shift        1X1         Frame shift. See WOLA_analysis.m and WOLA_synthesis.m
% -rank_s       1X1         Rank of desired speech correlation matrix.
% -rank_ses     1X1         Rank of sum of extended desired speech correlation matrix 
%                           and extended far-end room speech component in the echo.
% mode          String      Algorithm to use: either "MWF" (MWF), "MWFext" (MWFext), "AECNR" (AEC-NR),
%                           "NRAEC" (NR-AEC), "NRextAECPF" (NRext-AEC-PF).
%
% OUTPUT:          
% res           Struct      Struct containing the following processed signals:
% -m            TXM         M-microphone microphone signal of length T samples.
%                           m=s+n+es+en.
% -s            TXM         M-microphone desired speech signal of length T samples.
% -n            TXM         M-microphone near-end room noise signal of length T samples.
% -es           TXM         M-microphone far-end room speech component in the echo signal of length T samples.
% -en           TXM         M-microphone far-end room noise component in the echo signal of length T samples.
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


%% Check mode argument
if ~strcmp(mode,'AECNR') && ~strcmp(mode,'NRAEC') && ~strcmp(mode,'NRextAECPF') ...
   && ~strcmp(mode,'MWFext') && ~strcmp(mode,'MWF')
        error('Supplied mode not supported!');
end

%% Parse signals input
m = sig.m; 
s = sig.s;
n = sig.n;
es = sig.es;
en = sig.en;
ls = sig.ls;
ln = sig.ln;
l = sig.l;

%% STFT transformation: M X number of frames K X (N/2+1)
m_f = WOLA_analysis(m,p.win,p.N,p.shift);
s_f = WOLA_analysis(s,p.win,p.N,p.shift);
n_f = WOLA_analysis(n,p.win,p.N,p.shift);
es_f = WOLA_analysis(es,p.win,p.N,p.shift);
en_f = WOLA_analysis(en,p.win,p.N,p.shift);
ln_f = WOLA_analysis(ln,p.win,p.N,p.shift);
ls_f = WOLA_analysis(ls,p.win,p.N,p.shift);
l_f = WOLA_analysis(l,p.win,p.N,p.shift);

%% Voice activity detection (VAD) calculation
VADs = VAD(s_f,p.sensitivity,p.ref); % VAD speech
VADes = VAD(es_f,p.sensitivity,p.ref); % VAD echo

%% Prepare signals
signals = struct();
signals.m_f = m_f; signals.s_f = s_f; signals.n_f = n_f; 
signals.es_f = es_f; signals.en_f = en_f; signals.l_f = l_f; 
signals.ls_f = ls_f; signals.ln_f = ln_f;

%% MWF
if strcmp(mode,'MWF')
    % Parameters for processing
    param = struct();
    param.rank = p.rank_s; param.VADs = VADs; param.VADes = VADes;

    % Processing
    processed = process_NR(signals,param);
end


%% MWFext
if strcmp(mode,'MWFext')
    % Parameters for processing
    param = struct();
    param.rank = p.rank_s; param.VADs = VADs; param.VADes = VADes;

    % Processing
    processed = process_MWFext(signals,param);
end

%% AEC-NR
if strcmp(mode,'AECNR')
    % Parameters for processing
    param = struct();
    param.rank = p.rank_s; param.VADs = VADs; param.VADes = VADes;

    % Processing
    processed = struct(); 
    processed.AEC = process_AEC(signals,param);
    processed = process_NR(processed.AEC,param);
end

%% NR-AEC
if strcmp(mode,'NRAEC')
    % Parameters for processing
    param = struct();
    param.rank = p.rank_s; param.VADs = VADs; param.VADes = VADes;

    % Processing
    processed = struct();
    processed.NR = process_NR(signals,param);
    processed.NR.l_f = signals.l_f;
    processed.NR.ls_f = signals.ls_f;
    processed.NR.ln_f = signals.ln_f;
    processed = process_AEC(processed.NR,param);
end

%% NRext_AEC_PF
if strcmp(mode,'NRextAECPF')
    % Parameters for processing
    param = struct();
    param.rank = p.rank_ses; param.VADs = VADs; param.VADes = VADes;

    % Processing
    processed = struct(); 
    processed.NRext = process_NRext(signals,param);
    processed.AEC = process_AEC(processed.NRext,param);
    param.W11 = processed.NRext.W(1:p.M,1:p.M,:,:);
    param.rank = p.rank_s;
    processed = process_PF(processed.AEC,param);           
end
    
%% Conversion to time domain
res = struct();
res.m = WOLA_synthesis(processed.m_f,p.win,p.N,p.shift);
res.s = WOLA_synthesis(processed.s_f,p.win,p.N,p.shift);
res.n = WOLA_synthesis(processed.n_f,p.win,p.N,p.shift);
res.es = WOLA_synthesis(processed.es_f,p.win,p.N,p.shift);
res.en = WOLA_synthesis(processed.en_f,p.win,p.N,p.shift);  

end