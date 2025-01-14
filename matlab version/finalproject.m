% main function

%% extraction of data from point cloud, which filters out nans and scene edges

% raw point cloud data
pointCloudsRaw = load('eight_objects.pcd');

% number of point in raw point cloud
numberOfPointsRaw = length(pointCloudsRaw);

% stores the selected real points
pointClouds = zeros(numberOfPointsRaw, 3);
% indices of selected real points in raw point cloud
indices = zeros(numberOfPointsRaw, 1);

% select from the 10000th points from the raw point cloud to crop out the 
% messy edges of the scene
numberOfPoints = 0;
for i = 90000 : numberOfPointsRaw - 100000
    
    % rule out nan points
    if isfinite(pointCloudsRaw(i, 1)) && isfinite(pointCloudsRaw(i, 2)) && isfinite(pointCloudsRaw(i, 3))

        numberOfPoints = numberOfPoints + 1;

        indices(numberOfPoints, 1) = i;

        pointClouds(numberOfPoints, :) = pointCloudsRaw(i, :);

    end

end

indices = indices(1 : numberOfPoints, :);
pointClouds = pointClouds(1 : numberOfPoints, :);

%  Irina Code
pointCloudsTrans = pointClouds';

angle = 2.6*pi/4;
rotationmat = [ 1, 0, 0;
                0, cos(angle), -sin(angle);
                0, sin(angle),  cos(angle)];

pointClouds = (rotationmat * pointCloudsTrans)';

% visualize point cloud
figure1 = figure;
axis equal;
plot3(pointClouds(:, 1), pointClouds(:, 2), pointClouds(:, 3), 'k.')
hold on;

%% sampling neighborhoods from the point cloud

numberOfNeighborhoodCentroids = 1000;

% randomly sample points as centroids of neighborhoods
[neighborhoodCentroids, neighborhoodCentroidsIndices] = datasample(pointClouds, numberOfNeighborhoodCentroids);
neighborhoodCentroidsIndices = neighborhoodCentroidsIndices';
neighborhoodCentroids = [neighborhoodCentroids neighborhoodCentroidsIndices];

% each neighborhood is a matrix storing the coordinates of 
% each point in it, and we store all the neighborhoods in a struct
neighborhoods = struct();

% for each neighborhood centroids we include all the points that are within
% a sphere of certain radius around it as a neighborhood
for i = 1 : numberOfNeighborhoodCentroids

    singleNeighborhoodPoints = zeros(numberOfPoints, 3);
    numberOfSingleNeighborhoodPoints = 0;
    
    for j = 1 : numberOfPoints
        
        xNormSquare = (neighborhoodCentroids(i, 1) - pointClouds(j, 1)) ^ 2;
        yNormSquare = (neighborhoodCentroids(i, 2) - pointClouds(j, 2)) ^ 2;
        zNormSquare = (neighborhoodCentroids(i, 3) - pointClouds(j, 3)) ^ 2;
        
        distance = sqrt(xNormSquare +  yNormSquare + zNormSquare);

        if  distance < 0.05
            
            numberOfSingleNeighborhoodPoints = numberOfSingleNeighborhoodPoints + 1;
            
            singleNeighborhoodPoints(numberOfSingleNeighborhoodPoints, :) = pointClouds(j, :);
            
        end
        
    end
    
    l = ['neighborhood' num2str(i)];
    
    singleNeighborhoodPoints = singleNeighborhoodPoints(1 : numberOfSingleNeighborhoodPoints, :);
    
    neighborhoods.(l) = singleNeighborhoodPoints;

end

% visualize neighborhood centroids
% plot3(neighborhoodCentroids(:, 1), neighborhoodCentroids(:, 2), neighborhoodCentroids(:, 3), 'ro')
% hold on;

%% for each neighborhood, calculate principal curvature, normal and axis

curvatures = zeros(numberOfNeighborhoodCentroids, 1);
normals = zeros(numberOfNeighborhoodCentroids, 3);
principalAxes = zeros(numberOfNeighborhoodCentroids, 3);

for i = 1 : numberOfNeighborhoodCentroids

    neighborhood = neighborhoods.(['neighborhood' num2str(i)]);
    numberOfNeighborhoodPoints = length(neighborhood);

    %plot3(neighborhood(:, 1), neighborhood(:, 2), neighborhood(:, 3), 'b.');
    %hold on

    parameterVector = fitQuadric(neighborhood, numberOfNeighborhoodPoints);

    % calculate cuvature, normal and axis via function
    % estmateMedianCurvature()
    [curvature ,normal, principalAxis] = estimateMedianCurvature(neighborhood, numberOfNeighborhoodPoints, parameterVector);

    curvatures(i) = curvature;
    normals(i, :) = normal;
    principalAxes(i, :) = principalAxis;
    
