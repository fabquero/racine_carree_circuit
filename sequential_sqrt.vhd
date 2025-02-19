library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity nios_sequential_sqrt is
	generic(n_bits: natural := 32);
	port(
		clk, clk_en, reset, start: in  std_logic;
		done  : out std_logic;
		dataa : in  std_logic_vector(2 * n_bits - 1 downto 0);
		result: out std_logic_vector(2 * n_bits - 1 downto 0)
	);
end entity;

architecture structural of nios_sequential_sqrt is
	-- combinatorial computation module
	component dataflow
		generic(n_bits: natural);
		port(
			D_in : in  std_logic_vector(2 * n_bits - 1 downto 0);
			R_in : in  std_logic_vector(3 + n_bits - 1 downto 0);
			Z_in : in  std_logic_vector(    n_bits - 1 downto 0);

			D_out: out std_logic_vector(2 * n_bits - 1 downto 0);
			R_out: out std_logic_vector(3 + n_bits - 1 downto 0);
			Z_out: out std_logic_vector(    n_bits - 1 downto 0)
		);
	end component;

	-- dataflow input and ouputs
	signal D_in, D_out: std_logic_vector(2 * n_bits - 1 downto 0);
	signal R_in, R_out: std_logic_vector(3 + n_bits - 1 downto 0);
	signal Z_in, Z_out: std_logic_vector(    n_bits - 1 downto 0);

	-- previous and next register values (!= dataflow IO in certain states)
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
	signal done_sig, reg_ena, reg_rst: std_logic;

	-- dataflow control state machine
	component control_unit
		generic(n_bits: natural);
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
					D_in => D_in, D_out => D_out,					
					R_in => R_in, R_out => R_out,			
					Z_in => Z_in, Z_out => Z_out		
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
		generic map(n_bits => n_bits)
		port    map(
					clk => clk, rst => reset, start => start, done => done_sig,
					reg_rst => reg_rst, reg_ena => reg_ena
				);

	-- input/output ------------------------------------------------------------
	-- reg values go into the dataflow
	D_in <= p_D;
	R_in <= p_R;
	Z_in <= p_Z;

	-- dataflow values only go in the res during computation
	n_D  <= (others => '0') when clk_en = '0' else D_out when start = '0' else dataa;
	n_R  <= (others => '0') when clk_en = '0' else R_out when start = '0' else (others => '0');
	n_Z  <= (others => '0') when clk_en = '0' else Z_out when start = '0' else (others => '0');
	
	-- who let the sig out
	result <= (others => '0') when clk_en = '0' else (2 * n_bits - 1 downto n_bits => '0') & p_Z;
	done   <= '0' when clk_en = '0' else done_sig;
end architecture;
