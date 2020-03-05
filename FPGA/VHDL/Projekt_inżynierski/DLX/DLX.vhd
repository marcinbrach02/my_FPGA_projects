library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity DLX is
port (		CLK, RESET, INT : in std_logic;
			INTA : out std_logic;
			WR, RD : out std_logic;
			AD : out signed(31 downto 0);

			Dz : out signed (31 downto 0);
			Do : in signed (31 downto 0)
			
	);
end entity DLX;

architecture RTL of DLX is
--KOMPONENTY
component sterowanie port (
		clk : in std_logic;
		IR : in signed(31 downto 0);
		reset, C, Z, S, P, INT : in std_logic;
		Salu, Sbb, Sbc, Sba : out signed(4 downto 0);
		Sid : out signed(1 downto 0);
		Sadr : out signed(4 downto 0);
		SIRa, SIRb, SIRadr : out signed(1 downto 0);
		SIRc : out signed(2 downto 0);
		zapis : out signed(2 downto 0);
		odczyt : out signed(1 downto 0);
		Smar, Smbr, WRout, RDout, INTA : out std_logic
);
end component sterowanie;

component ALU port(
		A : in signed(31 downto 0);
		B : in signed(31 downto 0);
		Przes : in signed(31 downto 0);
		Salu : in signed(4 downto 0); 
		clk : in std_logic;
		Y : out signed (31 downto 0); 
		C,Z,S,P : out std_logic
);
end component ALU;

component Rejestry port(
		clk : in std_logic;
		DI : in signed (31 downto 0); 
		BA : in signed (31 downto 0);
		BB : out signed (31 downto 0);
		BC : out signed (31 downto 0);
	 
		Sbb : in signed (4 downto 0);
		Sbc : in signed (4 downto 0);
		Sba : in signed (4 downto 0);
	 
		Sid : in signed (1 downto 0);
		Sadr : in signed (4 downto 0);
	 
		SIRa : in signed (1 downto 0);
		SIRb : in signed (1 downto 0);
		SIRc : in signed (2 downto 0);
		SIRadr : in signed (1 downto 0);
	 
		zapis : in signed (2 downto 0);
		odczyt : in signed (1 downto 0);
	 
		ADR : out signed (31 downto 0);
		IRout : out signed (31 downto 0)
);
end component Rejestry;

component uklad port(
		ADR : in signed(31 downto 0);
		DO : in signed(31 downto 0);
		Smar, Smbr, WRin, RDin : in std_logic;
		AD : out signed (31 downto 0);
		Dzap : out signed (31 downto 0);
		Dodcz : in signed (31 downto 0);
		DI : out signed(31 downto 0);
		WR, RD : out std_logic
);
end component uklad;

-- SYGNALY
signal s_IR : signed (31 downto 0);
signal s_C, s_Z, s_S, s_P, s_INT : std_logic;
signal s_Salu, s_Sba, s_Sbb, s_Sbc, s_Sadr : signed (4 downto 0);
signal s_Sid, s_SIRa, s_SIRb, s_SIRadr, s_odczyt : signed (1 downto 0);
signal s_SIRc, s_zapis : signed (2 downto 0);

signal s_Smar, s_Smbr, s_WR, s_RD, s_INTA : std_logic;

signal s_BB, s_BC, s_Y : signed (31 downto 0);

signal s_DI : signed (31 downto 0); 
signal s_BA : signed (31 downto 0);
signal s_ADR : signed (31 downto 0);

signal s_DO : signed (31 downto 0);
signal s_WRout, s_RDout : std_logic;   --- sygnaly z ukladu do pamieci, maja koncowke -out
begin
c1: sterowanie port map(	clk => CLK, IR => s_IR, reset => RESET, C => s_C, Z => s_Z, S => s_S, P => s_P, INT => INT,
							Salu => s_Salu, Sba => s_Sba, Sbb => s_Sbb, Sbc => s_Sbc, Sid => s_Sid, Sadr => s_Sadr,
							SIRa => s_SIRa, SIRb => s_SIRb, SIRadr => s_SIRadr, SIRc => s_SIRc, zapis => s_zapis,
							odczyt => s_odczyt, Smar => s_Smar, Smbr => s_Smbr, WRout => s_WR, RDout => s_RD, INTA => INTA);
								
c2: ALU port map(			A => s_BB, B => s_BC, Przes => s_BC, Salu => s_Salu, clk => CLK, Y => s_Y, C => s_C, Z => s_Z, 
							S => s_S, P => s_P);
						
c3: Rejestry port map(		clk => CLK, DI => s_DI, BA => s_BA, BB => s_BB, BC => s_BC, Sbb => s_Sbb, Sbc => s_Sbc, Sba => s_Sba,
							Sid => s_Sid, Sadr => s_Sadr, SIRa => s_SIRa, SIRb => s_SIRb, SIRc => s_SIRc, SIRadr => s_SIRadr,
							zapis => s_zapis, odczyt => s_odczyt, ADR => s_ADR, IRout => s_IR);
								
c4: uklad port map(			Dzap =>Dz, Dodcz=>Do, ADR => s_ADR, DO => s_DO, Smar => s_Smar, Smbr => s_Smbr, WRin => s_WR, RDin => s_RD, AD => AD,
							DI => s_DI, WR => s_WRout, RD => s_RDout);

--------------------------							
s_BA <= s_Y;
s_DO <= s_Y;

WR <= s_WRout;
RD <= s_RDout;

end architecture RTL;
	