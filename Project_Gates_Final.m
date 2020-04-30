 %% Setting up
clear all;
close all;
clc;
% you can already run the whole code without changing anything
% NB: the order of the images is changed
%% settings
display=1; 
% = 1 for displaying details
% = 2 for displaying minimal details
% = 3 for displaying the result plot only
% = 0 for not displaying anything

sample=1; %change sample to sample images
frames= 68 ; % this is the frames we want to analyse % to analyse all the images, change to 1:sample:308

%% parameters for Phase I and Phase II
% Phase 1    (10,1)
MatchThreshold_1_in=10;   % parameter 1 %% The threshold represents a percent of the distance from a perfect match 
MaxRatio_1_in=0.95; % parameter 2 %% increase to consider more ambiguous matches 
% Phase 2    (6,0.8)
MatchThreshold_2_in=6;   %parameter 3 
MaxRatio_2_in=1;   %parameter 4 

% to take the data for an ROC curve, replace the parameter(s) studied by a
% discrete raw vector and run
% NB: it would be a good idea to put the display to 0
% example : MatchThreshold_1_in=2:3:30
% the data for the ROC is written in "Counter"

%% importing data
load('corners.mat')
[corners,corners_struct]=orderDATA(corners); % orders the data in a practical way we can use it

img_folder = ('image');
mask_folder = ('mask');

img_files = dir(img_folder);
img_files = img_files(3:end);
addpath(img_files(1).folder);

mask_files = dir(mask_folder);
mask_files = mask_files(3:end);
addpath(mask_files(1).folder);

%% Read the reference image containing the object of interest.

% Gate Template
image_number=190; %190 73 331 433
image_number1=73; %270
image_number2=331; %331
image_number3=433; %433

Case = 0;  % 0 for the most general case
switch Case
    case 2  % only 1 template image trained without normalized visualization
        [GateImage,princ_corners] = Prepare_Reference_Gate(image_number,corners,corners_struct);
        GateImage_normalised=GateImage;
        princ_corners_normalised=princ_corners;
       
    case 1 % only 1 template image trained and normalized visualization 
        [GateImage,princ_corners] = Prepare_Reference_Gate(image_number,corners,corners_struct);
        [GateImage_normalised,princ_corners_normalised] = Prepare_Reference_Gate_2(image_number,corners,corners_struct);
        switch display
            case 1
         figure()
         imshow(GateImage)
        end
    case 0 % 4 template images trained and normalized visualization
        [GateImage,princ_corners] = Prepare_Reference_Gate(image_number,corners,corners_struct);
        [GateImage_normalised,princ_corners_normalised] = Prepare_Reference_Gate_2(image_number,corners,corners_struct);
        
        [GateImage1,princ_corners1] = Prepare_Reference_Gate(image_number1,corners,corners_struct);
        [GateImage2,princ_corners2] = Prepare_Reference_Gate(image_number2,corners,corners_struct);
        [GateImage3,princ_corners3] = Prepare_Reference_Gate(image_number3,corners,corners_struct);
        switch display
        case 1
        figure()
        imshow(GateImage)
        end
end

%% Detect SURF feature points in The Gate (Pre-Analysis of the Gate Templates)
% detect gate points from non normalised image
GatePoints = detectSURFFeatures(GateImage);

tform = fitgeotrans([princ_corners(1:2:7);princ_corners(2:2:8)]',[princ_corners_normalised(1:2:7);princ_corners_normalised(2:2:8)]','projective');
GatePoints_NiceVisualisation=GatePoints;
% normalised gate points (just changed the location)
GatePoints_NiceVisualisation.Location=transformPointsForward(tform, GatePoints.Location);

if Case==0
GatePoints_extra1 = detectSURFFeatures(GateImage1);
GatePoints_extra2 = detectSURFFeatures(GateImage2);
GatePoints_extra3 = detectSURFFeatures(GateImage3);

