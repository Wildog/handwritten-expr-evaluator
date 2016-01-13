function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)

Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

m = size(X, 1);
         
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

for i = 1:m
    %Forward Propagation 算法计算各层输出值
    hidden_layer = zeros(hidden_layer_size,1);
    input_layer = [1; X(i,:)'];
    hidden_layer = [1; sigmoid(Theta1 * input_layer)];
    output_layer = zeros(num_labels,1);
    output_layer = sigmoid(Theta2 * hidden_layer);
    y_recode = zeros(num_labels,1);
    y_recode(y(i)) = 1;
    %Backpropagation 算法计算各层残差以计算 Theta1 和 Theta2 的梯度
    delta3 = output_layer - y_recode;
    delta2 = Theta2' * delta3 .* (hidden_layer .* (1 - hidden_layer));
    delta2 = delta2(2:end); %!!!丢弃 bias unit
    %累加梯度
    Theta1_grad = Theta1_grad + delta2 * input_layer';
    Theta2_grad = Theta2_grad + delta3 * hidden_layer';
    %累加 LR cost
    J = J + y_recode' * log(output_layer) + (1 - y_recode') * log(1 - output_layer);
end

%计算 NN cost
J = -(1/m) * J + lambda/(2*m) * (sum(sum(Theta1(:, 2:end).^2)) + sum(sum(Theta2(:, 2:end).^2)));

Theta1_temp = Theta1_grad;
Theta1_grad = (1/m) * Theta1_grad + (lambda/m) * Theta1;
tmp1 = ((1/m) * Theta1_temp);
Theta1_grad(:,1) = tmp1(:,1);

Theta2_temp = Theta2_grad;
Theta2_grad = (1/m) * Theta2_grad + (lambda/m) * Theta2;
tmp2 = ((1/m) * Theta2_temp);
Theta2_grad(:,1) = tmp2(:,1);

grad = [Theta1_grad(:) ; Theta2_grad(:)];
