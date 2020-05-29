library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sterowanie is
port(
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
		
		Smar, Smbr, WRout, RDout, INTA : out bit
);
end entity;


architecture RTL of sterowanie is
type state_type is (m0, m1,																			--fetch i dekodowanie
					m10, m11, m12,  	--....-przerwania?			
					m20, m21, m22, m23, m24, m25, m26, m27, m28, m29, m30, m31, m32, 				--pierwsza gr rozkaz�w
					m40, m41, m42, m43, m44, m45, m46, m47, m48, m49, m50, m51, m52, m53, m54, m55,	--druga gr rozkaz�w
					m60, m61, m62, m63, m64, m65, m66, m67, m68, m69, m70, m71,						--trzecia gr rozkaz�w
					--czwarta gr rozkaz�w rozszerzonych:
					m80, m81, m82, m83, m84, m85, m86, m87, m88, m89, 
					m90, m91, m92, m93, m94, m95, m96, m97, m98, m99, 
					m100, m101, m102, m103, m104, m105, m106, m107, m108, m109, m110, m111, m112
					);

signal state : state_type;

begin

process (clk, reset)
begin

if reset = '1' then 
state <= m0;		--pobranie rozkazu

elsif (clk'event and clk='1') then

if INT = '1' then state <= m10;
end if;

case state is

when m0=> state <= m1; 					--dekodowanie rozkazu
when m1=>

case IR(31 downto 30) is				--wyb�r najstarszych 3 bit�w z kodu operacji
when "00" =>

case IR(29 downto 26) is				
when "0000" => state <= m20;
when "0001" => state <= m21;
when "0010" => state <= m22;
when "0011" => state <= m23;				--pierwsza gr rozkaz�w (13)
when "0100" => state <= m24;
when "0101" => state <= m25;
when "0110" => state <= m26;
when "0111" => state <= m27;
when "1000" => state <= m28;
when "1001" => state <= m29;
when "1010" => state <= m30;
when "1011" => state <= m31;
when "1100" => state <= m32;
when others => state <= m0;
end case;

when "01" =>
case IR(29 downto 26) is				
when "0000" => state <= m40;
when "0001" => state <= m41;
when "0010" => state <= m42;
when "0011" => state <= m43;				--druga gr rozkaz�w (16)
when "0100" => state <= m44;
when "0101" => state <= m45;
when "0110" => state <= m46;
when "0111" => state <= m47;
when "1000" => state <= m48;
when "1001" => state <= m49;
when "1010" => state <= m50;
when "1011" => state <= m51;
when "1100" => state <= m52;
when "1101" => state <= m53;
when "1110" => state <= m54;
when "1111" => state <= m55;
when others => state <= m0;
end case;


when "10" => 
case IR(29 downto 26) is				
when "0000" => state <= m60;
when "0001" => state <= m61;
when "0010" => state <= m62;
when "0011" => state <= m64;				--trzecia gr rozkaz�w (10)
when "0100" => state <= m66;
when "0101" => state <= m68;
when "0110" => state <= m69;
when "0111" => state <= m70;
when "1000" => state <= m71;

--grupa rozkaz�w z listy rozszerzonej
when "1001" => 
case IR(5 downto 0) is	
when "000000" => state <= m80;
when "000001" => state <= m81;
when "000010" => state <= m82;
when "000011" => state <= m83;
when "000100" => state <= m84;
when "000101" => state <= m85;
when "000110" => state <= m86;
when "000111" => state <= m87;
when "001000" => state <= m88;
when "001001" => state <= m89;
when "001010" => state <= m90;
when "001011" => state <= m91;
when "001100" => state <= m92;
when "001101" => state <= m93;
when "001110" => state <= m94;
when "001111" => state <= m95;
when "010000" => state <= m96;
when "010001" => state <= m97;
when "010010" => state <= m98;
when "010011" => state <= m99;
when "010100" => state <= m100;
when "010101" => state <= m101;
when "010110" => state <= m102;
when "010111" => state <= m103;
when "011000" => state <= m104;
when "011001" => state <= m105;
when "011010" => state <= m106;
when "011011" => state <= m107;
when "011100" => state <= m108;
when "011101" => state <= m109;
when "011110" => state <= m110;
when "011111" => state <= m111;
when "100000" => state <= m112;
when others => state <= m0;
end case;

when others => state <= m0;
end case;
when others => state <= m0;
end case;

when m62=> state <= m63; 	
when m64=> state <= m65; 
when m66=> state <= m67; 

when m10=> state <= m11; 

when others => state <= null; --case do state
end case;
end if;
end process;


process (state, IR, Z)
begin
case state is
--fetch i dekodowanie
when m0 => --pobranie rozkazu(fetch)
Sadr <= "11111"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="01"; SIRb<="00"; SIRc <="011"; SIRadr <="00"; Smar <='1'; Smbr <= '0'; WRout <='0'; RDout <='1'; INTA <='0';

when m1 => --dekodowanie rozkazu
Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';


when m10 => --obs�uga przerwania
Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="10"; SIRb<="00"; SIRc <="100"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='1';
when m11 => 
Sadr <= "11111"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="01"; SIRb<="00"; SIRc <="011"; SIRadr <="00"; Smar <='1'; Smbr <= '0'; WRout <='0'; RDout <='1'; INTA <='1';



--pierwsza gr rozkaz�w
when m20 => --LB 
Sadr <= IR(25 downto 21); Sbb <= "00000"; Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="00000"; Sid <="01"; zapis<= "001"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="011"; SIRadr <="00"; Smar <='1'; Smbr <= '0'; WRout <='0'; RDout <='1'; INTA <='0';
when m21 => --LBU
Sadr <= IR(25 downto 21); Sbb <= "00000"; Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="00000"; Sid <="01"; zapis<= "010"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="011"; SIRadr <="00"; Smar <='1'; Smbr <= '0'; WRout <='0'; RDout <='1'; INTA <='0';
when m22 => --LH
Sadr <= IR(25 downto 21); Sbb <= "00000"; Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="00000"; Sid <="01"; zapis<= "011"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="011"; SIRadr <="00"; Smar <='1'; Smbr <= '0'; WRout <='0'; RDout <='1'; INTA <='0';
when m23 => --LHU
Sadr <= IR(25 downto 21); Sbb <= "00000"; Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="00000"; Sid <="01"; zapis<= "100"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="011"; SIRadr <="00"; Smar <='1'; Smbr <= '0'; WRout <='0'; RDout <='1'; INTA <='0';
when m24 => --LW
Sadr <= IR(25 downto 21); Sbb <= "00000"; Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="00000"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="011"; SIRadr <="00"; Smar <='1'; Smbr <= '0'; WRout <='0'; RDout <='1'; INTA <='0';
--when m25 => --LF
--Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
--SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
--when m26 => --LD
--Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
--SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m27 => --LHI
Sadr <= "00000"; Sbb <= "00000"; Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="00000"; Sid <="01"; zapis<= "101"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="001"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';

when m28 => --SB
Sadr <= IR(20 downto 16); Sbb <= "00000"; Sba <= "00000"; Sbc <=IR(25 downto 21); Salu <="00000"; Sid <="01"; zapis<= "000"; odczyt<="10";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='1'; Smbr <= '1'; WRout <='1'; RDout <='0'; INTA <='0';
when m29 => --SH
Sadr <= IR(20 downto 16); Sbb <= "00000"; Sba <= "00000"; Sbc <=IR(25 downto 21); Salu <="00000"; Sid <="01"; zapis<= "000"; odczyt<="11";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='1'; Smbr <= '1'; WRout <='1'; RDout <='0'; INTA <='0';
when m30 => --SW
Sadr <= IR(20 downto 16); Sbb <= "00000"; Sba <= "00000"; Sbc <=IR(25 downto 21); Salu <="00000"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='1'; Smbr <= '1'; WRout <='1'; RDout <='0'; INTA <='0';
--when m31 => --SF
--Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
--SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
--when m32 => --SD
--Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
--SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';


--druga gr rozkaz�w
when m40 => --ADDI
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="00001"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="001"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m41 => --SUBI
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="00011"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="001"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m42 => --SII
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="01001"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="001"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m43 => --SAUI
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="01010"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="001"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m44 => --XSAUI
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="01011"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="001"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m45 => --SLLI
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="01100"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="001"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m46 => --SRLI
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="01101"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="001"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m47 => --SRAI
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="01110"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="001"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m48 => --ADDUI
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="00010"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="001"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m49 => --SUBUI
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="00100"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="001"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m50 => --SLTI
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="01111"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="001"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m51 => --SGTI
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="10000"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="001"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m52 => --SLEI
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="10001"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="001"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m53 => --SGEI
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="10010"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="001"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m54 => --SEQI
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="10011"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="001"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m55 => --SNEI
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(20 downto 16); Sbc <="00000"; Salu <="10100"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="001"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';


----trzecia gr rozkaz�w
when m60 => --JMP
Sadr <= "11111"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
SIRa<="11"; SIRb<="00"; SIRc <="101"; SIRadr <="00"; Smar <='1'; Smbr <= '0'; WRout <='0'; RDout <='1'; INTA <='0';
when m61 => --JR
Sadr <= "11111"; Sbb <= "00000"; Sba <= "00000"; Sbc <=IR(25 downto 21); Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="01";
SIRa<="11"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='1'; Smbr <= '0'; WRout <='0'; RDout <='1'; INTA <='0';

when m62 => --JAL (2 takty)
Sadr <= "00000"; Sbb <= "00000"; Sba <= "11111"; Sbc <="00000"; Salu <="00000"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="100"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m63 => 
Sadr <= "11111"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
SIRa<="11"; SIRb<="00"; SIRc <="101"; SIRadr <="00"; Smar <='0'; Smbr <= '1'; WRout <='0'; RDout <='1'; INTA <='0';

when m64 => --JALR (2 takty)
Sadr <= "00000"; Sbb <= "00000"; Sba <= "11111"; Sbc <="00000"; Salu <="00000"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="100"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m65 => 
Sadr <= "11111"; Sbb <= "00000"; Sba <= "00000"; Sbc <=IR(25 downto 21); Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="01";
SIRa<="11"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='1'; Smbr <= '0'; WRout <='0'; RDout <='1'; INTA <='0';

when m66 => --TRAP (2 takty)
Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="10"; SIRb<="00"; SIRc <="100"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m67 => 
Sadr <= "11111"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
SIRa<="11"; SIRb<="00"; SIRc <="101"; SIRadr <="00"; Smar <='1'; Smbr <= '0'; WRout <='0'; RDout <='1'; INTA <='0';

when m68 => --RET
Sadr <= "11111"; Sbb <= "00000"; Sba <= "00000"; Sbc <="11111"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="01";
SIRa<="11"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='1'; Smbr <= '0'; WRout <='0'; RDout <='1'; INTA <='0';

when m69 => --BEQ
if (Z='0') then --skocz
Sadr <= "11111"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
SIRa<="11"; SIRb<="00"; SIRc <="110"; SIRadr <="00"; Smar <='1'; Smbr <= '0'; WRout <='0'; RDout <='1'; INTA <='0';
elsif (Z='1') then
Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
end if;

when m70 => --BNE
if (Z='1') then --skocz
Sadr <= "11111"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
SIRa<="11"; SIRb<="00"; SIRc <="110"; SIRadr <="00"; Smar <='1'; Smbr <= '0'; WRout <='0'; RDout <='1'; INTA <='0';
elsif (Z='0') then
Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
end if;

when m71 => --NOP
Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
--when m72 => --R3
--Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
--SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';



--czwarta gr rozkaz�w rozszerzonych:
when m80 => --ADD
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="00001"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m81 => --ADDU
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="00010"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m82 => --SUB
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="00011"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m83 => --SUBU
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="00100"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m84 => --MULT
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="00101"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m85 => --MULTU
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="00110"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m86 => --DIV
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="00111"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m87 => --DIVU
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="01000"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m88 => --SI
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="01001"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m89 => --SAU
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="01010"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m90 => --XSAU
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="01011"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m91 => --SLL
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="01100"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m92 => --SRL
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="01101"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m93 => --SRA
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="01110"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';

--when m94 => --ADDF
--Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
--SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
--when m95 => --ADDD
--Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
--SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
--when m96 => --SUBF
--Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
--SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
--when m97 => --SUBD
--Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
--SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
--when m98 => --MULTF
--Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
--SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
--when m99 => --MULTD
--Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
--SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
--when m100 => --DIVF
--Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
--SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
--when m101 => --DIVD
--Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
--SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';

when m102 => --SLT
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="01111"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m103 => --SGT
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="10000"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m104 => --SLE
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="10001"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m105 => --SGE
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="10010"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m106 => --SEQ
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="10011"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m107 => --SNE
Sadr <= "00000"; Sbb <= IR(25 downto 21); Sba <= IR(15 downto 11); Sbc <= IR(20 downto 16); Salu <="10100"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m108 => --MOVS2I
Sadr <= "00000"; Sbb <= "00000"; Sba <= IR(25 downto 21); Sbc <="00000";  Salu <="00000"; Sid <="01"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="010"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m109 => --MOVI2S
Sadr <= "00000"; Sbb <= "00000"; Sba <="00000";  Sbc <=IR(25 downto 21);  Salu <="00000"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="10"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
when m110 => --MOV
Sadr <= "00000"; Sbb <= "00000"; Sba <= IR(15 downto 11); Sbc <=IR(25 downto 21); Salu <="00000"; Sid <="01"; zapis<= "000"; odczyt<="01";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';

--when m111 => --MOVF
--Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
--SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';
--when m112 => --MOVD
--Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
--SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';


when others =>
Sadr <= "00000"; Sbb <= "00000"; Sba <= "00000"; Sbc <="00000"; Salu <="00000"; Sid <="00"; zapis<= "000"; odczyt<="00";
SIRa<="00"; SIRb<="00"; SIRc <="000"; SIRadr <="00"; Smar <='0'; Smbr <= '0'; WRout <='0'; RDout <='0'; INTA <='0';

end case;
end process;
end RTL;

