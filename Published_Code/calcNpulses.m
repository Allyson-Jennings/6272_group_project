dragons_tracked = 25; 
freq = 1*10^9.*(0:0.125:4);
vel = 100:10:500;%500;


c = physconst("lightspeed");
lambda = c ./freq;
D = 5; 
beamWidth = 0.89*(c ./freq)./D;


range_max = 30*10^3;
range_min = 300; % want to look at how many beams in the closest range case
%as BW is smaller
PRI = 2*range_max/c;


%TDwell = PRI*npulses;

                      
Crossrange_1beam = range_min*(beamWidth);      % What is the crossrange distance of one beam? (theta/360 x circumference of 300m circle)
threebeam_distance = Crossrange_1beam*3;

Rosette = 25; 

%calculate the most number of pulses possible
%i.e. we assume we let the dragon travel almost 3 beams
%nPulses = threebeam_distance./(PRI*Rosette*vel*dragons_tracked); 

FastDrag = 500*1*PRI*dragons_tracked*Rosette*ones(1,length(freq));
SlowDrag = 200*1*PRI*dragons_tracked*Rosette*ones(1,length(freq));

freq = freq/(1*10^9);
area(freq,threebeam_distance, 'FaceAlpha', 0.25, 'FaceColor', [0.4 0.6 0.7]) 
ylabel("Distance (m)")
xlabel("Freq (GHZ)")

hold on

plot(freq, FastDrag)
plot(freq, SlowDrag)
plot(freq, SlowDrag*2)
hold off

legend('Acceptable Travel Distance', ...
    'Distance Traveled 1 Pulse, vel=500', ... 
    'Distance Traveled 1 Pulse, vel=200', ...
    'Distance Traveled 2 Pulse, vel=200') %, ...
   % 'Distance Traveled, longer search (more dragons)')
   
   set(gca,'FontSize',15)
