function sync_vs_async()
% SYNC_VS_ASYNC  Freewheeling-device loss: Schottky (classic buck) vs low-side MOSFET (sync buck)
Vo = 12; fsw = 200e3;
Vf = 0.55;              % 60-100 V Schottky at 5 A, hot (typ. 0.5-0.65 V)
Rds = 9.6e-3*1.45;      % BSC117N08NS5 low-side MOSFET, hot
Vbd = 0.8; tdead = 105e-9;   % body diode during the two dead times (55 + 50 ns)
for Io = [5 7.5]
    fprintf('Io = %.1f A\n', Io);
    drop = zeros(1,4); k = 0;
    for Vin = [20 24 36 48]
        k = k + 1; D = Vo/Vin; Pout = Vo*Io;
        Psch = Vf*Io*(1-D);
        Pfet = Io^2*Rds*(1-D) + Vbd*Io*tdead*fsw;
        PinSync = Pout/0.97;                        % sync buck at ~97 %
        etaAsync = Pout/(PinSync - Pfet + Psch);
        drop(k) = 0.97 - etaAsync;
        fprintf('  Vin = %2d V  D = %.2f  Schottky %.2f W  sync MOSFET %.2f W  efficiency drop %.1f points\n', ...
                Vin, D, Psch, Pfet, 100*drop(k));
    end
    fprintf('  average efficiency drop with a diode: %.1f points (= %.1f bonus points)\n', ...
            100*mean(drop), 100*mean(drop));
end
end
