%---------------------------------------------------------------%
%              Function for sending data to command Fetch
%
%          normal 1X3 array praxis 1X3 array  point 1X3 array
%
%---------------------------------------------------------------%
function matlab_ros_c(normal, praxis, point)

%     t=tcpip('fetch7',9090);
%     fopen(t);
    adver = loadjson(['advertise.json']);
    json_com_adver = savejson('',adver);
%     fprintf(t,json_com_adver);
    publ = loadjson(['publish.json']);
    publ.msg.normal.x = normal(1);
    publ.msg.normal.y = normal(2);
    publ.msg.normal.z = normal(3);
    publ.msg.principalAxis.x = praxis(1);
    publ.msg.principalAxis.y = praxis(2);
    publ.msg.principalAxis.z = praxis(3);
    publ.msg.point.x = point(1);
    publ.msg.point.y = point(2);
    publ.msg.point.z = point(3);
    json_com_publ = savejson('',publ)
%     for i= 1:20
%         
%         fprintf(t,json_com_publ);
%         pause(1);
%     end
% 
% 
% 
% 
% 
%     fclose(t);
end