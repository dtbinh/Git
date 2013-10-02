function plotTestResults(trainingFile, validationFile, testFile, controlVariable)

% PLOTTESTRESULTS Plot the results of a MLP for three data sets
%    PLOTTESTRESULTS(training, validation, test, controlVariable) run the
%    function hdr_test_all for the training, validation and test data sets.
%    Then the network error and misclassification rate are plotted in
%    separated subplots. In each subplot, the training, the validation and
%    the test result are plotted simultaneously using the colors red, green
%    and blue, respectively.
%
%
%  Other m-files required: hdr_mlp_test_all.m, hdr_mlp_test.m, loadDataSet.m
%  Subfunctions: none
%  MAT-files required: trained networks (in the current directory)
%
%  See also: HDR_MLP_TEST, HDR_MLP_TEST_ALL

% Author: André Augusto Geraldes
% Email: andregeraldes@lara.unb.br
% September 2013; Last revision: 30-September-2013

trainingResult = hdr_mlp_test_all(trainingFile, controlVariable);
validationResult = hdr_mlp_test_all(validationFile, controlVariable);
testResult = hdr_mlp_test_all(testFile, controlVariable);

figure;
subplot(121);
hold on;
plot(trainingResult{1}   , trainingResult{2}   , 'r-');
plot(validationResult{1} , validationResult{2} , 'g-');
plot(testResult{1}       , testResult{2}       , 'b-');
legend('treinamento', 'validação', 'teste');
xlabel(controlVariable, 'fontsize', 16);
ylabel('Erro médio quadrático', 'fontsize', 16);


subplot(122);
hold on;
plot(trainingResult{1}   , trainingResult{3}   , 'r-');
plot(validationResult{1} , validationResult{3} , 'g-');
plot(testResult{1}       , testResult{3}       , 'b-');
legend('treinamento', 'validação', 'teste');
xlabel(controlVariable, 'fontsize', 16);
ylabel('Taxa de erro de classificação', 'fontsize', 16);