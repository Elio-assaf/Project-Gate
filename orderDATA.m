

function [corners,corners_struct]=orderDATA(corners)


id=0;
j=1;
corners(688,1)=9;
for i=1:688
    if corners(i,1) ~= id
        id=corners(i,1);
        corners(i,11)=j;
        if corners(i+1,1) == corners(i+2,1)
            corners_struct(j).image_number=corners(i,1);
            corners_struct(j).corners1=corners(i,2:9)  ;
            corners_struct(j).duplicats=3;
            corners_struct(j).corners2=corners(i+1,2:9);
            corners_struct(j).corners3=corners(i+2,2:9);
            
        elseif corners(i,1) == corners(i+1,1)
            corners_struct(j).image_number=corners(i,1);
            corners_struct(j).corners1=corners(i,2:9)  ;
            corners_struct(j).duplicats=2;
            corners_struct(j).corners2=corners(i+1,2:9);
        
        else
           
            corners_struct(j).image_number=corners(i,1);
            corners_struct(j).corners1=corners(i,2:9)  ;
            corners_struct(j).duplicats=1;
           
            
        end
   
    j=j+1;
    end
end

end