function NRext = process_NRext(signals,param)
% Extended noise reduction (NRext)
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
% -rank_ses     1X1         Rank of sum of extended desired speech correlation matrix 
%                           and extended far-end room speech component in the echo.
% OUTPUT:
% NRext         Struct      Struct containing the following processed signals:
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
% A preprint is available at
% A. Roebben, T. van Waterschoot, J. Wouters, and M. Moonen, "Integrated 
% Minimum Mean Squared Error Algorithms for Combined Acoustic Echo 
% Cancellation and Noise Reduction," 2024, arXiv:2412.04267.

%% Initialisation
M = size(signals.m_f,1); % Number of microphones
K = size(signals.m_f,2); % Number of frames
N = size(signals.m_f,3); % Number of channels
L = size(signals.l_f,1); % Number of loudspeakers

% Preallocate memory
NRext = struct(); % Struct to hold results
% Processed extended noise signal, uncorrelated across the microphones
NRext.m_f = nan(M+L,K,N); % Processed microphone signal
NRext.s_f = zeros(M+L,K,N); % Processed desired speech signal
NRext.n_f = zeros(M+L,K,N); % Processed near-end room white noise signal
NRext.es_f = zeros(M+L,K,N); % Processed far-end room speech component in the echo signal
NRext.en_f = zeros(M+L,K,N); % Processed far-end room noise component in the echo signal

%% Processing
% VAD
VADm = param.VADs & param.VADes; % VADs(k,n)=1 and VADes(k,n)=1
VADnen = ~param.VADs & ~param.VADes; % VADs(k,n)=01 and VADes(k,n)=0

% Placeholder for the extended microphone signal whenever VADx(k,n)=1 and VADes(k,n)=1
m1_f = cell(N,1);
% Placeholder for the extended microphone signal whenever VADnnu(k,n)=1 and VADes(k,n)=0
m0_f = cell(N,1);
for k = 1:K % Loop over frames
    for n=1:N % Loop over bins
        % Store extended microphone signal whenever VADm(k,n)=1
        if VADm(k,n)
            m1_f{n}(:,(sum(VADm(1:k,n)))) = cat(1,squeeze(...
                signals.m_f(:,k,n)),permute(signals.l_f(:,k,n),[1 3 2]));
        % Store extended microphone signal whenever VADnen(k,n)=1
        elseif VADnen(k,n)
            m0_f{n}(:,(sum(VADnen(1:k,n)))) = cat(1,squeeze(...
                signals.m_f(:,k,n)),permute(signals.l_f(:,k,n),[1 3 2]));      
        end
    end
end

% Collect the correlation matrices
% Placeholder for the extended microphone correlation matrix whenever 
% VADm(k,n)=1
Rmm1_f = nan(M+L,M+L,N);
% Placeholder for the extended microphone correlation matrix whenever 
% VADnen(k,n)=1
Rmm0_f = nan(M+L,M+L,N);
for n=1:N % Loop over bins
   % Compute the extended microphone correlation matrix whenever 
   % VADm(k,n)=1     
    Rmm1_f(:,:,n) = m1_f{n}*m1_f{n}'/(sum(VADm(:,n)==1));
   % Compute the extended microphone correlation matrix whenever 
   % VADnen(k,n)=1
    Rmm0_f(:,:,n) = m0_f{n}*m0_f{n}'/(sum(VADnen(:,n)==1));
end

% Compute the NRext filter
% Calculate the NRext filter using the GEVD approximation
NRext.W = updateMWFGEVDMultichannel(Rmm1_f,Rmm0_f,repmat(param.rank,N,1));
NRext.W(1:M,M+1:end,:,:) = 0;

% Apply the NRext filter...
for k = 1:K % Loop over frames
    %... to the extended microphone signal
    NRext.m_f(:,k,:) = applyFilterMultichannel(cat(1,squeeze(...
        signals.m_f(:,k,:)),permute(signals.l_f(:,k,:),[1 3 2])),NRext.W);
    %... to the extended desired speech signal
    NRext.s_f(:,k,:) = applyFilterMultichannel(cat(1,squeeze(...
        signals.s_f(:,k,:)),zeros(L,N)),NRext.W);
    %... to the extended near-end room noise signal
    NRext.n_f(:,k,:) = applyFilterMultichannel(cat(1,squeeze(...
        signals.n_f(:,k,:)),zeros(L,N)),NRext.W);
    %... to the extended far-end room speech component in the echo signal
    NRext.es_f(:,k,:) = applyFilterMultichannel(cat(1,squeeze(...
        signals.es_f(:,k,:)),permute(signals.ls_f(:,k,:),[1 3 2])),NRext.W);
    %... to the extended far-end room speech component in the echo signal
    NRext.en_f(:,k,:) = applyFilterMultichannel(cat(1,squeeze(...
        signals.en_f(:,k,:)),permute(signals.ln_f(:,k,:),[1 3 2])),NRext.W);
end

%% Return results
% Retrieve the processed loudspeaker signals 
NRext.l_f(:,:,:) = NRext.m_f(M+1:M+L,:,:);
NRext.ls_f(:,:,:) = NRext.es_f(M+1:M+L,:,:);
NRext.ln_f(:,:,:) = NRext.en_f(M+1:M+L,:,:);

% Retrieve the processed microphone signals 
NRext.m_f = NRext.m_f(1:M,:,:);
NRext.s_f = NRext.s_f(1:M,:,:);
NRext.n_f = NRext.n_f(1:M,:,:);
NRext.es_f = NRext.es_f(1:M,:,:);
NRext.en_f = NRext.en_f(1:M,:,:);

end