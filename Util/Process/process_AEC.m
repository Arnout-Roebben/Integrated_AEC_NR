function AEC = process_AEC(signals,param)
% Acoustic echo cancellation (AEC)
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
%
% OUTPUT:
% AEC           Struct      Struct containing the following processed signals:
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
AEC = struct(); % Struct to hold results
AEC.F = nan(M,L,N); % Echo paths transfer function matrix estimate
AEC.m_f = nan(M,K,N); % Processed desired speech
AEC.n_f = nan(M,K,N); % Processed near-end room noise
AEC.es_f = nan(M,K,N); % Processed far-end room speech component in the echo
AEC.en_f = nan(M,K,N); % Processed far-end room noise component in the echo

%% Processing
% Store echo signal
e_f = cell(N,1); % Placeholder for the stacked microphone and loudspeaker signal 
for k = 1:K % Loop over frames
    for n=1:N % Loop over bins
        % Store echo signal
        if ~param.VADs(k,n) && param.VADes(k,n)
            e_f{n}(:,sum(param.VADs(1:k,n)==0 & param.VADes(1:k,n)==1)) =  ...
                cat(1,squeeze(signals.m_f(:,k,n)),...
                permute(signals.l_f(:,k,n),[1 3 2]));            
        end
    end
end

% Compute correlation matrix
Ree_f = nan(M+L,M+L,N); % Placeholder for extended echo correlation matrix estimate
for n=1:N % Loop over bins
    % Compute the echo correlation matrix estimate using time averaging
    Ree_f(:,:,n) = e_f{n}*e_f{n}'/sum(param.VADs(:,n)==0 & param.VADes(:,n)==1);
end

% Compute the echo path transfer function matrix estimate
B = [zeros(M,L); eye(L)]; % Selects loudspeaker signals
H = [eye(M); zeros(L,M)]; % Selects microphone signals
for n=1:N % Loop over bins
    % Compute the echo path transfer function matrix estimate from the
    % correlation matrices
    AEC.F(:,:,n) = (pinv(B'*Ree_f(:,:,n)*B)*(B'*Ree_f(:,:,n)*H))';
end

% Subtract the estimated echo signal from the recorded signals.
for k = 1:K % Loop over frames
    % Apply the filter to the microphone signal
    AEC.m_f(:,k,:) = squeeze(signals.m_f(:,k,:)) - ...
                     sum(permute(AEC.F,[1 3 2]).*permute(repmat(...
                     signals.l_f(:,k,:),1,1,1,M),[4 3 1 2]),3);
    % Apply the filter to the far-end room speech component in the echo signal
    AEC.es_f(:,k,:) = squeeze(signals.es_f(:,k,:)) - ...
                      sum(permute(AEC.F,[1 3 2]).*permute(repmat(...
                      signals.ls_f(:,k,:),1,1,1,M),[4 3 1 2]),3);
    % Apply the filter to the far-end room noise component in the echo signal
    AEC.en_f(:,k,:) = squeeze(signals.en_f(:,k,:)) - ...
        sum(permute(AEC.F,[1 3 2]).*permute(repmat(...
        signals.ln_f(:,k,:),1,1,1,M),[4 3 1 2]),3);
end

% The desired speech and noise are left untouched by the filters.
AEC.s_f = signals.s_f;
AEC.n_f = signals.n_f;
AEC.l_f = signals.l_f;
AEC.ls_f = signals.ls_f;
AEC.ln_f = signals.ln_f;
end
