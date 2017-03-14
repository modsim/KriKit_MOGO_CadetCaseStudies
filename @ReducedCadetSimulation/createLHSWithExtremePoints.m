function [originalLHS] = createLHSWithExtremePoints(obj, varargin)
    
    LB = [0,0];
    UB = [1,1];
    gridPoints = createNDGRID(LB,UB,obj.nRandSamples+1+2); % Including two extreme points

    % GridPoints 
    uniqueX1 = unique(gridPoints(:,1));
    uniqueX2 = unique(gridPoints(:,2));

    % Normalized standard latin hypercube design
    originalLHS = lhsdesign(obj.nRandSamples,2);
    
    % Delete points which are in the extreme columns and redistribute theme
    notToUseX1 = originalLHS(:,1)<uniqueX1(2)&originalLHS(:,2)<uniqueX2(2);
    notToUseX2 = originalLHS(:,1)>=uniqueX1(end-1)&originalLHS(:,2)>=uniqueX2(end-1);
    originalLHS = originalLHS(~(notToUseX1|notToUseX2),:);
    if any(notToUseX1)
         originalLHS = [originalLHS;rand(1,2).*[uniqueX1(2)-uniqueX1(1),uniqueX2(end)-uniqueX2(2)] + [uniqueX1(1),uniqueX2(2)]];
    end
    if any(notToUseX2)
        originalLHS = [originalLHS;rand(1,2).*[uniqueX1(end)-uniqueX1(2),uniqueX2(2)-uniqueX2(1)] + [uniqueX1(2),uniqueX2(1)]];
    end


    % Add Points randomly ditributed in extreme quarters 
    randValues = rand(2,2);
    extremePointMin = randValues(1,:).*[uniqueX1(2)-uniqueX1(1),uniqueX1(2)-uniqueX2(1)]+ [uniqueX1(1),uniqueX2(1)];
    extremePointMax = randValues(2,:).*[uniqueX1(end)-uniqueX1(end-1),uniqueX1(end)-uniqueX2(end-1)]+ [uniqueX1(end-1),uniqueX2(end-1)];
    originalLHS = [originalLHS;extremePointMin;extremePointMax];
end

