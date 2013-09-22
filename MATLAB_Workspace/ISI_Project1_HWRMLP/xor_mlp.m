function xor_mlp()

close all;

d_dataSetFile = 'pendigits.tra';
d_nHiddenLayer = 1;
d_nHiddenNeuron = [16];
d_functionType = [2 2];
d_learningRate = 0.01;
d_onlineMode = 1;

stoppingCondition = cell(1,2);
stoppingCondition{1} = 0.0;
stoppingCondition{2} = 10000;

trainingDataSet = loadDataSet(d_dataSetFile);
hdr_mlp_train(trainingDataSet, d_nHiddenLayer, d_nHiddenNeuron, d_functionType, d_learningRate, d_onlineMode, stoppingCondition);
