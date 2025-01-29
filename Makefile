utils:=math_utils.vhd
src:=$(utils) bit_adder.vhd d_flip_flop.vhd data_register.vhd shift_register.vhd control_unit.vhd sequential_sqrt.vhd
tb:=testbench
uut:=bit_adder
time?=-all

com: $(src)
	vcom $(src)

tb: com
	vcom $(tb).vhd

sim: tb
	vsim $(tb) -c -do "vsim work.$(tb)($(uut)_tb); run -all; quit";

sim-gui: com
	vsim $(tb) -do "vsim work.$(tb)($(uut)_tb); add wave *; add wave sim:/$(tb)/$(uut)/*; run $(time);";

clean:
	rm -rf work transcript vsim.wlf

work:
	vlib work

help:
	@echo "com    : compiles given sources in order"
	@echo "tb     : compiles testbench sources"
	@echo "sim    : runs simulation on the unit specified by the uut variable"
	@echo "sim_gui: displays waveforms on the above test unit in modelsim"
	@echo "clean  : removes compilation output"
	@echo "work   : initializes working library"

.PHONY: clean, work, sim, sim-gui, help
