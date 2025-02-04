library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;

package utils is
	function clog2(n: natural) return natural;
	function to_string(vec: std_logic_vector) return string;
end package;

package body utils is
	function clog2(n: natural) return natural is
	begin
		return natural(floor(log2(real(n)))) + 1;
	end function;

	function to_string(vec: std_logic_vector) return string is
        variable res: string(1 to vec'length);
    begin
        for i in vec'range loop
            if vec(i) = '1' then
                res(vec'length - i) := '1';
            else
                res(vec'length - i) := '0';
            end if;
        end loop;
        return res;
    end function;
end package body;
