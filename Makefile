utils := math_utils.vhd
b_src := $(utils) racinecarre.vhd racinecarre_tb.vhd
s_src := $(utils) sequential_sqrt.vhd

b_com: $(b_src)
	vcom $(b_src);

s_com: $(s_src)
	vcom $(s_src)

sim: com
	vsim -c -do;

sim-gui: com
	vsim -do;

clean:
	rm -rf work transcript vsim.wlf

work:
	vlib work