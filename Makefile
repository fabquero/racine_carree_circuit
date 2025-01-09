src := racinecarre.vhd racinecarre_tb.vhd

com: $(src)
	vcom $(src);

sim: com
	vsim -c -do;

sim-gui: com
	vsim -do;

clean:
	rm -rf work transcript vsim.wlf

work:
	vlib work