tform1 = fitgeotrans([princ_corners1(1:2:7);princ_corners1(2:2:8)]',[princ_corners_normalised(1:2:7);princ_corners_normalised(2:2:8)]','projective');
tform2 = fitgeotrans([princ_corners2(1:2:7);princ_corners2(2:2:8)]',[princ_corners_normalised(1:2:7);princ_corners_normalised(2:2:8)]','projective');
tform3 = fitgeotrans([princ_corners3(1:2:7);princ_corners3(2:2:8)]',[princ_corners_normalised(1:2:7);princ_corners_normalised(2:2:8)]','projective');
% the nice visualisation is only for seing the strongest Features from the
% Gate
GatePoints_NiceVisualisation_extra1=GatePoints_extra1;
GatePoints_NiceVisualisation_extra2=GatePoints_extra2;
GatePoints_NiceVisualisation_extra3=GatePoints_extra3;

GatePoints_NiceVisualisation_extra1.Location=transformPointsForward(tform1, GatePoints_extra1.Location);
GatePoints_NiceVisualisation_extra2.Location=transformPointsForward(tform2, GatePoints_extra2.Location);
GatePoints_NiceVisualisation_extra3.Location=transformPointsForward(tform3, GatePoints_extra3.Location);
end

%Visualize the strongest feature points found in the reference images.

%% Visualisation

switch display
    case 1
figure;
imshow(GateImage_normalised);
title('200 Strongest Feature Points from Gate Image');
hold on;
plot(selectStrongest(GatePoints_NiceVisualisation, 50));
if Case==0
plot(selectStrongest(GatePoints_NiceVisualisation_extra1, 50));
plot(selectStrongest(GatePoints_NiceVisualisation_extra2, 50));
plot(selectStrongest(GatePoints_NiceVisualisation_extra3, 50));
end
end
%% taking the upper and lower features only
% sometimes useless
% takes the upper and lower 25% of the image features only
n = 0; % 1 to do something (keep 0)

switch n
    case 1
        SS=size(GateImage_normalised);
        for i=length(GatePoints_NiceVisualisation.Location):-1:1
          if  getfield(GatePoints_NiceVisualisation(i),'Location',{2})>=SS(1)/4 && getfield(GatePoints_NiceVisualisation(i),'Location',{2})<=3*SS(1)/4 
        GatePoints_NiceVisualisation(i)=[];
        GatePoints(i)=[];
          end
        end
        if Case==0
         for i=length(GatePoints_NiceVisualisation_extra1.Location):-1:1
          if  getfield(GatePoints_NiceVisualisation_extra1(i),'Location',{2})>=SS(1)/4 && getfield(GatePoints_NiceVisualisation_extra1(i),'Location',{2})<=3*SS(1)/4 
        GatePoints_NiceVisualisation_extra1(i)=[];
        GatePoints_extra1(i)=[];
          end
         end
        for i=length(GatePoints_NiceVisualisation_extra2.Location):-1:1
          if  getfield(GatePoints_NiceVisualisation_extra2(i),'Location',{2})>=SS(1)/4 && getfield(GatePoints_NiceVisualisation_extra2(i),'Location',{2})<=3*SS(1)/4 
        GatePoints_NiceVisualisation_extra2(i)=[];
        GatePoints_extra2(i)=[];
          end
        end
        for i=length(GatePoints_NiceVisualisation_extra3.Location):-1:1
          if  getfield(GatePoints_NiceVisualisation_extra3(i),'Location',{2})>=SS(1)/4 && getfield(GatePoints_NiceVisualisation_extra3(i),'Location',{2})<=3*SS(1)/4 
        GatePoints_NiceVisualisation_extra3(i)=[];
        GatePoints_extra3(i)=[];
          end
        end
        end
    case 0
        % do nothing
end
%% Extract feature descriptors at the GatePoints.

% can add something pour prendree juste les droites a un degre pres.

[GateFeatures] = extractFeatures(GateImage, GatePoints);
if Case==0

% we take the features from the original location
[GateFeatures_extra1] = extractFeatures(GateImage1, GatePoints_extra1);
[GateFeatures_extra2] = extractFeatures(GateImage2, GatePoints_extra2);
[GateFeatures_extra3] = extractFeatures(GateImage3, GatePoints_extra3);
end
%% here we add up the gate points and feautures of all the template images
if Case==0
    
