function graspSimulationVisualization(newPointClouds, neighborhoodCentroid, imageName)

    figure1 = figure;
    %figure
    plot3(newPointClouds(:, 1), newPointClouds(:, 2), newPointClouds(:, 3), 'k.')
    hold on;
    
    view(170, -30);
    refresh;
    
    vertex1 = [neighborhoodCentroid(1)+0.1, neighborhoodCentroid(2)+0.1, neighborhoodCentroid(3)+0.1];
    vertex2 = [neighborhoodCentroid(1)+0.1, neighborhoodCentroid(2)-0.1, neighborhoodCentroid(3)+0.1];
    vertex3 = [neighborhoodCentroid(1)-0.1, neighborhoodCentroid(2)+0.1, neighborhoodCentroid(3)+0.1];
    vertex4 = [neighborhoodCentroid(1)-0.1, neighborhoodCentroid(2)-0.1, neighborhoodCentroid(3)+0.1];
    
    vertex5 = [neighborhoodCentroid(1)+0.1, neighborhoodCentroid(2)+0.1, neighborhoodCentroid(3)-0.1];
    vertex6 = [neighborhoodCentroid(1)+0.1, neighborhoodCentroid(2)-0.1, neighborhoodCentroid(3)-0.1];
    vertex7 = [neighborhoodCentroid(1)-0.1, neighborhoodCentroid(2)+0.1, neighborhoodCentroid(3)-0.1];
    vertex8 = [neighborhoodCentroid(1)-0.1, neighborhoodCentroid(2)-0.1, neighborhoodCentroid(3)-0.1];
            
    line([vertex1(1) vertex2(1)],[vertex1(2) vertex2(2)],[vertex1(3) vertex2(3)]);
    line([vertex1(1) vertex3(1)],[vertex1(2) vertex3(2)],[vertex1(3) vertex3(3)]);
    line([vertex3(1) vertex4(1)],[vertex3(2) vertex4(2)],[vertex3(3) vertex4(3)]);
    line([vertex4(1) vertex2(1)],[vertex4(2) vertex2(2)],[vertex4(3) vertex2(3)]);
    
    line([vertex5(1) vertex6(1)],[vertex5(2) vertex6(2)],[vertex5(3) vertex6(3)]);
    line([vertex5(1) vertex7(1)],[vertex5(2) vertex7(2)],[vertex5(3) vertex7(3)]);
    line([vertex7(1) vertex8(1)],[vertex7(2) vertex8(2)],[vertex7(3) vertex8(3)]);
    line([vertex8(1) vertex6(1)],[vertex8(2) vertex6(2)],[vertex8(3) vertex6(3)]);
    
    line([vertex1(1) vertex5(1)],[vertex1(2) vertex5(2)],[vertex1(3) vertex5(3)]);
    line([vertex2(1) vertex6(1)],[vertex2(2) vertex6(2)],[vertex2(3) vertex6(3)]);
    line([vertex3(1) vertex7(1)],[vertex3(2) vertex7(2)],[vertex3(3) vertex7(3)]);
    line([vertex4(1) vertex8(1)],[vertex4(2) vertex8(2)],[vertex4(3) vertex8(3)]);
    
    saveas(figure1, imageName);

end