library ieee;
use ieee.std_logic_1164.all;

-- Wrapper around the sequential_sqrt module that handles avalon transactions
-- and stores results for future reads.
--
-- Write transactions load the sqrt computation module without blocking, read
-- transactions block until the sqrt of the previous written value is ready.
--
-- Does not support genericity, as it is only made to work with a 32 bit Nios.
entity avalon_sqrt is
    port (
        clk,  rst  : in  std_logic;
        read, write: in  std_logic;
        wdata      : in  std_logic_vector(31 downto 0);
        rdata      : out std_logic_vector(31 downto 0);
        waitrequest: out std_logic
    );
end entity;

architecture structural of avalon_sqrt is
    -- validity flag -----------------------------------------------------------
    component d_flip_flop
        generic(
            reset_value: std_logic
        );
        port(
            clk, rst, D: in std_logic;
            Q: out std_logic
        );
    end component;

    signal valid_D, valid_Q: std_logic;

    -- result storage ----------------------------------------------------------
    component data_register
        generic(n_bits: natural);
        port(
            clk, rst, ena: in std_logic;
            D: in  std_logic_vector(n_bits - 1 downto 0);
            Q: out std_logic_vector(n_bits - 1 downto 0)
        );
    end component;

    signal result_D, result_Q: std_logic_vector(15 downto 0);
    signal result_ena: std_logic;

    -- sqrt computation module -------------------------------------------------
    component sequential_sqrt
        generic(n_bits: natural);
	    port(
	    	clk, rst, start: in  std_logic;
	    	done           : out std_logic;
	    	data_in        : in  std_logic_vector(2 * n_bits - 1 downto 0);
	    	data_out       : out std_logic_vector(    n_bits - 1 downto 0)
	    );
    end component;
    
    signal sqrt_Q: std_logic_vector(15 downto 0);
    signal sqrt_D: std_logic_vector(31 downto 0);
    signal sqrt_done, sqrt_start: std_logic;

    -- output helper signal ----------------------------------------------------
    signal short_rdata: std_logic_vector(15 downto 0); -- 16-bit rdata signal
begin
    -- sqrt module -------------------------------------------------------------
    sqrt : sequential_sqrt
        generic map(n_bits => 16)
        port map(
            clk => clk, rst => rst, 
            done => sqrt_done, start => sqrt_start,
            data_in => sqrt_D, data_out => sqrt_Q
        );

    sqrt_D <= wdata;
    sqrt_start <= write;

    -- result storage ----------------------------------------------------------
    result_reg : data_register
        generic map(n_bits => 16)
        port map(
            clk => clk, rst => rst,
            ena => result_ena,
            D => result_D, Q => result_Q
        );

    result_D <= sqrt_Q;
    result_ena <= sqrt_done;

    -- validity flag -----------------------------------------------------------
    valid_dff : d_flip_flop
        generic map(
            reset_value => '1'
        )
        port map(
            clk => clk, rst => rst,
            D => valid_D, Q => valid_Q
        );

    valid_D <= (sqrt_done or valid_Q) and not write; 

    -- output signals ----------------------------------------------------------
    short_rdata <= result_Q when sqrt_done = '0' else sqrt_Q;
    rdata <= (31 downto 16 => '0') & short_rdata;

    waitrequest <= '0'                        when write = '1' else -- writing is non-blocking
                   not (valid_Q or sqrt_done) when read  = '1' else -- wait when reading if data isn't ready
                   '1';                                             -- wait if nothing is happenning
end architecture;
