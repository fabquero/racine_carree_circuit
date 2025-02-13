library ieee;
use ieee.std_logic_1164.all;

entity dataflow is
    generic(n_bits: natural);
    port(
        D_in : in  std_logic_vector(2 * n_bits - 1 downto 0);
        R_in : in  std_logic_vector(3 + n_bits - 1 downto 0);
        Z_in : in  std_logic_vector(    n_bits - 1 downto 0);

        D_out: out std_logic_vector(2 * n_bits - 1 downto 0);
        R_out: out std_logic_vector(3 + n_bits - 1 downto 0);
        Z_out: out std_logic_vector(    n_bits - 1 downto 0)
    );
end entity;

architecture structural of dataflow is
    constant d_bits: natural := 2 * n_bits;
    constant r_bits: natural := 3 + n_bits;
    constant z_bits: natural :=     n_bits;

    component signed_adder
        generic(n_bits: natural);
        port(
            A, B: in  std_logic_vector(n_bits - 1 downto 0); -- inputs, signed
            SUM : out std_logic_vector(n_bits - 1 downto 0); -- output sum
            SIG : in  std_logic; -- sign_flip B if 1
            OVF : out std_logic  -- overflow flag
        );
    end component;

    signal n_R, adder_constant, adder_Z: std_logic_vector(r_bits - 1 downto 0); 
    signal adder_flip: std_logic;
begin
    -- next D
    D_out <= D_in(d_bits - 3 downto 0) & "00";

    -- next R using signed adder with sign flip
    adder_constant <= R_in(r_bits - 1) &                  -- signed R << 1
                      R_in(r_bits - 4 downto 0) &         -- 
                      D_in(d_bits - 1 downto d_bits - 2); -- D/2^{2n-2}
 
    adder_Z <= ((r_bits - z_bits - 1) downto 0 => '0') &  -- padding
               Z_in(z_bits - 3 downto 0) &                -- 4*Z
               R_in(r_bits - 1) & '1';                    -- +1 or +3

    adder_flip <= not R_in(r_bits- 1);                    -- sub if R>=0

    adder : signed_adder
        generic map(n_bits => 3 + n_bits)
        port map(
            A => adder_constant,
            B => adder_Z,
            SIG => adder_flip,
            SUM => n_R
        );

    R_out <= n_R;

    -- next Z depending on next 
    Z_out <= Z_in(z_bits - 2 downto 0) & not n_R(r_bits - 1);
end architecture;
