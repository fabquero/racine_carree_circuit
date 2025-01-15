library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_register is
    generic(n_bits: natural);
    port(
        clk, rst, ena: in std_logic;
        D: in  std_logic_vector(n_bits - 1 downto 0);
        Q: out std_logic_vector(n_bits - 1 downto 0)
    );
end entity;

architecture behavioral of data_register is
    signal R: std_logic_vector(n_bits - 1 downto 0);
begin
    Q <= R;

    process(clk, rst) is
    begin
        if rst = '1' then
            R <= (others => '0');
        else
            if rising_edge(clk) and ena = '1' then
                R <= D;
            end if;
        end if;
    end process;
end architecture;
