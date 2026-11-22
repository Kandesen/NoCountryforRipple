function design_calc()
% DESIGN_CALC  EE463 60 W synchronous buck converter - analytical design
%   Controller : ADI LTC7801 (peak current mode, 150 V)
%   MOSFETs    : Infineon BSC117N08NS5 (high and low side)
%   Inductor   : Wurth 74435582200, 22 uH, 7 mOhm
%   Run in MATLAB or GNU Octave:  >> design_calc
%   Component data are datasheet typical values unless noted.

%% ---------------- Specification ----------------
P.Vo      = 12.0;
P.VinPts  = [20 24 36 48];          % efficiency-bonus measurement points
P.IoRated = 5.0;   P.IoOvl = 7.5;

%% ---------------- Controller (LTC7801 datasheet) ----------------
P.Vsense  = [0.066 0.075 0.084];    % min / typ / max current-sense threshold
P.tonMin  = 130e-9;                 % worst-case minimum on-time
P.Vfb     = 0.800;   P.gmEA = 2e-3;
P.RtgUp   = 2.2;  P.RtgDn = 1.0;    % TG driver resistances (DRVCC = 10 V)
P.tDead1  = 55e-9; P.tDead2 = 50e-9;% TG off->BG on, BG off->TG on
P.Vdrv    = 10.0;                   % DRVSET = INTVCC -> 10 V gate drive
P.Vextvcc = P.Vo;                   % EXTVCC tied to VOUT
P.IqCtrl  = 2.5e-3;                 % controller operating current (estimate)

%% ---------------- MOSFET data (Infineon OptiMOS 5, 80 V) ----------------
F117 = struct('rds',9.6e-3,'rg',1.1,'qsw',6e-9,'qg',15e-9,'qgSync',13e-9, ...
              'vpl',5.0,'qoss40',19e-9,'qrrSpec',45e-9,'qrrIf',25,'vsd',0.8);
F040 = struct('rds',3.4e-3,'rg',1.2,'qsw',15e-9,'qg',43e-9,'qgSync',37e-9, ...
              'vpl',4.8,'qoss40',52e-9,'qrrSpec',80e-9,'qrrIf',50,'vsd',0.8);
F030 = struct('rds',2.6e-3);   % BSC030N08NS5 (reverse-polarity Q3): typ 2.6 mOhm, max 3.0 mOhm at VGS = 10 V
P.kHot  = 1.45;   % RDS(on) multiplier at Tj ~ 90-100 C
P.kPar  = 2.0;    % switching-time multiplier for PCB/package inductance

%% ---------------- Passives ----------------
P.L = 22e-6;  P.DCR = 7e-3;  P.kCu = 1.24;  P.Isat = 18;
P.Rsense = 6e-3;
P.CinCer = 6*1.0e-6;  P.EsrCin  = 3e-3/6;     % 6 x 2.2 uF / 100 V X7R 1210 (DC-bias derated)
P.CoCer  = 4*10e-6;   P.EsrCoC  = 3e-3/4;     % 4 x 22 uF / 25 V X7R 1210 (DC-bias derated)
P.CoPoly = 100e-6;    P.EsrPoly = 25e-3;      % 1 x 100 uF / 25 V polymer
P.Rconn = 2e-3;  P.RpcbIn = 1.5e-3;  P.RpcbOut = 2.0e-3;
P.Ruvlo = 1.1e6;  P.RrpGate = 100e3;  P.VrpZ = 12;
P.Pcc = 1.2e-3*12;                             % optional current-limit circuit

FSW = 200e3;

%% 1. Switching-frequency sweep
fprintf('=== 1. Switching-frequency sweep (L = 22 uH, 5 A) ===\n');
for f = [150 200 250 300 350 400]*1e3
    e  = etaAvg(P, F117, F117, F030, f, P.IoRated, true);
    r  = losses(P, F117, F117, F030, 48, P.IoRated, f, true);
    fprintf('  f = %3.0f kHz  avg eta = %6.2f %%  bonus = %5.2f  dI@48V = %.2f A (%2.0f %%)\n', ...
            f/1e3, 100*e, bonusPts(e), r.dI, 100*r.dI/P.IoRated);
end

%% 2. Low-side MOSFET choice
fprintf('\n=== 2. Low-side MOSFET choice at %.0f kHz ===\n', FSW/1e3);
fprintf('  LS = BSC117N08NS5: avg eta 5 A = %.2f %%, 7.5 A = %.2f %%\n', ...
        100*etaAvg(P,F117,F117,F030,FSW,P.IoRated,true), 100*etaAvg(P,F117,F117,F030,FSW,P.IoOvl,true));
