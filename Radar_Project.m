import radarClass
% Authors: 
% Rachel Roley
% Eleni Spring
% Ally Jennings 
% Sarah Preston 

close all

%% constants 
c = physconst("lightspeed"); 
km = 10^3;
us = 10^-6;
k = physconst("Boltzman");
To = 290;
F = 1.25; 
G = 10; 

%graphing Flags
varFreqFlag = 1; 


%% dragon defintions 
dragon.lengthRange = [10 30];
dragon.RCSRange = [1 20];
dragon.speedRange = [0  500]; 
dragon.averageSpeed = 200;
dragon.maxAltitude = 15*km;

bewilderbeast.RCS = 1000;
bewilderbeast.maxSpeed = 100;


%% set paramters, create radar objects
dewds1 = radarClass("dewds1", varFreqFlag);
dewds2 = radarClass("dewds2", varFreqFlag);

%% calculation requirements

% required el angle
dewds1.elCoverageS = dewds1.elAngle(min(dewds1.rangeSearch), dragon.maxAltitude);

dewds2.elCoverageS = dewds2.elAngle(min(dewds2.rangeSearch), dragon.maxAltitude);
dewds2.elCoverageT = dewds2.elAngle(min(dewds2.rangeTrack), dragon.maxAltitude);

%min PRI 
dewds1.PRISearch = dewds1.PRI_calc(max(dewds1.rangeSearch));

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

%% vary frequency, 
if varFreqFlag == 1
    for i = 1:8
        dewds1BW_preCalc(i) = dewds1.beamWidth(dewds1.freq(i), dewds1.antennaSizeX);
        dewds2BW_preCalc(i) = dewds2.beamWidth(dewds2.freq(i), dewds2.antennaSizeX); 

        %beamwidth for Radar Freq
        dewds1.beamWidthSearch(i) = dewds1.beamWidth(dewds1.freq(i), dewds1.antennaSizeX);
        dewds2.beamWidthSearch(i) = dewds2.beamWidth(dewds2.freq(i), dewds2.antennaSizeX);
        dewds2.beamWidthTrack(i) = dewds2.beamWidth(dewds2.freq(i), dewds2.antennaSizeX);
        PRIAvg = 1./dewds1.PRFAvgMin;
        
        Tp = (2.*dewds1.rangeRes)./c;
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

if varFreqFlag == 1 
figure
plot(dewds1.beamWidthSearch,dewds1.freq./GHz)
title('fc vs Beamwidth')
xlabel('Beamwidth')
ylabel('fc (GHz)')

figure
plot(dewds1.dopAvg,dewds1.freq./GHz)
hold on
plot(dewds1.dopMax, dewds1.freq./GHz)
title('fc vs Doppler(avg)')
xlabel('Doppler')
ylabel('fc (GHz)')
legend('f_d avg','f_d max')
grid on


figure
plot(dewds1.PRFAvgMin,dewds1.freq./GHz)
hold on
plot(dewds1.PRFMaxMin,dewds1.freq./GHz)
title('fc vs PRF')
xlabel('PRF')
ylabel('fc (GHz)')
grid on
legend('PRF_{min}','PRF_{max}')

figure
plot(B./1e6,dewds1.rangeRes)
title('Range Resolution vs B')
xlabel('B (MHz)')
ylabel('Res (m)')
grid on
end

%% 
f = 1*10^9 *[0.5 1 2 3 4 5];
dewds1 = dewds1.varFreq(f, max(dragon.speedRange), dragon.averageSpeed); 
figure
plot(dewds1.freq./1e9,1./dewds1.PRFMaxMin.*1e6)
hold on 
plot(dewds1.freq./1e9,1./dewds1.PRFAvgMin.*1e6)

PRImin = dewds1.PRISearch;

plot(dewds1.freq./1e9,PRImin*ones(1,length(f)).*1e6)
hold off
xlabel('Frequency (GHz)')
ylabel('PRI (\mu s)')
legend('PRI_{min}','PRI_{avg}','PRI_{max}')
Ls = 2;
B = 1/dewds1.R_rangeResSearch;

Td = dewds1.beamWidthSearch/(dewds1.antennaSpin);
PAvg = dewds1.Pavg(dewds1.PPeak, 1./dewds1.PRFMaxMin, B);
Ae = dewds1.Ae(dewds1.antennaSizeX); 


%% Sweep Duty Cycles to see a range of Pave we can get
dutyCycle = 0.1:0.1:0.5;        % 10% - 50% duty cycle in 10% increments
pAve = sweep_Pave(dewds1, 1e6, dutyCycle);

figure
plot(dutyCycle.*100, pAve./1e3)
xlabel('Duty Cycle (%)')
ylabel('P_{ave} (kW)')
grid on
title('Avg Power from duty cycle')