end

%% filter out the neighborhoods with curvature below certain threshhold

filteredNeighborhoodsIndices = zeros(numberOfNeighborhoodCentroids, 1);
numberOfFilteredNeighborhoods = 0;
for i = 1 : numberOfNeighborhoodCentroids
   
    if curvatures(i) > 2
        
        numberOfFilteredNeighborhoods = numberOfFilteredNeighborhoods + 1;
        
        filteredNeighborhoodsIndices(numberOfFilteredNeighborhoods) = i;
        
    end
    
end

filteredNeighborhoodsIndices = filteredNeighborhoodsIndices(1 : numberOfFilteredNeighborhoods);

%% for each neighborhood, fit a circle to the points projected on a orthogonal plane to the axis

circlesInfo = zeros(numberOfFilteredNeighborhoods, 3);
shellCentroids = zeros(numberOfFilteredNeighborhoods, 3);
shellExtents = zeros(numberOfFilteredNeighborhoods, 1);

for i = 1 : numberOfFilteredNeighborhoods

    neighborhood = neighborhoods.(['neighborhood' num2str(filteredNeighborhoodsIndices(i))]);
    numberOfNeighborhoodPoints = length(neighborhood);
    
    normal = normals(filteredNeighborhoodsIndices(i), :);
    principalAxis = principalAxes(filteredNeighborhoodsIndices(i), :);
    neighborhoodCentroid = neighborhoodCentroids(filteredNeighborhoodsIndices(i), :);
    
    % calculate circle coordinates, circle radius, shell centroid and 
    % shell extent with function fitCylinder()
    [circleCenterX, circleCenterY, circleRadius, shellCentroid, shellExtent] = fitCylinder(neighborhood, numberOfNeighborhoodPoints, normal, principalAxis, neighborhoodCentroid);
    
    circlesInfo(i, :) = [circleCenterX, circleCenterY, circleRadius];
    shellCentroids(i, :) = shellCentroid;
    shellExtents(i) = shellExtent;

end

%% filter out the neighborhoods with a gap to let the robot hand fit in

gapFilteredNeighborhoodsIndices = zeros(numberOfFilteredNeighborhoods, 1);
numberOfGapFilteredNeighborhoodsIndices = 0;
for i = 1 : numberOfFilteredNeighborhoods

    neighborhood = neighborhoods.(['neighborhood' num2str(filteredNeighborhoodsIndices(i))]);
    numberOfNeighborhoodPoints = length(neighborhood);
    
    principalAxis = principalAxes(filteredNeighborhoodsIndices(i), :);
    shellCentroid = shellCentroids(i, :);
    shellExtent = shellExtents(i, :);
    circleRadius = circlesInfo(i, 3);
    
    % ensure the neighborhood has a gap outside the shell via function
    % hasClearance()
    if hasClearance(neighborhood, numberOfNeighborhoodPoints, principalAxis, shellCentroid, circleRadius, shellExtent)
        
        numberOfGapFilteredNeighborhoodsIndices = numberOfGapFilteredNeighborhoodsIndices + 1;
        
        gapFilteredNeighborhoodsIndices(numberOfGapFilteredNeighborhoodsIndices) = i;
        
    end
    
end

gapFilteredNeighborhoodsIndices = gapFilteredNeighborhoodsIndices(1 : numberOfGapFilteredNeighborhoodsIndices);

%% visualize the graspable parts of point cloud that has gap clearance

for i = 1 : numberOfGapFilteredNeighborhoodsIndices
    
    neighborhood = neighborhoods.(['neighborhood' num2str(filteredNeighborhoodsIndices(gapFilteredNeighborhoodsIndices(i)))]);
    numberOfNeighborhoodPoints = length(neighborhood);

    plot3(neighborhood(:, 1), neighborhood(:, 2), neighborhood(:, 3), 'g.');
    hold on;
    
end

% for i = 0 : 20 : 360
%     
%     view(i, -30);
%     refresh;
%     drawnow;
%     saveas(figure1, ['allGraspableAreas' num2str(i) '.jpg']);
%     
% end


