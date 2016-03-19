function A = oneDex(X, numLabels)
    
%size(X,2) must equal one
A = zeros(size(X,1),numLabels);

    %convert a vector to a logical array 
    for n = 1:size(X,1)
        
        A(n,X(n)) = 1;
        
    end

end