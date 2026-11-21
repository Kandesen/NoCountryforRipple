#!/bin/bash
# Runs the ideal power-stage simulation at all four input voltages and writes CSV data.
cd "$(dirname "$0")"
for VIN in 20 24 36 48; do
  D=$(python3 -c "print((12.0 + 5*0.014)/$VIN)")   # include resistive drops
  cat > /tmp/run01_$VIN.cir <<EOF
$(sed "s/^.param VIN=48 D=0.25 FSW=200k/.param VIN=$VIN D=$D FSW=200k/" 01_powerstage_ideal.cir | sed '/^.end$/d')
.control
run
meas tran vout_avg AVG v(vout) from=7.8m to=8m
meas tran vout_pp  PP  v(vout) from=7.8m to=8m
meas tran il_pp    PP  i(L1)  from=7.8m to=8m
meas tran il_max   MAX i(L1)  from=7.8m to=8m
wrdata out/01_vin$VIN.csv v(sw) i(L1) v(vout)
.endc
.end
EOF
  ngspice -b /tmp/run01_$VIN.cir 2>/dev/null | grep -E "^(vout_avg|vout_pp|il_pp|il_max)" | sed "s/^/Vin=$VIN  /"
done
