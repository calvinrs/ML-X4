function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%


%H(x) here is the Lth activation unit (a3 in the 3 layer network)

% Add ones to the X data matrix
Xbias = [ones(m, 1) X];

a1 = Xbias;

z2 = a1 * Theta1'; % vectorized Theta1 * a1 for all obs+1
a2 = sigmoid(z2); % activation function at layer 2

%now repeat for next layer

a2bias = [ones(m, 1) a2];
z3 = a2bias * Theta2';
a3 = sigmoid(z3);

%To evaluate the hypothsis one-for-all result at layer 3, take the index of the max
%probalitity found
% [maxVal, maxIndex] =  max (a3, [], 2);
% 
% H = maxIndex;

%convert H and y to index of logical values
% indexH = oneDex(H,num_labels);
indexY = oneDex(y,num_labels);

%Now calc the hypothesis function for all observed Y, for all ouput units K;

%double summation
sumTotal = 0;
for n = 1:m
    for k = 1:num_labels
        sumTotal = sumTotal + (indexY(n,k) * log(a3(n,k))) + ((1 - indexY(n,k)) * log(1- a3(n,k)));
    end
end

%now with regularisation term 
%- set to zero rather than removing so we can add to the deltas 
unbiasedTheta1 = [zeros(size(Theta1,1),1),Theta1(:,2:end)]; % as theta(0) = 0; don't regularise bias term
unbiasedTheta2 = [zeros(size(Theta2,1),1),Theta2(:,2:end)];
unbiasedThetas = [unbiasedTheta1(:);unbiasedTheta2(:)];
sumSqThetas = unbiasedThetas' * unbiasedThetas;

J = ( (-1 / m) * (sumTotal) ) + ((lambda/(2*m)) * sumSqThetas);


% -------------------------------------------------------------

% =========================================================================

%implement backpropogation algorithm for each training example

for t = 1:m
    
    % #1: Forward propigation to get output aL 
    % use vectors to match lecture notes
    a1 = [1;X(t,:)'];
    z2 = Theta1 * a1;
    a2 = [1; sigmoid(z2)];
    
    %now repeat for next layer    
    z3 = Theta2 * a2;
    a3 = sigmoid(z3); % no bias in last layer
    
    % #2: compute dL using actual observation
    delta_3 = a3 - indexY(t,:)';
    
    % #3: use sigmoid gradient function to get d at the previous layer
    delta_2 = (Theta2' * delta_3) .* [0; sigmoidGradient(z2)];
    delta_2 = delta_2(2:end);
    
    % #4: add this to the accumulated delta values
    dt2  = delta_3 * a2';
    dt1  = delta_2 * a1';
    
    %summations
    Theta2_grad = Theta2_grad + dt2;
    Theta1_grad = Theta1_grad + dt1;
    
end

% #5: final gradient divided by m
Theta1_grad = (1/m) * Theta1_grad + (lambda/m) * unbiasedTheta1;
Theta2_grad = (1/m) * Theta2_grad + (lambda/m) * unbiasedTheta2;

% Regularised gradient

% "unroll" the gradients into a single vector
% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
