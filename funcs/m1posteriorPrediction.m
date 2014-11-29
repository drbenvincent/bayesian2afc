function k = m1posteriorPrediction(T, si, variance)
% This function generates random samples of k

% Calculate value of the deterministic node P(PC|si,muN,variance)
PC = pcfunc(si, variance);

% Sample from P(k|T,PC)
k = binornd(T,PC);
end