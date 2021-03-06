library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux2 is
	port (
		Sel : in std_logic;
		A : in std_logic_Vector(31 downto 0);
		B : in std_logic_Vector(31 downto 0);
		Z : out std_logic_Vector(31 downto 0));
end entity;

architecture mux2_arch of mux2 is

begin
	mux2 : process(Sel, A, B)
		begin
		case Sel is
		when '0' =>
			Z <= A;
		when '1' =>
			Z <= B;
		when others =>
			Z <= (others => '0');
		end case;
	end process;

end mux2_arch;
