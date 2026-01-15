function MWFext = process_MWFext(signals,param)
% Extended multichannel Wiener filtering (MWFext)
%
% INPUT:
% sigals        Struct      Struct containing the following input signals:
% -m_f          MXKXN       M-microphone microphone signal of length K frames and N frequency bins.
%                           m=s+n+es+en.
% -s_f          MXKXN       M-microphone desired speech signal of length K frames and N frequency bins.
% -n_f          MXKXN       M-microphone near-end room noise signal of length K frames and N frequency bins.
% -es_f         MXKXN       M-microphone far-end room speech component in the echo signal of length K frames and N frequency bins.
% -en_f         MXKXN       M-microphone far-end room noise component in the echo signal of length K frames and N frequency bins.
% -ls_f         LXKXN       L-loudspeaker far-end room speech component in the loudspeaker signal of length K frames and N frequency bins.
% -ln_f         LXKXN       L-loudspeaker far-end room noise component in the loudspeaker signal of length K frames and N frequency bins.
% param         Struct      Struct containing the following parameters:
% -VADs         KXN         Voice activity detector (VAD) for the desired speech.
% -VADes        KXN         Voice activity detector (VAD) for the far-end room speech component in the echo.
% -rank_s       1X1         Rank of desired speech correlation matrix.
%
% OUTPUT:
% MWFext        Struct      Struct containing the following processed signals:
% -m_f          MXKXN       M-microphone microphone signal of length K frames and N frequency bins.
%                           m=s+n+es+en.
% -s_f          MXKXN       M-microphone desired speech signal of length K frames and N frequency bins.
% -n_f          MXKXN       M-microphone near-end room noise signal of length K frames and N frequency bins.
% -es_f         MXKXN       M-microphone far-end room speech component in the echo signal of length K frames and N frequency bins.
% -en_f         MXKXN       M-microphone far-end room noise component in the echo signal of length K frames and N frequency bins.
% -ls_f         LXKXN       L-loudspeaker far-end room speech component in the loudspeaker signal of length K frames and N frequency bins.
% -ln_f         LXKXN       L-loudspeaker far-end room noise component in the loudspeaker signal of length K frames and N frequency bins.
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
M = size(signals.m_f,1); % Number of microphones
K = size(signals.m_f,2); % Number of frames
N = size(signals.m_f,3); % Number of channels
L = size(signals.l_f,1); % Number of loudspeakers

% Preallocate memory
MWFext = struct(); % Struct to hold results
MWFext.m_f = nan(M+L,K,N); % Processed microphone signal
MWFext.s_f = nan(M+L,K,N); % Processed desired speech signal
MWFext.n_f = nan(M+L,K,N); % Processed near-end room noise signal
MWFext.es_f = nan(M+L,K,N); % Processed far-end room speech component in the echo signal
MWFext.en_f = nan(M+L,K,N); % Processed far-end room noise component in the echo signal

%% Processing
% Placeholder for the extended microphone signal whenever VADs(k,n)=1 and VADes(k,n)=1
m1_f = cell(N,1);
% Placeholder for the extended microphone signal whenever VADs(k,n)=0 and VADes(k,n)=1
m0_f = cell(N,1);
for k = 1:K % Loop over frames
    for n=1:N % Loop over bins
        if param.VADs(k,n) && param.VADes(k,n)
            m1_f{n}(:,(sum(param.VADs(1:k,n)==1 & param.VADes(1:k,n)==1))) = ...
                cat(1,squeeze(signals.m_f(:,k,n)),...
                permute(signals.l_f(:,k,n),[1 3 2]));
        elseif ~param.VADs(k,n) && param.VADes(k,n)
            m0_f{n}(:,(sum(param.VADs(1:k,n)==0 & param.VADes(1:k,n)==1))) = ...
                cat(1,squeeze(signals.m_f(:,k,n)),...
                permute(signals.l_f(:,k,n),[1 3 2]));     
        end            
    end
end

% Collect the correlation matrices
% Placeholder for the extended microphone correlation matrix whenever 
% VADs(k,n)=1 and VADes(k,n)=1
Rmm1_f = nan(M+L,M+L,N);
% Placeholder for the extended microphone correlation matrix whenever 
% VADs(k,n)=0 and VADes(k,n)=1
Rmm0_f = nan(M+L,M+L,N);
for n=1:N % Loop over bins
    Rmm1_f(:,:,n) = m1_f{n}*m1_f{n}'/(sum(param.VADs(:,n)==1 & param.VADes(:,n)==1));
    Rmm0_f(:,:,n) = m0_f{n}*m0_f{n}'/(sum(param.VADs(:,n)==0 & param.VADes(:,n)==1));
end

% Compute the MWFext filter
% Calculate the MWFext filter using the GEVD approximation    
MWFext.W = updateMWFGEVDMultichannel(Rmm1_f,Rmm0_f,repmat(param.rank,N,1));

% Apply the NR filter...
for k = 1:K % Loop over frames
    %... to the extended microphone signal
    MWFext.m_f(:,k,:) = applyFilterMultichannel(cat(1,squeeze(...
        signals.m_f(:,k,:)),permute(signals.l_f(:,k,:),[1 3 2])),MWFext.W);
    %... to the extended desired speech signal
    MWFext.s_f(:,k,:) = applyFilterMultichannel(cat(1,squeeze(...
        signals.s_f(:,k,:)),zeros(L,N)),MWFext.W);
    %... to the extended near-end room noise signal
    MWFext.n_f(:,k,:) = applyFilterMultichannel(cat(1,squeeze(...
        signals.n_f(:,k,:)),zeros(L,N)),MWFext.W);
    %... to the extended far-end room speech component in the echo signal
    MWFext.es_f(:,k,:) = applyFilterMultichannel(cat(1,squeeze(...
        signals.es_f(:,k,:)),permute(signals.ls_f(:,k,:),[1 3 2])),MWFext.W);
    %... to the extended far-end room speech component in the echo signal
    MWFext.en_f(:,k,:) = applyFilterMultichannel(cat(1,squeeze(...
        signals.en_f(:,k,:)),permute(signals.ln_f(:,k,:),[1 3 2])),MWFext.W);
end

%% Return results
% Retrieve the processed loudspeaker signals 
MWFext.l_f(:,:,:) = MWFext.m_f(M+1:end,:,:);
MWFext.ls_f(:,:,:) = MWFext.es_f(M+1:end,:,:);
MWFext.ln_f(:,:,:) = MWFext.en_f(M+1:end,:,:);

% Retrieve the processed microphone signals 
MWFext.m_f = MWFext.m_f(1:M,:,:);
MWFext.s_f = MWFext.s_f(1:M,:,:);
MWFext.n_f = MWFext.n_f(1:M,:,:);
MWFext.es_f = MWFext.es_f(1:M,:,:);
MWFext.en_f = MWFext.en_f(1:M,:,:);

end