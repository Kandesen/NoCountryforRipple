function loop_gain()
% LOOP_GAIN  Voltage-loop gain of the LTC7801 peak-current-mode buck (small-signal model)
%   Control-to-output after Ridley (sampled current loop), Type II gm compensator at ITH.
%   Sweeps the ITH-to-current gain Gcs (x0.5, x1, x2 of the datasheet-based estimate; x1.75 = 12.5 A/V
%   measured from the official LTspice LTC7801 model) and the input voltage.
%   Run in MATLAB or GNU Octave:  >> loop_gain        (writes loop_gain.csv)

Vo = 12; L = 22e-6; fsw = 200e3; Ts = 1/fsw; Rs = 6e-3;
R  = 2.4;                                   % rated load
Cc = 40e-6; ESRc = 0.75e-3;                 % ceramics (DC-bias derated)
Cp = 100e-6; ESRp = 25e-3;                  % polymer
gm = 2e-3; k = 0.8/Vo;                      % error-amp gm, feedback divider ratio
RC = 10e3;   CC = 6.8e-9; CC2 = 150e-12;    % chosen ITH network
Se = 1.64e-3/1e-6;                          % slope compensation [V/s] at the comparator (assumed 50 % of Sf)
Gcs0 = (0.075/Rs)/(2.2-0.45);               % assumed ITH -> peak inductor current gain [A/V]

f = logspace(1, log10(fsw/2), 600);  s = 2j*pi*f;
Zc = 1./(s*Cc) + ESRc;  Zp = 1./(s*Cp) + ESRp;
Zo = 1./(1/R + 1./Zc + 1./Zp);              % output impedance seen by the inductor current
Zith = 1./(1./(RC + 1./(s*CC)) + s*CC2);
H  = k*gm*Zith;                             % VOUT -> ITH

out = f(:);  hdr = 'f_Hz';
fprintf('  Vin   Gcs factor   fc [kHz]   phase margin [deg]   gain margin [dB]\n');
for Vin = [20 48]
    D  = Vo/Vin;
    Sn = (Vin - Vo)/L*Rs;                   % on-time slope at the comparator
    mc = 1 + Se/Sn;
    wn = pi*fsw;  Qp = 1/(pi*(mc*(1-D) - 0.5));
    Fh = 1./(1 + s/(wn*Qp) + s.^2/wn^2);    % sampling double pole
    Kdc = 1/(1 + R*Ts*(mc*(1-D) - 0.5)/L);  % finite current-loop gain
    for g = [0.5 1 1.75 2]
        Gvc = g*Gcs0*Kdc*Zo.*Fh;            % ITH -> VOUT
        T   = H.*Gvc;
        mag = 20*log10(abs(T));  ph = unwrap(angle(T))*180/pi;
        i = find(mag(1:end-1) > 0 & mag(2:end) <= 0, 1);
        fc = interp1(mag(i:i+1), f(i:i+1), 0);
        pm = 180 + interp1(f(i:i+1), ph(i:i+1), fc);
        j = find(ph(1:end-1) > -180 & ph(2:end) <= -180, 1);
        if isempty(j), gmg = Inf; else, gmg = -interp1(ph(j:j+1), mag(j:j+1), -180); end
        fprintf('  %2d V      x%.2f      %6.2f         %5.1f              %6.1f\n', Vin, g, fc/1e3, pm, gmg);
        out = [out, mag(:), ph(:)]; %#ok<AGROW>
        hdr = sprintf('%s,mag_%dV_x%.1f,ph_%dV_x%.1f', hdr, Vin, g, Vin, g);
    end
end
fid = fopen('loop_gain.csv', 'w'); fprintf(fid, '%s\n', hdr); fclose(fid);
dlmwrite('loop_gain.csv', out, '-append', 'precision', 6);
end
