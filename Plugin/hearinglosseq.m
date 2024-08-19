classdef hearinglosseq < audioPlugin

    % User parameters
    properties 
        HS_FREQ = 3000; % High frequency 
        HS_GAIN = -30; % High frequency gain 

        HMF_FREQ = 1000; % Mid frequency 
        HMF_GAIN = -10; % Mid frequency gain

        LMF_FREQ = 500; % Low frequency 
        LMF_GAIN = -10; % Low frequency gain

        HPF_FREQ = 30; % High-pass filter frequency
        LPF_FREQ = 1500; % Lowpass filter frequency
        LPF_GAIN = -6;   % Lowpass filter gain

        SMEAR_FREQ = 1500; % Frequency for spectral smearing
        SMEAR_GAIN = -20; % Spectral smearing gain

        fs = 44100; % Sampling rate
        fn = 22050; % Nyquist 

        NOISE = 'on';
        NOISE_GAIN = 0.011; 

        BYPASS = 'off';

    end

    properties (Constant)
        PluginInterface = audioPluginInterface( ...
            audioPluginParameter('HS_FREQ', ...
                'DisplayName', 'HI SHELF FREQ', ...
                'Label', 'Hz', ...
                'Mapping', {'log', 2500, 20000}), ...
            audioPluginParameter('HS_GAIN', ...
                'DisplayName', 'HI SHELF GAIN', ...
                'Label', 'dB', ...
                'Mapping', {'lin', -30, 10}), ...
            audioPluginParameter('HMF_FREQ', ...
                'DisplayName', 'HI-MID FREQ', ...
                'Label', 'Hz', ...
                'Mapping', {'log', 500, 12500}), ...
            audioPluginParameter('HMF_GAIN', ...
                'DisplayName', 'HI-MID GAIN', ...
                'Label', 'dB', ...
                'Mapping', {'lin', -20, 10}), ...
            audioPluginParameter('LMF_FREQ', ...
                'DisplayName', 'LOW-MID FREQ', ...
                'Label', 'Hz', ...
                'Mapping', {'log', 75, 1500}), ...
            audioPluginParameter('LMF_GAIN', ...
                'DisplayName', 'LOW-MID GAIN', ...
                'Label', 'dB', ...
                'Mapping', {'lin', -20, 10}), ...
            audioPluginParameter('HPF_FREQ', ...
                'DisplayName', 'DC BLOCK FREQ', ...
                'Label', 'Hz', ...
                'Mapping', {'log', 20, 400}), ...
            audioPluginParameter('LPF_FREQ', ...
                'DisplayName', 'LOWPASS FREQ', ...
                'Label', 'Hz', ...
                'Mapping', {'log', 20, 20000}), ...
            audioPluginParameter('LPF_GAIN', ...
                'DisplayName', 'LOWPASS GAIN', ...
                'Label', 'dB', ...
                'Mapping', {'lin', -20, 10}), ...
            audioPluginParameter('SMEAR_FREQ', ...
                'DisplayName', 'SMEAR FREQ', ...
                'Label', 'Hz', ...
                'Mapping', {'log', 20, 20000}), ...
            audioPluginParameter('SMEAR_GAIN', ...
                'DisplayName', 'SMEAR GAIN', ...
                'Label', 'dB', ...
                'Mapping', {'lin', -20, 10}), ...
            audioPluginParameter('NOISE', ...
                'DisplayName', 'NOISE', ...
                'Mapping', {'enum', 'off', 'on'}), ...
            audioPluginParameter('NOISE_GAIN', ...
                'DisplayName', 'NOISE GAIN', ...
                'Label', 'dB', ...
                'Mapping', {'log', 0.001, 0.03}), ...
            audioPluginParameter('BYPASS', ...
                'DisplayName', 'BYPASS', ...
                'Mapping', {'enum', 'off', 'on'}) ...
        );
    end

    properties (Access = private)
        % Filter structures as private properties
        filter_HS = struct('w', [0 0; 0 0], 'a0', 1, 'a1', 0, 'a2', 0, 'b0', 1, 'b1', 0, 'b2', 0) ;
        filter_HMF = struct('w', [0 0; 0 0], 'a0', 1, 'a1', 0, 'a2', 0, 'b0', 1, 'b1', 0, 'b2', 0);
        filter_LMF = struct('w', [0 0; 0 0], 'a0', 1, 'a1', 0, 'a2', 0, 'b0', 1, 'b1', 0, 'b2', 0);
        filter_HPF = struct('w', [0 0; 0 0], 'a0', 1, 'a1', 0, 'a2', 0, 'b0', 1, 'b1', 0, 'b2', 0);
        filter_LPF = struct('w', [0 0; 0 0], 'a0', 1, 'a1', 0, 'a2', 0, 'b0', 1, 'b1', 0, 'b2', 0);
        filter_SMEAR = struct('w', [0 0; 0 0], 'a0', 1, 'a1', 0, 'a2', 0, 'b0', 1, 'b1', 0, 'b2', 0);
        filter_NOISE = struct('w', [0 0; 0 0], 'a0', 1, 'a1', 0, 'a2', 0, 'b0', 1, 'b1', 0, 'b2', 0);
    end

    methods
        function out = process(plugin, in)
            out = zeros(size(in));

            for ch = 1:min(size(in))
                x = in(:,ch);

                [y1, plugin.filter_HS.w(:, ch)]  = processHearinglosseq(x, plugin.filter_HS, ch);
                [y2, plugin.filter_HMF.w(:, ch)] = processHearinglosseq(y1, plugin.filter_HMF, ch);
                [y3, plugin.filter_LMF.w(:, ch)] = processHearinglosseq(y2, plugin.filter_LMF, ch);
                [y4, plugin.filter_HPF.w(:, ch)] = processHearinglosseq(y3, plugin.filter_HPF, ch);
                [y5, plugin.filter_LPF.w(:, ch)] = processHearinglosseq(y4, plugin.filter_LPF, ch);
                [y6, plugin.filter_SMEAR.w(:, ch)] = processHearinglosseq(y5, plugin.filter_SMEAR, ch);

                if strcmp(plugin.BYPASS, 'on')
                    out(:, ch) = x;
                else
                    out(:, ch) = y6;
                end

                if strcmp(plugin.NOISE, 'on')
                    noise = plugin.NOISE_GAIN * randn(size(x)); % Generate low-amplitude white noise
                    [filtered_noise, plugin.filter_NOISE.w(:, ch)] = processHearinglosseq(noise, plugin.filter_NOISE, ch);
                    out(:, ch) = out(:, ch) + filtered_noise;
                end
            end
        end

        function reset(plugin)
            plugin.fs = getSampleRate(plugin);
            plugin.fn = plugin.fs/2;

            plugin.filter_HS.w = [0 0; 0 0] ;
            plugin.filter_HMF.w = [0 0; 0 0];
            plugin.filter_LMF.w = [0 0; 0 0];
            plugin.filter_HPF.w = [0 0; 0 0];
            plugin.filter_LPF.w = [0 0; 0 0];
            plugin.filter_SMEAR.w = [0 0; 0 0];
            plugin.filter_NOISE.w = [0 0; 0 0];
        end

        % HS
        function set.HS_FREQ(plugin, val)
            plugin.HS_FREQ = val;
            update_HS(plugin);
        end

        function set.HS_GAIN(plugin, val)
            plugin.HS_GAIN = val;
            update_HS(plugin);
        end

        function update_HS(plugin)
            Q = 0.5;
            f0 = plugin.HS_FREQ;
            gain = plugin.HS_GAIN;
            w0 = 2 * pi * f0 / plugin.fs;
            alpha = sin(w0) / (2 * Q);
            A = sqrt(db2mag(gain));

            plugin.filter_HS.a0 =      A*( (A+1) + (A-1)*cos(w0) + 2*sqrt(A)*alpha);
            plugin.filter_HS.a1 =   -2*A*( (A-1) + (A+1)*cos(w0))                  ;
            plugin.filter_HS.a2 =      A*( (A+1) + (A-1)*cos(w0) - 2*sqrt(A)*alpha);
            plugin.filter_HS.b0 =          (A+1) - (A-1)*cos(w0) + 2*sqrt(A)*alpha ;
            plugin.filter_HS.b1 =       2*((A-1) - (A+1)*cos(w0))                  ;
            plugin.filter_HS.b2 =          (A+1) - (A-1)*cos(w0) - 2*sqrt(A)*alpha ;

        end
       
        % HMF
        function set.HMF_FREQ(plugin, val)
            plugin.HMF_FREQ = val;
            update_HMF(plugin);
        end

        function set.HMF_GAIN(plugin, val)
            plugin.HMF_GAIN = val;
            update_HMF(plugin);
        end

        function update_HMF(plugin)
            Q=0.5;
            f0=plugin.HMF_FREQ;
            gain = plugin.HMF_GAIN;
            w0=2*pi*f0/plugin.fs;
            alpha=sin(w0)/(2*Q);
            A=sqrt(db2mag(gain));

            plugin.filter_HMF.a0 =  1 + alpha*A;     
            plugin.filter_HMF.a1 = -2*cos(w0)  ;
            plugin.filter_HMF.a2 =  1 - alpha*A;     
            plugin.filter_HMF.b0 =  1 + alpha/A;   
            plugin.filter_HMF.b1 = -2*cos(w0)  ; 
            plugin.filter_HMF.b2 =  1 - alpha/A;
        end

        % LMF
        function set.LMF_FREQ(plugin,val)
            plugin.LMF_FREQ = val;
            update_LMF(plugin);
        end

        function set.LMF_GAIN(plugin, val)
            plugin.LMF_GAIN = val;
            update_LMF(plugin);
        end

        function update_LMF(plugin)
            Q=0.5;
            f0=plugin.LMF_FREQ;
            gain = plugin.LMF_GAIN;
            w0=2*pi*f0/plugin.fs;
            alpha=sin(w0)/(2*Q);
            A=sqrt(db2mag(gain));

            plugin.filter_LMF.a0 =  1 + alpha*A;     
            plugin.filter_LMF.a1 = -2*cos(w0);
            plugin.filter_LMF.a2 =  1 - alpha*A;     
            plugin.filter_LMF.b0 =  1 + alpha/A;   
            plugin.filter_LMF.b1 = -2*cos(w0); 
            plugin.filter_LMF.b2 =  1 - alpha/A;
        end

        % HPF
        function set.HPF_FREQ(plugin,val)
                plugin.HPF_FREQ = val;
                update_HPF(plugin);
        end

        function update_HPF(plugin)
            f0=plugin.HPF_FREQ;
            Q = 0.5;
            w0=2*pi*f0/plugin.fs;
            alpha=sin(w0)/(2*Q);

            plugin.filter_HPF.a0 = (1 + cos(w0))/2;
            plugin.filter_HPF.a1 =-(1 + cos(w0))  ; 
            plugin.filter_HPF.a2 = (1+cos(w0))/2  ;
            plugin.filter_HPF.b0 =  1 + alpha     ;
            plugin.filter_HPF.b1 = -2*cos(w0)     ;
            plugin.filter_HPF.b2 =  1 - alpha     ;
        end
 
        % LPF 
        function set.LPF_FREQ(plugin, val)
            plugin.LPF_FREQ = val;
            update_LPF(plugin);
        end

        function set.LPF_GAIN(plugin, val)
            plugin.LPF_GAIN = val;
            update_LPF(plugin);
        end

        function update_LPF(plugin)
            Q = 0.5;
            f0 = plugin.LPF_FREQ;
            w0 = 2 * pi * f0 / plugin.fs;
            alpha = sin(w0) / (2 * Q);

            plugin.filter_LPF.a0 = (1 - cos(w0)) / 2;
            plugin.filter_LPF.a1 =  1 - cos(w0);
            plugin.filter_LPF.a2 = (1 - cos(w0)) / 2;
            plugin.filter_LPF.b0 =  1 + alpha;
            plugin.filter_LPF.b1 = -2 * cos(w0);
            plugin.filter_LPF.b2 =  1 - alpha;
        end

        % SPECTRAL SMEARING
        function set.SMEAR_FREQ(plugin, val)
            plugin.SMEAR_FREQ = val;
            update_SMEAR(plugin);
        end

        function set.SMEAR_GAIN(plugin, val)
            plugin.SMEAR_GAIN = val;
            update_SMEAR(plugin);
        end

        function update_SMEAR(plugin)
            Q = 2; 
            f0 = plugin.SMEAR_FREQ;
            gain = plugin.SMEAR_GAIN;
            w0 = 2 * pi * f0 / plugin.fs;
            alpha = sin(w0) / (2 * Q);
            A = sqrt(db2mag(gain));

            plugin.filter_SMEAR.a0 = 1 + alpha * A;
            plugin.filter_SMEAR.a1 = -2 * cos(w0);
            plugin.filter_SMEAR.a2 = 1 - alpha * A;
            plugin.filter_SMEAR.b0 = 1 + alpha / A;
            plugin.filter_SMEAR.b1 = -2 * cos(w0);
            plugin.filter_SMEAR.b2 = 1 - alpha / A;
        end

        %TINNITUS
        function set.NOISE(plugin, val)
            plugin.NOISE = val;
        end

        function set.NOISE_GAIN(plugin, val)
            plugin.NOISE_GAIN = val;
        end

        % BYPASS
        function set.BYPASS(plugin, val)
            plugin.BYPASS = val;
        end
    end
end
