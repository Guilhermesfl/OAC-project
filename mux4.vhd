library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux4 is
	port (
		Sel : in std_logic_Vector(1 downto 0);
		A : in std_logic_Vector(31 downto 0);
		B : in std_logic_Vector(31 downto 0);
		C : in std_logic_Vector(31 downto 0);
		D : in std_logic_Vector(31 downto 0);
		Z : out std_logic_Vector(31 downto 0));
end entity;

architecture mux4_arch of mux4 is

begin

	mux4 : process(Sel, A, B)
		begin
		case Sel is
		when "00" =>
			Z <= A;
		when "01" =>
			Z <= B;
		when "10" =>
			Z <= C;
		when "11" =>
			Z <= D;
		when others =>
			Z <= (others => '0');
		end case;
	end process;

end mux4_arch;
