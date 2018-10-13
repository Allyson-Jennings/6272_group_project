classdef radarClass
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        type %dewds 1 or dewds 2
        rangeTrack
        rangeSearch
        PRI 
        centerFreq
        antennaSpin
        PPeak
        azCoverage
        elCoverage
        
    end
    
    methods
        function radar = radarClass(dewdsType)
            radar.rangeSearch = [30*10^3 300*10^3];
            radar.PPeak = 1*10^6; 
            
            radar.type = dewdsType;
            if radar.type == "dewds1" 
            
            elseif radar.type == "dewds2" 
            radar.rangeSearch = [300 30*10^3];
            
            end 
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

