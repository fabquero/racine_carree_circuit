library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_register is
    generic(n_bits: natural);
    port(
        clk, rst, ena: in std_logic;
        Q: out std_logic;
        D: in  std_logic_vector(n_bits - 1 downto 0)
    );
end entity;

architecture structural of shift_register is
    component d_flip_flop
        port(
            clk, rst, D: in  std_logic;
            Q: out std_logic
        );
    end component;
    
    signal ff_in, ff_out: std_logic_vector(n_bits - 1 downto 0);
begin
    -- input
    ff_in <= D when ena = '1' else ff_out(n_bits - 2 downto 0) & '0';

    -- flip flops
    ffs : for i in 0 to n_bits - 1 generate
        d_ff : d_flip_flop
        port map(clk => clk, rst => rst, D => ff_in(i), Q => ff_out(i));
    end generate;

    -- output
    Q <= ff_out(n_bits - 1);
end architecture;
