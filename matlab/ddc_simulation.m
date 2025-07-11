%% FPGA-Based Digital RF Frontend - DDC Simulation
% This script simulates the DDC (Digital Downconversion) functionality
% and verifies performance with realistic RF signals
%
% Author: pater234
% Date: 2025
% Target: Xilinx Series 7, UltraScale, UltraScale+

clear all; close all; clc;

%% Simulation Parameters
fs = 100e6;              % Sample rate (100 MHz)
sim_duration = 1e-3;     % Simulation duration (1 ms)
num_samples = round(fs * sim_duration);

% RF signal parameters
rf_freq = 25e6;          % RF frequency (25 MHz)
rf_amplitude = 0.8;      % RF signal amplitude
noise_power = -60;       % Noise power (dB)

% DDC parameters
ddc_freq = 25e6;         % DDC frequency (25 MHz)
nco_width = 24;          % NCO bit width
cordic_iterations = 12;  % CORDIC iterations

fprintf('DDC Simulation Parameters:\n');
fprintf('Sample rate: %.1f MHz\n', fs/1e6);
fprintf('RF frequency: %.1f MHz\n', rf_freq/1e6);
fprintf('DDC frequency: %.1f MHz\n', ddc_freq/1e6);
fprintf('Simulation duration: %.1f ms\n', sim_duration*1000);
fprintf('Number of samples: %d\n', num_samples);

%% Generate RF Signal
fprintf('\nGenerating RF signal...\n');

% Time vector
t = (0:num_samples-1) / fs;

% Generate RF signal (real)
rf_signal = rf_amplitude * cos(2*pi*rf_freq*t);

% Add noise
noise_amplitude = 10^(noise_power/20);
noise = noise_amplitude * randn(size(t));
rf_signal_noisy = rf_signal + noise;

% Add interference signals
interference_freq1 = 30e6;
interference_freq2 = 40e6;
interference1 = 0.3 * cos(2*pi*interference_freq1*t);
interference2 = 0.2 * cos(2*pi*interference_freq2*t);
rf_signal_complete = rf_signal_noisy + interference1 + interference2;

%% NCO Implementation
fprintf('Implementing NCO...\n');

% Calculate NCO frequency control word
nco_freq_word = round((ddc_freq / fs) * 2^nco_width);

% Generate NCO phase
nco_phase = zeros(1, num_samples);
for i = 2:num_samples
    nco_phase(i) = mod(nco_phase(i-1) + nco_freq_word, 2^nco_width);
end

% Convert phase to angle (0 to 2π)
nco_angle = 2*pi * nco_phase / 2^nco_width;

%% CORDIC Implementation for Sine/Cosine
fprintf('Implementing CORDIC...\n');

% CORDIC constants
atan_table = [pi/4, atan(1/2), atan(1/4), atan(1/8), atan(1/16), ...
              atan(1/32), atan(1/64), atan(1/128), atan(1/256), ...
              atan(1/512), atan(1/1024), atan(1/2048)];

% Initialize CORDIC variables
x = zeros(1, num_samples);
y = zeros(1, num_samples);
z = zeros(1, num_samples);

% CORDIC gain
cordic_gain = 1;
for i = 1:cordic_iterations
    cordic_gain = cordic_gain * sqrt(1 + 2^(-2*(i-1)));
end

% Generate sine and cosine using CORDIC
sine_out = zeros(1, num_samples);
cosine_out = zeros(1, num_samples);

for sample = 1:num_samples
    % Initialize CORDIC
    x_temp = 1/cordic_gain;
    y_temp = 0;
    z_temp = nco_angle(sample);
    
    % CORDIC iterations
    for i = 1:cordic_iterations
        if z_temp >= 0
            x_next = x_temp - y_temp * 2^(-(i-1));
            y_next = y_temp + x_temp * 2^(-(i-1));
            z_next = z_temp - atan_table(i);
        else
            x_next = x_temp + y_temp * 2^(-(i-1));
            y_next = y_temp - x_temp * 2^(-(i-1));
            z_next = z_temp + atan_table(i);
        end
        x_temp = x_next;
        y_temp = y_next;
        z_temp = z_next;
    end
    
    cosine_out(sample) = x_temp;
    sine_out(sample) = y_temp;
end

%% DDC Processing
fprintf('Performing DDC processing...\n');

% Complex multiplication: RF * (cos - j*sin)
i_out = rf_signal_complete .* cosine_out;
q_out = rf_signal_complete .* sine_out;

