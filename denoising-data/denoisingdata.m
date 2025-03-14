% Two frequency signals
dt = 0.001; % Create a signal in time with delta t .001
t = 0:dt:1; % Signal is from 0 to 1
fclean = sin(2*pi*50*t) + sin(2*pi*120*t); % Sum of two frequencies
f = fclean + 2.5*randn(size(t)); % Add noise

figure; set(gcf, 'Position', [1500 200 2000 2000])

% Plot the time-domain signal
subplot(3,1,1)
plot(t, f, 'c', 'LineWidth', 3); hold on
plot(t, fclean, 'k', 'LineWidth', 2.5)
l1 = legend('Noisy', 'Clean'); set(l1, 'FontSize', 14)
xlabel('Time (s)', 'FontSize', 14)
ylabel('Amplitude', 'FontSize', 14)
title('Time-Domain Signal', 'FontSize', 16)
ylim([-10 10]); set(gca, 'FontSize', 14)

% FFT
n = length(t); 
fhat = fft(f, n); % Compute FFT
PSD = abs(fhat).^2 / n; % Power spectrum
freq = (0:n-1) * (1/(dt*n)); % Create x-axis of frequencies
L = 1:floor(n/2); % Only plot the first half of frequencies

% Plot the PSD before filtering
subplot(3,1,2);
plot(freq(L), PSD(L), 'c', 'LineWidth', 3); hold on
xlabel('Frequency (Hz)', 'FontSize', 14)
ylabel('Power/Frequency (dB/Hz)', 'FontSize', 14)
title('Power Spectral Density Before Filtering', 'FontSize', 16)
set(gca, 'FontSize', 14)

% Power Spectral Density (PSD) filter noise
indices = PSD > 100; % Find all frequencies with larger power
PSDclean = PSD .* indices; % Zero out all others
fhat = fhat .* indices'; % Zero out small Fourier coefficients in fhat
ffilt = ifft(fhat); % Inverse FFT for filtered time signal

% Plot the PSD after filtering
subplot(3,1,3);
plot(freq(L), PSD(L), 'c', 'LineWidth', 3); hold on
plot(freq(L), PSDclean(L), '-', 'Color', [.5 .1 0], 'LineWidth', 2.5)
xlabel('Frequency (Hz)', 'FontSize', 14)
ylabel('Power/Frequency (dB/Hz)', 'FontSize', 14)
title('Power Spectral Density After Filtering', 'FontSize', 16)
legend('Original', 'Filtered', 'FontSize', 14)
ylim([-10 10]); set(gca, 'FontSize', 14)
