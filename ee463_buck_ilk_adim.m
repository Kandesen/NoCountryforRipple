function [sonuc, kayit] = ee463_buck_ilk_adim(Vin, Rload, mod, VinSon)
% EE463 | Ilk anahtarlamali buck simulasyonu, MATLAB R2025b + Simulink + Simscape.
%
%   ee463_buck_ilk_adim                        % 24 V, 2.4 ohm, sabit %50 PWM
%   ee463_buck_ilk_adim(48, 1.6)               % 48 V, 7.5 A hedefi
%   ee463_buck_ilk_adim(24, 2.4, "acik", 36)   % 24 -> 36 V, duty sabit
%   ee463_buck_ilk_adim(24, 2.4, "kapali", 36) % Ayni adim, cikis geri beslemeli
%
% Model dosyasi ilk calistirmada Current Folder icinde olusur. Sonraki
% calistirmalar ayni modeli kullanir. Devreyi Simulink penceresinde, PWM
% ve ornek PI kontrolunu "PWM ve kontrol" alt sisteminde inceleyebilirsin.
% Simscape anahtarlarinin iletim direnci 1 mOhm. Bobin DCR ve kondansator
% ESR degerleri ilk deneyde sifirdir. PI, LM5117 ic modelini temsil etmez.

arguments
    Vin (1,1) double {mustBeFinite,mustBePositive} = 24
    Rload (1,1) double {mustBeFinite,mustBePositive} = 2.4
    mod (1,1) string {mustBeMember(mod,["acik","kapali"])} = "acik"
    VinSon (1,1) double {mustBeFinite,mustBePositive} = Vin
end

model = 'EE463_Buck_Baslangic';
modelFile = fullfile(pwd, [model '.slx']);
newModel = ~bdIsLoaded(model) && ~isfile(modelFile);
if newModel
    load_system('simulink');
    load_system('fl_lib');
    load_system('nesl_utility');
    new_system(model);
    try
        w = get_param(model, 'ModelWorkspace');
        assignin(w, 'Vref', 12);
        assignin(w, 'fsw', 230e3);
        assignin(w, 'Lval', 10e-6);
        assignin(w, 'Cval', 100e-6);
        assignin(w, 'ESR', 0);
        assignin(w, 'DCR', 0);
        assignin(w, 'Kp', 0.003);
        assignin(w, 'Ki', 25);
        setCase(model, w, Vin, Rload, mod, VinSon);
        buildCircuit(model);
        save_system(model, modelFile);
    catch problem
        close_system(model, 0);
        rethrow(problem);
    end
elseif ~bdIsLoaded(model)
    load_system(modelFile);
elseif ~strcmp(get_param(model,'FileName'), modelFile)
    error('Ayni isimli baska bir model acik. Kendi model klasorune gec veya diger modeli kapat.');
end

w = get_param(model, 'ModelWorkspace');
setCase(model, w, Vin, Rload, mod, VinSon);
open_system(model);
set_param(model,'ZoomFactor','FitSystem');
out = sim(model, 'ReturnWorkspaceOutputs', 'on');
kayit.Vout = out.get('buckVout');
kayit.IL   = out.get('buckIL');
kayit.Vsw  = out.get('buckVsw');
kayit.Duty = out.get('buckDuty');
kayit.Vin  = out.get('buckVin');
fsw = getVariable(w,'fsw');
tEnd = min(kayit.Vout.Time(end), kayit.IL.Time(end));

% Son 20 tam periyodu esit araliklarla ornekle. Degisken adimli cozumde
% ham major-step orneklerinin aritmetik ortalamasi zaman ortalamasi olmaz.
t = linspace(tEnd-20/fsw, tEnd, 20*160+1).';
v = readAt(kayit.Vout, t, 'linear');
i = readAt(kayit.IL, t, 'linear');
window = t(end)-t(1);
vMean = trapz(t,v)/window;
sonuc = table(VinSon, Rload, vMean, vMean/Rload, trapz(t,v.^2/Rload)/window, ...
    (max(v)-min(v))*1e3, min(i), max(i), max(i)-min(i), ...
    'VariableNames', {'Vin_V','R_ohm','Vout_V','Iload_A','Pout_W', ...
    'Vout_pp_mV','IL_min_A','IL_max_A','IL_pp_A'});
