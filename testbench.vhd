library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library std;
use std.textio.all;

library work;
use work.utils.all;

entity testbench is
end entity;

architecture data_register_tb of testbench is
    constant n_bits: natural := 4;
    constant period: time := 20 ns;

    signal clk, rst, ena: std_logic;
    signal D, Q: std_logic_vector(n_bits - 1 downto 0);

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
    data_register_inst : data_register
        generic map(n_bits => n_bits)
        port map(clk => clk, rst => rst, ena => ena, D => D, Q => Q);

    main : process
    begin
        rst <= '0';
        ena <= '0';

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

architecture shift_register_tb of testbench is
    constant period: time := 20 ns;
    constant n_bits: natural := 4;

    signal clk, rst, ena, Q: std_logic;
    signal D: std_logic_vector(n_bits - 1 downto 0);

    component shift_register
        generic(n_bits: natural);
        port(
            clk, rst, ena: in std_logic;
            Q: out std_logic;
            D: in  std_logic_vector(n_bits - 1 downto 0)
        );
    end component;

    procedure test(
            constant delay: in natural;

            signal   D_sig: out std_logic_vector(4 - 1 downto 0);
            constant D_val: in  std_logic_vector(4 - 1 downto 0);

            signal   rst_sig: out std_logic;
            constant rst_val: in  std_logic;

            signal   ena_sig: out std_logic;
            constant ena_val: in  std_logic;
            
            signal   Q_sig: in std_logic;
            constant Q_val: in std_logic
        ) is
    begin
        rst_sig <= rst_val;
        ena_sig <= ena_val;
        D_sig <= D_val;
        wait for period;
        rst_sig <= '0';
        ena_sig <= '0';
        wait for (delay - 1) * period;

        assert (Q_sig = Q_val)
            report "wrong output: ("
                & to_string(D_val) & ","
                & std_logic'image(rst_val) & ","
                & std_logic'image(ena_val) & ") => "
                & std_logic'image(Q_sig) & " != "
                & std_logic'image(Q_val)
            severity error;
    end procedure;
begin
    shift_register_inst : shift_register
        generic map(n_bits => n_bits)
        port map(clk => clk, rst => rst, ena => ena, D => D, Q => Q);

    clk_gen : process
    begin
        clk <= '1';
        wait for period/2;
        clk <= '0';
        wait for period/2;
    end process;

    main : process
    begin
        wait for period/2;

        -- reset with different values
        test(1, D, (n_bits - 1 downto 0 => '0'), rst, '1', ena, '0', Q, '0');
        test(1, D, (n_bits - 1 downto 0 => '1'), rst, '1', ena, '0', Q, '0');
        test(1, D, (n_bits - 1 downto 0 => '0'), rst, '1', ena, '1', Q, '0');
        test(1, D, (n_bits - 1 downto 0 => '1'), rst, '1', ena, '1', Q, '0');

        -- reset with hdifferent delays
        test(2, D, (n_bits - 1 downto 0 => '1'), rst, '1', ena, '0', Q, '0');
        test(3, D, (n_bits - 1 downto 0 => '1'), rst, '1', ena, '0', Q, '0');
        test(4, D, (n_bits - 1 downto 0 => '1'), rst, '1', ena, '0', Q, '0');

        -- ena with different values
        test(1, D,       (n_bits - 1 downto 0 => '0'), rst, '0', ena, '1', Q, '0');
        test(1, D, '0' & (n_bits - 2 downto 0 => '1'), rst, '0', ena, '1', Q, '0');
        test(1, D,       (n_bits - 1 downto 0 => '1'), rst, '0', ena, '1', Q, '1');

        -- ena with different delays
        test(1, D, (n_bits - 2 downto 0 => '0') & '1', rst, '0', ena, '1', Q, '0');
        test(2, D, (n_bits - 2 downto 0 => '0') & '1', rst, '0', ena, '1', Q, '0');
        test(3, D, (n_bits - 2 downto 0 => '0') & '1', rst, '0', ena, '1', Q, '0');
        test(4, D, (n_bits - 2 downto 0 => '0') & '1', rst, '0', ena, '1', Q, '1');
        test(5, D, (n_bits - 2 downto 0 => '0') & '1', rst, '0', ena, '1', Q, '0');

        report "Test: ok" severity failure;
    end process;
end architecture;

