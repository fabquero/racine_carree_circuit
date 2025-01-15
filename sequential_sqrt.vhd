library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.math_utils.all;

entity sequential_sqrt is
	generic(n_bits: integer);
	port(
		clk  : in std_logic;
		rst  : in std_logic;
		start: in std_logic;
		done : out std_logic;
		data_in : in std_logic_vector(2 * n_bits - 1 downto 0);
		data_out: out std_logic_vector(n_bits -1 downto 0)
	);
end entity;
