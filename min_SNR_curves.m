% Plot some ROC curves
clear all
clc
close all


snr1 = 20:5:45;
snr3 = 20:5:45;

[Pd1, Pfa1] = rocsnr(snr1,'SignalType','Swerling1');
[Pd3, Pfa3] = rocsnr(snr3,'SignalType','Swerling3');

figure
semilogx(Pfa1, Pd1)
legendStr = {};
grid on
% for n = 1:length(snr1)
% %     legendStr = {legendStr, [num2str(snr1(n)) ' dB']};
% % end
legend('20 dB', '25 dB','30 dB','35dB','40 dB','45 dB')
xlabel('P_{fa}'); ylabel('P_d')
title('ROC Curves for Swerling 1 type target')

figure
semilogx(Pfa3, Pd3)
grid on
xlabel('P_{fa}'); ylabel('P_d')
title('ROC Curves for Swerling 3 type target')
legend('20 dB', '25 dB','30 dB','35dB','40 dB','45 dB')
