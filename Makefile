utils:=math_utils.vhd
src:=$(utils) d_flip_flop.vhd data_register.vhd shift_register.vhd control_unit.vhd sequential_sqrt.vhd
tb:=testbench
uut:=reg
time?=-all

com: $(src)
	vcom $(src)

tb: com
	vcom $(tb).vhd

sim: tb
	vsim $(tb) -c -do "vsim work.$(tb)($(uut)_tb); run -all";

sim-gui: com
	vsim $(tb) -do "vsim work.$(tb)($(uut)_tb); add wave *; add wave sim:/$(tb)/$(uut)/*; run $(time);";

clean:
	rm -rf work transcript vsim.wlf

work:
	vlib work

.PHONY: clean, work, sim, sim-gui
