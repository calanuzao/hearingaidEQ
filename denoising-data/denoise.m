[cleanAudio, fs] = audioread("conversation.mp3");
noise = audioread("noisyRoom.mp3");

% Ensure both cleanAudio and noise are column vectors
cleanAudio = cleanAudio(:);
noise = noise(:);

% Extract a noise segment from a random location in the noise file
ind = randi(numel(noise) - numel(cleanAudio) + 1, 1, 1);
noiseSegment = noise(ind:ind + numel(cleanAudio) - 1);

% Define a scaling factor to make the noise quieter
scalingFactor = 0.5;  % Adjust this value between 0 and 1 to make the noise quieter

% Compute the power of the clean audio and the noise segment
speechPower = sum(cleanAudio.^2);
noisePower = sum(noiseSegment.^2);

% Generate noisy audio by adding scaled noise to clean audio
noisyAudio = cleanAudio + scalingFactor * sqrt(speechPower/noisePower) * noiseSegment;

% Save the noisy audio to a file
audiowrite("noisyAudio.wav", noisyAudio, fs);

% Visualization of signals
t = (1/fs)*(0:numel(cleanAudio) - 1);

figure(1)
tiledlayout(2,1)

nexttile
plot(t,cleanAudio)
title("Clean Audio")
grid on

nexttile
plot(t,noisyAudio)
title("Noisy Audio")
xlabel("Time (s)")
grid on

% Play the noisy audio
sound(noisyAudio, fs);
