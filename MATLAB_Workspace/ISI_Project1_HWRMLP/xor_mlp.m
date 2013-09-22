function xor_mlp()

close all;

d_dataSetFile = 'pendigits.tra';
d_nHiddenLayer = 1;
d_nHiddenNeuron = [16];
d_functionType = [2 2];
d_learningRate = 0.01;
d_onlineMode = 1;

trainingDataSet = loadDataSet(d_dataSetFile);
xor_mlp_train(trainingDataSet, d_nHiddenLayer, d_nHiddenNeuron, d_functionType, d_learningRate, d_onlineMode);
