library ieee;
use ieee.math_real.all;

package math_utils is
	function clog2(n: natural) return natural;
end package;

package body math_utils is
	function clog2(n: natural) return natural is
	begin
		return natural(floor(log2(real(n)))) + 1;
	end function;
end package body;
