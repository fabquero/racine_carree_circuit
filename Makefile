utils:=utils.vhd
src:=$(utils) bit_adder.vhd signed_adder.vhd d_flip_flop.vhd data_register.vhd shift_register.vhd control_unit.vhd sequential_sqrt.vhd
tb:=testbench
uut:=signed_adder

time?=-all
gui-cmds:=vsim work.$(tb)($(uut)_tb);
gui-cmds+=add wave -position insertpoint *;
gui-cmds+=add wave -position insertpoint sim:/$(tb)/$(uut)_inst/*;
gui-cmds+=run $(time);

com: $(src)
	vcom $(src)

tb: com
	vcom $(tb).vhd

sim: tb
	vsim $(tb) -c -do "vsim work.$(tb)($(uut)_tb); run -all; quit";

sim-gui: com
	vsim $(tb) -do "$(gui-cmds)";

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
