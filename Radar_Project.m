clear classes

import radarClass
% Authors: 
% Rachel Roley
% Eleni Spring
% Ally Jennings 
% Sarah Preston 

close all
clear all

%% constants 
c = physconst("lightspeed"); 
km = 10^3;
us = 10^-6;
k = physconst("Boltzman");
To = 290;
F = 2; 
G = 10; 



%% dragon defintions 
dragon.lengthRange = [10 30];
dragon.RCSRange = [1 20];
dragon.speedRange = [0  500]; 
dragon.averageSpeed = 200;
dragon.maxAltitude = 15*km;

bewilderbeast.RCS = 1000;
bewilderbeast.maxSpeed = 100;


%% set paramters, create radar objects
dewds1 = radarClass("dewds1");
dewds2 = radarClass("dewds2");
dewds1.F    = F;
dewds2.F    = F;
%% calculation requirements

% required el angle
dewds1.elCoverageS = dewds1.elAngle(min(dewds1.rangeSearch), dragon.maxAltitude);

dewds2.elCoverageS = dewds2.elAngle(min(dewds2.rangeSearch), dragon.maxAltitude);
dewds2.elCoverageT = dewds2.elAngle(min(dewds2.rangeTrack), dragon.maxAltitude);

%min PRI 
dewds1.PRISearch = dewds1.PRI_calc(max(dewds1.rangeSearch));
dewds1.PRIPerDwell = dewds1.beamWidthSearch/dewds1.PRISearch;

dewds2.PRISearch = dewds2.PRI_calc(max(dewds2.rangeSearch));
dewds2.PRITrack = dewds2.PRI_calc(max(dewds2.rangeTrack));

%total solid Angle coverage
dewds1.solidAngleSearch = dewds1.solidAngle(dewds1.elCoverageS);
dewds2.solidAngleSearch = dewds2.solidAngle(dewds2.elCoverageS);
dewds2.solidAngleTrack = dewds2.solidAngle(dewds2.elCoverageT);

%beamWidth
%beamWidth @ 1 GHz
GHz = 1*10^9;

dewds1BW_preCalc = dewds1.beamWidth(1*GHz, dewds1.antennaSizeX);
dewds2BW_preCalc = dewds2.beamWidth(1*GHz, dewds2.antennaSizeX);


%beamwidth for Radar Freq
dewds1.beamWidthSearch = dewds1.beamWidth(dewds1.freq, dewds1.antennaSizeX);
dewds2.beamWidthSearch = dewds2.beamWidth(dewds2.freq, dewds2.antennaSizeX);
dewds2.beamWidthTrack = dewds2.beamWidth(dewds2.freq, dewds2.antennaSizeX);


dewds1.nBeamsS = dewds1.beamCoverage(dewds1.solidAngleSearch, dewds1.beamWidthSearch, dewds1.beamWidthSearch);
dewds2.nBeamsS = dewds2.beamCoverage(dewds2.solidAngleSearch, dewds2.beamWidthSearch, dewds2.beamWidthSearch);
dewds2.nBeamsT = dewds2.beamCoverage(dewds2.solidAngleTrack, dewds2.beamWidthTrack, dewds2.beamWidthTrack);


%% Search and Track TFS

numPulses = 1:2;
dewds1 = dewds1.time_range(0, max(dragon.speedRange), 0);
dewds2 = dewds2.time_range(numPulses, max(dragon.speedRange), 25); %% too many dragons at this speed
dewds2 = dewds2.time_range(numPulses, max(dragon.speedRange), 18); %% can only use 1 pulse, # of dragons okay
dewds2 = dewds2.time_range(1, dragon.averageSpeed, 47); % we can use 1 pulse and track 48 avg speed dragons.
dewds2 = dewds2.time_range(numPulses, dragon.averageSpeed, 23); % we can use 2 pulses and track 23 avg speed dragons



%% Sweep Duty Cycles to see a range of Pave we can get
dutyCycle = 0.1:0.1:0.5;        % 10% - 50% duty cycle in 10% increments
pAve = dewds1.sweep_Pave(1e6, dutyCycle);

dewds2 = dewds2.SNRTrack(dragon.RCSRange);
testSNR = 10*log(dewds2.calcSNRTrack(1));
figure
plot(dutyCycle.*100, pAve./1e3)
xlabel('Duty Cycle (%)')
ylabel('P_{ave} (kW)')
grid on
title('Avg Power from duty cycle')
