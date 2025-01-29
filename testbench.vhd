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
    constant period: time := 20 ns;

    signal clk    : std_logic := '0';
    signal rst    : std_logic := '0';
    signal start  : std_logic := '0';
    signal done   : std_logic;
    signal reg_rst: std_logic;
    signal reg_ena: std_logic;

    component control_unit
        generic(n_bits: natural);
        port(
            clk, rst, start : in  std_logic; -- top inputs
            done            : out std_logic; -- top outputs
            reg_rst, reg_ena: out std_logic  -- control outputs
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
end architecture;

architecture bit_adder_tb of testbench is
    constant period: time := 20 ns;
    signal a, b, c, d, carry: std_logic;

    component bit_adder
        port(
            a, b, c: in std_logic;
            d, carry: out std_logic
        );
    end component;

    procedure test_adder(
            constant input_a, input_b, input_c, expected_d, expected_carry: in std_logic;
            signal a, b, c: out std_logic;
            signal d, carry: in std_logic
        ) is
    begin
        a <= input_a;
        b <= input_b;
        c <= input_c;
        wait for period;
        assert (d = expected_d and carry = expected_carry)
            report "wrong result: ("
                & std_logic'image(input_a) & ","
                & std_logic'image(input_b) & ","
                & std_logic'image(input_c) & ") => ("
                & std_logic'image(d) & ","
                & std_logic'image(carry) & ")"
            severity error;
    end procedure;
begin
    adder : bit_adder port map(a => a, b => b, c => c, d => d, carry => carry);

    main : process
    begin
        test_adder('0', '0', '0', '0', '0', a, b, c, d, carry);

        test_adder('1', '0', '0', '1', '0', a, b, c, d, carry);
        test_adder('0', '1', '0', '1', '0', a, b, c, d, carry);
        test_adder('0', '0', '1', '1', '0', a, b, c, d, carry);

        test_adder('1', '0', '1', '0', '1', a, b, c, d, carry);
        test_adder('1', '1', '0', '0', '1', a, b, c, d, carry);
        test_adder('0', '1', '1', '0', '1', a, b, c, d, carry);

        test_adder('1', '1', '1', '1', '1', a, b, c, d, carry);

        report "Test: ok" severity failure;
    end process;
end architecture;