% we are associating the Features (extractyed from their actual position )
% to a normalized position 
GateFeatures=[GateFeatures;GateFeatures_extra1;GateFeatures_extra2;GateFeatures_extra3];

% now GatePoints is the normalized GatePoints
GatePoints=[GatePoints_NiceVisualisation;GatePoints_NiceVisualisation_extra1;GatePoints_NiceVisualisation_extra2;GatePoints_NiceVisualisation_extra3];
end

if Case == 1
GatePoints=GatePoints_NiceVisualisation;
end

%% Iterate (Post-Analysis)
% here we iterate all over the images
%--------------

Results.Frame=[] ;
Results.ImageNumber=[];
Results.Result=[];
Results.binomial=[];
Results.Method=[];
Results.AreaRatio=[];
Results.PolyOriginal=[];
Results.PolyFound=[];

z=2;
for MatchThreshold_1 = MatchThreshold_1_in
    for MaxRatio_1 = MaxRatio_1_in
        for MatchThreshold_2 = MatchThreshold_2_in
            for MaxRatio_2 = MaxRatio_2_in
a=MatchThreshold_1;
b=MaxRatio_1;
c=MatchThreshold_2;
d=MaxRatio_2;
for frame = frames 
   disp(strcat("frame :  ",num2str(frame),"   ||   iteration :  ", num2str((z-2)/3+1),"   ||   MT_1 :  ",num2str(a),"   ||   MR_1 : ",num2str(b),...
       "   ||   MT_2 :  ",num2str(c),"   ||   MR_2 :  ",num2str(d)))
    image_num = corners_struct(frame).image_number ;
Results(frame).Frame=frame ;
Results(frame).ImageNumber=image_num;

SceneImage = rgb2gray(imread(strcat('img_',string(image_num),'.png')));

%% Cropping the Scene

% remove unnecessary parts of the gates based on the average grey color
% seeling is more dark
% floor is more bright

[SceneImage,upper_removal,left_removal]= CroppingSceneImage(SceneImage);
 
% figure;
% imshow(SceneImage);
% title('Image of the cropped Scene');

%% Detect SURF feature points in The Scene.

ScenePoints = detectSURFFeatures(SceneImage);

%% Visualisation

switch display
    case 1
%Visualize the strongest feature points found in the target image.
figure;
imshow(SceneImage);
title('100 Strongest Feature Points from Scene Image');
hold on;
plot(selectStrongest(ScenePoints, 100));
end
%% Extract feature descriptors at the ScenePoints.

[SceneFeatures, ScenePoints] = extractFeatures(SceneImage, ScenePoints);

%Match the features using their descriptors.

GatePairs = matchFeatures(GateFeatures, SceneFeatures,'MatchThreshold',MatchThreshold_1,'MaxRatio', MaxRatio_1); % takes more features % 10 ,  1


%before improving
matchedGatePoints = GatePoints(GatePairs(:, 1), :);
matchedScenePoints = ScenePoints(GatePairs(:, 2), :);

switch display
    case 1
figure;
showMatchedFeatures(GateImage_normalised, SceneImage, matchedGatePoints, ...
    matchedScenePoints, 'montage');

title('Phase I Matched Points (Including Outliers)');
end

%% Rematching the features intelligently

Scene_Location=ScenePoints(GatePairs(:, 2), :).Location; 
Average_point=round(sum(Scene_Location)/length(Scene_Location));
%% most basic guess untill now
S=size(SceneImage);
basic_gate=Average_point+[ -S(2) , -S(1)  ; +S(2) , -S(1) ; S(2) , S(1) ; -S(2) , S(1) ;-S(2) , -S(1) ]./5; % makes the drone just go forward; % most basic guess

switch display
    case {1,2}
%Display the detected object.
figure;
imshow(SceneImage);
hold on;
line(basic_gate(:, 1), basic_gate(:, 2), 'Color', 'y');
title('Most basic detection');
end


