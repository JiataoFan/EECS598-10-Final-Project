ad_pub =true ;
subs = false ;
t=tcpip('fetch7',9090);
fopen(t);
if ad_pub
    data = loadjson(['advertise.json']);
    json_com = savejson('',data);
    fprintf(t,json_com);
    for i= 1:20
        data = loadjson(['publish.json']);
        json_com = savejson('',data);
        fprintf(t,json_com);
        pause(1);
    end
end
if subs
   data = loadjson(['subscribe.json']);
   json_com = savejson('',data);
   fprintf(t,json_com);
   fscanf(t)
end
    
    

fclose(t);