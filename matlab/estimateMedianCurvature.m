function [normal, principalAxis] = estimateMedianCurvature(pointClouds, numberOfPoints, parameterVector)

    curvatures  = zeros(numberOfPoints, 2);
    principalDirections = zeros(numberOfPoints, 3);

    deltaNx = [
                    2 * parameterVector(1), parameterVector(4), parameterVector(6);
                    parameterVector(4), 2 * parameterVector(2), parameterVector(5);
                    parameterVector(6), parameterVector(5), 2 * parameterVector(3);
              ];

    for i  = 1: 1 : numberOfPoints
   
        identityMatrix = eye(3);
    
        dx = 2 * parameterVector(1) * pointClouds(i, 1) + parameterVector(4) * pointClouds(i, 2) + parameterVector(6) * pointClouds(i, 3) + parameterVector(7);
        dy = 2 * parameterVector(2) * pointClouds(i, 2) + parameterVector(4) * pointClouds(i, 1) + parameterVector(5) * pointClouds(i, 3) + parameterVector(8);
        dz = 2 * parameterVector(3) * pointClouds(i, 3) + parameterVector(5) * pointClouds(i, 2) + parameterVector(6) * pointClouds(i, 1) + parameterVector(9);

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

    if mod(numberOfPoints, 2) == 0;
    
        indexMedianCurvature = curvatures(numberOfPoints / 2, 2);
    
    elseif mod(numberOfPoints, 2) ~= 0;
    
        indexMedianCurvature = curvatures((numberOfPoints + 1) / 2, 2);
    
    end

    principalDirection = principalDirections(indexMedianCurvature, :);

    normalX = 2 * parameterVector(1) * pointClouds(indexMedianCurvature, 1) + parameterVector(4) * pointClouds(indexMedianCurvature, 2) + parameterVector(6) * pointClouds(indexMedianCurvature, 3) + parameterVector(7);
    normalY = 2 * parameterVector(2) * pointClouds(indexMedianCurvature, 2) + parameterVector(4) * pointClouds(indexMedianCurvature, 1) + parameterVector(5) * pointClouds(indexMedianCurvature, 3) + parameterVector(8);
    normalZ = 2 * parameterVector(3) * pointClouds(indexMedianCurvature, 3) + parameterVector(5) * pointClouds(indexMedianCurvature, 2) + parameterVector(6) * pointClouds(indexMedianCurvature, 1) + parameterVector(9);

    normal = [
            normalX;
            normalY;
            normalZ
         ];
     
    normal = normal / norm(normal');
    normal = normal';

    principalAxis = cross(principalDirection, normal);

    hold on;
    scale=20;
    principalAxis=principalAxis/scale;
    principalDirection=principalDirection/scale;
    normal=normal/scale;
    
    quiver3(pointClouds(indexMedianCurvature, 1), pointClouds(indexMedianCurvature, 2), pointClouds(indexMedianCurvature, 3), principalAxis(1), principalAxis(2), principalAxis(3), 'y');
    quiver3(pointClouds(indexMedianCurvature, 1), pointClouds(indexMedianCurvature, 2), pointClouds(indexMedianCurvature, 3), normal(1), normal(2), normal(3),'b');
    quiver3(pointClouds(indexMedianCurvature, 1), pointClouds(indexMedianCurvature, 2), pointClouds(indexMedianCurvature, 3), principalDirection(1), principalDirection(2), principalDirection(3), 'g');
    
    principalAxis=principalAxis*scale;
    principalDirection=principalDirection*scale;
    normal=normal*scale;
    
end