try   % to continue if any error in rematching and take the most basic guess (only used in ROC curves for impossible parameters)
    
S1=size(GateImage_normalised);  

% get the non already matched GatePoints and Scene Points belonging to the
% right locations and match them again:

 GatePoints1_id=[];
 GatePoints2_id=[];
 GatePoints3_id=[];
 GatePoints4_id=[];
   

for i=1:length(GatePoints)
    xy_G=GatePoints(i).Location ;  % x y axis location 
    if xy_G(2) < round((S1(1))/2) && xy_G(1) < round((S1(2))/2) % top left corner
        GatePoints1_id = [GatePoints1_id, i]; % add points id to gatepoints1
        
    elseif xy_G(2) < round((S1(1))/2) && xy_G(1) > round((S1(2))/2) % top right corner
        GatePoints2_id = [GatePoints2_id, i ]; % add points id to gatepoints2
        
    elseif xy_G(2) > round((S1(1))/2) && xy_G(1) > round((S1(2))/2) % bottum right corner
        GatePoints3_id = [GatePoints3_id, i]; % add points id to gatepoints3
          
    elseif xy_G(2) > round((S1(1))/2) && xy_G(1) < round((S1(2))/2)  % bottum lrft corner
        GatePoints4_id = [GatePoints4_id, i ]; % add points id to gatepoints4
           
    end
end

 GatePoints1=GatePoints(GatePoints1_id);
 GateFeatures1=GateFeatures(GatePoints1_id,:);
 GatePoints2=GatePoints(GatePoints2_id);
 GateFeatures2=GateFeatures(GatePoints2_id,:);
 GatePoints3=GatePoints(GatePoints3_id);
 GateFeatures3=GateFeatures(GatePoints3_id,:);
 GatePoints4=GatePoints(GatePoints4_id);
 GateFeatures4=GateFeatures(GatePoints4_id,:);

 ScenePoints1_id=[];
 ScenePoints2_id=[];
 ScenePoints3_id=[];
 ScenePoints4_id=[];


for i=1:length(ScenePoints)
    xy_S=ScenePoints(i).Location; % x y axis location 
    if xy_S(2) < Average_point(2) && xy_S(1) < Average_point(1) 
        ScenePoints1_id = [ScenePoints1_id, i]; % add points id to Scenepoints1
      
    elseif xy_S(2) < Average_point(2) && xy_S(1) > Average_point(1) 
        ScenePoints2_id = [ScenePoints2_id, i]; % add points id to Scenepoints2
        
    elseif xy_S(2) > Average_point(2) && xy_S(1) > Average_point(1) 
        ScenePoints3_id = [ScenePoints3_id, i]; % add points id to Scenepoints3
         
    elseif xy_S(2) > Average_point(2) && xy_S(1) < Average_point(1) 
        ScenePoints4_id = [ScenePoints4_id, i]; % add points id to Scenepoints4
         
    end
end

ScenePoints1=ScenePoints(ScenePoints1_id);
SceneFeatures1=SceneFeatures(ScenePoints1_id,:);
ScenePoints2=ScenePoints(ScenePoints2_id);
SceneFeatures2=SceneFeatures(ScenePoints2_id,:);
ScenePoints3=ScenePoints(ScenePoints3_id);
SceneFeatures3=SceneFeatures(ScenePoints3_id,:);
ScenePoints4=ScenePoints(ScenePoints4_id);
SceneFeatures4=SceneFeatures(ScenePoints4_id,:);

% match again intelligently

GatePairs1 = matchFeatures(GateFeatures1, SceneFeatures1,'MatchThreshold',MatchThreshold_2,'MaxRatio', MaxRatio_2);
GatePairs2 = matchFeatures(GateFeatures2, SceneFeatures2,'MatchThreshold',MatchThreshold_2,'MaxRatio', MaxRatio_2);
GatePairs3 = matchFeatures(GateFeatures3, SceneFeatures3,'MatchThreshold',MatchThreshold_2,'MaxRatio', MaxRatio_2);
GatePairs4 = matchFeatures(GateFeatures4, SceneFeatures4,'MatchThreshold',MatchThreshold_2,'MaxRatio', MaxRatio_2);