% Apply low-pass filter to remove high-frequency components
% Simple moving average filter for demonstration
filter_length = 16;
i_filtered = filter(ones(1, filter_length)/filter_length, 1, i_out);
q_filtered = filter(ones(1, filter_length)/filter_length, 1, q_out);

%% Performance Analysis
fprintf('\nAnalyzing performance...\n');

% Calculate signal power
signal_power = mean(rf_signal.^2);
noise_power_measured = mean(noise.^2);
snr_input = 10*log10(signal_power / noise_power_measured);

% Calculate output signal characteristics
i_power = mean(i_filtered.^2);
q_power = mean(q_filtered.^2);
total_power = i_power + q_power;

% Calculate image rejection
image_freq = 2*ddc_freq - rf_freq;
image_power = 0; % Would need to calculate from spectrum

fprintf('Input SNR: %.2f dB\n', snr_input);
fprintf('I-channel power: %.6f\n', i_power);
fprintf('Q-channel power: %.6f\n', q_power);
fprintf('Total output power: %.6f\n', total_power);

%% Spectral Analysis
fprintf('\nPerforming spectral analysis...\n');

% Calculate FFT
nfft = 2^nextpow2(num_samples);
freq = (0:nfft-1) * fs / nfft;

% Input spectrum
rf_spectrum = fft(rf_signal_complete, nfft);
rf_spectrum_db = 20*log10(abs(rf_spectrum));

% Output spectrum (complex)
output_complex = i_filtered + 1j*q_filtered;
output_spectrum = fft(output_complex, nfft);
output_spectrum_db = 20*log10(abs(output_spectrum));

% Find peak frequencies
[~, peak_idx] = max(rf_spectrum_db(1:nfft/2));
peak_freq = freq(peak_idx);

fprintf('Peak frequency in input: %.1f MHz\n', peak_freq/1e6);

%% Plot Results
figure('Name', 'DDC Simulation Results', 'Position', [100, 100, 1400, 1000]);

% Input signal
subplot(3,3,1);
plot(t(1:1000)*1e6, rf_signal_complete(1:1000), 'b-', 'LineWidth', 1);
grid on;
xlabel('Time (μs)');
ylabel('Amplitude');
title('Input RF Signal (First 1000 samples)');

% NCO output
subplot(3,3,2);
plot(t(1:1000)*1e6, cosine_out(1:1000), 'r-', 'LineWidth', 1);
hold on;
plot(t(1:1000)*1e6, sine_out(1:1000), 'g-', 'LineWidth', 1);
grid on;
xlabel('Time (μs)');
ylabel('Amplitude');
title('NCO Output (Cosine/Sine)');
legend('Cosine', 'Sine');

% DDC output
subplot(3,3,3);
plot(t(1:1000)*1e6, i_out(1:1000), 'r-', 'LineWidth', 1);
hold on;
plot(t(1:1000)*1e6, q_out(1:1000), 'g-', 'LineWidth', 1);
grid on;
xlabel('Time (μs)');
ylabel('Amplitude');
title('DDC Output (Before Filtering)');
legend('I-channel', 'Q-channel');

% Filtered output
subplot(3,3,4);
plot(t(1:1000)*1e6, i_filtered(1:1000), 'r-', 'LineWidth', 1);
hold on;
plot(t(1:1000)*1e6, q_filtered(1:1000), 'g-', 'LineWidth', 1);
grid on;
xlabel('Time (μs)');
ylabel('Amplitude');
title('DDC Output (After Filtering)');
legend('I-channel', 'Q-channel');

% Input spectrum
subplot(3,3,5);
plot(freq(1:nfft/2)/1e6, rf_spectrum_db(1:nfft/2), 'b-', 'LineWidth', 2);
grid on;
xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');
title('Input Signal Spectrum');
xlim([0 fs/2e6]);

% Output spectrum
subplot(3,3,6);
plot(freq(1:nfft/2)/1e6, output_spectrum_db(1:nfft/2), 'r-', 'LineWidth', 2);
grid on;
xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');
title('Output Signal Spectrum');
xlim([0 fs/2e6]);

% Constellation diagram
subplot(3,3,7);
scatter(i_filtered(1000:end), q_filtered(1000:end), 10, 'b.');
grid on;
xlabel('I-channel');
ylabel('Q-channel');
title('Constellation Diagram');
axis equal;

% Phase trajectory
subplot(3,3,8);
phase = atan2(q_filtered, i_filtered);
plot(t(1:1000)*1e6, phase(1:1000)*180/pi, 'm-', 'LineWidth', 1);
grid on;
xlabel('Time (μs)');
ylabel('Phase (degrees)');
title('Phase Trajectory');

