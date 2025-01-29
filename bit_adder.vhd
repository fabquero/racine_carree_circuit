library ieee;
use ieee.std_logic_1164.all;

entity bit_adder is
    port(
        a, b, c: in std_logic;
        d, carry: out std_logic
    );
end entity;

architecture structural of bit_adder is
begin
    d <= a xor b xor c;
    carry <= (a and b) or (a and c) or (b and c);
end architecture;
