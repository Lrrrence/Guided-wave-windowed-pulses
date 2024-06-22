% Change the current folder to the folder of this m-file.
if(~isdeployed)
  cd(fileparts(matlab.desktop.editor.getActiveFilename));
end

f_0= 0.3e6;     %frequency
np= 5;          %num cycles
fs = 1e8;       %sample rate
T0= 1/f_0;
T = 0:1/fs:np*T0;

% generate pulse
pulse = sin(2*pi*f_0*T).*(T<(np/f_0));

% generate hamming window
window_ham = hamming(length(T),'symmetric')';
window_hann = hann(length(T),"symmetric")';

%multiply
ham_pulse = pulse.*window_ham;
hann_pulse = pulse.*window_hann;

%% FFT

% Define the pad size
padsize = 50000;

% Zero-pad the Hann pulse
hann_pulse_pad = padarray(hann_pulse, [0 padsize], 0, 'post');

% Perform FFT on the Hann pulse
N_hann = length(hann_pulse_pad);
Y_hann = fft(hann_pulse_pad);
P2_hann = abs(Y_hann / N_hann);
P1_hann = P2_hann(1:N_hann/2+1);
P1_hann(2:end-1) = 2 * P1_hann(2:end-1);

% Zero-pad the Hamming pulse
ham_pulse_pad = padarray(ham_pulse, [0 padsize], 0, 'post');

% Perform FFT on the Hamming pulse
N_ham = length(ham_pulse_pad);
Y_ham = fft(ham_pulse_pad);
P2_ham = abs(Y_ham / N_ham);
P1_ham = P2_ham(1:N_ham/2+1);
P1_ham(2:end-1) = 2 * P1_ham(2:end-1);

% Define the frequency axis
f = fs*(0:(N_hann/2))/N_hann;
P1_hann = normalize(P1_hann,"range");
P1_ham = normalize(P1_ham,"range");

%% save to file

% fft
%fft_array = transpose([f ;P1]);
%writematrix(fft_array ,'fft_pulse_hann_1MHz.txt','Delimiter','tab')

pulse_array = transpose([T ;hann_pulse]); 
pulse_edit = round(pulse_array(:,2)*8191); %for sig gen

%writematrix(pulse_edit,'pulse_3cyc.csv','Delimiter',',')

%% plot

figure

tiledlayout(1, 2);
nexttile
hold on
grid on 
box on
set(gca, 'fontsize', 16);
plot(T*1e6,ham_pulse, 'LineWidth', 3)
plot(T*1e6,hann_pulse, 'LineWidth', 3)
xlim([0 max(T*1e6)])

ylabel('Amplitude')
xlabel('Time (us)')
legend('Hamming','Hann')

set(groot,'DefaultLineLineWidth',1)
set(gca, 'FontName', 'HelveticaLTStd-Roman')
set(gca,'GridLineStyle',':')
set(gca,'LineWidth',1) %for grid lines
ax = gca;
ax.GridColor = 'k';

nexttile
set(gca, 'LineWidth', 1.2); % For grid lines
hold on
grid on 
box on
set(gca, 'fontsize', 16);
plot(f/1e3, P1_ham, 'LineWidth', 3);
plot(f/1e3, P1_hann, 'LineWidth', 3);

xlim([0 (f_0*2)/1e3])
ylabel('Amplitude')
xlabel('Frequency (kHz)')
legend('Hamming','Hann')

set(groot,'DefaultLineLineWidth',1)
set(gca, 'FontName', 'HelveticaLTStd-Roman')
set(gca,'GridLineStyle',':')
set(gca,'LineWidth',1) %for grid lines
ax = gca;
ax.GridColor = 'k';

x0=10;
y0=10;
width=2000;
height=1000;
set(gcf,'position',[x0,y0,width,height])
set(gcf, 'Color', 'w');

export_fig pulse.png -m2