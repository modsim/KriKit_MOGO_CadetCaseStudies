function [newRange]=adjustIniRange(oldRange,variableIndexVec,percentage)

    if length(percentage)==1
        percentage = ones(1,3)*percentage;
    end

    if any(percentage<0)||any(percentage>0.5)
        error('percentage has to be btween 0 and 0.5')
    end
    newRange = oldRange;

    for variableIndex = variableIndexVec
        switch variableIndex
            case 1
                newRange(variableIndex,2) = oldRange(variableIndex,1) + (oldRange(variableIndex,2)-oldRange(variableIndex,1))*percentage(variableIndex)*2;
            case {2,3}
                meanValue = mean(oldRange(variableIndex,:));
                newRange(variableIndex,1) = meanValue - (oldRange(variableIndex,2)-oldRange(variableIndex,1))*percentage(variableIndex);
                newRange(variableIndex,2) = meanValue + (oldRange(variableIndex,2)-oldRange(variableIndex,1))*percentage(variableIndex);
            otherwise
        end
    end
end