% take matched points after finding the respective matched pairs
matchedGatePoints1 = GatePoints1(GatePairs1(:, 1), :);
matchedScenePoints1 = ScenePoints1(GatePairs1(:, 2), :);
matchedGatePoints2 = GatePoints2(GatePairs2(:, 1), :);
matchedScenePoints2 = ScenePoints2(GatePairs2(:, 2), :);
matchedGatePoints3 = GatePoints3(GatePairs3(:, 1), :);
matchedScenePoints3 = ScenePoints3(GatePairs3(:, 2), :);
matchedGatePoints4 = GatePoints4(GatePairs4(:, 1), :);
matchedScenePoints4 = ScenePoints4(GatePairs4(:, 2), :);

%Display putatively matched features.
matchedGatePoints = [matchedGatePoints1;matchedGatePoints2;matchedGatePoints3;matchedGatePoints4];
matchedScenePoints = [matchedScenePoints1;matchedScenePoints2; matchedScenePoints3;matchedScenePoints4];

switch display
    case 1
figure;
showMatchedFeatures(GateImage_normalised, SceneImage, matchedGatePoints, ...
    matchedScenePoints, 'montage');

title('Phase II Matched Points (Including Outliers)');
end

%% Gate detection (based on AFTER rematching)  Worse but the only option for tricky images
%%Mode 2:take the average of each corner and draw a gate

Scene_Location_1=matchedScenePoints1.Location;
Scene_Location_2=matchedScenePoints2.Location; 
Scene_Location_3=matchedScenePoints3.Location; 
Scene_Location_4=matchedScenePoints4.Location; 

Corner_1=round(sum(Scene_Location_1,[1])/ size(Scene_Location_1,1));
Corner_2=round(sum(Scene_Location_2,[1])/ size(Scene_Location_2,1));
Corner_3=round(sum(Scene_Location_3,[1])/ size(Scene_Location_3,1));
Corner_4=round(sum(Scene_Location_4,[1])/ size(Scene_Location_4,1));

Corners=[Corner_1;Corner_2;Corner_3;Corner_4;Corner_1];
switch display
    case {1,2}
figure;
imshow(SceneImage);
hold on;
line(Corners(:, 1), Corners(:, 2), 'Color', 'y');
title('Detected Box from Corner Averages');
end
%% estimateGeometricTransform calculates the transformation relating the matched points, while eliminating outliers. This transformation allows us to localize the object in the scene.


if matchedScenePoints.Count>=2 
if  matchedScenePoints.Count>=4    
    [tform, inlierGatePoints, inlierScenePoints] = ...
    estimateGeometricTransform(matchedGatePoints, matchedScenePoints, 'projective','MaxDistance',12,'confidence',99.99,'MaxNumTrials',10000);    %similatity% projective more accurate for closer images
elseif matchedScenePoints.Count==3 
    [tform, inlierGatePoints, inlierScenePoints] = ...
    estimateGeometricTransform(matchedGatePoints, matchedScenePoints, 'affine','MaxDistance',12,'confidence',99.9,'MaxNumTrials',10000);    %similatity% projective more accurate for closer images
elseif matchedScenePoints.Count==2 
    [tform, inlierGatePoints, inlierScenePoints] = ...
    estimateGeometricTransform(matchedGatePoints, matchedScenePoints, 'similarity','MaxDistance',12,'confidence',99.9,'MaxNumTrials',10000);    %similatity% projective more accurate for closer images
end

switch display
    case 1
%Display the matching point pairs with the outliers removed
figure;
showMatchedFeatures(GateImage_normalised, SceneImage, inlierGatePoints, ...
    inlierScenePoints, 'montage');
title('Phase II Matched Points (Inliers Only)');
end

%Get the bounding polygon of the reference image.
GatePolygon = [princ_corners_normalised(1:2);...                           % top-left
        princ_corners_normalised(3:4);...                 % top-right
        princ_corners_normalised(5:6);... % bottom-right
        princ_corners_normalised(7:8);...                 % bottom-left
        princ_corners_normalised(1:2)];                   % top-left again to close the polygon

   