disp(sonuc);

% Dort PWM periyodu: anahtar dugumu, bobin akimi ve cikis gerilimi.
tZoom = linspace(tEnd-4/fsw, tEnd, 1001).';
tUs = (tZoom-tZoom(1))*1e6;
figure('Name','EE463 - kararli durum','Color','w');
tiledlayout(3,1,'TileSpacing','compact');
nexttile;
stairs(tUs,readAt(kayit.Vsw,tZoom,'previous'),'LineWidth',1.3);
grid on; ylabel('V_{SW} (V)'); ylim([-0.08*VinSon,1.12*VinSon]);
title(sprintf('Son 4 PWM periyodu  |  Vin = %.1f V, R = %.2f ohm',VinSon,Rload));
nexttile;
plot(tUs,readAt(kayit.IL,tZoom,'linear'),'LineWidth',1.4);
grid on; ylabel('i_L (A)');
nexttile;
plot(tUs,readAt(kayit.Vout,tZoom,'linear'),'LineWidth',1.4);
grid on; ylabel('V_{out} (V)'); xlabel('Pencere basindan zaman (\mus)');

if Vin ~= VinSon
    tStep = getVariable(w,'tStep');
    figure('Name','EE463 - giris adimi','Color','w');
    tiledlayout(3,1,'TileSpacing','compact');
    nexttile;
    stairs(kayit.Vin.Time*1e3,kayit.Vin.Data(:),'LineWidth',1.2);
    grid on; ylabel('V_{in} (V)'); xlim([(tStep-0.001)*1e3,tEnd*1e3]);
    title(sprintf('Giris adimi %.0f V -> %.0f V | %s cevrim',Vin,VinSon,char(mod)));
    nexttile;
    plot(kayit.Vout.Time*1e3,kayit.Vout.Data(:),'LineWidth',1);
    yline(getVariable(w,'Vref'),'--'); grid on; ylabel('V_{out} (V)');
    xlim([(tStep-0.001)*1e3,tEnd*1e3]);
    nexttile;
    stairs(kayit.Duty.Time*1e3,100*kayit.Duty.Data(:),'LineWidth',1.2);
    grid on; ylabel('Duty (%)'); xlabel('Zaman (ms)');
    xlim([(tStep-0.001)*1e3,tEnd*1e3]);
end
end

function setCase(model,w,Vin,Rload,mod,VinSon)
assignin(w,'Vin0',Vin); assignin(w,'Vin1',VinSon);
assignin(w,'Rval',Rload); assignin(w,'loopOn',double(mod=="kapali"));
assignin(w,'tStep',0.008);
if Vin==VinSon && mod=="acik"
    tFinal = 0.007;
else
    tFinal = 0.025;
end
set_param(model,'SolverType','Variable-step','Solver','ode23t', ...
    'MaxStep',sprintf('%.17g',1/(40*getVariable(w,'fsw'))), ...
    'StartTime','0','StopTime',sprintf('%.17g',tFinal));
end

function val = readAt(ts,t,method)
[time, keep] = unique(ts.Time(:),'last');
x = reshape(ts.Data,[],1);
val = interp1(time,x(keep),t,method);
end

function buildCircuit(m)
set_param(m,'RelTol','1e-6','AbsTol','1e-8','ReturnWorkspaceOutputs','on');
elm = 'fl_lib/Electrical/Electrical Elements/';
sen = 'fl_lib/Electrical/Electrical Sensors/';
put = @(name,src,xy,varargin) add_block(src,[m '/' name], 'Position',xy,varargin{:});
wire = @(a,b) add_line(m,a,b,'autorouting','smart');
phy = @(a,ap,b,bp) simscape.addConnection([m '/' a],ap,[m '/' b],bp,'autorouting','smart');