fprintf('  LS = BSC040N08NS5: avg eta 5 A = %.2f %%, 7.5 A = %.2f %%\n', ...
        100*etaAvg(P,F117,F040,F030,FSW,P.IoRated,true), 100*etaAvg(P,F117,F040,F030,FSW,P.IoOvl,true));

%% 3. Operating points and loss breakdown at rated load
fprintf('\n=== 3. Operating points (f = %.0f kHz, 5 A) ===\n', FSW/1e3);
R = cell(1,4);
for k = 1:4, R{k} = losses(P, F117, F117, F030, P.VinPts(k), P.IoRated, FSW, true); end
fprintf('  %-34s', ''); fprintf('%9.0f V', P.VinPts); fprintf('\n');
q = {'D','duty cycle'; 'dI','inductor ripple [A pp]'; 'Ipk','inductor peak [A]'; ...
     'Irms','inductor RMS [A]'; 'Icin','input-cap RMS [A]'; 'Iin','input current [A]'};
for m = 1:size(q,1)
    fprintf('  %-34s', q{m,2});
    for k = 1:4, fprintf('%11.3f', R{k}.(q{m,1})); end
    fprintf('\n');
end
fprintf('  --- losses [W] ---\n');
for m = 1:numel(R{1}.names)
    fprintf('  %-34s', R{1}.names{m});
    for k = 1:4, fprintf('%11.3f', R{k}.P(m)); end
    fprintf('\n');
end
fprintf('  %-34s', 'TOTAL');            for k = 1:4, fprintf('%11.3f', R{k}.Ploss); end; fprintf('\n');
fprintf('  %-34s', 'Efficiency [%]');   for k = 1:4, fprintf('%11.2f', 100*R{k}.eta); end; fprintf('\n');
ea  = etaAvg(P, F117, F117, F030, FSW, P.IoRated, true);
eab = etaAvg(P, F117, F117, F030, FSW, P.IoRated, false);
fprintf('  average efficiency = %.2f %%  ->  efficiency bonus ~ %+.1f points\n', 100*ea, bonusPts(ea));
fprintf('  (base converter without the two optional add-ons: %.2f %%)\n', 100*eab);

%% 4. Overload
fprintf('\n=== 4. Overload 7.5 A (f = %.0f kHz) ===\n', FSW/1e3);
for v = P.VinPts
    r = losses(P, F117, F117, F030, v, P.IoOvl, FSW, true);
    fprintf('  Vin = %2.0f V  eta = %.2f %%  Ploss = %.2f W  Ipk = %.2f A  Iin = %.2f A\n', ...
            v, 100*r.eta, r.Ploss, r.Ipk, r.Iin);
end

%% 5. Current sensing / built-in current limit
fprintf('\n=== 5. Current sensing / built-in limit ===\n');
r48 = losses(P, F117, F117, F030, 48, P.IoOvl, FSW, true);
fprintf('  RSENSE(max) for 7.5 A = %.2f mOhm -> chosen %.0f mOhm\n', ...
        1e3*P.Vsense(1)/(P.IoOvl + r48.dI/2), 1e3*P.Rsense);
Ilim = P.Vsense/P.Rsense;
fprintf('  peak current limit min/typ/max = %.1f / %.1f / %.1f A  (inductor Isat %.0f A)\n', Ilim, P.Isat);
Isc = 0.45*Ilim(2) - (P.tonMin*48/P.L)/2;
fprintf('  short-circuit current (foldback, datasheet formula) ~ %.1f A\n', Isc);

%% 6. Ripple
fprintf('\n=== 6. Output / input ripple ===\n');
w = 2*pi*FSW;
for v = P.VinPts
    r  = losses(P, F117, F117, F030, v, P.IoRated, FSW, true);
    zc = 1/(1j*w*P.CoCer) + P.EsrCoC;   zp = 1/(1j*w*P.CoPoly) + P.EsrPoly;
    z  = 1/(1/zc + 1/zp);
    dv = r.dI*abs(z)*0.81*1.25;          % triangle fundamental, 25 % margin for harmonics
    dvin = P.IoRated*r.D*(1-r.D)/(FSW*P.CinCer);
    fprintf('  Vin = %2.0f V  dI = %.2f A  Vout ripple ~ %5.1f mV pp (limit 120)  Vin ripple (ceramic only) ~ %.2f V pp\n', ...
            v, r.dI, 1e3*dv, dvin);
