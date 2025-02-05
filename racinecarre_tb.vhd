library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity racinecarre_tb is
end racinecarre_tb;

architecture behavior of racinecarre_tb is
    constant nb: natural := 32;
    -- periode d'horloge de 10ns typique du Nios II standard
    constant clock_period: time := 10 ns;

    constant facilityNumber: natural := 512;

    signal clk : std_logic := '0';
    signal start : std_logic := '0';
    signal rst : std_logic := '0';
    -- on aurait pu utiliser
    signal A : std_logic_vector(2*nb-1 downto 0) := std_logic_vector(to_unsigned(facilityNumber, 2*nb));
    signal Result : std_logic_vector((nb-1) downto 0);
    signal done : std_logic;
    
    begin
     racinecarree : entity work.racinecarree(arch)
        generic map(n_bits => nb)
        port map (
            clk => clk,
            rst => rst,
            start => start,
            data_in => A,
            done => done,
            data_out => Result
        );

    reset_process: process
    begin
        rst <= '1';
        wait for clock_period;
        rst <= '0';
        wait;
    end process;

    clock_process: process begin
        clk <= '0';
        wait for clock_period/2;
        clk <= '1';
        wait for clock_period/2;
    end process;

    simple_test: process begin
        start <= '0';
        wait for clock_period;
        start <= '1';
        wait for clock_period;
        wait until done'event and done = '1';
            --test qu'on a bien 2^5 = 32
            -- 00000000000000000000000000000011
           assert Result = "00000000000000000000000000010110" report "Erreur, ce n'est pas la valeur 3, la valeur donnee est :" & (integer'image(to_integer(unsigned(A)))) & " mais la valeur " & (integer'image(to_integer(unsigned(Result)))) & " est trouvee !" severity failure;
           --assert Result = "11" report "Erreur, ce n'est pas la valeur 3" severity failure;
           report "Test Done." severity failure ;
    end process;


end architecture behavior;