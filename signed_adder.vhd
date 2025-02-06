library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity signed_adder is
    generic(n_bits: natural);
    port(
        A, B: in  std_logic_vector(n_bits - 1 downto 0); -- inputs, signed
        SUM : out std_logic_vector(n_bits - 1 downto 0); -- output sum
        SIG : in  std_logic; -- sign-flip B if 1
        OVF : out std_logic  -- overflow flag
    );
end entity;

architecture structural of signed_adder is
    -- carry(i) is the carry of the sum from index i-1 to i
    signal carry: std_logic_vector(n_bits downto 0);
    -- internal sum signal for ovf computation, shitty language
    signal sum_i: std_logic_vector(n_bits - 1 downto 0);
    -- bit flipped (or not) B value, shitty language
    signal B_in: std_logic_vector(n_bits - 1 downto 0);
    -- bit flip into a vector, shitty language
    signal SIG_vec: std_logic_vector(n_bits - 1 downto 0);

    component bit_adder
        port(
            a, b, c : in std_logic;
            d, carry: out std_logic
        );
    end component;
begin
    SIG_vec <= (others => SIG);
    B_in <= (B and (not SIG_vec)) or ((not B) and SIG_vec);
    
    carry(0) <= SIG;
    
    bit_adders : for i in 0 to n_bits - 1 generate
        b_add : bit_adder
        port map(
            a => A(i),
            b => B_in(i),
            c => carry(i),
            d => sum_i(i),
            carry => carry(i+1)
        );
    end generate;

    SUM <= sum_i;
    OVF <= not (A(n_bits - 1) xor B_in (n_bits - 1))
           and (A(n_bits - 1) xor sum_i(n_bits - 1));
end architecture;
