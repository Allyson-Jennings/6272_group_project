%% TFS sidecar code
dragons_tracked = 25; 
freq = 1*10^9.*transpose(0.25:0.25:10);
vel = 500;%500;
npulses = 1:1:100;


%function nPulsesPossible  = tfsSearch(freq, vel, dragons_tracked, npulses) 
c = physconst("lightspeed");

lambda = c ./freq;
D = 5; 
beamWidth = 0.89*(c ./freq)./D;


range_max = 30*10^3;
range_min = 300; % want to look at how many beams in the closest range case
%as BW is smaller
PRI = 2*range_max/c;



TDwell = PRI*npulses;

                        %How many dragons are you trying to track?
Crossrange_1beam = range_min*(beamWidth);      % What is the crossrange distance of one beam? (theta/360 x circumference of 300m circle)
threebeam_distance = Crossrange_1beam*3;                  % Per spec, dragon not allowed to go more than three of these

numBeamsTraveled = vel*TDwell./Crossrange_1beam;
n =ceil(numBeamsTraveled);
RosetteCALC = 2*sum(1:2:n*2-1)+n*2+1; %number of cells to search
Rosette = 25;

revisit_time= dragons_tracked.*TDwell.*Rosette;  % The time it takes to revist a tracked dragon (25 is the rosette squares for 3 beamwidths)

disTraveled = vel.*revisit_time;

nPulsesPossible = disTraveled<threebeam_distance ;% If a dragon going 300 m/s goes less than 3 beamwidths in the revisit time you meet spec
nPulsesPossible = npulses.*nPulsesPossible;



%end 