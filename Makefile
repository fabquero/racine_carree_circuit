# fichier de package
PACKAGES_FILES := math_utils.vhd
# fichier comportemental
SOURCES := $(PACKAGES_FILES) racinecarree.vhd racinecarre_tb.vhd

# nom du testbench utilise
TESTBENCH := racinecarre_tb
TIME ?= -all

com: $(SOURCES)
	vcom $(SOURCES);

# lance une simulation en mode console
sim: com
	vsim $(TESTBENCH) -c -do "run -all;";

# lance une simulation en mode gui
# commande : make sim-gui [TIME=TempsUnite]; exemple: make sim-gui TIME=100us
sim-gui: com
	vsim $(TESTBENCH) -do "add wave *; add wave sim:/racinecarre_tb/racinecarree/*; add wave sim:/racinecarre_tb/racinecarree/comport/*; run $(TIME);";

clean:
	rm -rf work transcript vsim.wlf

work:
	vlib work