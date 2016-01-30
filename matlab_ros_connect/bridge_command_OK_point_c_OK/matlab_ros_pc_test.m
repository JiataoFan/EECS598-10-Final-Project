ad_pub = true ;
subs = false ;
adv = false ;
t=tcpip('fetch7',9090);
fopen(t);
i = 1;
if ad_pub
    if adv
        data = loadjson(['advertise_pointcloud.json']);
        json_com = savejson('',data);
        fprintf(t,json_com);
    else
        data = loadjson(['advertise_pointcloud.json']);
        json_com = savejson('',data);
        fprintf(t,json_com);
        data = loadjson(['subscribe_pointcloud.json']);
        json_com = savejson('',data);
        fprintf(t,json_com);
        for i= 1:100
            data = loadjson(['publish_pointcloud.json']);
            json_com = savejson('',data,'ParseLogical',1,'ArrayIndent',1);
            fprintf(t,json_com);
            while t.BytesAvailable 
                fscanf(t)
            end
            pause(1);
        end
    end
end
if subs
   data = loadjson(['subscribe.json']);
   json_com = savejson('',data);
   fprintf(t,json_com);
   pause(3)
   while t.BytesAvailable 
        fscanf(t)
%           fread(t)

   end
end
    
    

fclose(t);