%Transform the polygon into the coordinate system of the target image. The transformed polygon indicates the location of the object in the scene.

newGatePolygon = transformPointsForward(tform, GatePolygon);


switch display
    case {1,2}
%Display the detected object.
figure;
imshow(SceneImage);
hold on;
line(newGatePolygon(:, 1), newGatePolygon(:, 2), 'Color', 'y');
title('Detected Box with Geometric Transpose');
end

elseif matchedScenePoints.Count==1  
    newGatePolygon=Corners;
    % still the case of zero detections , take the gate from the averages 
    %Mode 2
else   
    S=size(SceneImage);
    newGatePolygon=basic_gate; % makes the drone just go forward; % most basic guess
    Results(frame).Method= 'Most Basic';
    % Mode 1
end


%% Checks and Classification


aa1=polyarea(newGatePolygon(:,1)',newGatePolygon(:,2)');
aa2=polyarea(Corners(:,1)',Corners(:,2)');
if isnan(aa1)
   aa1=0;
end
if isnan(aa2)
    aa2=0;
end
if (aa2/aa1)> 2.5  || (aa2/aa1)<(1/2.5) 
    newGatePolygon=Corners;
    Results(frame).Method= 'rematching averages';
else
    Results(frame).Method= 'transforme';
end

if aa2 < 200 || aa1 < 200 % which means that neather of them will be good
    newGatePolygon=basic_gate;
    Results(frame).Method= 'Most Basic';
end
catch ME
    fprintf(ME.message)    
    disp('we will take the most basic guess')
    Results(frame).Method= 'Most Basic';

end % try catch block

poly1=polyshape(corners_struct(frame).corners1(1:2:7),corners_struct(frame).corners1(2:2:8));
Results(frame).PolyOriginal=poly1;
poly2=polyshape(left_removal+newGatePolygon(:,1)',upper_removal+newGatePolygon(:,2)');
Results(frame).PolyFound=poly2;
% poly1 real gate polygon
% poly2 detected gate polygone

switch display
    case {1,2,3}
figure()
plot(poly1)
hold on
plot(poly2)
hold off
end
% for the union 
 poly_union = union(poly1,poly2);
 a1=polyarea(poly_union.Vertices(:,1),poly_union.Vertices(:,2));
 poly_inters = intersect(poly1,poly2);
 a2=polyarea(poly_inters.Vertices(:,1),poly_inters.Vertices(:,2));
 IoU=a2/a1;
 % true or false
 
 threshold_true=0.5; % is iterated in ROC curves
 threshold_false=0.2;
 
  Results(frame).AreaRatio = IoU;
  Counter(frame,z+2)=IoU;
 if  IoU > threshold_true % condition to be true
     switch display
    case 1
     disp('this is a true positive')
     end
    Results(frame).Result='true';
    Results(frame).binomial=1;
    
    Counter(frame,z)=1;
 elseif IoU < threshold_false
     switch display
    case 1
     disp('this is a false positive')
     end
    Results(frame).Result='false';
    Results(frame).binomial=0;
    
    Counter(frame,z+1)=1;
    
 end

 

end     % end of the frame iteration 
Counter(1,1)=frames(2)-frames(1)  ;             
Counter(frames(end)+1,z)=MatchThreshold_1; 
Counter(frames(end)+2,z)=MaxRatio_1;
Counter(frames(end)+3,z)=MatchThreshold_2;
Counter(frames(end)+4,z)=MaxRatio_2;
       
z=z+3;
             end % end of the Results classification
        end
    end
end


%% Results and Visualisation

% the results are written in the "Results" structure
% you can visualize the polygones intersection by indicating which image number you want
% to visualize
% to make it work, uncomment the lines below:


% frame = input("input frame for which you want to visualize the results : frame = ") 
% 
% poly1=Results(frame).PolyOriginal
% poly2=Results(frame).PolyFound
% 
% 
% figure()
% plot(poly1)
% hold on
% plot(poly2)
% hold off

