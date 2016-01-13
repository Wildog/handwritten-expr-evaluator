clear ; close all; clc

%参数设置
input_layer_size  = 400;
hidden_layer_size = 80;
num_labels = 17;
lambda = 1.28;
options = optimset('MaxIter', 200);

%加载训练数据
[X y] = readMNIST('image.idx', 'label.idx', 6000, 0);
X = reshape(X, 400, 6000);
X = X';
y(y==0)=10;
load('AdditionalTrainData.mat');
%附加训练数据'4'
X = [X; Four];
y_add = ones(size(Four, 1), 1)*4;
y = [y; y_add];
%附加训练数据'5'
X = [X; Five];
y_add = ones(size(Five, 1), 1)*5;
y = [y; y_add];
%附加训练数据'7'
X = [X; Seven];
y_add = ones(size(Seven, 1), 1)*7;
y = [y; y_add];
%附加训练数据'9'
X = [X; Nine];
y_add = ones(size(Nine, 1), 1)*9;
y = [y; y_add];
%附加训练数据'+'
X = [X; A; B; Plus_Add];
y_add = ones(size([A; B; Plus_Add], 1), 1)*11;
y = [y; y_add];
%附加训练数据'-'
X = [X; C; D; E; F; G; H];
y_add = ones(size([C; D; E; F; G; H], 1), 1)*12;
y = [y; y_add];
%附加训练数据'/'
X = [X; M; N; O; P];
y_add = ones(size([M; N; O; P], 1), 1)*13;
y = [y; y_add];
%附加训练数据'*'
X = [X; Q; R; S; T];
y_add = ones(size([Q; R; S; T], 1), 1)*14;
y = [y; y_add];
%附加训练数据'^'
X = [X; U; V; W];
y_add = ones(size([U; V; W], 1), 1)*15;
y = [y; y_add];
%附加训练数据'('
X = [X; Z];
y_add = ones(size(Z, 1), 1)*16;
y = [y; y_add];
%附加训练数据')'
X = [X; Y];
y_add = ones(size(Y, 1), 1)*17;
y = [y; y_add];

%随机初始化参数(Random Initialization)
initial_Theta1 = randInitializeWeights(input_layer_size, hidden_layer_size);
initial_Theta2 = randInitializeWeights(hidden_layer_size, num_labels);
initial_nn_params = [initial_Theta1(:) ; initial_Theta2(:)];

fprintf('\nTraining...\n')

%设置代价函数句柄
costFunction = @(p) nnCostFunction(p, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, X, y, lambda);

[nn_params, cost] = fmincg(costFunction, initial_nn_params, options);

Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));
Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

%计算训练数据识别率
pred = predict(Theta1, Theta2, X);
fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred == y)) * 100);
