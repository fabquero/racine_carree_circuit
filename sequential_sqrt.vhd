library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.math_utils.all;

entity sequential_sqrt is
	generic(n_bits: natural);
	port(
		clk, rst, start: in  std_logic;
		done           : out std_logic;
		data_in        : in  std_logic_vector(2 * n_bits - 1 downto 0);
		data_out       : out std_logic_vector(n_bits -1 downto 0)
	);
end entity;

architecture structural of sequential_sqrt is
	-- combinatorial computation module
	component dataflow
		generic(n_bits: natural);
		port(
			p_D: in  std_logic_vector(2 * n_bits - 1 downto 0);
			p_R: in  std_logic_vector(3 + n_bits - 1 downto 0);
			p_Z: in  std_logic_vector(    n_bits - 1 downto 0);

			n_D: out std_logic_vector(2 * n_bits - 1 downto 0);
			n_R: out std_logic_vector(3 + n_bits - 1 downto 0);
			n_Z: out std_logic_vector(    n_bits - 1 downto 0)
		);
	end component;

	-- previous and next data values relative to the computation module
	signal p_D, n_D: std_logic_vector(2 * n_bits - 1 downto 0);
	signal p_R, n_R: std_logic_vector(3 + n_bits - 1 downto 0);
	signal p_Z, n_Z: std_logic_vector(    n_bits - 1 downto 0);

	-- data register in-between iterations
	component data_register
		generic(n_bits: natural);
		port(
			clk, rst, ena: in  std_logic;
			D            : in  std_logic_vector(n_bits - 1 downto 0);
			Q            : out std_logic_vector(n_bits - 1 downto 0)
		);
	end component;

	-- data register control signals
	signal reg_ena, reg_rst: std_logic;

	-- dataflow control state machine
	component control_unit
		generic(ctr_bits, ctr_init: natural);
		port(
			clk, rst, start : in  std_logic; -- top inputs
			done            : out std_logic; -- top outputs
			reg_ena, reg_rst: out std_logic  -- control signals
		);
	end component;
begin
	-- dataflow ----------------------------------------------------------------
	df : dataflow
		generic map(n_bits => n_bits)
		port    map(
					p_D => p_D, p_R => p_R, p_Z => p_Z,
					n_D => n_D, n_R => n_R, n_Z => n_Z
				);

	-- registers ---------------------------------------------------------------
	reg_D : data_register
		generic map(n_bits => 2 * n_bits)
		port    map(
					clk => clk, rst => reg_rst, ena =>reg_ena,
					D => n_D,
					Q => p_D
				);

	reg_R : data_register
		generic map(n_bits => 3 + n_bits)
		port    map(
					clk => clk, rst => reg_rst, ena => reg_ena,
					D => n_R,
					Q => p_R
				);

	reg_Z : data_register
		generic map(n_bits => n_bits)
		port    map(
					clk => clk, rst => reg_rst, ena => reg_ena,
					D => n_Z,
					Q => p_Z
				);

	-- control unit ------------------------------------------------------------
	cu : control_unit
		generic map(ctr_bits => clog2(n_bits), ctr_init => n_bits)
		port    map(
					clk => clk, rst => rst, start => start, done => done,
					reg_rst => reg_rst, reg_ena => reg_ena
				);
end architecture;
