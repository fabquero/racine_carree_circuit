library ieee;
use ieee.std_logic_1164.all;

entity racinecarre_tb is
end racinecarre_tb;

architecture behavior of racinecarre_tb is
    constant nb: integer := 32;
    constant clock_period: time := 100 ns;

    signal clk : std_logic := '0';
    signal start : std_logic := '0';
    signal rst : std_logic := '0';
    signal A : std_logic_vector(nb-1 downto 0) := (9=>'1',others => '0');
    signal Result : std_logic_vector(nb-1 downto 0);
    signal done : std_logic;
    
    begin
     racinecarre : entity work.racinecarre(arch)
        generic map(N => nb)
        port map (
            clk => clk,
            rst => rst,
            start => start,
            data_in => A,
            done => done,
            data_out => Result
        );

    rst <= '1';

    clock_process: process begin
        clk <= '0';
        wait for clock_period/2;
        clk <= '1';
        wait for clock_period/2;
    end process;

    process begin
        start <= '0';
        wait for clock_period*2;
        start <= '1';
        if done = '1' then
            -- test qu'on a bien 2^5 = 32
            assert Result = "00000000000000000000000000010000" report "Erreur, ce n'est pas la valeur 2^5" severity error;
            assert false report "Test: OK" severity failure;
        end if;
    end process;


end architecture behavior;