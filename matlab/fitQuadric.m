function parameterVector = fitQuadric(pointClouds, numberOfPoints)

    M = zeros(10, 10);

    for i  = 1 : 1 : numberOfPoints
   
        l = [   
                pointClouds(i, 1) ^ 2;
                pointClouds(i, 2) ^ 2;
                pointClouds(i, 3) ^ 2;
                pointClouds(i, 1) * pointClouds(i, 2);
                pointClouds(i, 1) * pointClouds(i, 3);
                pointClouds(i, 2) * pointClouds(i, 3);
                pointClouds(i, 1);
                pointClouds(i, 2);
                pointClouds(i, 3);
                1
            ];
        
        M = M + l * l';
   
    end

    N = zeros(10, 10);

    for i  = 1: 1 : numberOfPoints
   
        l1 = [  
                pointClouds(i, 1) * 2;
                0;
                0;
                pointClouds(i, 2);
                pointClouds(i, 3);
                0;
                1;
                0;
                0;
                0
             ];
        
        N = N + l1 * l1';
   
        l2 = [  
                0;
                pointClouds(i, 2) * 2;
                0;
                pointClouds(i, 1);
                0;
                pointClouds(i, 3);
                0;
                1;
                0;
                0
             ];
        
        N = N + l2 * l2';
    
        l3 = [  
                0;
                0;
                pointClouds(i, 3) * 2;
                0;
                pointClouds(i, 1);
                pointClouds(i, 2);
                0;
                0;
                1;
                0
             ];
        
        N = N + l3 * l3';

    end

    [coefficientEigenVectors, coefficientEigenValues] = eig(M, N);

    coefficientEigenValues = diag(coefficientEigenValues);
    coefficientEigenValues = coefficientEigenValues';

    [~, indexMinCoefficientEigenValue] = min(coefficientEigenValues);

    parameterVector = coefficientEigenVectors(:, indexMinCoefficientEigenValue);
    parameterVector = parameterVector';

end