library ieee;
use ieee.math_real.all;

package math_utils is
	function clog2(n: integer) return integer;
end package;

package body math_utils is
	function clog2(n: integer) return integer is
	begin
		return integer(ceil(log2(real(n))));
	end function;
end package body;
