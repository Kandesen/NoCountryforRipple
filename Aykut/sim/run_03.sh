#!/bin/bash
# Current-limit test at 24 V input, with (CCLOOP=1) and without (CCLOOP=0) the optional add-on.
cd "$(dirname "$0")"; mkdir -p out
for CC in 1 0; do
  cat > /tmp/run03_$CC.cir <<EOT
$(sed "s/^.param VIN=24 FSW=200k CCLOOP=1/.param VIN=24 FSW=200k CCLOOP=$CC/" 03_current_limit.cir | sed '/^.end$/d')
.control
save v(vout) i(L1) v(opo) v(ith) v(fb) v(ina)
run
let iout = i(L1)
meas tran v_5A     AVG v(vout) from=2.5m  to=3m
meas tran i_5A     AVG iout    from=2.5m  to=3m
meas tran v_1p6    AVG v(vout) from=5.5m  to=6m
meas tran i_1p6    AVG iout    from=5.5m  to=6m
meas tran v_0p5    AVG v(vout) from=8.5m  to=9m
meas tran i_0p5    AVG iout    from=8.5m  to=9m
meas tran v_short  AVG v(vout) from=11.5m to=12m
meas tran i_short  AVG iout    from=11.5m to=12m
meas tran ipk_all  MAX iout    from=3m    to=12m
meas tran v_rec    AVG v(vout) from=14.5m to=15m
meas tran i_rec    AVG iout    from=14.5m to=15m
meas tran vmax_rec MAX v(vout) from=12m   to=15m
linearize v(vout) i(L1) v(opo) v(ith)
wrdata out/03_cc$CC.csv v(vout) i(L1) v(opo) v(ith)
.endc
.end
EOT
  ( ngspice -b /tmp/run03_$CC.cir 2>&1 | grep -E "^(v_|i_|ipk|vmax)|trouble" | awk '{print $1, $3}' | sed "s/^/CCLOOP=$CC  /" > out/r03_$CC.txt ) &
done
wait; cat out/r03_1.txt out/r03_0.txt
