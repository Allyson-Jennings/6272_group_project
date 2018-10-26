
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
        Ae
        
        %% waveform Parameters 
        TpTrack
        TpSearch
        PRISearch
        PRITrack
        freq
        lambda
        PRIPerDwell
        bandWidthTrack
        bandWidthSearch
        
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
        SNRmin_search
        SNRmin_track
        
        c = physconst("lightspeed");
        k = physconst("Boltzman");
        To = 290;
        
        %Losses 
        

    end
    
    methods
        
        function radar = radarClass(dewdsType, varFreqFlag)
            
            radar.rangeSearch = [30*10^3 300*10^3];
            radar.PPeak = 1*10^6; 
            radar.duty_cycle = .2; %needs to be fixed
            radar.Pt = radar.PPeak*radar.duty_cycle;
            
            radar.antennaSizeX = 5;
            radar.antennaSizeY = 5; 
            radar.azCoverage = 2*pi;
            radar.Ae = radar.areaEffective(radar.antennaSizeX);
            
            % enter in required values
            radar.R_rangeResTrack = 10;
            radar.R_rangeResSearch = 30; 
            radar.R_warningTime = 5*60;
            radar.SNRmin_search = 10^(26/10);
            
            radar.TpSearch = (2.*radar.R_rangeResSearch)./radar.c;
            radar.bandWidthSearch = 1./radar.TpSearch;
            
            radar.type = dewdsType;
            if radar.type == "dewds1" 
                radar.antennaSpin = 60; 
                radar.numAntenna = 1;
                
             
            elseif radar.type == "dewds2" 
                radar.rangeTrack = [300 30*10^3];
                radar.numAntenna = 4; 
                radar.TpTrack = (2.*radar.R_rangeResTrack)./radar.c;
                radar.bandWidthTrack = 1./radar.TpTrack;
                
            end 
            
            
            if varFreqFlag==1
            	radar.freq = [1*10^9 3*10^9 5*10^9 10*10^9 15*10^9 35*10^9 70*10^9 90*10^9];
                radar.lambda = radar.c ./radar.freq;
                radar.dopAvg = (2*200)./radar.lambda;     %500 is max, 200 is average           
                radar.dopMax = (2*500)./radar.lambda;
                radar.PRFAvgMin = (4*200)./radar.lambda;     %500 is max, 200 is average           
                radar.PRFMaxMin = (4*500)./radar.lambda; 
                radar.rangeRes = [1 10 20 30 40]; %most are 10m to 30m
            else
            	radar.freq = 1*10^9;
                radar.lambda = radar.c ./radar.freq;
                radar.dopMax = (2*500)/radar.lambda;
                radar.dopAvg = (2*200)/radar.lambda;
                radar.PRFMaxMin = (4*500)/radar.lambda;
                radar.PRFAvgMin = (4*200)/radar.lambda;
                
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
        
        function BWCalc = BWCalculation(radar, c)
            BWCalc = c/rangeRes;
        end
                
        function priMax = PRI_max(radar, f, vmax)
            priMax = (radar.c ./f)./(4*vmax);
        end 
        
        function prf = PRF(radar, PRI)
            prf = 1./PRI;
        end 
        
        function radar = GainCalc(radar)             
            radar.Gain = 32400./(radar.beamWidthSearch.*...
                radar.beamWidthSearch*180/pi); %note this must be BW in degrees
        end
        
        function Pavg = Pavg(radar,  PRI, B) 
         %pavg = Pt*nPulses./(Td*B);
         Pavg = radar.PPeak*(1./B)*(1./PRI); 
        end 
        
        function Pave_sweep = sweep_Pave(radar, Pt, dutyCyc)
            Pave_sweep = Pt.*dutyCyc;
        end
        function ae = areaEffective(radar, D) %%%not sure if this is correct?
            ae = D^2; %piazza post Ae = efficiency * A, efficiency = 1 for our system; 
        end
        
        function lhs = SNR_Track_LHS(radar, Pavg, G, Ae, Ls, F)
            lhs = Pavg*G*Ae / Ls*F; 
        end 
        
        function rhs = SNR_Track_RHS(radar, SNR, range, PRF, RCS)
            rhs = SNR*(4*pi)^2 * range^4 * radar.k * radar.To * PRF / RCS ...
                *1/Tfs; 
        end 
        
        function lhs = SNR_Search_LHS(radar, PAvg, Ae, F, Ls)
            lhs = PAvg.*Ae/(Ls * radar.To * F);
        end 
        
        
        function rhs = SNR_Search_RHS(radar, dragon)
            RCS = dragon.RCSRange(1);
            rangeS = radar.rangeSearch(2);
            SNRmin = radar.SNRmin_search;
            num_pulse = SingBeamSNR(radar, RCS, SNRmin);
            Tfs = radar.time_range(num_pulse, max(dragon.speedRange)); 
            % choose max dragon speed
            rhs = SNRmin*4*pi*(rangeS^4/RCS).*(radar.solidAngleSearch./Tfs);
        end 
        
        function td = Td(radar, updateRate, NTargets)
            td = (updateRate*NTargets);
        end 

     
        function radar = varFreq(radar, freq, vMax, vAvg)
            radar.freq = freq;
            radar.PRFMaxMin = radar.PRF(radar.PRI_max(radar.freq, vMax));
            radar.PRFAvgMin = radar.PRF(radar.PRI_max(radar.freq, vAvg));
            radar.beamWidthSearch = radar.beamWidth(freq, radar.antennaSizeX);

            if radar.type == "dewds2" 
                radar.beamWidthTrack= radar.beamWidthSearch;
            end 
            

        end 
        function num_pulse = SingBeamSNR(radar, RCS, SNRmin)
            if radar.type == "dewds2"
                num_pulse = 4:1:20;
                
            else 
               Tdwell = radar.beamWidthSearch / 2*pi*radar.antennaSpin/60 ;
               num_pulse = floor(Tdwell/radar.PRISearch);
            end 
            
            %changed to max(radar.rangeSearch), to make division work
            %num_pulse = (SNRmin*(4*pi)^3*(max(radar.rangeSearch))^4*radar.k ...
             %    *radar.To*radar.F*radar.Ls*radar.bandWidthSearch)./...
               % (radar.Pt * (radar.Gain).^2 .* (radar.lambda).^2 * RCS);
        end
        
        function Tfs = time_range(radar,  num_pulse, maxspeedRange) 
            
            %M = (radar.solidAngleSearch)/(radar.beamWidthSearch); %number of beams in solid angle
            M = radar.nBeamsS; 
            
            Tdwell = num_pulse.*(radar.PRISearch)
            Tslow = Tdwell.*M
            %Tslow = num_pulse*(radar.PRISearch)*radar*M; %what this was
            %before
            
            Tspeed = (radar.beamWidthSearch)*maxspeedRange*3;
            Tdistance = (M -(radar.elCoverageS./radar.beamWidthSearch)).*...
                radar.beamWidthSearch; 
            Tsingle = Tdistance./Tspeed;
            Tfast = Tsingle.*M
            Tfs = [Tfast Tslow];
            
        end

    end
end        

