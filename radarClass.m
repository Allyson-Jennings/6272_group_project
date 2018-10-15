classdef radarClass
    %Class to store radar parameters, constants, and requirements
   
    
    properties
        EleniGraphs = 1;      
  
        type %dewds 1 or dewds 2
        dopmax
        dopavg
        
        %% Antenna Parameters
        antennaSizeX
        antennaSizeY
        numAntenna
        antennaSpin % in rpm
        
        %% waveform Parameters 
        TpTrack
        TpSearch
        PRISearch
        PRITrack
        freq
        
        %% RRE parameters
        PPeak
        
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
        
        
        
        %requirments 
        R_warningTime % in seconds 
        R_rangeResTrack %in meters
        R_rangeResSearch
        
        

    end
    
    methods
        function radar = radarClass(dewdsType)
            
            radar.rangeSearch = [30*10^3 300*10^3];
            radar.PPeak = 1*10^6; 
            
            radar.antennaSizeX = 5;
            radar.antennaSizeY = 5; 
            radar.azCoverage = 2*pi; 
            
            %enter in required values
            radar.R_rangeResTrack = 10;
            radar.R_rangeResSearch = 30; 
            radar.R_warningTime = 5*60; 
            
            if radar.EleniGraphs==1
            	radar.freq = [1*10^9 3*10^9 5*10^9 10*10^9 15*10^9 35*10^9 70*10^9 90*10^9];
                radar.dopavg = (4*200)./(physconst("lightspeed")./radar.freq);     %500 is max, 200 is average           
                radar.dopmax = (4*500)./(physconst("lightspeed")./radar.freq);
            else
            	radar.freq = 1*10^9;
                radar.dopmax = (4*500)/(physconst("lightspeed")/radar.freq);
                radar.dopavg = (4*200)/(physconst("lightspeed")/radar.freq);
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


    end
end

