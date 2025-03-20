library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity racinecarre_tb is
end racinecarre_tb;

architecture behavior of racinecarre_tb is
    constant nb: natural := 16;
    -- periode d'horloge de 10ns typique du Nios II standard
    constant clock_period: time := 10 ns;

    constant facilityNumber: natural := 512;

    signal clk : std_logic := '0';
    signal start : std_logic := '0';
    signal rst : std_logic := '0';
    -- on aurait pu utiliser
    signal A : std_logic_vector(2*nb-1 downto 0) := std_logic_vector(to_unsigned(facilityNumber, 2*nb));
    signal Result : std_logic_vector(2*nb-1 downto 0);
    signal readsig : std_logic := '0';
    signal waitrequestsig : std_logic := '0';
    
    begin
     racinecarree : entity work.racinecarree(arch)
        generic map(n_bits => nb)
        port map (
            clk => clk,
            rst => rst,
            write => start,
            read => readsig,
            waitrequest => waitrequestsig,
            writedata => A,
            readdata => Result
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
        readsig <= '1';
        wait for clock_period;
        start <= '1';
        wait for clock_period;
        
        wait until waitrequestsig'event and waitrequestsig = '0';
        wait for clock_period;
            --test qu'on a bien 2^5 = 32
            -- 00000000000000000000000000000011
        assert Result = "00000000000000000000000000010110" report "Erreur, ce n'est pas la valeur 22, la valeur donnee est :" & (integer'image(to_integer(unsigned(A)))) & " mais la valeur " & (integer'image(to_integer(unsigned(Result)))) & " est trouvee !" severity failure;

        start <= '0';
        readsig <= '0';
        wait for clock_period;
        -- test la limite de la valeur
        A <= "11111111111111111111111111111111";
        wait for clock_period;
        start <= '1';
        wait until waitrequestsig'event and waitrequestsig = '0';
        readsig <= '1';
           --test qu'on a bien 2^16-1
           -- 00000000000000001111111111111111
            assert Result = "00000000000000001111111111111111" report "Erreur, ce n'est pas la valeur 65535, la valeur donnee est :" & (integer'image(to_integer(unsigned(A)))) & " mais la valeur " & (integer'image(to_integer(unsigned(Result)))) & " est trouvee !" severity failure;
           --assert Result = "11" report "Erreur, ce n'est pas la valeur 3" severity failure;
            report "Test Done." severity failure ;
    end process;


end architecture behavior;
