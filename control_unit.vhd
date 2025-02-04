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
    signal sr_in:  std_logic_vector(n_bits - 1 downto 0);
begin
    -- sequential state update
    state_reg : data_register
    generic map(n_bits => 2)
    port    map(
        clk => clk, rst => rst, ena => '1',
        D => n_state, Q => state
    );

    -- computation state counter
    sr_rst <= '1' when (state ="10") or (rst = '1') else '0';
    sr_in  <= (n_bits - 1 downto 1 => '0') & '1';
    sr_ena <= '1' when state = "00" else '0';

    sr : shift_register
    generic map(n_bits => n_bits)
    port map(
        clk => clk, rst => sr_rst, ena => sr_ena,
        D => sr_in, Q => sr_out
    );

    -- next state computation
    process(state, start) is
    begin
        if start = '0' then -- stay stuck at init if state isn't on
            n_state <= "00";
        else
            n_state <= state;
            case state is
                when "00" =>
                    n_state <= "01";
                when "01" =>
                    if sr_out = '1' then
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
