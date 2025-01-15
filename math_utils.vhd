library ieee;
use ieee.math_real.all;

package math_utils is
	function clog2(n: natural) return natural;
end package;

package body math_utils is
	function clog2(n: natural) return natural is
	begin
		return natural(ceil(log2(real(n))));
	end function;
end package body;
