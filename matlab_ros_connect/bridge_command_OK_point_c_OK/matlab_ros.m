ad_pub = false ;
subs = true ;
adv = false ;
t=tcpip('fetch7',9090);
t.InputBufferSize = 512000;
fopen(t);
i = 1;
if ad_pub
    if adv
        data = loadjson(['advertise.json']);
        json_com = savejson('',data);
        fprintf(t,json_com);
    else
        for i= 1:4
            data = loadjson(['publish.json']);
            json_com = savejson('',data);
            fprintf(t,json_com);
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
         receive = fscanf(t);
         [C,matches] = strsplit(receive,{'"'});
         final = base64decode(num2str(cell2mat(C(32))))

   end
end
    
    

fclose(t);