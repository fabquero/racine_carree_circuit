library ieee;
use ieee.std_logic_1164.all;

entity d_flip_flop is
    generic(
        reset_value: std_logic := '0'
    );
    port(
        clk, rst, D: in  std_logic;
        Q: out std_logic
    );
end entity;

architecture behavioral of d_flip_flop is
    signal R: std_logic;
begin
    process(clk, rst) is
    begin
        if rst = '1' then
            R <= '0';
        else
            if rising_edge(clk) then
                R <= D;
            end if;
        end if;
    end process;

    Q <= R;
end architecture;
