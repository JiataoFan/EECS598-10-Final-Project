function [normal, principalAxis] = estimateMedianCurvature(neighborHood, numberOfNeighborhoodPoints, parameterVector)

    curvatures  = zeros(numberOfNeighborhoodPoints, 2);
    principalDirections = zeros(numberOfNeighborhoodPoints, 3);

    deltaNx = [
                    2 * parameterVector(1), parameterVector(4), parameterVector(6);
                    parameterVector(4), 2 * parameterVector(2), parameterVector(5);
                    parameterVector(6), parameterVector(5), 2 * parameterVector(3);
              ];

    for i  = 1: 1 : numberOfNeighborhoodPoints
   
        identityMatrix = eye(3);
    
        dx = 2 * parameterVector(1) * neighborHood(i, 1) + parameterVector(4) * neighborHood(i, 2) + parameterVector(6) * neighborHood(i, 3) + parameterVector(7);
        dy = 2 * parameterVector(2) * neighborHood(i, 2) + parameterVector(4) * neighborHood(i, 1) + parameterVector(5) * neighborHood(i, 3) + parameterVector(8);
        dz = 2 * parameterVector(3) * neighborHood(i, 3) + parameterVector(5) * neighborHood(i, 2) + parameterVector(6) * neighborHood(i, 1) + parameterVector(9);

        gradient = [
                        dx;
                        dy;
                        dz
                   ];
    
        Nx = gradient / norm(gradient');
    
        %why times (-1)?
        shapeOperator  = (-1) * (identityMatrix - Nx * Nx') * deltaNx;
    
        [shapeOperatorEigenVectors, shapeOperatorEigenValues] = eig(shapeOperator);
    
        shapeOperatorEigenValues = diag(shapeOperatorEigenValues);
        shapeOperatorEigenValues = shapeOperatorEigenValues';
    
        [~, indexMaxShapeOperatorEigenValue] = max(abs(shapeOperatorEigenValues));
    
        curvatures(i, 1) = abs(shapeOperatorEigenValues(indexMaxShapeOperatorEigenValue));
        curvatures(i, 2) = i;
    
        principalDirections(i, 1) = shapeOperatorEigenVectors(1, indexMaxShapeOperatorEigenValue);
        principalDirections(i, 2) = shapeOperatorEigenVectors(2, indexMaxShapeOperatorEigenValue);
        principalDirections(i, 3) = shapeOperatorEigenVectors(3, indexMaxShapeOperatorEigenValue);
    
    end

    curvatures = sortrows(curvatures);

    if mod(numberOfNeighborhoodPoints, 2) == 0;
    
        indexMedianCurvature = curvatures(numberOfNeighborhoodPoints / 2, 2);
    
    elseif mod(numberOfNeighborhoodPoints, 2) ~= 0;
    
        indexMedianCurvature = curvatures((numberOfNeighborhoodPoints + 1) / 2, 2);
    
    end

    principalDirection = principalDirections(indexMedianCurvature, :);

    normalX = 2 * parameterVector(1) * neighborHood(indexMedianCurvature, 1) + parameterVector(4) * neighborHood(indexMedianCurvature, 2) + parameterVector(6) * neighborHood(indexMedianCurvature, 3) + parameterVector(7);
    normalY = 2 * parameterVector(2) * neighborHood(indexMedianCurvature, 2) + parameterVector(4) * neighborHood(indexMedianCurvature, 1) + parameterVector(5) * neighborHood(indexMedianCurvature, 3) + parameterVector(8);
    normalZ = 2 * parameterVector(3) * neighborHood(indexMedianCurvature, 3) + parameterVector(5) * neighborHood(indexMedianCurvature, 2) + parameterVector(6) * neighborHood(indexMedianCurvature, 1) + parameterVector(9);

    normal = [
            normalX;
            normalY;
            normalZ
         ];
     
    normal = normal / norm(normal');
    normal = normal';

    principalAxis = cross(principalDirection, normal);

    hold on;
    quiver3(neighborHood(indexMedianCurvature, 1), neighborHood(indexMedianCurvature, 2), neighborHood(indexMedianCurvature, 3), principalAxis(1), principalAxis(2), principalAxis(3), 'y');
    quiver3(neighborHood(indexMedianCurvature, 1), neighborHood(indexMedianCurvature, 2), neighborHood(indexMedianCurvature, 3), normal(1), normal(2), normal(3), 'b');
    quiver3(neighborHood(indexMedianCurvature, 1), neighborHood(indexMedianCurvature, 2), neighborHood(indexMedianCurvature, 3), principalDirection(1), principalDirection(2), principalDirection(3), 'g');

end