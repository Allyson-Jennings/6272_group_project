%this is creating a document to initiate git repo

import radarClass
% Authors: 
% Rachel Roley
% Eleni Spring
% Ally Jennings 
% Sarah Preston 

%% constants 
c = physconst("lightspeed"); 
k = 10^3;
u = 10^-6;

%functions
rangeRes = @(Tp) (c/2)*Tp;
elAngle = @(range, alt) atan(alt /range);
PRI_calc = @(range) 2*range/c;
solidAngle = @(el) 2*pi*(1 - (sin(pi/2 - el))^2);
beamWidth = @(freq, D) (c/freq)/D;
beamCoverage = @(solidAngle, theta3, phi3) solidAngle/(theta3*phi3);


%dragon defintions 
dragon.lengthRange = [10 30];
dragon.RCSRange = [1 20];
dragon.speedRange = [0  500]; 
dragon.averageSpeed = 200;
dragon.maxAltitude = 15*k;

bewilderbeast.RCS = 1000;
bewilderbeast.maxSpeed = 100;


%% set paramters, create radar objects
dewds1 = radarClass("dewds1");
dewds2 = radarClass("dewds2");

%% calculation requirements

% required el angle
dewds1.elCoverageS = elAngle(min(dewds1.rangeSearch), dragon.maxAltitude);

dewds2.elCoverageS = elAngle(min(dewds2.rangeSearch), dragon.maxAltitude);
dewds2.elCoverageT = elAngle(min(dewds2.rangeTrack), dragon.maxAltitude);

%min PRI 
dewds1.PRISearch = PRI_calc(max(dewds1.rangeSearch));

dewds2.PRISearch = PRI_calc(max(dewds2.rangeSearch));
dewds2.PRITrack = PRI_calc(max(dewds2.rangeTrack));

%total solid Angle coverage
dewds1.solidAngleSearch = solidAngle(dewds1.elCoverageS);
dewds2.solidAngleSearch = solidAngle(dewds2.elCoverageS);
dewds2.solidAngleTrack = solidAngle(dewds2.elCoverageT);

%beamWidth @ 1 GHz
GHz = 1*10^9;
if dewds1.EleniGraphs == 1
    for i = 1:8
        dewds1BW_preCalc(i) = beamWidth(dewds1.freq(i), dewds1.antennaSizeX);
        dewds2BW_preCalc(i) = beamWidth(dewds2.freq(i), dewds2.antennaSizeX); 

        %beamwidth for Radar Freq
        dewds1.beamWidthSearch(i) = beamWidth(dewds1.freq(i), dewds1.antennaSizeX);
        dewds2.beamWidthSearch(i) = beamWidth(dewds2.freq(i), dewds2.antennaSizeX);
        dewds2.beamWidthTrack(i) = beamWidth(dewds2.freq(i), dewds2.antennaSizeX);
        PRIAvg = 1./dewds1.PRFAvgMin;
        
        
        Tp = (2.*dewds1.rangeRes)./c
        B = 1./Tp;
        unRange = c./(2.*B);
    end   
else
    dewds1BW_preCalc = beamWidth(1*GHz, dewds1.antennaSizeX);
    dewds2BW_preCalc = beamWidth(1*GHz, dewds2.antennaSizeX);

    %beamwidth for Radar Freq
    dewds1.beamWidthSearch = beamWidth(dewds1.freq, dewds1.antennaSizeX);
    dewds2.beamWidthSearch = beamWidth(dewds2.freq, dewds2.antennaSizeX);
    dewds2.beamWidthTrack = beamWidth(dewds2.freq, dewds2.antennaSizeX);
end


        
%% check requirements 
plot(dewds1.beamWidthSearch,dewds1.freq)
title('fc vs Beamwidth')
xlabel('Beamwidth')
ylabel('fc')

figure
subplot(1,2,1)
plot(dewds1.dopAvg,dewds1.freq)
title('fc vs Doppler(avg)')
xlabel('Doppler')
ylabel('fc')

subplot(1,2,2)
plot(dewds1.dopMax,dewds1.freq)
title('fc vs Doppler(max)')
xlabel('Doppler')
ylabel('fc')

figure
subplot(1,2,1)
plot(dewds1.PRFAvgMin,dewds1.freq)
title('fc vs PRF(avg)')
xlabel('PRF')
ylabel('fc')

subplot(1,2,2)
plot(dewds1.PRFMaxMin,dewds1.freq)
title('fc vs PRF(max)')
xlabel('PRF')
ylabel('fc')

figure
plot(B,dewds1.rangeRes)
title('Range Resolution vs B')
xlabel('B')
ylabel('Res')


