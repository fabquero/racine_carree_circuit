library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.utils.all;

entity control_unit is
    generic(n_bits: natural);
    port(
        clk, rst, start : in  std_logic; -- top inputs
        done            : out std_logic; -- top outputs
        reg_rst, reg_ena: out std_logic  -- control outputs
    );
end entity;

architecture structural of control_unit is
    -- register to store state
    component data_register
		generic(n_bits: natural);
		port(
			clk, rst, ena: in std_logic;
			D: in  std_logic_vector(n_bits - 1 downto 0);
			Q: out std_logic_vector(n_bits - 1 downto 0)
		);
	end component;

    -- 00: init; 01: computing; 10: done
    signal state, n_state: std_logic_vector(1 downto 0);
    constant init_s: std_logic_vector(1 downto 0) := "00";
    constant comp_s: std_logic_vector(1 downto 0) := "01";
    constant done_s: std_logic_vector(1 downto 0) := "10";
    
    -- shift register for computation state
    component shift_register
        generic(n_bits: natural);
        port(
            clk, rst, ena: in std_logic;
            Q: out std_logic;
            D: in  std_logic_vector(n_bits - 1 downto 0)
        );
    end component;

    signal sr_out, sr_rst, sr_ena: std_logic;
    signal sr_in:  std_logic_vector(n_bits - 2 downto 0);
begin
    -- sequential state update
    state_reg : data_register
    generic map(n_bits => 2)
    port map(
        clk => clk, rst => rst, ena => '1',
        D => n_state, Q => state
    );

    -- computation state counter
    sr_ena <= to_std_logic(state = init_s);
    sr_rst <= to_std_logic(state = done_s or rst = '1');
    sr_in  <= (n_bits - 2 downto 1 => '0') & '1';
    
    shift_reg : shift_register
    generic map(n_bits => n_bits - 1) -- count n-1 cycles, then the state machine's lag accounts for the last one
    port map(
        clk => clk, rst => sr_rst, ena => sr_ena,
        D => sr_in, Q => sr_out
    );

    -- next state computation
    process(state, start, sr_out) is
    begin
        if start = '0' then -- stay stuck at init if state isn't on
            n_state <= init_s;
        else
            case state is
                when init_s =>
                    n_state <= comp_s;
                when comp_s =>
                    if sr_out = '1' then
                        n_state <= done_s;
                    else
                        n_state <= comp_s;
                    end if;
                when done_s =>
                    n_state <= done_s;
                when others =>
                    n_state <= init_s;
            end case;
        end if;
    end process;

    -- output
    done    <= state(1);
    reg_rst <= rst;
    reg_ena <= not rst and not state(1);
end architecture;