%% sort the graspable areas according to their altitude
% 
% for i = 2 : numberOfGapFilteredNeighborhoodsIndices
%    
%     j = i;
%     while j > 1 && neighborhoodCentroids(filteredNeighborhoodsIndices(gapFilteredNeighborhoodsIndices(j - 1)), 3) > neighborhoodCentroids(filteredNeighborhoodsIndices(gapFilteredNeighborhoodsIndices(j)), 3)
% 
%         temp =  gapFilteredNeighborhoodsIndices(j);
%         gapFilteredNeighborhoodsIndices(j) = gapFilteredNeighborhoodsIndices(j-1);
%         gapFilteredNeighborhoodsIndices(j-1) = temp;
%         
%         j = j - 1;
% 
%     end
%     
% end

%% find the graspable area with the highest altitude

graspableNeighborhoodCentroids = zeros(numberOfGapFilteredNeighborhoodsIndices, 3);
for i = 1 : numberOfGapFilteredNeighborhoodsIndices

    graspableNeighborhoodCentroids(i, :) = neighborhoodCentroids(filteredNeighborhoodsIndices(gapFilteredNeighborhoodsIndices(i)), 1 : 3);

end

graspableNeighborhoodCentroids = (rotationmat' * graspableNeighborhoodCentroids')';

[highestGraspableCentroidZ, highestGraspableCentroidIndex] = min(graspableNeighborhoodCentroids(:, 3));

%% visualization

figure
axis equal;
plot3(pointClouds(:, 1), pointClouds(:, 2), pointClouds(:, 3), 'k.');
hold on;

neighborhood = neighborhoods.(['neighborhood' num2str(filteredNeighborhoodsIndices(gapFilteredNeighborhoodsIndices(highestGraspableCentroidIndex)))]);

plot3(neighborhood(:, 1), neighborhood(:, 2), neighborhood(:, 3), 'g.');
hold on;

normal = normals(filteredNeighborhoodsIndices(gapFilteredNeighborhoodsIndices(highestGraspableCentroidIndex)), :);
principalAxis = principalAxes(filteredNeighborhoodsIndices(gapFilteredNeighborhoodsIndices(highestGraspableCentroidIndex)), :);
neighborhoodCentroid = neighborhoodCentroids(filteredNeighborhoodsIndices(gapFilteredNeighborhoodsIndices(highestGraspableCentroidIndex)), :);

quiver3(neighborhoodCentroid(1, 1), neighborhoodCentroid(1, 2), neighborhoodCentroid(1, 3), normal(1,1), normal(1,2), normal(1,3), 'b');
quiver3(neighborhoodCentroid(1, 1), neighborhoodCentroid(1, 2), neighborhoodCentroid(1, 3), principalAxis(1,1), principalAxis(1,2), principalAxis(1,3), 'y');
hold on;

normal = (rotationmat' * normal')';
principalAxis = (rotationmat' * principalAxis')';
neighborhoodCentroid = (rotationmat' * neighborhoodCentroid(1:3)')';

matlab_ros_c(normal, principalAxis, neighborhoodCentroid);

%% simulate multi-object task

% newPointClouds = pointClouds;
% newNumberOfPoints = numberOfPoints;
% 
% for i = 1 : numberOfGapFilteredNeighborhoodsIndices
% 
%     neighborhoodCentroid = neighborhoodCentroids(filteredNeighborhoodsIndices(gapFilteredNeighborhoodsIndices(i)), :);
% 
%     graspSimulationVisualization(newPointClouds, neighborhoodCentroid, ['before' num2str(i) '.jpg']);
% 
%     j = 1;
%     while j <= newNumberOfPoints
% 
%         deltaX = abs(newPointClouds(j, 1) - neighborhoodCentroid(1));
%         deltaY = abs(newPointClouds(j, 2) - neighborhoodCentroid(2));
%         deltaZ = abs(newPointClouds(j, 3) - neighborhoodCentroid(3));
% 
%         if deltaX < 0.1 && deltaY < 0.1 && deltaZ < 0.1
% 
%             newPointClouds(j, :) = [];
%             
%             newNumberOfPoints = newNumberOfPoints - 1;
%  
%         else
% 
%             j = j + 1;
% 
%         end
% 
%     end
% 
%    graspSimulationVisualization(newPointClouds, neighborhoodCentroid, ['after' num2str(i) '.jpg']);
% 
% end