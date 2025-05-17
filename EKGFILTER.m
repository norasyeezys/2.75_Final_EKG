% Load CSV file
data = readtable('av2_processed.csv');

% Change this for EU Electricity standards
EU = true;

% Extract time and Lead I
time = data.("Time_s_");
signal = data.I;

% Sampling frequency (Fs) estimation
Fs = 1 / mean(diff(time));
N = length(signal);
f = linspace(0, Fs/2, floor(N/2)+1); % Frequency axis

%% 1. Plot Raw Signal (Time Domain)
figure;
subplot(4,2,1);
plot(time, signal);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('Raw ECG Signal (Lead I) - Time Domain');

%% 2. Plot Raw Signal (Frequency Domain)
Y_raw = fft(signal);
P2 = abs(Y_raw / N);
P1 = P2(1:length(f));

%figure;
subplot(4,2,2);
plot(f, P1);
xlabel('Frequency (Hz)');
ylabel('|Magnitude|');
title('Raw ECG Signal (Lead I) - Frequency Domain');

%% 3. High-Pass Filter (0.5 Hz)
fc = 0.5;
[b_hpf, a_hpf] = butter(1, fc / (Fs/2), 'high');
signal_hpf = filtfilt(b_hpf, a_hpf, signal);

%figure;
subplot(4,2,3);
plot(time, signal_hpf);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('High-Pass Filtered Signal (0.5 Hz) - Time Domain');

%% 4. Frequency Domain After HPF
Y_lpf = fft(signal_hpf);
P2_lpf = abs(Y_lpf / N);
P1_lpf = P2_lpf(1:length(f));

%figure;
subplot(4,2,4);
plot(f, P1_lpf);
xlabel('Frequency (Hz)');
ylabel('|Magnitude|');
title('After HPF (0.5 Hz) - Frequency Domain');

%% 5. Notch Filter at 60 Hz (Remove 59–61 Hz)
if EU
    e_freq = 50;
else
    e_freq = 60;
end
wo = e_freq / (Fs/2);     % Center frequency (normalized)
bw = 2 / (Fs/2);      % Bandwidth (normalized)
if wo >= 1
    warning('Sampling rate too low for notch filter at %d Hz. Skipping notch.', e_freq);
    signal_filtered = signal_hpf;  % Skip notch
else
    [b_notch, a_notch] = iirnotch(wo, bw);
    signal_filtered = filtfilt(b_notch, a_notch, signal_hpf);
end

%figure;
subplot(4,2,5);
plot(time, signal_filtered);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('HPF + Notch Filtered Signal - Time Domain');

%% 6. Frequency Domain after Notch
Y_final = fft(signal_filtered);
P2_final = abs(Y_final / N);
P1_final = P2_final(1:length(f));

%figure;
subplot(4,2,6);
plot(f, P1_final);
xlabel('Frequency (Hz)');
ylabel('|Magnitude|');
title('HPF + Notch Filtered Signal - Frequency Domain');

%% 7. Low Pass Filter (150 Hz)
fc = 150;
wn = fc / (Fs/2);

if wn >= 1
    warning('Low-pass filter cutoff too high for Fs = %.2f Hz. Skipping LPF.', Fs);
    signal_lpf = signal_filtered;  % No low-pass applied
else
    [b_lpf, a_lpf] = butter(1, wn, 'low');
    signal_lpf = filtfilt(b_lpf, a_lpf, signal_filtered);
end

%figure;
subplot(4,2,7);
plot(time, signal_lpf);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('LPF + Notch Filtered Signal + HPF - Time Domain');

%% 8. Final Frequency Spectrum
Y_hpf = fft(signal_lpf);
P2_hpf = abs(Y_hpf / N);
P1_hpf = P2_hpf(1:length(f));

%figure;
subplot(4,2,8);
plot(f, P1_hpf);
xlabel('Frequency (Hz)');
ylabel('|Magnitude|');
title('LPF + Notch Filtered Signal + HPF - Frequency Domain');

%% 9. Zoomed-In Comparison: Raw vs Final Output (Around 100s)
start_time = 10;      % seconds
window_width = 3;      % seconds
end_time = start_time + window_width;

% Logical index for the desired time window
idx = time >= start_time & time <= end_time;

% Subtract DC offset from raw signal for better viewing
signal = signal - mean(signal);

% New figure for comparison
figure;
plot(time(idx), signal(idx), 'b');
%hold on;
%plot(time(idx), signal_lpf(idx), 'b');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
%title(sprintf('Raw vs Final Filtered Signal at %.0f–%.0f s', start_time, end_time));
title('Raw Signal Only');
%legend('Raw', 'Final Filtered');
grid on;


