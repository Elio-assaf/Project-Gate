
function [GateImage,princ_corners]=Prepare_Reference_Gate(image_number,corners,corners_struct)

GateImage = imread(strcat('img_',string(image_number),'.png'));

% greyimage
GateImage=rgb2gray(GateImage);

% blackout the nonrelevent part

table_id=find(corners(:,1)==image_number); 

princ_corners=corners_struct(corners(table_id(1),11)).corners1;


% taking only the relevent part of the image
mask=imread(strcat('mask_',string(image_number),'.png')); 
Size=size(GateImage);

% removing the second and third mask

for x= max(princ_corners(1),princ_corners(7)):min(princ_corners(5),princ_corners(3))
    for y= max(princ_corners(2),princ_corners(4)):min(princ_corners(6),princ_corners(8))
        mask(y,x)=0;   % remove masks inside the main mask
    end
end



 for i=1:Size(1)
     for j=1:Size(2)
         if mask(i,j)==0
             GateImage(i,j)=150; %make the backgroung grey
         end
     end
 end
 
 % crop
 a=40; 
 b=40; 

 GateImage=GateImage(min(princ_corners(2),princ_corners(4))-a ...
     :max(princ_corners(6),princ_corners(8))+b,...
     min(princ_corners(1),princ_corners(7))-b:...
     max(princ_corners(3),princ_corners(5))+a);
 
 
 princ_corners(2:2:8)=princ_corners(2:2:8)-min(princ_corners(2),princ_corners(4))+a;
 princ_corners(1:2:7)=princ_corners(1:2:7)-min(princ_corners(1),princ_corners(7))+b;
 
      
end



