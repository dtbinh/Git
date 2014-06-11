function TESTE9ALL(lambdaVector, Kvector, Avector)

%
% FUNCTION DESCRIPTION
%

nLambda = length(lambdaVector);
nK = length(Kvector);
nA = length(Avector);

iTest = 1;
for iA = 1:nA
    for iK = 1:nK
        for iLambda = 1:nLambda
            for iVideo = 1:3
                fprintf('TEST %d: \t video=%d, Aexp=%f, Kexp=%f, lambda=%f\n', iTest, iVideo, Avector(iA), Kvector(iK), lambdaVector(iLambda));
                TESTE9(iVideo, Avector(iA), Kvector(iK), lambdaVector(iLambda));
                iTest = iTest+1;
            end
        end
    end
end