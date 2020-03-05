library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity uklad is
port
(
	ADR : in signed(31 downto 0);
	DO : in signed(31 downto 0);
	Smar, Smbr, WRin, RDin : in bit;
	AD : out signed (31 downto 0);
	
	Dzap : out signed (31 downto 0);
	Dodcz : in signed (31 downto 0);
	
	DI : out signed(31 downto 0);
	WR, RD : out bit
);
end entity;

architecture RTL of uklad is
begin
process(Smar, ADR, Smbr, DO, Dodcz, WRin, RDin)
variable MBRin, MBRout: signed(31 downto 0);
variable MAR : signed(31 downto 0);
begin

		if(Smar='1') then MAR := ADR; end if;
		
		if(Smbr='1') then MBRout := DO; end if;
		
		if (RDin='1') then MBRin := Dodcz; end if;
		
		if (WRin='1') then Dzap <= MBRout; end if;
		
DI <= MBRin;
AD <= MAR;


WR <= WRin;
RD <= RDin;
end process;
end RTL;