architecture control_unit_tb of testbench is
    constant period: time := 20 ns;
    constant n_bits: natural := 4;

    signal clk, rst, start, done, reg_rst, reg_ena: std_logic;

    component control_unit
        generic(n_bits: natural);
        port(
            clk, rst, start : in  std_logic; -- top inputs
            done            : out std_logic; -- top outputs
            reg_rst, reg_ena: out std_logic  -- control outputs
        );
    end component;

    procedure test(
        constant delay: in natural;
        constant done_val, reg_rst_val, reg_ena_val: in std_logic;
        constant message: in string
    ) is
        variable result: line;
    begin
        wait for delay * period;
        write(result, "("
            & std_logic'image(rst) & ","
            & std_logic'image(start) & ") => ("
            & std_logic'image(done) & "," 
            & std_logic'image(reg_rst) & "," 
            & std_logic'image(reg_ena) & ") != ("
            & std_logic'image(done_val) & "," 
            & std_logic'image(reg_rst_val) & "," 
            & std_logic'image(reg_ena_val) & ")"
        );
        assert done = done_val and reg_rst = reg_rst_val and reg_ena = reg_ena_val
            report message & ": " & result.all
            severity error;
    end procedure;
begin
    -- uut
    control_unit_inst : control_unit
        generic map(n_bits => n_bits)
        port map(
            clk => clk, rst => rst, start => start,
            done => done,
            reg_rst => reg_rst, reg_ena => reg_ena
        );

    -- clock
    clk_gen : process
    begin
        clk <= '0';
        wait for period / 2;
        clk <= '1';
        wait for period / 2;
    end process;

    -- main
    main : process
    begin
        rst <= '1';
        start <= '0';
        test(1, '0', '1', '0', "wrong reset values");

        rst <= '0';
        test(1, '0', '0', '1', "wrong init values");

        start <= '1';
        test(1, '0', '0', '1', "wrong value during computation (3)");
        test(1, '0', '0', '1', "wrong value during computation (2)");
        test(1, '0', '0', '1', "wrong value during computation (1)");
        test(1, '0', '0', '1', "wrong value during computation (0)");
        test(1, '1', '0', '0', "wrong value after computation (result)");
        test(1, '1', '0', '0', "wrong value after computation (hold)");

        start <= '0';
        test(1, '0', '0', '1', "wrong transition from done_s to init_s");

        report "Test: ok" severity failure;
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

    procedure test(
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
    bit_adder_inst : bit_adder port map(a => a, b => b, c => c, d => d, carry => carry);

    main : process
    begin
        test('0', '0', '0', '0', '0', a, b, c, d, carry);

        test('1', '0', '0', '1', '0', a, b, c, d, carry);
        test('0', '1', '0', '1', '0', a, b, c, d, carry);
        test('0', '0', '1', '1', '0', a, b, c, d, carry);

        test('1', '0', '1', '0', '1', a, b, c, d, carry);
        test('1', '1', '0', '0', '1', a, b, c, d, carry);
        test('0', '1', '1', '0', '1', a, b, c, d, carry);

        test('1', '1', '1', '1', '1', a, b, c, d, carry);

        report "Test: ok" severity failure;
    end process;
end architecture;

architecture signed_adder_tb of testbench is
    constant period: time := 20 ns;
    signal A, B, SUM: std_logic_vector(2 downto 0);
    signal OVF, SIG: std_logic;

    component signed_adder
        generic(n_bits: natural);
        port(
            A, B: in  std_logic_vector(n_bits - 1 downto 0); -- inputs, signed
            SUM : out std_logic_vector(n_bits - 1 downto 0); -- output sum
            SIG : in  std_logic; -- sign-flips B
            OVF : out std_logic  -- overflow flag
        );
    end component;

    procedure test(
        signal   A_sig: out std_logic_vector(2 downto 0);
        constant A_val: in  std_logic_vector(2 downto 0);

        signal   B_sig: out std_logic_vector(2 downto 0);
        constant B_val: in  std_logic_vector(2 downto 0);
        
        signal   SUM_sig: in std_logic_vector(2 downto 0);
        constant SUM_val: in std_logic_vector(2 downto 0);
        
        signal   SIG_sig: out std_logic;
        constant SIG_val: in  std_logic;

        signal   OVF_sig: in std_logic;
        constant OVF_val: in std_logic
    ) is
    begin
        A_sig <= A_val;
        B_sig <= B_val;
        SIG_sig <= SIG_val;
        wait for period;
        assert (SUM_sig = SUM_val) and (OVF_sig = OVF_val)
            report "wrong result: ("
                & to_string(A_val) & ","
                & to_string(B_val) & ","
                & std_logic'image(SIG_val) & ") => ("
                & to_string(SUM_sig) & ","
                & std_logic'image(OVF_sig) & ") != ("
                & to_string(SUM_val) & ","
                & std_logic'image(OVF_val) & ")"
            severity error;
    end procedure;
begin
    signed_adder_inst : signed_adder
        generic map(n_bits => 3)
        port map(A => A, B => B, SUM => SUM, SIG => SIG, OVF => OVF);

    main : process
    begin
        -- unsigned additions
        test(A, "000", B, "000", SUM, "000", SIG, '0', OVF, '0');
        test(A, "001", B, "000", SUM, "001", SIG, '0', OVF, '0');
        test(A, "000", B, "001", SUM, "001", SIG, '0', OVF, '0');
        test(A, "010", B, "001", SUM, "011", SIG, '0', OVF, '0');

        -- unsigned addition overflow
        test(A, "011", B, "001", SUM, "100", SIG, '0', OVF, '1');
        test(A, "011", B, "011", SUM, "110", SIG, '0', OVF, '1');

        -- additions with sign-flip
        test(A, "000", B, "000", SUM, "000", SIG, '1', OVF, '0');
        test(A, "001", B, "111", SUM, "010", SIG, '1', OVF, '0');
        test(A, "000", B, "101", SUM, "011", SIG, '1', OVF, '0');
        test(A, "010", B, "111", SUM, "011", SIG, '1', OVF, '0');

        -- substractions
        test(A, "000", B, "100", SUM, "100", SIG, '0', OVF, '0');
        test(A, "001", B, "100", SUM, "101", SIG, '0', OVF, '0');
        test(A, "111", B, "011", SUM, "010", SIG, '0', OVF, '0');
        test(A, "100", B, "001", SUM, "101", SIG, '0', OVF, '0');
        test(A, "011", B, "111", SUM, "010", SIG, '0', OVF, '0');

        -- negative overflow
        test(A, "111", B, "100", SUM, "011", SIG, '0', OVF, '1');
        test(A, "100", B, "111", SUM, "011", SIG, '0', OVF, '1');

        -- substractions with sign flip
        test(A, "011", B, "001", SUM, "010", SIG, '1', OVF, '0');
        test(A, "011", B, "011", SUM, "000", SIG, '1', OVF, '0');
        test(A, "000", B, "011", SUM, "101", SIG, '1', OVF, '0');
        test(A, "001", B, "011", SUM, "110", SIG, '1', OVF, '0');

        report "Test: ok" severity failure;
    end process;
end architecture;

architecture dataflow_tb of testbench is
    constant period: time := 20 ns;
    constant n_bits: natural := 4;

    component dataflow
        generic(n_bits: natural);
        port(
            D_in : in  std_logic_vector(2 * n_bits - 1 downto 0);
            R_in : in  std_logic_vector(3 + n_bits - 1 downto 0);
            Z_in : in  std_logic_vector(    n_bits - 1 downto 0);
    
            D_out: out std_logic_vector(2 * n_bits - 1 downto 0);
            R_out: out std_logic_vector(3 + n_bits - 1 downto 0);
            Z_out: out std_logic_vector(    n_bits - 1 downto 0)
        );
    end component;

    signal D_in, D_out: std_logic_vector(2 * n_bits - 1 downto 0);
    signal R_in, R_out: std_logic_vector(3 + n_bits - 1 downto 0);
    signal Z_in, Z_out: std_logic_vector(    n_bits - 1 downto 0);

    procedure test(
        signal   D_in     : inout std_logic_vector(2 * n_bits - 1 downto 0);
        constant D_in_val : in    std_logic_vector(2 * n_bits - 1 downto 0);
        signal   D_out    : in    std_logic_vector(2 * n_bits - 1 downto 0);
        constant D_out_val: in    std_logic_vector(2 * n_bits - 1 downto 0);

        signal   R_in     : inout std_logic_vector(3 + n_bits - 1 downto 0);
        constant R_in_val : in    std_logic_vector(3 + n_bits - 1 downto 0);
        signal   R_out    : in    std_logic_vector(3 + n_bits - 1 downto 0);
        constant R_out_val: in    std_logic_vector(3 + n_bits - 1 downto 0);

        signal   Z_in     : inout std_logic_vector(    n_bits - 1 downto 0);
        constant Z_in_val : in    std_logic_vector(    n_bits - 1 downto 0);
        signal   Z_out    : in    std_logic_vector(    n_bits - 1 downto 0);
        constant Z_out_val: in    std_logic_vector(    n_bits - 1 downto 0)
    ) is
    begin
        D_in <= D_in_val;    
        R_in <= R_in_val;
        Z_in <= Z_in_val;
        wait for period;
        assert D_out = D_out_val and R_out = R_out_val and Z_out = Z_out_val
            report "wrong result: ("
                & to_string(D_in_val)  & ","
                & to_string(R_in_val)  & ","
                & to_string(Z_in_val)  & ") => ("
                & to_string(D_out) & ","
                & to_string(R_out) & ","
                & to_string(Z_out) & ") != ("
                & to_string(D_out_val) & ","
                & to_string(R_out_val) & ","
                & to_string(Z_out_val) & ")"
            severity error;
    end procedure;
begin
    dataflow_inst : dataflow
        generic map (n_bits => n_bits)
        port map(
            D_in => D_in, D_out => D_out,
            R_in => R_in, R_out => R_out,
            Z_in => Z_in, Z_out => Z_out
        );

    main : process
    begin
        -- sqrt(4)
        test(D_in, "00000100", D_out, "00010000", R_in, "0000000", R_out, "1111111", Z_in, "0000", Z_out, "0000");
        test(D_in, "00010000", D_out, "01000000", R_in, "1111111", R_out, "1111111", Z_in, "0000", Z_out, "0000");
        test(D_in, "01000000", D_out, "00000000", R_in, "1111111", R_out, "0000000", Z_in, "0000", Z_out, "0001");
        test(D_in, "00000000", D_out, "00000000", R_in, "0000000", R_out, "1111011", Z_in, "0001", Z_out, "0010");

        -- sqrt(3)
        test(D_in, "00000011", D_out, "00001100", R_in, "0000000", R_out, "1111111", Z_in, "0000", Z_out, "0000");
        test(D_in, "00001100", D_out, "00110000", R_in, "1111111", R_out, "1111111", Z_in, "0000", Z_out, "0000");
        test(D_in, "00110000", D_out, "11000000", R_in, "1111111", R_out, "1111111", Z_in, "0000", Z_out, "0000");
        test(D_in, "11000000", D_out, "00000000", R_in, "1111111", R_out, "0000010", Z_in, "0000", Z_out, "0001");

        report "Test: ok" severity failure;
    end process;
end architecture;

architecture sequential_sqrt_tb of testbench is
    constant period: time := 20 ns;
    constant n_bits: natural := 16;

    component sequential_sqrt
        generic(n_bits: natural);
        port(
            clk, rst, start: in  std_logic;
            done           : out std_logic;
            data_in        : in  std_logic_vector(2 * n_bits - 1 downto 0);
            data_out       : out std_logic_vector(    n_bits - 1 downto 0)
        );
    end component;

    signal clk, rst, start, done: std_logic;
    signal data_in : std_logic_vector(2 * n_bits - 1 downto 0);
    signal data_out: std_logic_vector(    n_bits - 1 downto 0);

    procedure test(
        signal   start   : out std_logic;
        signal   data_in : out std_logic_vector(2 * n_bits - 1 downto 0);
        constant n       : in  natural;
        signal   data_out: in  std_logic_vector(    n_bits - 1 downto 0);
        constant e       : in  natural
    ) is
        variable r: natural;
    begin
        start <= '0';
        data_in <= std_logic_vector(to_unsigned(n, 2 * n_bits));
        wait for period;
        start <= '1';
        wait until done = '1';
        r := to_integer(unsigned(data_out));
        assert (e = r)
            report "wrong result: sqrt("
                & natural'image(n) & ") => "
                & natural'image(r) & " != "
                & natural'image(e)
            severity error;
        start <= '0';
        wait for period;
    end procedure;

    procedure test(
        signal   start   : out std_logic;
        signal   data_in : out std_logic_vector(2 * n_bits - 1 downto 0);
        constant n       : in  unsigned        (2 * n_bits - 1 downto 0);
        signal   data_out: in  std_logic_vector(    n_bits - 1 downto 0);
        constant e       : in  natural
    ) is
        variable r: natural;
    begin
        start <= '0';
        data_in <= std_logic_vector(n);
        wait for period;
        start <= '1';
        wait until done = '1';
        r := to_integer(unsigned(data_out));
        assert (e = r)
            report "wrong result: sqrt("
                & to_string(std_logic_vector(n)) & ") => "
                & natural'image(r) & " != "
                & natural'image(e)
            severity error;
        start <= '0';
        wait for period;
    end procedure;
begin
    sequential_sqrt_inst : sequential_sqrt
        generic map(n_bits => n_bits)
        port map(
            clk => clk, rst => rst, start => start, done => done,
            data_in => data_in, data_out => data_out
        );

    clk_gen : process
    begin
        clk <= '1';
        wait for period / 2;
        clk <= '0';
        wait for period / 2;
    end process;

    main : process
    begin
        rst <= '1';
        start <= '0';
        wait for period;
        rst <= '0';

        test(start, data_in, 0,  data_out, 0);
        test(start, data_in, 1,  data_out, 1);
        test(start, data_in, 3,  data_out, 1);
        test(start, data_in, 4,  data_out, 2);
        test(start, data_in, 16, data_out, 4);
        test(start, data_in, 512, data_out, integer(floor(sqrt(real(512)))));
        test(start, data_in, 1194877489, data_out, integer(floor(sqrt(real(1194877489)))));
        test(start, data_in, (2 * n_bits - 1 downto 0 => '1'), data_out, 65535);

        report "Test: ok" severity failure;
    end process;
end architecture;
