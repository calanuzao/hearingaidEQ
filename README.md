# Hearing Loss Emulation and Denoising Plugin

## Overview

The Hearing Loss Emulation Plugin and Denoising Script is a MATLAB-based tool designed to simulate hearing loss and demonstrate the need for hearing aids. This project uses various acoustic parameters to model hearing impairment and provides an FFT-based denoising script to simulate how hearing aids can reduce unwanted noise and enhance important sounds like speech.

## Purpose

This project aims to:

- **Emulate Hearing Loss**: Simulate various types of hearing loss using customizable parameters to reflect the impact on auditory perception.
- **Justify the Need for Hearing Aids**: Use the simulated hearing loss to highlight how hearing aids can improve sound quality and clarity for individuals with hearing impairment.
- **Denoise Audio**: Implement FFT-based denoising to illustrate how hearing aids reduce unwanted noise and focus on important sounds.

## Features

- **Hearing Loss Simulation**: Adjust high, mid, and low frequencies, apply filters, and simulate spectral smearing to model different aspects of hearing loss.
- **Noise Injection**: Add simulated noise to reflect conditions like tinnitus or background noise.
- **FFT-Based Denoising Script**: A MATLAB script that uses Fast Fourier Transform (FFT) to reduce noise and enhance speech signals, simulating the noise reduction capabilities of hearing aids.

## Installation

1. **Prerequisites**: Ensure you have MATLAB installed with the Audio Toolbox.

2. **Clone the Repository**:
    ```bash
    git clone https://github.com/calanuzao/hearingaidEQ.git
    ```

3. **Navigate to the Project Directory**:
    ```bash
    cd hearingaidEQ
    ```

4. **Add the Plugin to MATLAB**:
    - Open MATLAB.
    - Navigate to the directory containing the `hearinglosseq.m` file.
    - Add the directory to the MATLAB path:
      ```matlab
      addpath('path/to/hearingaidEQ')
      ```

## Usage

### Hearing Loss Emulation

1. **Configure Parameters**:
    ```matlab
    plugin.HS_FREQ = 3000;     % Set high-frequency shelf frequency
    plugin.HS_GAIN = -30;      % Set high-frequency shelf gain
    plugin.HMF_FREQ = 1000;    % Set mid-frequency
    plugin.HMF_GAIN = -10;     % Set mid-frequency gain
    plugin.LMF_FREQ = 500;     % Set low-mid frequency
    plugin.LMF_GAIN = -10;     % Set low-mid frequency gain
    plugin.HPF_FREQ = 30;      % Set high-pass filter frequency
    plugin.LPF_FREQ = 1500;    % Set low-pass filter frequency
    plugin.LPF_GAIN = -6;      % Set low-pass filter gain
    plugin.SMEAR_FREQ = 1500;  % Set spectral smearing frequency
    plugin.SMEAR_GAIN = -20;   % Set spectral smearing gain
    plugin.NOISE = 'on';       % Enable noise
    plugin.NOISE_GAIN = 0.011; % Set noise gain
    plugin.BYPASS = 'off';     % Disable bypass
    ```
2. **Run Plugin through the MATLAB Command Window or as a VST/VST3/AU Plugin on your machine**.

3. **Add Input Audio Files (.wav or .mp3)**.

4. **Reset Plugin**.

![Hearing Loss Plugin Image](https://github.com/calanuzao/hearingaidEQ/blob/main/Plugin/hearinglossEQ.png)

### FFT-Based Denoising Script

To use the FFT-based denoising script, follow these steps:

1. **Open the Script**:
   - Locate the `denoisingdata.m` script in the project directory.

2. **Run the Script**:
    ```matlab
    % Example usage of the FFT-based denoising script
    % Generate a noisy signal
    dt = 0.001; % Time step
    t = 0:dt:1; % Time vector
    fclean = sin(2*pi*50*t) + sin(2*pi*120*t); % Clean signal
    f = fclean + 2.5*randn(size(t)); % Add noise

    % Plot the time-domain signal and its frequency domain representation
    figure; set(gcf, 'Position', [1500 200 2000 2000])
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
    freq = (0:n-1) * (1/(dt*n)); % Frequency vector
    L = 1:floor(n/2); % Only plot the first half of frequencies

    % Plot the PSD before filtering
    subplot(3,1,2);
    plot(freq(L), PSD(L), 'c', 'LineWidth', 3); hold on
    xlabel('Frequency (Hz)', 'FontSize', 14)
    ylabel('Power/Frequency (dB/Hz)', 'FontSize', 14)
    title('Power Spectral Density Before Filtering', 'FontSize', 16)
    set(gca, 'FontSize', 14)

    % Filter noise using PSD
    indices = PSD > 100; % Threshold for filtering
    PSDclean = PSD .* indices; % Apply filter
    fhat = fhat .* indices'; % Zero out small coefficients
    ffilt = ifft(fhat); % Inverse FFT for filtered signal

    % Plot the PSD after filtering
    subplot(3,1,3);
    plot(freq(L), PSD(L), 'c', 'LineWidth', 3); hold on
    plot(freq(L), PSDclean(L), '-', 'Color', [.5 .1 0], 'LineWidth', 2.5)
    xlabel('Frequency (Hz)', 'FontSize', 14)
    ylabel('Power/Frequency (dB/Hz)', 'FontSize', 14)
    title('Power Spectral Density After Filtering', 'FontSize', 16)
    legend('Original', 'Filtered', 'FontSize', 14)
    ylim([-10 10]); set(gca, 'FontSize', 14)
    ```

3. **Analyze Results**:
   - Review the time-domain and frequency-domain plots to compare the noisy and denoised signals.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

- MATLAB Audio Toolbox for providing essential tools for audio processing.
- GitHub for hosting the project repository.
- NYU for providing the COMSOL Multiphysics Acoustic Modules and MATLAB License.

**CALODII STUDIOS** Copyright 2024
