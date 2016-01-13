%计算测试数据识别率
clear ; close all; clc

load('Theta.mat');

[X_test y_test] = readMNIST('image_test.idx', 'label_test.idx', 10000, 0);
X_test = reshape(X_test, 400, 10000);
X_test = X_test';
y_test(y_test==0)=10;

test_pred = predict(Theta1, Theta2, X_test);

fprintf('\nTest Set Accuracy: %f\n', mean(double(test_pred == y_test)) * 100);
