library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.math_utils.all;

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
			clk, rst, ena: in  std_logic;
			D            : in  std_logic_vector(n_bits - 1 downto 0);
			Q            : out std_logic_vector(n_bits - 1 downto 0)
		);
	end component;

    -- 00: init; 01: computing; 10: done
    signal state, n_state: std_logic_vector(1 downto 0);
    
    -- counter for computation state
    component decrementing_counter
        generic(ctr_bits, ctr_init: natural);
        port(
            clk, rst: in std_logic;
            Q: out std_logic_vector(ctr_bits - 1 downto 0)
        );
    end component;

    -- counter signals
    signal ctr_rst: std_logic;
    signal ctr: std_logic_vector(clog2(n_bits) - 1 downto 0);
begin
    -- sequential state update
    state_reg : data_register
    generic map(n_bits => 2)
    port    map(
        clk => clk, rst => rst, ena => '1',
        D => n_state, Q => state
    );

    -- computation state counter
    ctr_rst <= '1' when not (state ="01") or (rst = '1') else '0';

    counter : decrementing_counter
    generic map(
        ctr_bits => clog2(n_bits),
        ctr_init => n_bits - 1
    )
    port map(
        clk => clk,
        rst => ctr_rst,
        Q => ctr
    );

    -- next state computation
    process(state, start) is
    begin
        if start = '0' then -- stay stuck at init if state isn't on
            n_state <= "00";
        else
            n_state <= state;
            case state is
                when "00" =>     -- start computation when start
                    n_state <= "01";
                when "01" =>     -- stop computation at the end of the counter
                    if ctr = "0" then
                        n_state <= "10";
                    end if;
                when others =>
                    n_state <= "00";
            end case;
        end if;
    end process;

    -- output
    done    <= '1' when state = "10"                else '0';
    reg_rst <= '1' when rst   = '1'  or start = '0' else '0';
    reg_ena <= '0' when state = "10"                else '1';
end architecture;
