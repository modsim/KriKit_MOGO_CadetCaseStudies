function [muContraint,sigmaConstraint] =  inequalityConstraintOutput(mu,sigma)
% c1: y1 > 0.75 --> -y1 + 0.75 < 0
% c2: y2 > 0.75 --> -y2 + 0.75 < 0

nPoints = size(mu,1);
muContraint = zeros(nPoints,2);
sigmaConstraint = zeros(nPoints,2);
   
muContraint(:,1) = -mu(:,1) + 0.8;
sigmaConstraint(:,1) = sigma(:,1);

muContraint(:,2) = -mu(:,2) + 0.8;
sigmaConstraint(:,2) = sigma(:,2);

end