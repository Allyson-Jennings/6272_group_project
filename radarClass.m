classdef radarClass
    %Class to store radar parameters, constants, and requirements
    
    properties
        type %dewds 1 or dewds 2
       
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
            
            radar.freq = 1*10^9;
            
            
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

