library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity;

architecture reg_tb of testbench is
    constant n_bits: natural := 4;
    constant period: time := 20 ns;

    signal clk: std_logic := '0';
    signal rst: std_logic := '0';
    signal ena: std_logic := '0';
    signal D: std_logic_vector(n_bits - 1 downto 0);
    signal Q: std_logic_vector(n_bits - 1 downto 0);

    component data_register
        generic(n_bits: natural);
        port(
            clk, rst, ena: in std_logic;
            D: in  std_logic_vector(n_bits - 1 downto 0);
            Q: out std_logic_vector(n_bits - 1 downto 0)
        );
    end component;
begin
    -- clock
    clk_gen : process
    begin
        clk <= '0';
        wait for period / 2;
        clk <= '1';
        wait for period / 2;
    end process;

    -- unit under test
    reg : data_register
    generic map(n_bits => n_bits)
    port map(clk => clk, rst => rst, ena => ena, D => D, Q => Q);

    main : process
    begin
        rst <= '1';
        wait for period;
        assert (Q = (n_bits - 1 downto 0 => '0')) report "wrong Q value during reset" severity error;

        rst <= '0';
        D <= (others => '1');
        wait for period;
        assert (Q = (n_bits - 1 downto 0 => '0')) report "Q modified without enable" severity error;

        ena <= '1';
        wait for period;
        assert (Q = (n_bits - 1 downto 0 => '1')) report "Q not modified with enable" severity error;

        ena <= '0';
        wait for period;
        D <= (others => '0');
        wait for period;
        assert (Q = (n_bits - 1 downto 0 => '1')) report "Q reset without enable" severity error;

        report "Test: ok" severity failure;
    end process;
end architecture;

architecture cu_tb of testbench is

    component control_unit
        generic(n_bits: natural);
        port(
            clk, rst, start : in  std_logic; -- top inputs
            done            : out std_logic; -- top outputs
            reg_rst, reg_ena: out std_logic  -- control outputs
        );
    end component;
begin

end architecture;
