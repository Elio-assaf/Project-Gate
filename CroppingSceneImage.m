function [SceneImage,upper_removal,left_removal]= CroppingSceneImage(SceneImage)

for i=1:30
    if mean(SceneImage(70+7*(i-1):70+7*i,:),'All')>115 ;  % upper black seeling
    break % increase to remove more upper seeling
    end
end
 S=size(SceneImage);
for ii=1:30           % lower floor level
    if mean(SceneImage(S(1)-7*(ii):S(1)-7*(ii-1),round(0.2*S(2)):round(0.8*S(2))),'All') < 200   ;
    break     % decrese to remove more ground
    end
end
upper_removal=70+6*(i-1)-1;
SceneImage=SceneImage(70+6*(i-1):S(1)-7*(ii-1),:);
% now already cropped
 S=size(SceneImage);
for j=1:30
    if mean(SceneImage(round(0.4*S(1)):round(0.75*S(1)),S(2)-7*j:S(2)-7*(j-1)),'All') < 180  ;     
    break
    end
end

for k=1:20
     S=size(SceneImage);
    if mean(SceneImage(round(0.4*S(1)):round(0.75*S(1)),1+7*(k-1):7*k),'All')<120  ; % to the left is blacker :/
    break
    end
end
if j>=26 && k>=17
    j=20 ;
    k=15 ;
end
left_removal=7*(k-1);
SceneImage=SceneImage(:,1+7*(k-1):S(2)-7*(j-1));


end