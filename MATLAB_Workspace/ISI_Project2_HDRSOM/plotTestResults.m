function plotTestResults(trainingFile, validationFile, testFile, controlVariable)

%
% FUNCTION DESCRIPTION
%

trainingResult = hdr_som_test_all(trainingFile, controlVariable);
validationResult = hdr_som_test_all(validationFile, controlVariable);
testResult = hdr_som_test_all(testFile, controlVariable);

figure;
subplot(121);
hold on;
plot(trainingResult{1}   , trainingResult{2}   , 'r-');
plot(validationResult{1} , validationResult{2} , 'g-');
plot(testResult{1}       , testResult{2}       , 'b-');
legend('treinamento', 'valida��o', 'teste');
xlabel(controlVariable, 'fontsize', 16);
ylabel('Dist�ncia euclidiana m�dia', 'fontsize', 16);


subplot(122);
hold on;
plot(trainingResult{1}   , trainingResult{3}   , 'r-');
plot(validationResult{1} , validationResult{3} , 'g-');
plot(testResult{1}       , testResult{3}       , 'b-');
legend('treinamento', 'valida��o', 'teste');
xlabel(controlVariable, 'fontsize', 16);
ylabel('Taxa de erro de classifica��o', 'fontsize', 16);