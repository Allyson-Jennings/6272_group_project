
classdef radarClass
    %Class to store radar parameters, constants, and requirements
   
    
    properties    
  
        type %dewds 1 or dewds 2
        
        %Frequency
        dopMax
        dopAvg
        
        %% Antenna Parameters
        antennaSizeX
        antennaSizeY
        numAntenna
        antennaSpin % in rpm
        rangeRes
        
        %% waveform Parameters 
        TpTrack
        TpSearch
        PRISearch
        PRITrack
        freq
        lambda
        %% waveform Parameters for graphs
        PRFAvgMin
        PRFMaxMin
        
        %% RRE parameters
        PPeak
        Pt
        duty_cycle
        Gain
       
        %Range and az/El coverage
        rangeTrack
        rangeSearch
        azCoverage
        elCoverageS %search
        elCoverageT %track
        solidAngleTrack
        solidAngleSearch
        beamWidthTrack
        beamWidthSearch
        nBeamsS
        nBeamsT
        
        
        
        %requirments 
        R_warningTime % in seconds 
        R_rangeResTrack %in meters
        R_rangeResSearch
        
        c = physconst("lightspeed");
        k = physconst("Boltzman");
        To = 290;

    end
    
    methods
        
        function radar = radarClass(dewdsType, varFreqFlag)
            
            radar.rangeSearch = [30*10^3 300*10^3];
            radar.PPeak = 1*10^6; 
            radar.Pt = radar.PPeak*radar.duty_cycle;
            
            radar.antennaSizeX = 5;
            radar.antennaSizeY = 5; 
            radar.azCoverage = 2*pi; 
            
            % enter in required values
            radar.R_rangeResTrack = 10;
            radar.R_rangeResSearch = 30; 
            radar.R_warningTime = 5*60; 
            
            if varFreqFlag==1
            	radar.freq = [1*10^9 3*10^9 5*10^9 10*10^9 15*10^9 35*10^9 70*10^9 90*10^9];
                radar.lambda = radar.freq/physconst("lightspeed");
                radar.dopAvg = (2*200)./(physconst("lightspeed")./radar.freq);     %500 is max, 200 is average           
                radar.dopMax = (2*500)./(physconst("lightspeed")./radar.freq);
                radar.PRFAvgMin = (4*200)./(physconst("lightspeed")./radar.freq);     %500 is max, 200 is average           
                radar.PRFMaxMin = (4*500)./(physconst("lightspeed")./radar.freq); 
                radar.rangeRes = [1 10 20 30 40]; %most are 10m to 30m
            else
            	radar.freq = 1*10^9;
                radar.dopMax = (2*500)/(physconst("lightspeed")/radar.freq);
                radar.dopAvg = (2*200)/(physconst("lightspeed")/radar.freq);
                radar.PRFMaxMin = (4*500)/(physconst("lightspeed")/radar.freq);
                radar.PRFAvgMin = (4*200)/(physconst("lightspeed")/radar.freq);
            end
            
            radar.type = dewdsType;
            if radar.type == "dewds1" 
                radar.antennaSpin = 60; 
                radar.numAntenna = 1;
                
             
            elseif radar.type == "dewds2" 
                radar.rangeTrack = [300 30*10^3];
                radar.numAntenna = 4; 
                
            end 
        end
        
        function res = rangeResFunc(radar, Tp)
            res = (radar.c/2)*Tp;
        end 
        
        function angle = elAngle(radar, range, alt)
            angle = atan(alt ./range);
        end 
        
        function PRI = PRI_calc(radar, range) 
            PRI = 2*range/radar.c;
        end 
        
        function SA = solidAngle(radar, el) 
            SA = 2*pi*sin(el);
        end 
        
        function BW = beamWidth(radar, freq, D)
            BW = 0.89*(radar.c./freq)./D;
        end 
        
        function BC = beamCoverage(radar, solidAngle, theta3, phi3) 
            BC = solidAngle./(theta3.*phi3);
        end 
        
        function BW = bandWidth(radar, Tp)
            BW = 1./Tp; 
        end 
        
        function priMax = PRI_max(radar, f, vmax)
            priMax = (radar.c ./f)./(4*vmax);
        end 
        
        function prf = PRF(radar, PRI)
            prf = 1./PRI;
        end 
        
        function Pavg = Pavg(radar, Pt, PRI, B) %%%Pt is never set?
         %pavg = Pt*nPulses./(Td*B);
         Pavg = Pt*(1./B)*(1./PRI); 
        end 
        
        function ae = Ae(radar, D) %%%not sure if this is correct?
            ae = D^2; 
        end
        
        function lhs = SNR_Track_LHS(radar, Pavg, G, Ae, Ls, F)
            lhs = Pavg*G*Ae / Ls*F; 
        end 
        
        function rhs = SNR_Track_RHS(radar, SNR, range, PRF, RCS)
            num_pulse = SingBeamSNR(radar, RCS, SNRmin, loss);
            Tfs = time_range(num_pulse,radar, maxspeedRange); 
            rhs = SNR*(4*pi)^2 * range^4 * radar.k * radar.To * PRF / RCS ...
                *1/Tfs; 
        end 
        
        function lhs = SNR_Search_LHS(radar, PAvg, Ae, F, Ls)
            lhs = PAvg.*Ae/(Ls * radar.To * F);
        end 
        
        function rhs = SNR_Search_RHS(radar, range, SNRmin, RCS, solidAngle, Tfs)
            rhs = SNRmin*4*pi*(range^4/RCS).*(solidAngle./Tfs);
        end 
        
        function td = Td(radar, updateRate, NTargets)
            td = (updateRate*NTargets);
        end 

     
        function radar = varFreq(radar, freq, vMax, vAvg)
            radar.freq = freq;
            radar.PRFMaxMin = radar.PRF(radar.PRI_max(radar.freq, vMax));
            radar.PRFAvgMin = radar.PRF(radar.PRI_max(radar.freq, vAvg));
            radar.beamWidthSearch = radar.beamWidth(freq, radar.antennaSizeX);
            radar.Gain = 32400./(radar.beamWidthSearch([1 3 5]).*...
                radar.beamWidthSearch([2 4 6])*180/pi); %note this must be BW in degrees

            if radar.type == "dewds2" 
                radar.beamWidthTrack= radar.beamWidthSearch;
            end 
            

        end 
        function num_pulse = SingBeamSNR(radar, RCS, SNRmin, loss)
            num_pulse = (SNRmin*(4*pi)^3*radar.rangeSearch*radar.k*loss)/...
                (radar.Pt*radar.Gain^2*radar.lambda*RCS);
        end
        function Tfs = time_range(num_pulse,radar, maxspeedRange) 
            M = radar.solidAngleSearch/radar.beamWidthSearch; %number of beams in solid angle
            Tslow = num_pulse*PRI*radar*M;
            Tspeed = 3*radar.beamWidthSearch*maxspeedRange;
            Tdistance = (M -(radar.elCoverageS./radar.beamWidthSearch)).*...
                radar.beamWidthSearch; 
            Tsingle = Tdistance./Tspeed;
            Tfast = Tsingle*M;
            Tfs = Tfast:Tslow;
            
        end

    end
end

