
function [GateImage,princ_corners]=Prepare_Reference_Gate_2(image_number,corners,corners_struct)

GateImage = imread(strcat('img_',string(image_number),'.png'));
 
%% greyimage
GateImage=rgb2gray(GateImage);

%% blackout the nonrelevent part

table_id=find(corners(:,1)==image_number); 

princ_corners=corners_struct(corners(table_id(1),11)).corners1;


% taking only the relevent part of the image
Mask=imread(strcat('mask_',string(image_number),'.png')); 
Size=size(GateImage); % the size of gate and mask is the same



%% Distorting the image 

points_prev = [princ_corners(1:2:7) % v / x    % gate polygone
               princ_corners(2:2:8)];  % u / y
points_now = [ princ_corners(1) princ_corners(5) princ_corners(5) princ_corners(1) % [v ,u]    % new gate polygone
               princ_corners(2) princ_corners(2) princ_corners(6) princ_corners(6)];
           

tform = fitgeotrans(points_prev',points_now','projective');


newGatePolygon = transformPointsForward(tform, points_prev');

R = imref2d(Size);
newGateImage = imwarp(GateImage,tform,'OutputView',R);
newMask= imwarp(Mask,tform,'OutputView',R);

%% removing the second and third mask

for x=princ_corners(1):princ_corners(5)
    for y= princ_corners(2):princ_corners(6)
        newMask(y,x)=0;   % remove masks inside the main mask
    end
end



 for i=1:Size(1)
     for j=1:Size(2)
         if newMask(i,j)==0
             newGateImage(i,j)=150; %make the backgroung grey
         end
     end
 end
 
 %% crop
 a1=40;  
 b1=40;  
 newGateImage=newGateImage(princ_corners(2)-a1 ...
     :princ_corners(6)+b1,...
     princ_corners(1)-b1:...
     princ_corners(5)+a1);
 
 
 princ_corners(2:2:8)=princ_corners(2:2:8)-princ_corners(2)+a1+1;
 princ_corners(1:2:7)=princ_corners(1:2:7)-princ_corners(1)+b1+1;
 princ_corners(7)=princ_corners(1);
 princ_corners(3)=princ_corners(5);
 princ_corners(4)=princ_corners(2);
 princ_corners(8)=princ_corners(6);
 GateImage=newGateImage;

         
end