end

%% 7. Stresses and 8. MOSFET temperatures
fprintf('\n=== 7. Component stresses ===\n');
r20 = losses(P, F117, F117, F030, 20, P.IoOvl, FSW, true);
fprintf('  MOSFET VDS: 48 V + 25 %% ringing = %.0f V vs 80 V rating\n', 48*1.25);
fprintf('  Inductor at 7.5 A, 48 V: Ipk = %.2f A, Irms = %.2f A (rated 15 A, Isat 18 A)\n', r48.Ipk, r48.Irms);
fprintf('  Cin RMS current (D = 0.5): %.2f A at 5 A, %.2f A at 7.5 A\n', 0.5*P.IoRated, 0.5*P.IoOvl);
fprintf('  Input current at 20 V: %.2f A (5 A out), %.2f A (7.5 A out)\n', R{1}.Iin, r20.Iin);
fprintf('\n=== 8. MOSFET junction temperatures (RthJA ~ 40 K/W, Ta = 30 C) ===\n');
for io = [P.IoRated P.IoOvl]
    for v = [20 48]
        r = losses(P, F117, F117, F030, v, io, FSW, true);
        pHS = r.P(1) + r.P(2) + 0.5*r.P(3) + 0.5*r.P(4);
        pLS = r.P(5) + r.P(6);
        fprintf('  Io = %.1f A, Vin = %2.0f V: P_HS = %.2f W (Tj ~ %.0f C), P_LS = %.2f W (Tj ~ %.0f C)\n', ...
                io, v, pHS, 30+40*pHS, pLS, 30+40*pLS);
    end
end

%% 9. Feedback divider and compensation
fprintf('\n=== 9. Feedback divider and Type II compensation ===\n');
RA = 10.0e3; RB = 140e3;
fprintf('  VOUT = 0.8*(1+RB/RA) = %.3f V  (RA = 10.0k, RB = 140k, 0.1 %%)\n', P.Vfb*(1+RB/RA));
fprintf('  worst case (VFB 0.788-0.812 V, 0.1 %% resistors): %.3f - %.3f V  (spec 11.76-12.24 V)\n', ...
        0.788*(1+RB*0.999/(RA*1.001)), 0.812*(1+RB*1.001/(RA*0.999)));
Gcs = (P.Vsense(2)/P.Rsense)/(2.2-0.45);   % ITH 0.45 V -> 0 A, ~2.2 V -> VSENSE(max) (assumed)
fc  = 15e3;  Co = P.CoCer + P.CoPoly;
RC  = 2*pi*fc*Co/((P.Vfb/P.Vo)*P.gmEA*Gcs);
CC  = 1/(2*pi*RC*fc/5);   CC2 = 1/(2*pi*RC*FSW/2);
fprintf('  assumed Gcs = %.2f A/V (to be confirmed in simulation)\n', Gcs);
fprintf('  fc = %.0f kHz -> RC = %.1f k, CC = %.2f nF, CC2 = %.0f pF\n', fc/1e3, RC/1e3, CC*1e9, CC2*1e12);

%% 10. UVLO / OVLO divider  (VIN - R3 - RUN - R4 - OVLO - R5 - GND)
fprintf('\n=== 10. UVLO / OVLO divider ===\n');
R3 = 1.02e6; R4 = 53.6e3; R5 = 23.7e3; Rt = R3+R4+R5;
fprintf('  RUN on = %.1f V, off = %.1f V;  OVLO trip = %.1f V, release = %.1f V\n', ...
        1.2*Rt/(R4+R5), 1.12*Rt/(R4+R5), 1.2*Rt/R5, 1.1*Rt/R5);

%% 11. Optional precise current limit
fprintf('\n=== 11. Optional constant-current limit (INA180A1, gain 20) ===\n');
Vref = 1.24*(1+30.1/10.0);    % TLV431 set as ~5.0 V shunt regulator (30.1k/10.0k)
fprintf('  TLV431 rail = %.2f V (also supplies INA180)\n', Vref);
lims = [5.5 8.0]; rb = [1.54e3 2.37e3];
for k = 1:2
    vset = Vref*rb(k)/(10e3+rb(k));
    fprintf('  setpoint 10.0k / %.2fk -> %.3f V -> limit %.2f A\n', rb(k)/1e3, vset, vset/(20*P.Rsense));
