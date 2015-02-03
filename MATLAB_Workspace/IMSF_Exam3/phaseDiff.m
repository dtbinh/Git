function phase = phaseDiff(signalA, signalB)

% PHASEDIFF Calaculates the phase difference in degrees of two signals
%    P = PHASEDIFF(A,B) calculates the phase difference in degrees of two 
%    periodic signals A and B with the same period. The phase difference is
%    calculated by finding the zero crossings of the AC components of
%    signals A and B.
%
%    OBS: Signals A and B must have the same frequency and contain at least
%    one entire period.
%
%
%    Other m-files required: none
%    Subfunctions: none
%    MAT-files required: none

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% December 2014; Last revision: 06-December-2014

% Find the mean value of signals A and B
meanA = (max(signalA) + min(signalA))/2;
meanB = (max(signalB) + min(signalB))/2;

% Find the first rising edge zero-crossing of signal A
indexNegA = find(signalA < meanA);
indexPosA = find(signalA(indexNegA(1):end) >= meanA);
zeroCrossingA = indexPosA(1) + indexNegA(1) - 1;

% Find the first rising edge zero-crossing of signal B
indexNegB = find(signalB < meanB);
indexPosB = find(signalB(indexNegB(1):end) >= meanB);
zeroCrossingB = indexPosB(1) + indexNegB(1) - 1;

% Calculate the period by finding the secong zero-crossing of signal A
indexNegA2 = find(signalA(zeroCrossingA:end) < meanA);
indexPosA2 = find(signalA(indexNegA2(1):end) >= meanA);
period = indexPosA2(1) + indexNegA2(1) - 1;

% Calculate the phase difference between signals A and B
deltaT = zeroCrossingA - zeroCrossingB;
phase = 360*(deltaT/period);

% Unwrap the phase to the interval (-360 0]
if(phase > 0)
    phase = phase - 360;
end