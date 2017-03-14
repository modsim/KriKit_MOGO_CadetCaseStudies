function [newLHS]=deleteInvalidSamples(obj,originalLHS)
    boolHoldConstraint = obj.InequalityConstraintHandle(originalLHS);
    newLHS = originalLHS(boolHoldConstraint,:);
end