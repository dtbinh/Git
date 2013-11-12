function result = plotTestResults(trainingFile, validationFile, testFile, controlVariable)

%
% FUNCTION DESCRIPTION
%

trainingResult = hdr_som_test_all(trainingFile, controlVariable);
validationResult = hdr_som_test_all(validationFile, controlVariable);
testResult = hdr_som_test_all(testFile, controlVariable);

figure;
subplot(121);
hold on;
plot(trainingResult{1}   , trainingResult{2}   , 'ro-');
plot(validationResult{1} , validationResult{2} , 'go-');
plot(testResult{1}       , testResult{2}       , 'bo-');
legend('treinamento', 'validação', 'teste');
xlabel(controlVariable, 'fontsize', 16);
ylabel('Distância euclidiana média', 'fontsize', 16);


subplot(122);
hold on;
plot(trainingResult{1}   , trainingResult{3}   , 'ro-');
plot(validationResult{1} , validationResult{3} , 'go-');
plot(testResult{1}       , testResult{3}       , 'bo-');
legend('treinamento', 'validação', 'teste');
xlabel(controlVariable, 'fontsize', 16);
ylabel('Taxa de erro de classificação', 'fontsize', 16);

result = cell(1,3);
result{1} = trainingResult;
result{2} = validationResult;
result{3} = testResult;