end
iNeed = P.Vfb/RA + P.Vfb/RB;
fprintf('  injection to pull VOUT to 0 V: %.0f uA -> R_inj <= %.0f k (22 k chosen)\n', 1e6*iNeed, (8.5-1.4)/iNeed/1e3);

%% 12. Reverse-polarity MOSFET
fprintf('\n=== 12. Reverse-polarity MOSFET (low side, BSC030N08NS5) ===\n');
for k = 1:4
    fprintf('  Vin = %2.0f V: Iin = %.2f A, P = %.0f mW\n', P.VinPts(k), R{k}.Iin, 1e3*R{k}.P(end));
end
end

%% ======================= local functions =======================
function r = losses(P, H, Lw, RP, vin, io, f, addons)
% Loss model of one operating point. H/Lw/RP: high-side, low-side, reverse-polarity FET data.
d    = P.Vo/vin;
dI   = P.Vo*(1-d)/(P.L*f);
ipk  = io + dI/2;  ival = io - dI/2;
irms2 = io^2 + dI^2/12;
iOn  = (P.Vdrv - H.vpl)/(P.RtgUp + H.rg);
iOff = H.vpl/(P.RtgDn + H.rg);
tOn  = P.kPar*H.qsw/iOn;   tOff = P.kPar*H.qsw/iOff;
qossHS = H.qoss40*sqrt(vin/40);   qossLS = Lw.qoss40*sqrt(vin/40);
qrr  = Lw.qrrSpec*sqrt(max(ival,0.5)/Lw.qrrIf)*1.3;
icin = io*sqrt(d*(1-d) + (dI/io)^2*d/12);
names = {'HS conduction','HS switching (V-I overlap)','Coss (HS+LS)','LS reverse recovery', ...
         'LS conduction','Dead-time body diode','Gate drive','Controller bias','Inductor DCR', ...
         'Inductor core (estimate)','Sense resistor','Cin + Cout ESR','Output connector + copper', ...
         'UVLO/OVLO divider'};
Pl = [ irms2*d*H.rds*P.kHot, ...
       0.5*vin*(ival*tOn + ipk*tOff)*f, ...
       0.5*(qossHS + qossLS)*vin*f, ...
       qrr*vin*f, ...
       irms2*(1-d)*Lw.rds*P.kHot, ...
       Lw.vsd*(ipk*P.tDead1 + ival*P.tDead2)*f, ...
       (H.qg + Lw.qgSync)*f*P.Vextvcc, ...
       P.IqCtrl*P.Vextvcc, ...
       irms2*P.DCR*P.kCu, ...
       coreLoss(dI, f), ...
       irms2*P.Rsense, ...
       icin^2*P.EsrCin + dI^2/12*min(P.EsrCoC, P.EsrPoly), ...
       io^2*(2*P.Rconn + P.RpcbOut), ...
       vin^2/P.Ruvlo ];
if addons
    names{end+1} = 'Current-limit circuit (optional)';  Pl(end+1) = P.Pcc;
end
pout = P.Vo*io;
pin  = pout + sum(Pl);
for it = 1:3                               % input-side losses depend on input current
    iin  = pin/vin;
    pInS = iin^2*(2*P.Rconn + P.RpcbIn);
    pRP  = 0;
    if addons, pRP = iin^2*RP.rds*1.2 + vin*(vin - P.VrpZ)/P.RrpGate; end
    pin  = pout + sum(Pl) + pInS + pRP;
end
names{end+1} = 'Input connector + copper';  Pl(end+1) = pInS;
if addons, names{end+1} = 'Reverse-polarity FET (optional)'; Pl(end+1) = pRP; end
r = struct('D',d,'dI',dI,'Ipk',ipk,'Ival',ival,'Irms',sqrt(irms2),'Icin',icin, ...
           'Iin',pin/vin,'Ploss',sum(Pl),'eta',pout/(pout+sum(Pl)));
r.P = Pl;  r.names = names;
end

function e = etaAvg(P, H, Lw, RP, f, io, addons)
e = 0;
for v = P.VinPts, r = losses(P, H, Lw, RP, v, io, f, addons); e = e + r.eta/4; end
end

function p = coreLoss(dI, f)
% Rough ferrite core-loss estimate (refine with Wurth REDEXPERT):
% 0.10 W at dI = 1.64 A, 250 kHz; Steinmetz alpha = 1.3, beta = 2.5
p = 0.10*(dI/1.64)^2.5*(f/250e3)^1.3;
end

function b = bonusPts(e)
if e >= 0.8, b = 100*(e-0.8); else, b = 50*(e-0.8); end
end
