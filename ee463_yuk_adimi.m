function [T, iz] = ee463_yuk_adimi()
% EE463 | 24 V girişte 4.8 ohm -> 2.4 ohm yük adımı (MATLAB R2025b).
% EE463_Buck_Baslangic.slx ile aynı klasörde Tyuk = ee463_yuk_adimi;
% İkinci çıktı, çıkış gerilimi ve toplam yük akımının zaman kayıtlarını verir.
% Devre ve kontrol değerleri 60 W statik taraması ile aynıdır. Yük anahtarı
% 8 ms'de ikinci bir 4.8 ohm direnci ilkine paralel bağlar.

source = 'EE463_Buck_Baslangic';
if bdIsLoaded(source)
    file = get_param(source,'FileName');
else
    file = which([source '.slx']);
end
if isempty(file) || ~isfile(file)
    error('EE463_Buck_Baslangic.slx dosyasinin bulundugu klasore gec.');
end

% Ayrı bir geçici model kullan. Ana modeldeki devre ve ayarları koru.
[~,suffix] = fileparts(tempname);
model = matlab.lang.makeValidName(['EE463_Yuk_' suffix]);
new_system(model,'FromFile',file);
releaseModel = onCleanup(@()close_system(model,0)); %#ok<NASGU>
ws = get_param(model,'ModelWorkspace');
fsw = 230e3;
tStep = 8e-3;
R = 4.8;
parameters = struct('Vin0',24,'Vin1',24,'Vref',12,'loopOn',1,'tStep',tStep, ...
    'fsw',fsw,'Lval',10e-6,'Cval',100e-6,'ESR',0.010,'DCR',0.0069, ...
    'Kp',0.003,'Ki',25,'Rval',R);
names = fieldnames(parameters);
for k = 1:numel(names)
    name = names{k};
    assignin(ws,name,parameters.(name));
end
set_param([model '/QH'],'R_closed','5.2e-3');
set_param([model '/QL'],'R_closed','5.2e-3');
set_param(model,'SolverType','Variable-step','Solver','ode23t', ...
    'MaxStep',sprintf('%.17g',1/(40*fsw)),'StartTime','0','StopTime','0.020', ...
    'RelTol','1e-6','AbsTol','1e-8','ReturnWorkspaceOutputs','on');

addLoadBranch(model);
simOut = sim(model,'ReturnWorkspaceOutputs','on');
vo = simOut.get('buckVout');
extra = simOut.get('extraLoadA');
[t, iv] = unique(vo.Time(:),'last');
v = reshape(vo.Data,[],1);
v = v(iv);
[ti, ii] = unique(extra.Time(:),'last');
secondBranch = reshape(extra.Data,[],1);
% Sabit kolda i=v/R. İkinci kolun akımını seri akım sensörü ölçer.
iLoad = v/R + interp1(ti,secondBranch(ii),t,'linear');

% Yük adımından önceki ve simülasyon sonundaki ortalamalar 20 tam PWM
% periyoduna aittir. İlk pencere, yük adımından bir periyot önce biter.
before = linspace(tStep-21/fsw,tStep-1/fsw,1601).';
tail = linspace(t(end)-20/fsw,t(end),1601).';
meanOn = @(x,grid) trapz(grid,interp1(t,x,grid,'linear'))/(grid(end)-grid(1));
vFinal = meanOn(v,tail);
after = t >= tStep;
vAfter = v(after);
tAfter = t(after);
vMin = min(vAfter);
vMax = max(vAfter);
% Yerleşme: çıkışın son ortalama değerin ±%2 bandında kalmaya başladığı an.
band = 0.02*vFinal;
lastOutside = find(abs(vAfter-vFinal)>band,1,'last');
if isempty(lastOutside)
    settlingMs = 0;
elseif lastOutside == numel(tAfter)
    settlingMs = NaN;
else
    settlingMs = 1e3*(tAfter(lastOutside+1)-tStep);
end
T = table(meanOn(iLoad,before),meanOn(iLoad,tail),meanOn(v,before),vFinal, ...
    vMin,vMax,1000*max(0,vFinal-vMin),settlingMs, ...
    'VariableNames',{'Ionce_A','Ison_A','Vonce_V','Vson_V', ...
    'Vmin_V','Vmax_V','Cokme_mV','Yerlesme_ms'});
disp(T);
if nargout > 1
    iz = timetable(seconds(t),v,iLoad,'VariableNames',{'Vout_V','Iload_A'});
end

figure('Name','EE463 | 24 V yük adımı');
tiledlayout(2,1,'TileSpacing','compact');
% Grafikte sıfır, yükün değiştiği andır.
tms = 1e3*(t-tStep);
visible = (tms>=-0.25) & (tms<=1.50);
ax1 = nexttile;
plot(tms(visible),iLoad(visible),'LineWidth',1.2);
xline(0,':'); ylabel('Yük akımı (A)'); grid on;
title('24 V giriş | 4,8 \Omega yükten 2,4 \Omega yüke geçiş');
ax2 = nexttile;
plot(tms(visible),v(visible),'LineWidth',1.2);
xline(0,':'); yline(vFinal-band,'--'); yline(vFinal+band,'--');
ylabel('Çıkış gerilimi (V)'); xlabel('Yük adımından itibaren zaman (ms)'); grid on;
linkaxes([ax1 ax2],'x'); xlim([-0.25 1.50]);
end

function addLoadBranch(m)
elm = 'fl_lib/Electrical/Electrical Elements/';
put = @(name,src,pos,varargin) add_block(src,[m '/' name],'Position',pos,varargin{:});
connect = @(a,pa,b,pb) simscape.addConnection([m '/' a],pa,[m '/' b],pb,'autorouting','smart');
put('Yuk komutu','simulink/Sources/Step',[550 535 585 565], ...
    'Time','tStep','Before','0','After','1');
put('Yuk komutu PS','nesl_utility/Simulink-PS Converter',[640 535 683 565], ...
    'FilteringAndDerivatives','zero');
put('Yuk anahtari',[elm 'Switch'],[745 525 805 575], ...
    'Threshold','0.5','R_closed','1e-6','G_open','1e-8');
put('Ek yuk',[elm 'Resistor'],[890 530 940 570],'R','Rval');
put('Ek akim sensoru','fl_lib/Electrical/Electrical Sensors/Current Sensor',[1000 520 1055 575]);
put('Ek akim olcumu','nesl_utility/PS-Simulink Converter',[1110 535 1155 565],'Unit','A');
put('Ek akim kaydi','simulink/Sinks/To Workspace',[1210 535 1300 565], ...
    'VariableName','extraLoadA','SaveFormat','Timeseries','MaxDataPoints','inf');
add_line(m,'Yuk komutu/1','Yuk komutu PS/1','autorouting','smart');
connect('Yuk komutu PS','output','Yuk anahtari','vT');
connect('Yuk','p','Yuk anahtari','p');
connect('Yuk anahtari','n','Ek yuk','p');
connect('Ek yuk','n','Ek akim sensoru','p');
connect('Ek akim sensoru','n','Yuk','n');
connect('Ek akim sensoru','I','Ek akim olcumu','input');
add_line(m,'Ek akim olcumu/1','Ek akim kaydi/1','autorouting','smart');
end
