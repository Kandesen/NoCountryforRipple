#!/bin/bash
# Closed-loop simulation at the four efficiency-bonus input voltages.
# Usage: ./run_02.sh [VIN ...]     (default: 20 24 36 48)
cd "$(dirname "$0")"
mkdir -p out
VINS=${@:-20 24 36 48}
for VIN in $VINS; do
  cat > /tmp/run02_$VIN.cir <<EOF
$(sed "s/^.param VIN=48 FSW=200k/.param VIN=$VIN FSW=200k/" 02_closed_loop.cir | sed '/^.end$/d')
.control
save v(vout) v(sw) i(L1) v(ith) v(vin) i(Lsrc) i(Vdrv) v(tg) v(bg) v(ss) v(fb)
run
meas tran vout_ss  AVG v(vout) from=3.0m to=3.5m
meas tran vout_pp  PP  v(vout) from=3.3m to=3.5m
meas tran il_pp    PP  i(L1)   from=3.3m to=3.5m
meas tran il_avg   AVG i(L1)   from=3.0m to=3.5m
let pinst = v(vin)*i(Lsrc)
let poinst = v(vout)*v(vout)/2.4
meas tran pin      AVG pinst from=3.0m to=3.5m
meas tran pout     AVG poinst from=3.0m to=3.5m
meas tran idrv     AVG i(Vdrv) from=3.0m to=3.5m
meas tran ith_ss   AVG v(ith)  from=3.0m to=3.5m
meas tran vmax_dn  MAX v(vout) from=3.5m to=4.2m
meas tran vmin_up  MIN v(vout) from=4.25m to=5m
meas tran vout_hl  AVG v(vout) from=4.1m to=4.25m
meas tran vout_end AVG v(vout) from=4.85m to=5m
meas tran vout_max_start MAX v(vout) from=0 to=3m
meas tran sw_max   MAX v(sw)   from=3.3m to=3.5m
let eta = pout/(pin - idrv*12)
let pdrv = -idrv*12
print pdrv
print eta
linearize v(vout) i(L1) v(ith) v(ss)
wrdata out/02_vin${VIN}_slow.csv v(vout) i(L1) v(ith) v(ss)
.endc
.end
EOF
  echo "=== VIN = $VIN V ==="
  ( time ngspice -b /tmp/run02_$VIN.cir ) 2>&1 | grep -E "^(pdrv|vout_ss|vout_pp|il_pp|il_avg|pin|pout|idrv|ith_ss|vmax_dn|vmin_up|vout_hl|vout_end|vout_max_start|sw_max|eta)|^real|rror"
done
