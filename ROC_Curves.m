
%ROC Curves
% RUN directly


% Load the "Counter" matrix you are interested in.
% uncomment one:

 load('Mix_MaxRatio_(3)more_adjusted.mat')
%  load('MatchThreshold_1_(2to50).mat', 'Counter')
%  load('MatchThreshold_1.mat', 'Counter')
%  load('MatchThreshold_2.mat', 'Counter')
%  load('MaxRatio_1.mat', 'Counter')
%  load('MaxRatio_2.mat', 'Counter')
%  load('Mix_MatchThreshold_(3).mat', 'Counter')
%  load('Mix_MatchThreshold_(3)_more_adjusted.mat', 'Counter')
%  load('Mix_MatchThreshold_(3)_more_adjusted.mat', 'Counter')
%  load('Mix_mix_big.mat', 'Counter')
%  load('Mix_one.mat', 'Counter')
 
 
 
 
% Example for True_pos == IoU > 80%
%            False_pos == IoU < 20%
%            False negative: when  IoU == NaN so no gate detection
% 
% HERE WE CAN SEE THE STRUCTURE OF THE COUNTER MATRIX. IT IS IN MATRIX FORM
% FOR FASTER COMPUTATION:
%                       /    True_Pos  False_Pos  IoU       
% 
% counter :    frame  sample     1        0       0.81
%              frame    \        0        1       0.19
%              frame    \        1        0       0.85
%              frame    \        0        0       0.67
%              frame    \        1        0       0.97
%              frame    \        0        0       NaN
%              frame    \        0        1       0.15
%              frame    \        1        0       0.89
%              frame    \        0        0       0.78
%              MT_1     \        10       \    inNaN_number
%              MR_1     \       0.85      \         \
%              MT_2     \        6        \         \
%              MR_2     \       0.6       \         \
%

sample=Counter(1,1);
frames=1:sample:308 ;
number_of_trials=length(frames);
TPR=[];
FPR=[];
threshold_true=1;
threshold_false=0;

while threshold_false < 1
    
threshold_true=threshold_true-0.01 ;
threshold_false=threshold_false+0.01  ;

 for z=2:3:size(Counter,2)
   for frame=frames
   
      if Counter(frame,z+2)>=threshold_true  % this is a true positive
          Counter(frame,z)=1;
      else Counter(frame,z)=0;
      end
      if Counter(frame,z+2)<=threshold_false   % this is a false positive
          Counter(frame,z+1)=1;
      else Counter(frame,z+1)=0;
          
      end
     
   end
   Counter(end,z+2)=sum(isnan( Counter(:,z+2)));  % misses gate, so False negative
   
end
for i=2:3:length(Counter(1,:))
   TPR=[TPR sum(Counter(1:end-4,i))/(sum(Counter(1:end-4,i))+Counter(end,i+2))];  % true positive over all the positive
   FPR=[FPR sum(Counter(1:end-4,i+1))/(number_of_trials)];  % false positive per image

end
end

%% Nicer plotting
var1=(size(Counter,2)-1)/3;
var2= length(TPR)/var1;
Area=[];
figure()
hold on
for j=1:var1

    
 plot(FPR(j:var1:end),TPR(j:var1:end),'-.')
 Area=[Area polyarea([1 ,0 ,FPR(j:var1:end) ,1 ,1 ],[0 ,0 ,TPR(j:var1:end),1 ,0 ])];
end

hold off

disp('the max area under the curve is')
max(Area)
k = find(Area == max(Area)); % index
figure()
plot(FPR(k:var1:end),TPR(j:var1:end),'-.')
title('best ROC Curve')


disp('the best parameters out of the cases presented in this Counter Matrix are:')

Counter(end-3:end,1+3*k-2)

%% best
%Mix_MatchThreshold: MT_1= 8 and MT_2= 11 in Mix_MatchThreshold_(3)_more_adjusted
%Mix_MaxRatio : MR_1=0.95 MR_2=1 in Mix_MaxRatio_(3)more_adjusted