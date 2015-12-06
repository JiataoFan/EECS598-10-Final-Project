function [circleCenterX, circleCenterY, circleRadius, centroid, extent] = fitCylinder(pointClouds, numberOfPoints, normal, principalAxis)

    rotationMatrix = zeros(3, 3);

    rotationMatrix(1, :) = normal;
    rotationMatrix(2, :) = principalAxis;
    rotationMatrix(3, :) = cross(normal, principalAxis);

    rotationPoints = pointClouds';
    rotationPoints = rotationMatrix * rotationPoints;
    rotationPoints = rotationPoints';

    for i = 1 : 1 : numberOfPoints
        
        plot3(rotationPoints(i, 1), rotationPoints(i, 3), rotationPoints(i, 2), 'c.');
        hold on;

    end


    Q = zeros(3, 3);
    c = zeros(3, 1);
    for i = 1 : 1 : numberOfPoints
   
        li = [
                - rotationPoints(i, 1);
                - rotationPoints(i, 3);
                1
             ];
     
        Q = Q + li * li';
    
        lambdai = rotationPoints(i, 1) ^ 2 + rotationPoints(i, 3) ^ 2;
    
        c = c + lambdai * li;
    
    end

    w =  - inv(Q) * c;

    circleCenterX = - 0.5 * w(1);
    circleCenterY = - 0.5 * w(2);
    circleRadius = sqrt(circleCenterX ^ 2 + circleCenterY ^ 2 - w(3));

    axisCoordinate = sum(rotationPoints(:, 2)) / numberOfPoints;

    centroidCylinderNoRotation = [
                                    circleCenterX; 
                                    axisCoordinate;
                                    circleCenterY
                                 ];
    centroid = rotationMatrix' * centroidCylinderNoRotation;
    centroid = centroid';

    extent = max(rotationPoints(:, 2)) - min(rotationPoints(:, 2));

end