utils:=math_utils.vhd
src:=$(utils) d_flip_flop.vhd data_register.vhd control_unit.vhd sequential_sqrt.vhd

com: $(src)
	vcom $(src)

sim: com
	vsim -c -do;

sim-gui: com
	vsim -do;

clean:
	rm -rf work transcript vsim.wlf

work:
	vlib work

.PHONY: clean, work, sim, sim-gui
