function p = getBasicParams(obj)
%GETBASICPARAMETERS Returns a struct with basic process parameters

    % Total process duration in s
    p.endTime = 8e3+1;
    
    % Start time of first gradient in s
    p.startTime = 1e3;
    
    % Salt buffer concentration in mM for loading and washing
    p.initialSalt = 10;
    
    % Maximum salt buffer concentration in mM
    p.maxSalt = 1500;
end