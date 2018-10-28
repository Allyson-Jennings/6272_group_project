% rangeRes = @(Tp) (c/2)*Tp;
% elAngle = @(range, alt) atan(alt /range);
% PRI_calc = @(range) 2*range/c;
% solidAngle = @(el) 2*pi*(1 - (sin(pi/2 - el))^2);
% beamWidth = @(freq, D) (c./freq)./D;
% beamCoverage = @(solidAngle, theta3, phi3) solidAngle./(theta3.*phi3);
% bandWidth = @(Tp) 1/Tp;
% PRI_max = @(f, vmax) (c/f)/(4*vmax);
% PRF = @(PRI) 1/PRI;
% Pavg = @(nPulses, Td, B) Pt*nPulses/(Td*B);
% Ae = @(D) D^2;
% SNR = @(RCS, range, PAvg, Ls, F, G, PRF, Ae) ... 
%     (PAvg*G*Ae/(Ls*F)) * (PRI*RCS)/((4*pi)^2*range^4*k*To);
% Td = @(updateRate, NTargets) 1/(updateRate*Nt);
% 
% 