% Power spectral density
subplot(3,3,9);
psd_input = abs(rf_spectrum).^2 / (fs * nfft);
psd_output = abs(output_spectrum).^2 / (fs * nfft);
plot(freq(1:nfft/2)/1e6, 10*log10(psd_input(1:nfft/2)), 'b-', 'LineWidth', 1);
hold on;
plot(freq(1:nfft/2)/1e6, 10*log10(psd_output(1:nfft/2)), 'r-', 'LineWidth', 1);
grid on;
xlabel('Frequency (MHz)');
ylabel('PSD (dB/Hz)');
title('Power Spectral Density');
legend('Input', 'Output');
xlim([0 fs/2e6]);

%% Error Analysis
fprintf('\nError Analysis:\n');

% Calculate ideal DDC output
ideal_freq = rf_freq - ddc_freq;
ideal_i = rf_amplitude * cos(2*pi*ideal_freq*t);
ideal_q = rf_amplitude * sin(2*pi*ideal_freq*t);

% Calculate error
i_error = i_filtered - ideal_i;
q_error = q_filtered - ideal_q;
error_power = mean(i_error.^2 + q_error.^2);
signal_power_ideal = mean(ideal_i.^2 + ideal_q.^2);
snr_output = 10*log10(signal_power_ideal / error_power);

fprintf('Output SNR: %.2f dB\n', snr_output);
fprintf('Error power: %.6f\n', error_power);

%% Fixed-Point Analysis
fprintf('\nFixed-point analysis...\n');

% Simulate fixed-point quantization
bit_width = 18;
fractional_bits = 2;
quantization_level = 2^(-fractional_bits);

% Quantize signals
i_quantized = round(i_filtered / quantization_level) * quantization_level;
q_quantized = round(q_filtered / quantization_level) * quantization_level;

% Calculate quantization error
quant_error_i = i_filtered - i_quantized;
quant_error_q = q_filtered - q_quantized;
quant_error_power = mean(quant_error_i.^2 + quant_error_q.^2);

fprintf('Bit width: %d bits\n', bit_width);
fprintf('Fractional bits: %d\n', fractional_bits);
fprintf('Quantization level: %.6f\n', quantization_level);
fprintf('Quantization error power: %.6f\n', quant_error_power);

%% Generate Test Vectors
fprintf('\nGenerating test vectors...\n');

% Create test vector file
filename = '../sim/test_vectors/ddc_test_vectors.txt';
fid = fopen(filename, 'w');

fprintf(fid, '// DDC Test Vectors - Auto-generated by MATLAB\n');
fprintf(fid, '// Sample Rate: %.1f MHz\n', fs/1e6);
fprintf(fid, '// RF Frequency: %.1f MHz\n', rf_freq/1e6);
fprintf(fid, '// DDC Frequency: %.1f MHz\n', ddc_freq/1e6);
fprintf(fid, '// Number of samples: %d\n\n', num_samples);

% Write test vectors
for i = 1:min(1000, num_samples) % Limit to first 1000 samples
    fprintf(fid, '%d %d %d %d\n', ...
        round(rf_signal_complete(i) * 2^15), ... % Input (16-bit)
        round(cosine_out(i) * 2^15), ...         % NCO cosine (16-bit)
        round(sine_out(i) * 2^15), ...           % NCO sine (16-bit)
        round(i_filtered(i) * 2^15));            % Output I (16-bit)
end

fclose(fid);
fprintf('Test vectors saved to: %s\n', filename);

%% Save Simulation Data
fprintf('\nSaving simulation data...\n');

save('../matlab/ddc_simulation.mat', 'rf_signal_complete', 'i_filtered', ...
     'q_filtered', 'cosine_out', 'sine_out', 'fs', 'rf_freq', 'ddc_freq', ...
     'snr_input', 'snr_output', 'error_power');

fprintf('Simulation data saved to ddc_simulation.mat\n');

%% Summary
fprintf('\n=== DDC Simulation Summary ===\n');
fprintf('Input SNR: %.2f dB\n', snr_input);
fprintf('Output SNR: %.2f dB\n', snr_output);
fprintf('SNR degradation: %.2f dB\n', snr_input - snr_output);
fprintf('Error power: %.6f\n', error_power);
fprintf('Quantization error power: %.6f\n', quant_error_power);
fprintf('Peak frequency: %.1f MHz\n', peak_freq/1e6);

fprintf('\nSimulation completed successfully!\n'); 