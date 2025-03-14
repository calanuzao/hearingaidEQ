% Load the clean and noisy audio files
[clean_audio, fs_clean] = audioread('conversation.mp3');
[noisy_audio, fs_noisy] = audioread('noisyRoom.mp3');

% Check if sample rates are the same
if fs_clean ~= fs_noisy
    error('Sample rates of the clean and noisy audio files must be the same.');
end
fs = fs_clean; % Use the sample rate of the audio files

% Ensure the lengths of both signals are the same
n = min(length(clean_audio), length(noisy_audio));
clean_audio = clean_audio(1:n);
noisy_audio = noisy_audio(1:n);

% Ensure audio signals are column vectors
clean_audio = clean_audio(:);
noisy_audio = noisy_audio(:);

% Zero-padding to next power of two for FFT efficiency
n_fft = 2^nextpow2(n);
clean_audio = [clean_audio; zeros(n_fft - n, 1)];
noisy_audio = [noisy_audio; zeros(n_fft - n, 1)];

% Plot the original noisy signal
dt = 1/fs;
t = (0:n_fft-1) * dt; % Time vector
figure; set(gcf, 'Position', [100 100 1200 900])
subplot(3,1,1)
plot(t, noisy_audio, 'c', 'LineWidth', 1); hold on
plot(t, clean_audio, 'k', 'LineWidth', 0.5)
legend('Noisy', 'Clean', 'FontSize', 12, 'Location', 'Best')
xlabel('Time (s)', 'FontSize', 12)
ylabel('Amplitude', 'FontSize', 12)
title('Time-Domain Signal', 'FontSize', 14)
ylim([-max(abs(noisy_audio)) max(abs(noisy_audio))]); 
set(gca, 'FontSize', 12)

% FFT of the noisy audio
fhat_noisy = fft(noisy_audio, n_fft);
PSD_noisy = abs(fhat_noisy).^2 / n_fft;
freq = (0:n_fft-1) * (fs / n_fft);
L = 1:floor(n_fft/2);

% Plot the PSD of the noisy signal
subplot(3,1,2);
semilogy(freq(L), PSD_noisy(L), 'c', 'LineWidth', 1.5);
xlabel('Frequency (Hz)', 'FontSize', 12)
ylabel('Power/Frequency (dB/Hz)', 'FontSize', 12)
title('Power Spectral Density of Noisy Signal', 'FontSize', 14)
set(gca, 'FontSize', 12)

% FFT of the clean audio for reference
fhat_clean = fft(clean_audio, n_fft);
PSD_clean = abs(fhat_clean).^2 / n_fft;

% Define a threshold for noise and filter based on clean audio PSD
threshold = 0.000001; 
indices = PSD_clean > threshold;

% Power Spectral Density (PSD) filter noise
PSD_clean_filtered = PSD_noisy;
PSD_clean_filtered(~indices) = 0;
fhat_filtered = fhat_noisy;
fhat_filtered(~indices) = 0;
filtered_audio = real(ifft(fhat_filtered));

% Compute the PSD of the filtered signal
fhat_filtered = fft(filtered_audio, n_fft);
PSD_filtered = abs(fhat_filtered).^2 / n_fft;

% Plot the PSD after filtering
subplot(3,1,3);
semilogy(freq(L), PSD_noisy(L), 'c', 'LineWidth', 1.5); hold on
semilogy(freq(L), PSD_filtered(L), 'r', 'LineWidth', 1.5)
xlabel('Frequency (Hz)', 'FontSize', 12)
ylabel('Power/Frequency (dB/Hz)', 'FontSize', 12)
title('Power Spectral Density After Filtering', 'FontSize', 14)
legend('Noisy', 'Filtered', 'FontSize', 12, 'Location', 'Best')
set(gca, 'FontSize', 12)

% Display some diagnostic information
disp(['Max PSD_clean: ', num2str(max(PSD_clean))])
disp(['Min PSD_clean: ', num2str(min(PSD_clean))])
disp(['Threshold used: ', num2str(threshold)])
disp(['Number of frequencies kept: ', num2str(sum(indices))])
disp(['Total number of frequencies: ', num2str(length(indices))])

% Save the filtered audio
audiowrite('filtered_audio.wav', filtered_audio, fs);