put('Giris gerilimi','simulink/Sources/Step',[35 180 70 210], ...
    'Time','tStep','Before','Vin0','After','Vin1');
put('Vin PS','nesl_utility/Simulink-PS Converter',[120 179 165 211], ...
    'Unit','V','FilteringAndDerivatives','zero');
put('Kaynak','fl_lib/Electrical/Electrical Sources/Controlled Voltage Source',[210 180 255 235]);
put('QH',[elm 'Switch'],[375 165 440 215],'R_closed','1e-3','G_open','1e-8','Threshold','0.5');
put('QL',[elm 'Switch'],[475 290 540 340],'R_closed','1e-3','G_open','1e-8','Threshold','0.5');
put('L',[elm 'Inductor'],[610 165 670 205],'l','Lval','r','DCR');
put('iL',[sen 'Current Sensor'],[715 160 760 210]);
put('C',[elm 'Capacitor'],[820 270 870 315],'c','Cval','r','ESR');
put('Yuk',[elm 'Resistor'],[925 270 975 315],'R','Rval');
put('Vo',[sen 'Voltage Sensor'],[1005 170 1050 215]);
put('Vsw',[sen 'Voltage Sensor'],[595 375 640 420]);
put('GND',[elm 'Electrical Reference'],[385 420 425 455]);
put('Solver','nesl_utility/Solver Configuration',[210 390 280 425],'UseLocalSolver','off');
put('PWM ve kontrol','simulink/Ports & Subsystems/Subsystem',[245 35 390 115]);
buildPWM([m '/PWM ve kontrol']);
put('Ust kapi','nesl_utility/Simulink-PS Converter',[465 32 505 58],'FilteringAndDerivatives','zero');
put('Alt kapi','nesl_utility/Simulink-PS Converter',[465 82 505 108],'FilteringAndDerivatives','zero');
put('Vo olcum','nesl_utility/PS-Simulink Converter',[1090 165 1130 195],'Unit','V');
put('IL olcum','nesl_utility/PS-Simulink Converter',[785 82 825 112],'Unit','A');
put('Vsw olcum','nesl_utility/PS-Simulink Converter',[710 378 750 408],'Unit','V');
% Geri besleme yuk uclarindan alinir. Etiketler devre uzerinde uzun hatlari kisaltir.
put('Geri besleme','simulink/Signal Routing/Goto',[1180 113 1270 139],'GotoTag','Vout_feedback');
put('Yuk gerilimi','simulink/Signal Routing/From',[82 60 175 87],'GotoTag','Vout_feedback');
logBlocks = {'Vout kaydi','buckVout',[1180 166 1275 196];'IL kaydi','buckIL',[915 80 1005 110]; ...
    'Vsw kaydi','buckVsw',[810 375 905 405];'Duty kaydi','buckDuty',[400 119 490 145]; ...
    'Vin kaydi','buckVin',[105 258 195 287]};
for k = 1:size(logBlocks,1)
    put(logBlocks{k,1},'simulink/Sinks/To Workspace',logBlocks{k,3}, ...
        'VariableName',logBlocks{k,2},'SaveFormat','Timeseries','MaxDataPoints','inf');
end
set_param([m '/Vin kaydi'],'SampleTime','1/fsw');
set_param([m '/Duty kaydi'],'SampleTime','1/fsw');

