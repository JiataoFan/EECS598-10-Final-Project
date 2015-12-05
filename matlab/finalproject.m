%helix
layers = 7;
t = 0:pi/200:pi;
%k = 0:pi/layers:pi;
X = sin(t);
Y = cos(t);

pointClouds=[];
indices=[];
pointCloudsRow=[];
pointCloudsRaw=load('eight_objects.pcd');

numberOfPoints=length(pointCloudsRaw);


for i=1:numberOfPoints
    
    if isfinite(pointCloudsRaw(i,1))==1 && isfinite(pointCloudsRaw(i,2))==1 && isfinite(pointCloudsRaw(i,3))==1
        indices=[indices;i];
        
        pointCloudsRow=pointCloudsRaw(i,:);
        pointClouds=[pointClouds;pointCloudsRow];
    end
end

numberOfPoints = layers * length(t);
pointClouds = zeros(numberOfPoints, 3);

for i = 1 : 1 : layers

    for j = 1 : 1 : length(t)
    
        pointClouds((i - 1) * length(t) + j, 1) = X(j);
        pointClouds((i - 1) * length(t) + j, 2) = Y(j);
        pointClouds((i - 1) * length(t) + j, 3) = (i - 1) * 0.1;
        
        plot3(X(j), Y(j), (i - 1) * 0.1, 'r.');
        hold on;

    end

end


parameterVector = fitQuadric(pointClouds, numberOfPoints);

[normal, principalAxis] = estimateMedianCurvature(pointClouds, numberOfPoints, parameterVector);

[circleCenterX, circleCenterY, circleRadius, centroid, extent] = fitCylinder(pointClouds, numberOfPoints, normal, principalAxis);