% clear all

%helix
layers = 7;
t = 0:pi/200:pi;
%k = 0:pi/layers:pi;
X = sin(t);
Y = cos(t);

%% extract data from pointcloud
pointClouds=[];
indices=[];
pointCloudsRow=[];
pointCloudsRaw=load('eight_objects.pcd');

numberOfPointsRaw=length(pointCloudsRaw);

% numberOfPoints
for i=1:numberOfPointsRaw
    
    if isfinite(pointCloudsRaw(i,1))==1 && isfinite(pointCloudsRaw(i,2))==1 && isfinite(pointCloudsRaw(i,3))==1
        indices=[indices;i];
        
        pointCloudsRow=pointCloudsRaw(i,:);
        pointClouds=[pointClouds;pointCloudsRow];
    end
end

numberOfPoints=length(pointClouds)

%% sampling


numberOfNeighborCenter=100

[sampledPointClouds,idx]=datasample(pointClouds,numberOfNeighborCenter);
idx=idx'
sampledPointClouds=[sampledPointClouds idx];
neighbor=struct();
neighborPoints=[];
for i=1:length(idx)
    for j=1:numberOfPoints
        if sqrt((sampledPointClouds(i,1)-pointClouds(j,1))^2+(sampledPointClouds(i,2)-pointClouds(j,2))^2+(sampledPointClouds(i,3)-pointClouds(j,3))^2) < 0.01            
            l=['neighbor' num2str(sampledPointClouds(i,4))];
            neighborPoints=[neighborPoints;pointClouds(j,:)];
            neighbor.(l)=neighborPoints;
        end
    end
    neighborPoints=[];
end

%Accesing each neighborhood

%iterate through every sampledPointClouds

% for i = 1:1:length(idx)
    i=2
    neighborhoods=neighbor.(['neighbor' num2str(idx(i))])
    numberOfNeighborhoods=length(neighborhoods);
    for k= 1: length(idx)
        if sampledPointClouds(k,4)==idx(i)
           plot3(sampledPointClouds(k,1),sampledPointClouds(k,2),sampledPointClouds(k,3),'ro')
           hold on;
        end
    end
    for j = 1:length(neighborhoods)
    plot3(neighborhoods(j,1),neighborhoods(j,2),neighborhoods(j,3),'b.');
    hold on
    end



%numberOfPoints = layers * length(t);
% pointClouds = zeros(numberOfPoints, 3);
% 
% for i = 1 : 1 : layers
% 
%     for j = 1 : 1 : length(t)
%     
%         pointClouds((i - 1) * length(t) + j, 1) = X(j);
%         pointClouds((i - 1) * length(t) + j, 2) = Y(j);
%         pointClouds((i - 1) * length(t) + j, 3) = (i - 1) * 0.1;
%         
%         plot3(X(j), Y(j), (i - 1) * 0.1, 'r.');
%         hold on;
% 
%     end
% 
% end


parameterVector = fitQuadric(neighborhoods, numberOfNeighborhoods);

% add output of median value to use if
[normal, principalAxis] = estimateMedianCurvature(pointClouds, numberOfPoints, parameterVector);
%if median value >k
[circleCenterX, circleCenterY, circleRadius, centroid, extent] = fitCylinder(pointClouds, numberOfPoints, normal, principalAxis);


% end