wire('Giris gerilimi/1','Vin PS/1'); wire('Giris gerilimi/1','Vin kaydi/1');
wire('Yuk gerilimi/1','PWM ve kontrol/1');
wire('PWM ve kontrol/1','Ust kapi/1'); wire('PWM ve kontrol/2','Alt kapi/1');
wire('PWM ve kontrol/3','Duty kaydi/1');
phy('Vin PS','output','Kaynak','vT');
phy('Ust kapi','output','QH','vT'); phy('Alt kapi','output','QL','vT');
phy('Kaynak','p','QH','p');
phy('QH','n','QL','p'); phy('QH','n','L','p'); phy('QH','n','Vsw','p');
phy('L','n','iL','p');
phy('iL','n','C','p'); phy('iL','n','Yuk','p'); phy('iL','n','Vo','p');
phy('Kaynak','n','GND','V'); phy('QL','n','GND','V'); phy('C','n','GND','V');
phy('Yuk','n','GND','V'); phy('Vo','n','GND','V'); phy('Vsw','n','GND','V');
phy('Solver','port','GND','V');
phy('iL','I','IL olcum','input'); phy('Vo','V','Vo olcum','input'); phy('Vsw','V','Vsw olcum','input');
wire('Vo olcum/1','Geri besleme/1'); wire('Vo olcum/1','Vout kaydi/1');
wire('IL olcum/1','IL kaydi/1'); wire('Vsw olcum/1','Vsw kaydi/1');
end

function buildPWM(s)
Simulink.SubSystem.deleteContents(s);
put = @(name,src,xy,varargin) add_block(src,[s '/' name],'Position',xy,varargin{:});
wire = @(a,b) add_line(s,a,b,'autorouting','smart');
put('Vout','built-in/Inport',[30 95 60 109],'Port','1');
put('Bir periyot gecikme','simulink/Discrete/Unit Delay',[100 85 150 119], ...
    'SampleTime','1/fsw','InitialCondition','Vref');
put('Referans','simulink/Sources/Constant',[110 25 150 55],'Value','Vref');
put('Hata','simulink/Math Operations/Sum',[195 40 215 95],'Inputs','+-');
put('Ornek PI','simulink/Discrete/Discrete Transfer Fcn',[260 42 375 82], ...
    'Numerator','[Kp Ki/fsw-Kp]','Denominator','[1 -1]','SampleTime','1/fsw');
put('Kapali cevrim secimi','simulink/Math Operations/Gain',[415 46 465 78],'Gain','loopOn');
put('Baslangic duty','simulink/Sources/Constant',[425 117 480 147],'Value','Vref/Vin0');
put('Duty toplami','simulink/Math Operations/Sum',[520 50 545 105],'Inputs','++');
put('Duty siniri','simulink/Discontinuities/Saturation',[590 55 640 92], ...
    'LowerLimit','0.05','UpperLimit','0.95');
put('Tasiyici','simulink/Sources/Repeating Sequence',[578 166 642 204], ...
    'rep_seq_t','[0 1/fsw]','rep_seq_y','[0 1]');
put('PWM','built-in/RelationalOperator',[680 64 720 107],'Operator','>');
put('Tamamlayici','built-in/Logic',[754 129 795 160],'Operator','NOT');
put('QH sayisal','simulink/Signal Attributes/Data Type Conversion',[816 52 873 81],'OutDataTypeStr','double');
put('QL sayisal','simulink/Signal Attributes/Data Type Conversion',[816 127 873 156],'OutDataTypeStr','double');
put('QH','built-in/Outport',[915 58 945 72],'Port','1');
put('QL','built-in/Outport',[915 134 945 148],'Port','2');
put('Duty','built-in/Outport',[915 217 945 231],'Port','3');
wire('Vout/1','Bir periyot gecikme/1'); wire('Referans/1','Hata/1');
wire('Bir periyot gecikme/1','Hata/2'); wire('Hata/1','Ornek PI/1');
wire('Ornek PI/1','Kapali cevrim secimi/1'); wire('Kapali cevrim secimi/1','Duty toplami/1');
wire('Baslangic duty/1','Duty toplami/2'); wire('Duty toplami/1','Duty siniri/1');
wire('Duty siniri/1','PWM/1'); wire('Tasiyici/1','PWM/2'); wire('PWM/1','QH sayisal/1');
wire('PWM/1','Tamamlayici/1'); wire('Tamamlayici/1','QL sayisal/1');
wire('QH sayisal/1','QH/1'); wire('QL sayisal/1','QL/1'); wire('Duty siniri/1','Duty/1');
end
