library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity Rejestry is
port(clk : in std_logic;
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
end entity;

architecture RTL of Rejestry is

signal BC1, BC2 : signed (31 downto 0);
signal BB1, BB2 : signed (31 downto 0);
signal ADR1, ADR2 : signed (31 downto 0);

begin

process (clk, Sbb, Sbc, Sba, Sid, Sadr, SIRa, SIRb, SIRc, SIRadr, DI, zapis, odczyt, BB1, BB2, BC1, BC2, ADR1, ADR2)

variable R0 : signed (31 downto 0) := (others => '0');
variable R1,  R2,  R3,  R4,  R5,  R6,  R7,  R8,  R9, 
			R10, R11, R12, R13, R14, R15, R16, R17, R18, R19,
			R20, R21, R22, R23, R24, R25, R26, R27, R28, R29,
			R30, R31 : signed (31 downto 0);
variable IR, IAR, PC, TEMP : signed (31 downto 0);

begin

if (clk'event and clk='1') then
case Sid is
when "01" => PC := PC + 1;
when others => null;
end case;

case Sba is
--when "00000" => R := BA;
when "00001" => 
	case zapis is
		when "000" => R1 := BA; -- word
		when "001" => -- byte with sign
			R1(31 downto 31):= BA(31 downto 31); R1(30 downto 30):= BA(31 downto 31); R1(29 downto 29):= BA(31 downto 31); R1(28 downto 28):= BA(31 downto 31);
			R1(27 downto 27):= BA(31 downto 31); R1(26 downto 26):= BA(31 downto 31); R1(25 downto 25):= BA(31 downto 31); R1(24 downto 24):= BA(31 downto 31);
			R1(23 downto 23):= BA(31 downto 31); R1(22 downto 22):= BA(31 downto 31); R1(21 downto 21):= BA(31 downto 31); R1(20 downto 20):= BA(31 downto 31);
			R1(19 downto 19):= BA(31 downto 31); R1(18 downto 18):= BA(31 downto 31); R1(17 downto 17):= BA(31 downto 31); R1(16 downto 16):= BA(31 downto 31);
			R1(15 downto 15):= BA(31 downto 31); R1(14 downto 14):= BA(31 downto 31); R1(13 downto 13):= BA(31 downto 31); R1(12 downto 12):= BA(31 downto 31);
			R1(11 downto 11):= BA(31 downto 31); R1(10 downto 10):= BA(31 downto 31); R1(9 downto 9):= BA(31 downto 31);   R1(8 downto 8):= BA(31 downto 31);
			R1(7 downto 0):= BA(31 downto 24);
		when "010" =>-- byte without sign:
			R1(31 downto 8):= (others => '0'); 
			R1(7 downto 0):= BA(31 downto 24);
		when "011" =>-- half word with sign:
			R1(31 downto 31):= BA(31 downto 31); R1(30 downto 30):= BA(31 downto 31); R1(29 downto 29):= BA(31 downto 31); R1(28 downto 28):= BA(31 downto 31);
			R1(27 downto 27):= BA(31 downto 31); R1(26 downto 26):= BA(31 downto 31); R1(25 downto 25):= BA(31 downto 31); R1(24 downto 24):= BA(31 downto 31);
			R1(23 downto 23):= BA(31 downto 31); R1(22 downto 22):= BA(31 downto 31); R1(21 downto 21):= BA(31 downto 31); R1(20 downto 20):= BA(31 downto 31);
			R1(19 downto 19):= BA(31 downto 31); R1(18 downto 18):= BA(31 downto 31); R1(17 downto 17):= BA(31 downto 31); R1(16 downto 16):= BA(31 downto 31);
			R1(15 downto 0):= BA(31 downto 16);
		when "100" =>-- half word without sign:
			R1(31 downto 16):= (others => '0'); 
			R1(15 downto 0):= BA(31 downto 16);
		when "101" => --LHI
			R1(31 downto 16):=(others => '0');
			R1(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "00010" =>
	case zapis is
		when "000" => R2 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R2(31 downto 31):= BA(31 downto 31); R2(30 downto 30):= BA(31 downto 31); R2(29 downto 29):= BA(31 downto 31); R2(28 downto 28):= BA(31 downto 31);
			R2(27 downto 27):= BA(31 downto 31); R2(26 downto 26):= BA(31 downto 31); R2(25 downto 25):= BA(31 downto 31); R2(24 downto 24):= BA(31 downto 31);
			R2(23 downto 23):= BA(31 downto 31); R2(22 downto 22):= BA(31 downto 31); R2(21 downto 21):= BA(31 downto 31); R2(20 downto 20):= BA(31 downto 31);
			R2(19 downto 19):= BA(31 downto 31); R2(18 downto 18):= BA(31 downto 31); R2(17 downto 17):= BA(31 downto 31); R2(16 downto 16):= BA(31 downto 31);
			R2(15 downto 15):= BA(31 downto 31); R2(14 downto 14):= BA(31 downto 31); R2(13 downto 13):= BA(31 downto 31); R2(12 downto 12):= BA(31 downto 31);
			R2(11 downto 11):= BA(31 downto 31); R2(10 downto 10):= BA(31 downto 31); R2(9 downto 9):= BA(31 downto 31);   R2(8 downto 8):= BA(31 downto 31);
			R2(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R2(31 downto 8):= (others => '0'); 
			R2(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R2(31 downto 31):= BA(31 downto 31); R2(30 downto 30):= BA(31 downto 31); R2(29 downto 29):= BA(31 downto 31); R2(28 downto 28):= BA(31 downto 31);
			R2(27 downto 27):= BA(31 downto 31); R2(26 downto 26):= BA(31 downto 31); R2(25 downto 25):= BA(31 downto 31); R2(24 downto 24):= BA(31 downto 31);
			R2(23 downto 23):= BA(31 downto 31); R2(22 downto 22):= BA(31 downto 31); R2(21 downto 21):= BA(31 downto 31); R2(20 downto 20):= BA(31 downto 31);
			R2(19 downto 19):= BA(31 downto 31); R2(18 downto 18):= BA(31 downto 31); R2(17 downto 17):= BA(31 downto 31); R2(16 downto 16):= BA(31 downto 31);
			R2(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R2(31 downto 16):= (others => '0'); 
			R2(15 downto 0):= BA(31 downto 16);
		when "101" =>-- LHI
			R2(31 downto 16):=(others => '0');
			R2(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "00011" => 
	case zapis is
		when "000" => R3 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R3(31 downto 31):= BA(31 downto 31); R3(30 downto 30):= BA(31 downto 31); R3(29 downto 29):= BA(31 downto 31); R3(28 downto 28):= BA(31 downto 31);
			R3(27 downto 27):= BA(31 downto 31); R3(26 downto 26):= BA(31 downto 31); R3(25 downto 25):= BA(31 downto 31); R3(24 downto 24):= BA(31 downto 31);
			R3(23 downto 23):= BA(31 downto 31); R3(22 downto 22):= BA(31 downto 31); R3(21 downto 21):= BA(31 downto 31); R3(20 downto 20):= BA(31 downto 31);
			R3(19 downto 19):= BA(31 downto 31); R3(18 downto 18):= BA(31 downto 31); R3(17 downto 17):= BA(31 downto 31); R3(16 downto 16):= BA(31 downto 31);
			R3(15 downto 15):= BA(31 downto 31); R3(14 downto 14):= BA(31 downto 31); R3(13 downto 13):= BA(31 downto 31); R3(12 downto 12):= BA(31 downto 31);
			R3(11 downto 11):= BA(31 downto 31); R3(10 downto 10):= BA(31 downto 31); R3(9 downto 9):= BA(31 downto 31);   R3(8 downto 8):= BA(31 downto 31);
			R3(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R3(31 downto 8):= (others => '0'); 
			R3(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R3(31 downto 31):= BA(31 downto 31); R3(30 downto 30):= BA(31 downto 31); R3(29 downto 29):= BA(31 downto 31); R3(28 downto 28):= BA(31 downto 31);
			R3(27 downto 27):= BA(31 downto 31); R3(26 downto 26):= BA(31 downto 31); R3(25 downto 25):= BA(31 downto 31); R3(24 downto 24):= BA(31 downto 31);
			R3(23 downto 23):= BA(31 downto 31); R3(22 downto 22):= BA(31 downto 31); R3(21 downto 21):= BA(31 downto 31); R3(20 downto 20):= BA(31 downto 31);
			R3(19 downto 19):= BA(31 downto 31); R3(18 downto 18):= BA(31 downto 31); R3(17 downto 17):= BA(31 downto 31); R3(16 downto 16):= BA(31 downto 31);
			R3(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R3(31 downto 16):= (others => '0'); 
			R3(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R3(31 downto 16):=(others => '0');
			R3(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "00100" => 
	case zapis is
		when "000" => R4 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R4(31 downto 31):= BA(31 downto 31); R4(30 downto 30):= BA(31 downto 31); R4(29 downto 29):= BA(31 downto 31); R4(28 downto 28):= BA(31 downto 31);
			R4(27 downto 27):= BA(31 downto 31); R4(26 downto 26):= BA(31 downto 31); R4(25 downto 25):= BA(31 downto 31); R4(24 downto 24):= BA(31 downto 31);
			R4(23 downto 23):= BA(31 downto 31); R4(22 downto 22):= BA(31 downto 31); R4(21 downto 21):= BA(31 downto 31); R4(20 downto 20):= BA(31 downto 31);
			R4(19 downto 19):= BA(31 downto 31); R4(18 downto 18):= BA(31 downto 31); R4(17 downto 17):= BA(31 downto 31); R4(16 downto 16):= BA(31 downto 31);
			R4(15 downto 15):= BA(31 downto 31); R4(14 downto 14):= BA(31 downto 31); R4(13 downto 13):= BA(31 downto 31); R4(12 downto 12):= BA(31 downto 31);
			R4(11 downto 11):= BA(31 downto 31); R4(10 downto 10):= BA(31 downto 31); R4(9 downto 9):= BA(31 downto 31);   R4(8 downto 8):= BA(31 downto 31);
			R4(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R4(31 downto 8):= (others => '0'); 
			R4(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R4(31 downto 31):= BA(31 downto 31); R4(30 downto 30):= BA(31 downto 31); R4(29 downto 29):= BA(31 downto 31); R4(28 downto 28):= BA(31 downto 31);
			R4(27 downto 27):= BA(31 downto 31); R4(26 downto 26):= BA(31 downto 31); R4(25 downto 25):= BA(31 downto 31); R4(24 downto 24):= BA(31 downto 31);
			R4(23 downto 23):= BA(31 downto 31); R4(22 downto 22):= BA(31 downto 31); R4(21 downto 21):= BA(31 downto 31); R4(20 downto 20):= BA(31 downto 31);
			R4(19 downto 19):= BA(31 downto 31); R4(18 downto 18):= BA(31 downto 31); R4(17 downto 17):= BA(31 downto 31); R4(16 downto 16):= BA(31 downto 31);
			R4(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R4(31 downto 16):= (others => '0'); 
			R4(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R4(31 downto 16):=(others => '0');
			R4(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "00101" => 
	case zapis is
		when "000" => R5 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R5(31 downto 31):= BA(31 downto 31); R5(30 downto 30):= BA(31 downto 31); R5(29 downto 29):= BA(31 downto 31); R5(28 downto 28):= BA(31 downto 31);
			R5(27 downto 27):= BA(31 downto 31); R5(26 downto 26):= BA(31 downto 31); R5(25 downto 25):= BA(31 downto 31); R5(24 downto 24):= BA(31 downto 31);
			R5(23 downto 23):= BA(31 downto 31); R5(22 downto 22):= BA(31 downto 31); R5(21 downto 21):= BA(31 downto 31); R5(20 downto 20):= BA(31 downto 31);
			R5(19 downto 19):= BA(31 downto 31); R5(18 downto 18):= BA(31 downto 31); R5(17 downto 17):= BA(31 downto 31); R5(16 downto 16):= BA(31 downto 31);
			R5(15 downto 15):= BA(31 downto 31); R5(14 downto 14):= BA(31 downto 31); R5(13 downto 13):= BA(31 downto 31); R5(12 downto 12):= BA(31 downto 31);
			R5(11 downto 11):= BA(31 downto 31); R5(10 downto 10):= BA(31 downto 31); R5(9 downto 9):= BA(31 downto 31);   R5(8 downto 8):= BA(31 downto 31);
			R5(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R5(31 downto 8):= (others => '0'); 
			R5(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R5(31 downto 31):= BA(31 downto 31); R5(30 downto 30):= BA(31 downto 31); R5(29 downto 29):= BA(31 downto 31); R5(28 downto 28):= BA(31 downto 31);
			R5(27 downto 27):= BA(31 downto 31); R5(26 downto 26):= BA(31 downto 31); R5(25 downto 25):= BA(31 downto 31); R5(24 downto 24):= BA(31 downto 31);
			R5(23 downto 23):= BA(31 downto 31); R5(22 downto 22):= BA(31 downto 31); R5(21 downto 21):= BA(31 downto 31); R5(20 downto 20):= BA(31 downto 31);
			R5(19 downto 19):= BA(31 downto 31); R5(18 downto 18):= BA(31 downto 31); R5(17 downto 17):= BA(31 downto 31); R5(16 downto 16):= BA(31 downto 31);
			R5(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R5(31 downto 16):= (others => '0'); 
			R5(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R5(31 downto 16):=(others => '0');
			R5(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "00110" => 
	case zapis is
		when "000" => R6 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R6(31 downto 31):= BA(31 downto 31); R6(30 downto 30):= BA(31 downto 31); R6(29 downto 29):= BA(31 downto 31); R6(28 downto 28):= BA(31 downto 31);
			R6(27 downto 27):= BA(31 downto 31); R6(26 downto 26):= BA(31 downto 31); R6(25 downto 25):= BA(31 downto 31); R6(24 downto 24):= BA(31 downto 31);
			R6(23 downto 23):= BA(31 downto 31); R6(22 downto 22):= BA(31 downto 31); R6(21 downto 21):= BA(31 downto 31); R6(20 downto 20):= BA(31 downto 31);
			R6(19 downto 19):= BA(31 downto 31); R6(18 downto 18):= BA(31 downto 31); R6(17 downto 17):= BA(31 downto 31); R6(16 downto 16):= BA(31 downto 31);
			R6(15 downto 15):= BA(31 downto 31); R6(14 downto 14):= BA(31 downto 31); R6(13 downto 13):= BA(31 downto 31); R6(12 downto 12):= BA(31 downto 31);
			R6(11 downto 11):= BA(31 downto 31); R6(10 downto 10):= BA(31 downto 31); R6(9 downto 9):= BA(31 downto 31);   R6(8 downto 8):= BA(31 downto 31);
			R6(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R6(31 downto 8):= (others => '0'); 
			R6(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R6(31 downto 31):= BA(31 downto 31); R6(30 downto 30):= BA(31 downto 31); R6(29 downto 29):= BA(31 downto 31); R6(28 downto 28):= BA(31 downto 31);
			R6(27 downto 27):= BA(31 downto 31); R6(26 downto 26):= BA(31 downto 31); R6(25 downto 25):= BA(31 downto 31); R6(24 downto 24):= BA(31 downto 31);
			R6(23 downto 23):= BA(31 downto 31); R6(22 downto 22):= BA(31 downto 31); R6(21 downto 21):= BA(31 downto 31); R6(20 downto 20):= BA(31 downto 31);
			R6(19 downto 19):= BA(31 downto 31); R6(18 downto 18):= BA(31 downto 31); R6(17 downto 17):= BA(31 downto 31); R6(16 downto 16):= BA(31 downto 31);
			R6(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R6(31 downto 16):= (others => '0'); 
			R6(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R6(31 downto 16):=(others => '0');
			R6(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "00111" => 
	case zapis is
		when "000" => R7 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R7(31 downto 31):= BA(31 downto 31); R7(30 downto 30):= BA(31 downto 31); R7(29 downto 29):= BA(31 downto 31); R7(28 downto 28):= BA(31 downto 31);
			R7(27 downto 27):= BA(31 downto 31); R7(26 downto 26):= BA(31 downto 31); R7(25 downto 25):= BA(31 downto 31); R7(24 downto 24):= BA(31 downto 31);
			R7(23 downto 23):= BA(31 downto 31); R7(22 downto 22):= BA(31 downto 31); R7(21 downto 21):= BA(31 downto 31); R7(20 downto 20):= BA(31 downto 31);
			R7(19 downto 19):= BA(31 downto 31); R7(18 downto 18):= BA(31 downto 31); R7(17 downto 17):= BA(31 downto 31); R7(16 downto 16):= BA(31 downto 31);
			R7(15 downto 15):= BA(31 downto 31); R7(14 downto 14):= BA(31 downto 31); R7(13 downto 13):= BA(31 downto 31); R7(12 downto 12):= BA(31 downto 31);
			R7(11 downto 11):= BA(31 downto 31); R7(10 downto 10):= BA(31 downto 31); R7(9 downto 9):= BA(31 downto 31);   R7(8 downto 8):= BA(31 downto 31);
			R7(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R7(31 downto 8):= (others => '0'); 
			R7(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R7(31 downto 31):= BA(31 downto 31); R7(30 downto 30):= BA(31 downto 31); R7(29 downto 29):= BA(31 downto 31); R7(28 downto 28):= BA(31 downto 31);
			R7(27 downto 27):= BA(31 downto 31); R7(26 downto 26):= BA(31 downto 31); R7(25 downto 25):= BA(31 downto 31); R7(24 downto 24):= BA(31 downto 31);
			R7(23 downto 23):= BA(31 downto 31); R7(22 downto 22):= BA(31 downto 31); R7(21 downto 21):= BA(31 downto 31); R7(20 downto 20):= BA(31 downto 31);
			R7(19 downto 19):= BA(31 downto 31); R7(18 downto 18):= BA(31 downto 31); R7(17 downto 17):= BA(31 downto 31); R7(16 downto 16):= BA(31 downto 31);
			R7(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R7(31 downto 16):= (others => '0'); 
			R7(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R7(31 downto 16):=(others => '0');
			R7(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "01000" => 
	case zapis is
		when "000" => R8 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R8(31 downto 31):= BA(31 downto 31); R8(30 downto 30):= BA(31 downto 31); R8(29 downto 29):= BA(31 downto 31); R8(28 downto 28):= BA(31 downto 31);
			R8(27 downto 27):= BA(31 downto 31); R8(26 downto 26):= BA(31 downto 31); R8(25 downto 25):= BA(31 downto 31); R8(24 downto 24):= BA(31 downto 31);
			R8(23 downto 23):= BA(31 downto 31); R8(22 downto 22):= BA(31 downto 31); R8(21 downto 21):= BA(31 downto 31); R8(20 downto 20):= BA(31 downto 31);
			R8(19 downto 19):= BA(31 downto 31); R8(18 downto 18):= BA(31 downto 31); R8(17 downto 17):= BA(31 downto 31); R8(16 downto 16):= BA(31 downto 31);
			R8(15 downto 15):= BA(31 downto 31); R8(14 downto 14):= BA(31 downto 31); R8(13 downto 13):= BA(31 downto 31); R8(12 downto 12):= BA(31 downto 31);
			R8(11 downto 11):= BA(31 downto 31); R8(10 downto 10):= BA(31 downto 31); R8(9 downto 9):= BA(31 downto 31);   R8(8 downto 8):= BA(31 downto 31);
			R8(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R8(31 downto 8):= (others => '0'); 
			R8(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R8(31 downto 31):= BA(31 downto 31); R8(30 downto 30):= BA(31 downto 31); R8(29 downto 29):= BA(31 downto 31); R8(28 downto 28):= BA(31 downto 31);
			R8(27 downto 27):= BA(31 downto 31); R8(26 downto 26):= BA(31 downto 31); R8(25 downto 25):= BA(31 downto 31); R8(24 downto 24):= BA(31 downto 31);
			R8(23 downto 23):= BA(31 downto 31); R8(22 downto 22):= BA(31 downto 31); R8(21 downto 21):= BA(31 downto 31); R8(20 downto 20):= BA(31 downto 31);
			R8(19 downto 19):= BA(31 downto 31); R8(18 downto 18):= BA(31 downto 31); R8(17 downto 17):= BA(31 downto 31); R8(16 downto 16):= BA(31 downto 31);
			R8(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R8(31 downto 16):= (others => '0'); 
			R8(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R8(31 downto 16):=(others => '0');
			R8(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "01001" => 
	case zapis is
		when "000" => R9 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R9(31 downto 31):= BA(31 downto 31); R9(30 downto 30):= BA(31 downto 31); R9(29 downto 29):= BA(31 downto 31); R9(28 downto 28):= BA(31 downto 31);
			R9(27 downto 27):= BA(31 downto 31); R9(26 downto 26):= BA(31 downto 31); R9(25 downto 25):= BA(31 downto 31); R9(24 downto 24):= BA(31 downto 31);
			R9(23 downto 23):= BA(31 downto 31); R9(22 downto 22):= BA(31 downto 31); R9(21 downto 21):= BA(31 downto 31); R9(20 downto 20):= BA(31 downto 31);
			R9(19 downto 19):= BA(31 downto 31); R9(18 downto 18):= BA(31 downto 31); R9(17 downto 17):= BA(31 downto 31); R9(16 downto 16):= BA(31 downto 31);
			R9(15 downto 15):= BA(31 downto 31); R9(14 downto 14):= BA(31 downto 31); R9(13 downto 13):= BA(31 downto 31); R9(12 downto 12):= BA(31 downto 31);
			R9(11 downto 11):= BA(31 downto 31); R9(10 downto 10):= BA(31 downto 31); R9(9 downto 9):= BA(31 downto 31);   R9(8 downto 8):= BA(31 downto 31);
			R9(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R9(31 downto 8):= (others => '0'); 
			R9(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R9(31 downto 31):= BA(31 downto 31); R9(30 downto 30):= BA(31 downto 31); R9(29 downto 29):= BA(31 downto 31); R9(28 downto 28):= BA(31 downto 31);
			R9(27 downto 27):= BA(31 downto 31); R9(26 downto 26):= BA(31 downto 31); R9(25 downto 25):= BA(31 downto 31); R9(24 downto 24):= BA(31 downto 31);
			R9(23 downto 23):= BA(31 downto 31); R9(22 downto 22):= BA(31 downto 31); R9(21 downto 21):= BA(31 downto 31); R9(20 downto 20):= BA(31 downto 31);
			R9(19 downto 19):= BA(31 downto 31); R9(18 downto 18):= BA(31 downto 31); R9(17 downto 17):= BA(31 downto 31); R9(16 downto 16):= BA(31 downto 31);
			R9(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R9(31 downto 16):= (others => '0'); 
			R9(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R9(31 downto 16):=(others => '0');
			R9(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "01010" =>
	case zapis is
		when "000" => R10 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R10(31 downto 31):= BA(31 downto 31); R10(30 downto 30):= BA(31 downto 31); R10(29 downto 29):= BA(31 downto 31); R10(28 downto 28):= BA(31 downto 31);
			R10(27 downto 27):= BA(31 downto 31); R10(26 downto 26):= BA(31 downto 31); R10(25 downto 25):= BA(31 downto 31); R10(24 downto 24):= BA(31 downto 31);
			R10(23 downto 23):= BA(31 downto 31); R10(22 downto 22):= BA(31 downto 31); R10(21 downto 21):= BA(31 downto 31); R10(20 downto 20):= BA(31 downto 31);
			R10(19 downto 19):= BA(31 downto 31); R10(18 downto 18):= BA(31 downto 31); R10(17 downto 17):= BA(31 downto 31); R10(16 downto 16):= BA(31 downto 31);
			R10(15 downto 15):= BA(31 downto 31); R10(14 downto 14):= BA(31 downto 31); R10(13 downto 13):= BA(31 downto 31); R10(12 downto 12):= BA(31 downto 31);
			R10(11 downto 11):= BA(31 downto 31); R10(10 downto 10):= BA(31 downto 31); R10(9 downto 9):= BA(31 downto 31);   R10(8 downto 8):= BA(31 downto 31);
			R10(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R10(31 downto 8):= (others => '0'); 
			R10(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R10(31 downto 31):= BA(31 downto 31); R10(30 downto 30):= BA(31 downto 31); R10(29 downto 29):= BA(31 downto 31); R10(28 downto 28):= BA(31 downto 31);
			R10(27 downto 27):= BA(31 downto 31); R10(26 downto 26):= BA(31 downto 31); R10(25 downto 25):= BA(31 downto 31); R10(24 downto 24):= BA(31 downto 31);
			R10(23 downto 23):= BA(31 downto 31); R10(22 downto 22):= BA(31 downto 31); R10(21 downto 21):= BA(31 downto 31); R10(20 downto 20):= BA(31 downto 31);
			R10(19 downto 19):= BA(31 downto 31); R10(18 downto 18):= BA(31 downto 31); R10(17 downto 17):= BA(31 downto 31); R10(16 downto 16):= BA(31 downto 31);
			R10(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R10(31 downto 16):= (others => '0'); 
			R10(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R10(31 downto 16):=(others => '0');
			R10(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "01011" => 
	case zapis is
		when "000" => R11 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R11(31 downto 31):= BA(31 downto 31); R11(30 downto 30):= BA(31 downto 31); R11(29 downto 29):= BA(31 downto 31); R11(28 downto 28):= BA(31 downto 31);
			R11(27 downto 27):= BA(31 downto 31); R11(26 downto 26):= BA(31 downto 31); R11(25 downto 25):= BA(31 downto 31); R11(24 downto 24):= BA(31 downto 31);
			R11(23 downto 23):= BA(31 downto 31); R11(22 downto 22):= BA(31 downto 31); R11(21 downto 21):= BA(31 downto 31); R11(20 downto 20):= BA(31 downto 31);
			R11(19 downto 19):= BA(31 downto 31); R11(18 downto 18):= BA(31 downto 31); R11(17 downto 17):= BA(31 downto 31); R11(16 downto 16):= BA(31 downto 31);
			R11(15 downto 15):= BA(31 downto 31); R11(14 downto 14):= BA(31 downto 31); R11(13 downto 13):= BA(31 downto 31); R11(12 downto 12):= BA(31 downto 31);
			R11(11 downto 11):= BA(31 downto 31); R11(10 downto 10):= BA(31 downto 31); R11(9 downto 9):= BA(31 downto 31);   R11(8 downto 8):= BA(31 downto 31);
			R11(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R11(31 downto 8):= (others => '0'); 
			R11(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R11(31 downto 31):= BA(31 downto 31); R11(30 downto 30):= BA(31 downto 31); R11(29 downto 29):= BA(31 downto 31); R11(28 downto 28):= BA(31 downto 31);
			R11(27 downto 27):= BA(31 downto 31); R11(26 downto 26):= BA(31 downto 31); R11(25 downto 25):= BA(31 downto 31); R11(24 downto 24):= BA(31 downto 31);
			R11(23 downto 23):= BA(31 downto 31); R11(22 downto 22):= BA(31 downto 31); R11(21 downto 21):= BA(31 downto 31); R11(20 downto 20):= BA(31 downto 31);
			R11(19 downto 19):= BA(31 downto 31); R11(18 downto 18):= BA(31 downto 31); R11(17 downto 17):= BA(31 downto 31); R11(16 downto 16):= BA(31 downto 31);
			R11(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R11(31 downto 16):= (others => '0'); 
			R11(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R11(31 downto 16):=(others => '0');
			R11(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "01100" => 
	case zapis is
		when "000" => R12 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R12(31 downto 31):= BA(31 downto 31); R12(30 downto 30):= BA(31 downto 31); R12(29 downto 29):= BA(31 downto 31); R12(28 downto 28):= BA(31 downto 31);
			R12(27 downto 27):= BA(31 downto 31); R12(26 downto 26):= BA(31 downto 31); R12(25 downto 25):= BA(31 downto 31); R12(24 downto 24):= BA(31 downto 31);
			R12(23 downto 23):= BA(31 downto 31); R12(22 downto 22):= BA(31 downto 31); R12(21 downto 21):= BA(31 downto 31); R12(20 downto 20):= BA(31 downto 31);
			R12(19 downto 19):= BA(31 downto 31); R12(18 downto 18):= BA(31 downto 31); R12(17 downto 17):= BA(31 downto 31); R12(16 downto 16):= BA(31 downto 31);
			R12(15 downto 15):= BA(31 downto 31); R12(14 downto 14):= BA(31 downto 31); R12(13 downto 13):= BA(31 downto 31); R12(12 downto 12):= BA(31 downto 31);
			R12(11 downto 11):= BA(31 downto 31); R12(10 downto 10):= BA(31 downto 31); R12(9 downto 9):= BA(31 downto 31);   R12(8 downto 8):= BA(31 downto 31);
			R12(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R12(31 downto 8):= (others => '0'); 
			R12(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R12(31 downto 31):= BA(31 downto 31); R12(30 downto 30):= BA(31 downto 31); R12(29 downto 29):= BA(31 downto 31); R12(28 downto 28):= BA(31 downto 31);
			R12(27 downto 27):= BA(31 downto 31); R12(26 downto 26):= BA(31 downto 31); R12(25 downto 25):= BA(31 downto 31); R12(24 downto 24):= BA(31 downto 31);
			R12(23 downto 23):= BA(31 downto 31); R12(22 downto 22):= BA(31 downto 31); R12(21 downto 21):= BA(31 downto 31); R12(20 downto 20):= BA(31 downto 31);
			R12(19 downto 19):= BA(31 downto 31); R12(18 downto 18):= BA(31 downto 31); R12(17 downto 17):= BA(31 downto 31); R12(16 downto 16):= BA(31 downto 31);
			R12(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R12(31 downto 16):= (others => '0'); 
			R12(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R12(31 downto 16):=(others => '0');
			R12(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "01101" => 
	case zapis is
		when "000" => R13 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R13(31 downto 31):= BA(31 downto 31); R13(30 downto 30):= BA(31 downto 31); R13(29 downto 29):= BA(31 downto 31); R13(28 downto 28):= BA(31 downto 31);
			R13(27 downto 27):= BA(31 downto 31); R13(26 downto 26):= BA(31 downto 31); R13(25 downto 25):= BA(31 downto 31); R13(24 downto 24):= BA(31 downto 31);
			R13(23 downto 23):= BA(31 downto 31); R13(22 downto 22):= BA(31 downto 31); R13(21 downto 21):= BA(31 downto 31); R13(20 downto 20):= BA(31 downto 31);
			R13(19 downto 19):= BA(31 downto 31); R13(18 downto 18):= BA(31 downto 31); R13(17 downto 17):= BA(31 downto 31); R13(16 downto 16):= BA(31 downto 31);
			R13(15 downto 15):= BA(31 downto 31); R13(14 downto 14):= BA(31 downto 31); R13(13 downto 13):= BA(31 downto 31); R13(12 downto 12):= BA(31 downto 31);
			R13(11 downto 11):= BA(31 downto 31); R13(10 downto 10):= BA(31 downto 31); R13(9 downto 9):= BA(31 downto 31);   R13(8 downto 8):= BA(31 downto 31);
			R13(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R13(31 downto 8):= (others => '0'); 
			R13(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R13(31 downto 31):= BA(31 downto 31); R13(30 downto 30):= BA(31 downto 31); R13(29 downto 29):= BA(31 downto 31); R13(28 downto 28):= BA(31 downto 31);
			R13(27 downto 27):= BA(31 downto 31); R13(26 downto 26):= BA(31 downto 31); R13(25 downto 25):= BA(31 downto 31); R13(24 downto 24):= BA(31 downto 31);
			R13(23 downto 23):= BA(31 downto 31); R13(22 downto 22):= BA(31 downto 31); R13(21 downto 21):= BA(31 downto 31); R13(20 downto 20):= BA(31 downto 31);
			R13(19 downto 19):= BA(31 downto 31); R13(18 downto 18):= BA(31 downto 31); R13(17 downto 17):= BA(31 downto 31); R13(16 downto 16):= BA(31 downto 31);
			R13(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R13(31 downto 16):= (others => '0'); 
			R13(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R13(31 downto 16):=(others => '0');
			R13(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "01110" => 
	case zapis is
		when "000" => R14 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R14(31 downto 31):= BA(31 downto 31); R14(30 downto 30):= BA(31 downto 31); R14(29 downto 29):= BA(31 downto 31); R14(28 downto 28):= BA(31 downto 31);
			R14(27 downto 27):= BA(31 downto 31); R14(26 downto 26):= BA(31 downto 31); R14(25 downto 25):= BA(31 downto 31); R14(24 downto 24):= BA(31 downto 31);
			R14(23 downto 23):= BA(31 downto 31); R14(22 downto 22):= BA(31 downto 31); R14(21 downto 21):= BA(31 downto 31); R14(20 downto 20):= BA(31 downto 31);
			R14(19 downto 19):= BA(31 downto 31); R14(18 downto 18):= BA(31 downto 31); R14(17 downto 17):= BA(31 downto 31); R14(16 downto 16):= BA(31 downto 31);
			R14(15 downto 15):= BA(31 downto 31); R14(14 downto 14):= BA(31 downto 31); R14(13 downto 13):= BA(31 downto 31); R14(12 downto 12):= BA(31 downto 31);
			R14(11 downto 11):= BA(31 downto 31); R14(10 downto 10):= BA(31 downto 31); R14(9 downto 9):= BA(31 downto 31);   R14(8 downto 8):= BA(31 downto 31);
			R14(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R14(31 downto 8):= (others => '0'); 
			R14(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R14(31 downto 31):= BA(31 downto 31); R14(30 downto 30):= BA(31 downto 31); R14(29 downto 29):= BA(31 downto 31); R14(28 downto 28):= BA(31 downto 31);
			R14(27 downto 27):= BA(31 downto 31); R14(26 downto 26):= BA(31 downto 31); R14(25 downto 25):= BA(31 downto 31); R14(24 downto 24):= BA(31 downto 31);
			R14(23 downto 23):= BA(31 downto 31); R14(22 downto 22):= BA(31 downto 31); R14(21 downto 21):= BA(31 downto 31); R14(20 downto 20):= BA(31 downto 31);
			R14(19 downto 19):= BA(31 downto 31); R14(18 downto 18):= BA(31 downto 31); R14(17 downto 17):= BA(31 downto 31); R14(16 downto 16):= BA(31 downto 31);
			R14(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R14(31 downto 16):= (others => '0'); 
			R14(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R14(31 downto 16):=(others => '0');
			R14(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "01111" => 
	case zapis is
		when "000" => R15 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R15(31 downto 31):= BA(31 downto 31); R15(30 downto 30):= BA(31 downto 31); R15(29 downto 29):= BA(31 downto 31); R15(28 downto 28):= BA(31 downto 31);
			R15(27 downto 27):= BA(31 downto 31); R15(26 downto 26):= BA(31 downto 31); R15(25 downto 25):= BA(31 downto 31); R15(24 downto 24):= BA(31 downto 31);
			R15(23 downto 23):= BA(31 downto 31); R15(22 downto 22):= BA(31 downto 31); R15(21 downto 21):= BA(31 downto 31); R15(20 downto 20):= BA(31 downto 31);
			R15(19 downto 19):= BA(31 downto 31); R15(18 downto 18):= BA(31 downto 31); R15(17 downto 17):= BA(31 downto 31); R15(16 downto 16):= BA(31 downto 31);
			R15(15 downto 15):= BA(31 downto 31); R15(14 downto 14):= BA(31 downto 31); R15(13 downto 13):= BA(31 downto 31); R15(12 downto 12):= BA(31 downto 31);
			R15(11 downto 11):= BA(31 downto 31); R15(10 downto 10):= BA(31 downto 31); R15(9 downto 9):= BA(31 downto 31);   R15(8 downto 8):= BA(31 downto 31);
			R15(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R15(31 downto 8):= (others => '0'); 
			R15(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R15(31 downto 31):= BA(31 downto 31); R15(30 downto 30):= BA(31 downto 31); R15(29 downto 29):= BA(31 downto 31); R15(28 downto 28):= BA(31 downto 31);
			R15(27 downto 27):= BA(31 downto 31); R15(26 downto 26):= BA(31 downto 31); R15(25 downto 25):= BA(31 downto 31); R15(24 downto 24):= BA(31 downto 31);
			R15(23 downto 23):= BA(31 downto 31); R15(22 downto 22):= BA(31 downto 31); R15(21 downto 21):= BA(31 downto 31); R15(20 downto 20):= BA(31 downto 31);
			R15(19 downto 19):= BA(31 downto 31); R15(18 downto 18):= BA(31 downto 31); R15(17 downto 17):= BA(31 downto 31); R15(16 downto 16):= BA(31 downto 31);
			R15(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R15(31 downto 16):= (others => '0'); 
			R15(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R15(31 downto 16):=(others => '0');
			R15(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "10000" => 
	case zapis is
		when "000" => R16 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R16(31 downto 31):= BA(31 downto 31); R16(30 downto 30):= BA(31 downto 31); R16(29 downto 29):= BA(31 downto 31); R16(28 downto 28):= BA(31 downto 31);
			R16(27 downto 27):= BA(31 downto 31); R16(26 downto 26):= BA(31 downto 31); R16(25 downto 25):= BA(31 downto 31); R16(24 downto 24):= BA(31 downto 31);
			R16(23 downto 23):= BA(31 downto 31); R16(22 downto 22):= BA(31 downto 31); R16(21 downto 21):= BA(31 downto 31); R16(20 downto 20):= BA(31 downto 31);
			R16(19 downto 19):= BA(31 downto 31); R16(18 downto 18):= BA(31 downto 31); R16(17 downto 17):= BA(31 downto 31); R16(16 downto 16):= BA(31 downto 31);
			R16(15 downto 15):= BA(31 downto 31); R16(14 downto 14):= BA(31 downto 31); R16(13 downto 13):= BA(31 downto 31); R16(12 downto 12):= BA(31 downto 31);
			R16(11 downto 11):= BA(31 downto 31); R16(10 downto 10):= BA(31 downto 31); R16(9 downto 9):= BA(31 downto 31);   R16(8 downto 8):= BA(31 downto 31);
			R16(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R16(31 downto 8):= (others => '0'); 
			R16(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R16(31 downto 31):= BA(31 downto 31); R16(30 downto 30):= BA(31 downto 31); R16(29 downto 29):= BA(31 downto 31); R16(28 downto 28):= BA(31 downto 31);
			R16(27 downto 27):= BA(31 downto 31); R16(26 downto 26):= BA(31 downto 31); R16(25 downto 25):= BA(31 downto 31); R16(24 downto 24):= BA(31 downto 31);
			R16(23 downto 23):= BA(31 downto 31); R16(22 downto 22):= BA(31 downto 31); R16(21 downto 21):= BA(31 downto 31); R16(20 downto 20):= BA(31 downto 31);
			R16(19 downto 19):= BA(31 downto 31); R16(18 downto 18):= BA(31 downto 31); R16(17 downto 17):= BA(31 downto 31); R16(16 downto 16):= BA(31 downto 31);
			R16(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R16(31 downto 16):= (others => '0'); 
			R16(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R16(31 downto 16):=(others => '0');
			R16(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "10001" => 
	case zapis is
		when "000" => R17 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R17(31 downto 31):= BA(31 downto 31); R17(30 downto 30):= BA(31 downto 31); R17(29 downto 29):= BA(31 downto 31); R17(28 downto 28):= BA(31 downto 31);
			R17(27 downto 27):= BA(31 downto 31); R17(26 downto 26):= BA(31 downto 31); R17(25 downto 25):= BA(31 downto 31); R17(24 downto 24):= BA(31 downto 31);
			R17(23 downto 23):= BA(31 downto 31); R17(22 downto 22):= BA(31 downto 31); R17(21 downto 21):= BA(31 downto 31); R17(20 downto 20):= BA(31 downto 31);
			R17(19 downto 19):= BA(31 downto 31); R17(18 downto 18):= BA(31 downto 31); R17(17 downto 17):= BA(31 downto 31); R17(16 downto 16):= BA(31 downto 31);
			R17(15 downto 15):= BA(31 downto 31); R17(14 downto 14):= BA(31 downto 31); R17(13 downto 13):= BA(31 downto 31); R17(12 downto 12):= BA(31 downto 31);
			R17(11 downto 11):= BA(31 downto 31); R17(10 downto 10):= BA(31 downto 31); R17(9 downto 9):= BA(31 downto 31);   R17(8 downto 8):= BA(31 downto 31);
			R17(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R17(31 downto 8):= (others => '0'); 
			R17(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R17(31 downto 31):= BA(31 downto 31); R17(30 downto 30):= BA(31 downto 31); R17(29 downto 29):= BA(31 downto 31); R17(28 downto 28):= BA(31 downto 31);
			R17(27 downto 27):= BA(31 downto 31); R17(26 downto 26):= BA(31 downto 31); R17(25 downto 25):= BA(31 downto 31); R17(24 downto 24):= BA(31 downto 31);
			R17(23 downto 23):= BA(31 downto 31); R17(22 downto 22):= BA(31 downto 31); R17(21 downto 21):= BA(31 downto 31); R17(20 downto 20):= BA(31 downto 31);
			R17(19 downto 19):= BA(31 downto 31); R17(18 downto 18):= BA(31 downto 31); R17(17 downto 17):= BA(31 downto 31); R17(16 downto 16):= BA(31 downto 31);
			R17(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R17(31 downto 16):= (others => '0'); 
			R17(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R17(31 downto 16):=(others => '0');
			R17(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "10010" => 
	case zapis is
		when "000" => R18 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R18(31 downto 31):= BA(31 downto 31); R18(30 downto 30):= BA(31 downto 31); R18(29 downto 29):= BA(31 downto 31); R18(28 downto 28):= BA(31 downto 31);
			R18(27 downto 27):= BA(31 downto 31); R18(26 downto 26):= BA(31 downto 31); R18(25 downto 25):= BA(31 downto 31); R18(24 downto 24):= BA(31 downto 31);
			R18(23 downto 23):= BA(31 downto 31); R18(22 downto 22):= BA(31 downto 31); R18(21 downto 21):= BA(31 downto 31); R18(20 downto 20):= BA(31 downto 31);
			R18(19 downto 19):= BA(31 downto 31); R18(18 downto 18):= BA(31 downto 31); R18(17 downto 17):= BA(31 downto 31); R18(16 downto 16):= BA(31 downto 31);
			R18(15 downto 15):= BA(31 downto 31); R18(14 downto 14):= BA(31 downto 31); R18(13 downto 13):= BA(31 downto 31); R18(12 downto 12):= BA(31 downto 31);
			R18(11 downto 11):= BA(31 downto 31); R18(10 downto 10):= BA(31 downto 31); R18(9 downto 9):= BA(31 downto 31);   R18(8 downto 8):= BA(31 downto 31);
			R18(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R18(31 downto 8):= (others => '0'); 
			R18(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R18(31 downto 31):= BA(31 downto 31); R18(30 downto 30):= BA(31 downto 31); R18(29 downto 29):= BA(31 downto 31); R18(28 downto 28):= BA(31 downto 31);
			R18(27 downto 27):= BA(31 downto 31); R18(26 downto 26):= BA(31 downto 31); R18(25 downto 25):= BA(31 downto 31); R18(24 downto 24):= BA(31 downto 31);
			R18(23 downto 23):= BA(31 downto 31); R18(22 downto 22):= BA(31 downto 31); R18(21 downto 21):= BA(31 downto 31); R18(20 downto 20):= BA(31 downto 31);
			R18(19 downto 19):= BA(31 downto 31); R18(18 downto 18):= BA(31 downto 31); R18(17 downto 17):= BA(31 downto 31); R18(16 downto 16):= BA(31 downto 31);
			R18(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R18(31 downto 16):= (others => '0'); 
			R18(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R18(31 downto 16):=(others => '0');
			R18(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "10011" => 
	case zapis is
		when "000" => R19 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R19(31 downto 31):= BA(31 downto 31); R19(30 downto 30):= BA(31 downto 31); R19(29 downto 29):= BA(31 downto 31); R19(28 downto 28):= BA(31 downto 31);
			R19(27 downto 27):= BA(31 downto 31); R19(26 downto 26):= BA(31 downto 31); R19(25 downto 25):= BA(31 downto 31); R19(24 downto 24):= BA(31 downto 31);
			R19(23 downto 23):= BA(31 downto 31); R19(22 downto 22):= BA(31 downto 31); R19(21 downto 21):= BA(31 downto 31); R19(20 downto 20):= BA(31 downto 31);
			R19(19 downto 19):= BA(31 downto 31); R19(18 downto 18):= BA(31 downto 31); R19(17 downto 17):= BA(31 downto 31); R19(16 downto 16):= BA(31 downto 31);
			R19(15 downto 15):= BA(31 downto 31); R19(14 downto 14):= BA(31 downto 31); R19(13 downto 13):= BA(31 downto 31); R19(12 downto 12):= BA(31 downto 31);
			R19(11 downto 11):= BA(31 downto 31); R19(10 downto 10):= BA(31 downto 31); R19(9 downto 9):= BA(31 downto 31);   R19(8 downto 8):= BA(31 downto 31);
			R19(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R19(31 downto 8):= (others => '0'); 
			R19(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R19(31 downto 31):= BA(31 downto 31); R19(30 downto 30):= BA(31 downto 31); R19(29 downto 29):= BA(31 downto 31); R19(28 downto 28):= BA(31 downto 31);
			R19(27 downto 27):= BA(31 downto 31); R19(26 downto 26):= BA(31 downto 31); R19(25 downto 25):= BA(31 downto 31); R19(24 downto 24):= BA(31 downto 31);
			R19(23 downto 23):= BA(31 downto 31); R19(22 downto 22):= BA(31 downto 31); R19(21 downto 21):= BA(31 downto 31); R19(20 downto 20):= BA(31 downto 31);
			R19(19 downto 19):= BA(31 downto 31); R19(18 downto 18):= BA(31 downto 31); R19(17 downto 17):= BA(31 downto 31); R19(16 downto 16):= BA(31 downto 31);
			R19(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R19(31 downto 16):= (others => '0'); 
			R19(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R19(31 downto 16):=(others => '0');
			R19(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "10100" => 
	case zapis is
		when "000" => R20 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R20(31 downto 31):= BA(31 downto 31); R20(30 downto 30):= BA(31 downto 31); R20(29 downto 29):= BA(31 downto 31); R20(28 downto 28):= BA(31 downto 31);
			R20(27 downto 27):= BA(31 downto 31); R20(26 downto 26):= BA(31 downto 31); R20(25 downto 25):= BA(31 downto 31); R20(24 downto 24):= BA(31 downto 31);
			R20(23 downto 23):= BA(31 downto 31); R20(22 downto 22):= BA(31 downto 31); R20(21 downto 21):= BA(31 downto 31); R20(20 downto 20):= BA(31 downto 31);
			R20(19 downto 19):= BA(31 downto 31); R20(18 downto 18):= BA(31 downto 31); R20(17 downto 17):= BA(31 downto 31); R20(16 downto 16):= BA(31 downto 31);
			R20(15 downto 15):= BA(31 downto 31); R20(14 downto 14):= BA(31 downto 31); R20(13 downto 13):= BA(31 downto 31); R20(12 downto 12):= BA(31 downto 31);
			R20(11 downto 11):= BA(31 downto 31); R20(10 downto 10):= BA(31 downto 31); R20(9 downto 9):= BA(31 downto 31);   R20(8 downto 8):= BA(31 downto 31);
			R20(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R20(31 downto 8):= (others => '0'); 
			R20(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R20(31 downto 31):= BA(31 downto 31); R20(30 downto 30):= BA(31 downto 31); R20(29 downto 29):= BA(31 downto 31); R20(28 downto 28):= BA(31 downto 31);
			R20(27 downto 27):= BA(31 downto 31); R20(26 downto 26):= BA(31 downto 31); R20(25 downto 25):= BA(31 downto 31); R20(24 downto 24):= BA(31 downto 31);
			R20(23 downto 23):= BA(31 downto 31); R20(22 downto 22):= BA(31 downto 31); R20(21 downto 21):= BA(31 downto 31); R20(20 downto 20):= BA(31 downto 31);
			R20(19 downto 19):= BA(31 downto 31); R20(18 downto 18):= BA(31 downto 31); R20(17 downto 17):= BA(31 downto 31); R20(16 downto 16):= BA(31 downto 31);
			R20(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R20(31 downto 16):= (others => '0'); 
			R20(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R20(31 downto 16):=(others => '0');
			R20(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "10101" =>
	case zapis is
		when "000" => R21 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R21(31 downto 31):= BA(31 downto 31); R21(30 downto 30):= BA(31 downto 31); R21(29 downto 29):= BA(31 downto 31); R21(28 downto 28):= BA(31 downto 31);
			R21(27 downto 27):= BA(31 downto 31); R21(26 downto 26):= BA(31 downto 31); R21(25 downto 25):= BA(31 downto 31); R21(24 downto 24):= BA(31 downto 31);
			R21(23 downto 23):= BA(31 downto 31); R21(22 downto 22):= BA(31 downto 31); R21(21 downto 21):= BA(31 downto 31); R21(20 downto 20):= BA(31 downto 31);
			R21(19 downto 19):= BA(31 downto 31); R21(18 downto 18):= BA(31 downto 31); R21(17 downto 17):= BA(31 downto 31); R21(16 downto 16):= BA(31 downto 31);
			R21(15 downto 15):= BA(31 downto 31); R21(14 downto 14):= BA(31 downto 31); R21(13 downto 13):= BA(31 downto 31); R21(12 downto 12):= BA(31 downto 31);
			R21(11 downto 11):= BA(31 downto 31); R21(10 downto 10):= BA(31 downto 31); R21(9 downto 9):= BA(31 downto 31);   R21(8 downto 8):= BA(31 downto 31);
			R21(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R21(31 downto 8):= (others => '0'); 
			R21(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R21(31 downto 31):= BA(31 downto 31); R21(30 downto 30):= BA(31 downto 31); R21(29 downto 29):= BA(31 downto 31); R21(28 downto 28):= BA(31 downto 31);
			R21(27 downto 27):= BA(31 downto 31); R21(26 downto 26):= BA(31 downto 31); R21(25 downto 25):= BA(31 downto 31); R21(24 downto 24):= BA(31 downto 31);
			R21(23 downto 23):= BA(31 downto 31); R21(22 downto 22):= BA(31 downto 31); R21(21 downto 21):= BA(31 downto 31); R21(20 downto 20):= BA(31 downto 31);
			R21(19 downto 19):= BA(31 downto 31); R21(18 downto 18):= BA(31 downto 31); R21(17 downto 17):= BA(31 downto 31); R21(16 downto 16):= BA(31 downto 31);
			R21(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R21(31 downto 16):= (others => '0'); 
			R21(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R21(31 downto 16):=(others => '0');
			R21(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "10110" => 
	case zapis is
		when "000" => R22 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R22(31 downto 31):= BA(31 downto 31); R22(30 downto 30):= BA(31 downto 31); R22(29 downto 29):= BA(31 downto 31); R22(28 downto 28):= BA(31 downto 31);
			R22(27 downto 27):= BA(31 downto 31); R22(26 downto 26):= BA(31 downto 31); R22(25 downto 25):= BA(31 downto 31); R22(24 downto 24):= BA(31 downto 31);
			R22(23 downto 23):= BA(31 downto 31); R22(22 downto 22):= BA(31 downto 31); R22(21 downto 21):= BA(31 downto 31); R22(20 downto 20):= BA(31 downto 31);
			R22(19 downto 19):= BA(31 downto 31); R22(18 downto 18):= BA(31 downto 31); R22(17 downto 17):= BA(31 downto 31); R22(16 downto 16):= BA(31 downto 31);
			R22(15 downto 15):= BA(31 downto 31); R22(14 downto 14):= BA(31 downto 31); R22(13 downto 13):= BA(31 downto 31); R22(12 downto 12):= BA(31 downto 31);
			R22(11 downto 11):= BA(31 downto 31); R22(10 downto 10):= BA(31 downto 31); R22(9 downto 9):= BA(31 downto 31);   R22(8 downto 8):= BA(31 downto 31);
			R22(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R22(31 downto 8):= (others => '0'); 
			R22(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R22(31 downto 31):= BA(31 downto 31); R22(30 downto 30):= BA(31 downto 31); R22(29 downto 29):= BA(31 downto 31); R22(28 downto 28):= BA(31 downto 31);
			R22(27 downto 27):= BA(31 downto 31); R22(26 downto 26):= BA(31 downto 31); R22(25 downto 25):= BA(31 downto 31); R22(24 downto 24):= BA(31 downto 31);
			R22(23 downto 23):= BA(31 downto 31); R22(22 downto 22):= BA(31 downto 31); R22(21 downto 21):= BA(31 downto 31); R22(20 downto 20):= BA(31 downto 31);
			R22(19 downto 19):= BA(31 downto 31); R22(18 downto 18):= BA(31 downto 31); R22(17 downto 17):= BA(31 downto 31); R22(16 downto 16):= BA(31 downto 31);
			R22(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R22(31 downto 16):= (others => '0'); 
			R22(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R22(31 downto 16):=(others => '0');
			R22(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "10111" => 
	case zapis is
		when "000" => R23 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R23(31 downto 31):= BA(31 downto 31); R23(30 downto 30):= BA(31 downto 31); R23(29 downto 29):= BA(31 downto 31); R23(28 downto 28):= BA(31 downto 31);
			R23(27 downto 27):= BA(31 downto 31); R23(26 downto 26):= BA(31 downto 31); R23(25 downto 25):= BA(31 downto 31); R23(24 downto 24):= BA(31 downto 31);
			R23(23 downto 23):= BA(31 downto 31); R23(22 downto 22):= BA(31 downto 31); R23(21 downto 21):= BA(31 downto 31); R23(20 downto 20):= BA(31 downto 31);
			R23(19 downto 19):= BA(31 downto 31); R23(18 downto 18):= BA(31 downto 31); R23(17 downto 17):= BA(31 downto 31); R23(16 downto 16):= BA(31 downto 31);
			R23(15 downto 15):= BA(31 downto 31); R23(14 downto 14):= BA(31 downto 31); R23(13 downto 13):= BA(31 downto 31); R23(12 downto 12):= BA(31 downto 31);
			R23(11 downto 11):= BA(31 downto 31); R23(10 downto 10):= BA(31 downto 31); R23(9 downto 9):= BA(31 downto 31);   R23(8 downto 8):= BA(31 downto 31);
			R23(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R23(31 downto 8):= (others => '0'); 
			R23(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R23(31 downto 31):= BA(31 downto 31); R23(30 downto 30):= BA(31 downto 31); R23(29 downto 29):= BA(31 downto 31); R23(28 downto 28):= BA(31 downto 31);
			R23(27 downto 27):= BA(31 downto 31); R23(26 downto 26):= BA(31 downto 31); R23(25 downto 25):= BA(31 downto 31); R23(24 downto 24):= BA(31 downto 31);
			R23(23 downto 23):= BA(31 downto 31); R23(22 downto 22):= BA(31 downto 31); R23(21 downto 21):= BA(31 downto 31); R23(20 downto 20):= BA(31 downto 31);
			R23(19 downto 19):= BA(31 downto 31); R23(18 downto 18):= BA(31 downto 31); R23(17 downto 17):= BA(31 downto 31); R23(16 downto 16):= BA(31 downto 31);
			R23(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R23(31 downto 16):= (others => '0'); 
			R23(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R23(31 downto 16):=(others => '0');
			R23(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "11000" =>
	case zapis is
		when "000" => R24 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R24(31 downto 31):= BA(31 downto 31); R24(30 downto 30):= BA(31 downto 31); R24(29 downto 29):= BA(31 downto 31); R24(28 downto 28):= BA(31 downto 31);
			R24(27 downto 27):= BA(31 downto 31); R24(26 downto 26):= BA(31 downto 31); R24(25 downto 25):= BA(31 downto 31); R24(24 downto 24):= BA(31 downto 31);
			R24(23 downto 23):= BA(31 downto 31); R24(22 downto 22):= BA(31 downto 31); R24(21 downto 21):= BA(31 downto 31); R24(20 downto 20):= BA(31 downto 31);
			R24(19 downto 19):= BA(31 downto 31); R24(18 downto 18):= BA(31 downto 31); R24(17 downto 17):= BA(31 downto 31); R24(16 downto 16):= BA(31 downto 31);
			R24(15 downto 15):= BA(31 downto 31); R24(14 downto 14):= BA(31 downto 31); R24(13 downto 13):= BA(31 downto 31); R24(12 downto 12):= BA(31 downto 31);
			R24(11 downto 11):= BA(31 downto 31); R24(10 downto 10):= BA(31 downto 31); R24(9 downto 9):= BA(31 downto 31);   R24(8 downto 8):= BA(31 downto 31);
			R24(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R24(31 downto 8):= (others => '0'); 
			R24(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R24(31 downto 31):= BA(31 downto 31); R24(30 downto 30):= BA(31 downto 31); R24(29 downto 29):= BA(31 downto 31); R24(28 downto 28):= BA(31 downto 31);
			R24(27 downto 27):= BA(31 downto 31); R24(26 downto 26):= BA(31 downto 31); R24(25 downto 25):= BA(31 downto 31); R24(24 downto 24):= BA(31 downto 31);
			R24(23 downto 23):= BA(31 downto 31); R24(22 downto 22):= BA(31 downto 31); R24(21 downto 21):= BA(31 downto 31); R24(20 downto 20):= BA(31 downto 31);
			R24(19 downto 19):= BA(31 downto 31); R24(18 downto 18):= BA(31 downto 31); R24(17 downto 17):= BA(31 downto 31); R24(16 downto 16):= BA(31 downto 31);
			R24(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R24(31 downto 16):= (others => '0'); 
			R24(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R24(31 downto 16):=(others => '0');
			R24(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "11001" => 
	case zapis is
		when "000" => R25 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R25(31 downto 31):= BA(31 downto 31); R25(30 downto 30):= BA(31 downto 31); R25(29 downto 29):= BA(31 downto 31); R25(28 downto 28):= BA(31 downto 31);
			R25(27 downto 27):= BA(31 downto 31); R25(26 downto 26):= BA(31 downto 31); R25(25 downto 25):= BA(31 downto 31); R25(24 downto 24):= BA(31 downto 31);
			R25(23 downto 23):= BA(31 downto 31); R25(22 downto 22):= BA(31 downto 31); R25(21 downto 21):= BA(31 downto 31); R25(20 downto 20):= BA(31 downto 31);
			R25(19 downto 19):= BA(31 downto 31); R25(18 downto 18):= BA(31 downto 31); R25(17 downto 17):= BA(31 downto 31); R25(16 downto 16):= BA(31 downto 31);
			R25(15 downto 15):= BA(31 downto 31); R25(14 downto 14):= BA(31 downto 31); R25(13 downto 13):= BA(31 downto 31); R25(12 downto 12):= BA(31 downto 31);
			R25(11 downto 11):= BA(31 downto 31); R25(10 downto 10):= BA(31 downto 31); R25(9 downto 9):= BA(31 downto 31);   R25(8 downto 8):= BA(31 downto 31);
			R25(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R25(31 downto 8):= (others => '0'); 
			R25(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R25(31 downto 31):= BA(31 downto 31); R25(30 downto 30):= BA(31 downto 31); R25(29 downto 29):= BA(31 downto 31); R25(28 downto 28):= BA(31 downto 31);
			R25(27 downto 27):= BA(31 downto 31); R25(26 downto 26):= BA(31 downto 31); R25(25 downto 25):= BA(31 downto 31); R25(24 downto 24):= BA(31 downto 31);
			R25(23 downto 23):= BA(31 downto 31); R25(22 downto 22):= BA(31 downto 31); R25(21 downto 21):= BA(31 downto 31); R25(20 downto 20):= BA(31 downto 31);
			R25(19 downto 19):= BA(31 downto 31); R25(18 downto 18):= BA(31 downto 31); R25(17 downto 17):= BA(31 downto 31); R25(16 downto 16):= BA(31 downto 31);
			R25(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R25(31 downto 16):= (others => '0'); 
			R25(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R25(31 downto 16):=(others => '0');
			R25(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "11010" =>
	case zapis is
		when "000" => R26 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R26(31 downto 31):= BA(31 downto 31); R26(30 downto 30):= BA(31 downto 31); R26(29 downto 29):= BA(31 downto 31); R26(28 downto 28):= BA(31 downto 31);
			R26(27 downto 27):= BA(31 downto 31); R26(26 downto 26):= BA(31 downto 31); R26(25 downto 25):= BA(31 downto 31); R26(24 downto 24):= BA(31 downto 31);
			R26(23 downto 23):= BA(31 downto 31); R26(22 downto 22):= BA(31 downto 31); R26(21 downto 21):= BA(31 downto 31); R26(20 downto 20):= BA(31 downto 31);
			R26(19 downto 19):= BA(31 downto 31); R26(18 downto 18):= BA(31 downto 31); R26(17 downto 17):= BA(31 downto 31); R26(16 downto 16):= BA(31 downto 31);
			R26(15 downto 15):= BA(31 downto 31); R26(14 downto 14):= BA(31 downto 31); R26(13 downto 13):= BA(31 downto 31); R26(12 downto 12):= BA(31 downto 31);
			R26(11 downto 11):= BA(31 downto 31); R26(10 downto 10):= BA(31 downto 31); R26(9 downto 9):= BA(31 downto 31);   R26(8 downto 8):= BA(31 downto 31);
			R26(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R26(31 downto 8):= (others => '0'); 
			R26(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R26(31 downto 31):= BA(31 downto 31); R26(30 downto 30):= BA(31 downto 31); R26(29 downto 29):= BA(31 downto 31); R26(28 downto 28):= BA(31 downto 31);
			R26(27 downto 27):= BA(31 downto 31); R26(26 downto 26):= BA(31 downto 31); R26(25 downto 25):= BA(31 downto 31); R26(24 downto 24):= BA(31 downto 31);
			R26(23 downto 23):= BA(31 downto 31); R26(22 downto 22):= BA(31 downto 31); R26(21 downto 21):= BA(31 downto 31); R26(20 downto 20):= BA(31 downto 31);
			R26(19 downto 19):= BA(31 downto 31); R26(18 downto 18):= BA(31 downto 31); R26(17 downto 17):= BA(31 downto 31); R26(16 downto 16):= BA(31 downto 31);
			R26(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R26(31 downto 16):= (others => '0'); 
			R26(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R26(31 downto 16):=(others => '0');
			R26(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "11011" => 
	case zapis is
		when "000" => R27 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R27(31 downto 31):= BA(31 downto 31); R27(30 downto 30):= BA(31 downto 31); R27(29 downto 29):= BA(31 downto 31); R27(28 downto 28):= BA(31 downto 31);
			R27(27 downto 27):= BA(31 downto 31); R27(26 downto 26):= BA(31 downto 31); R27(25 downto 25):= BA(31 downto 31); R27(24 downto 24):= BA(31 downto 31);
			R27(23 downto 23):= BA(31 downto 31); R27(22 downto 22):= BA(31 downto 31); R27(21 downto 21):= BA(31 downto 31); R27(20 downto 20):= BA(31 downto 31);
			R27(19 downto 19):= BA(31 downto 31); R27(18 downto 18):= BA(31 downto 31); R27(17 downto 17):= BA(31 downto 31); R27(16 downto 16):= BA(31 downto 31);
			R27(15 downto 15):= BA(31 downto 31); R27(14 downto 14):= BA(31 downto 31); R27(13 downto 13):= BA(31 downto 31); R27(12 downto 12):= BA(31 downto 31);
			R27(11 downto 11):= BA(31 downto 31); R27(10 downto 10):= BA(31 downto 31); R27(9 downto 9):= BA(31 downto 31);   R27(8 downto 8):= BA(31 downto 31);
			R27(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R27(31 downto 8):= (others => '0'); 
			R27(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R27(31 downto 31):= BA(31 downto 31); R27(30 downto 30):= BA(31 downto 31); R27(29 downto 29):= BA(31 downto 31); R27(28 downto 28):= BA(31 downto 31);
			R27(27 downto 27):= BA(31 downto 31); R27(26 downto 26):= BA(31 downto 31); R27(25 downto 25):= BA(31 downto 31); R27(24 downto 24):= BA(31 downto 31);
			R27(23 downto 23):= BA(31 downto 31); R27(22 downto 22):= BA(31 downto 31); R27(21 downto 21):= BA(31 downto 31); R27(20 downto 20):= BA(31 downto 31);
			R27(19 downto 19):= BA(31 downto 31); R27(18 downto 18):= BA(31 downto 31); R27(17 downto 17):= BA(31 downto 31); R27(16 downto 16):= BA(31 downto 31);
			R27(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R27(31 downto 16):= (others => '0'); 
			R27(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R27(31 downto 16):=(others => '0');
			R27(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "11100" => 
	case zapis is
		when "000" => R28 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R28(31 downto 31):= BA(31 downto 31); R28(30 downto 30):= BA(31 downto 31); R28(29 downto 29):= BA(31 downto 31); R28(28 downto 28):= BA(31 downto 31);
			R28(27 downto 27):= BA(31 downto 31); R28(26 downto 26):= BA(31 downto 31); R28(25 downto 25):= BA(31 downto 31); R28(24 downto 24):= BA(31 downto 31);
			R28(23 downto 23):= BA(31 downto 31); R28(22 downto 22):= BA(31 downto 31); R28(21 downto 21):= BA(31 downto 31); R28(20 downto 20):= BA(31 downto 31);
			R28(19 downto 19):= BA(31 downto 31); R28(18 downto 18):= BA(31 downto 31); R28(17 downto 17):= BA(31 downto 31); R28(16 downto 16):= BA(31 downto 31);
			R28(15 downto 15):= BA(31 downto 31); R28(14 downto 14):= BA(31 downto 31); R28(13 downto 13):= BA(31 downto 31); R28(12 downto 12):= BA(31 downto 31);
			R28(11 downto 11):= BA(31 downto 31); R28(10 downto 10):= BA(31 downto 31); R28(9 downto 9):= BA(31 downto 31);   R28(8 downto 8):= BA(31 downto 31);
			R28(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R28(31 downto 8):= (others => '0'); 
			R28(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R28(31 downto 31):= BA(31 downto 31); R28(30 downto 30):= BA(31 downto 31); R28(29 downto 29):= BA(31 downto 31); R28(28 downto 28):= BA(31 downto 31);
			R28(27 downto 27):= BA(31 downto 31); R28(26 downto 26):= BA(31 downto 31); R28(25 downto 25):= BA(31 downto 31); R28(24 downto 24):= BA(31 downto 31);
			R28(23 downto 23):= BA(31 downto 31); R28(22 downto 22):= BA(31 downto 31); R28(21 downto 21):= BA(31 downto 31); R28(20 downto 20):= BA(31 downto 31);
			R28(19 downto 19):= BA(31 downto 31); R28(18 downto 18):= BA(31 downto 31); R28(17 downto 17):= BA(31 downto 31); R28(16 downto 16):= BA(31 downto 31);
			R28(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R28(31 downto 16):= (others => '0'); 
			R28(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R28(31 downto 16):=(others => '0');
			R28(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "11101" =>
	case zapis is
		when "000" => R29 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R29(31 downto 31):= BA(31 downto 31); R29(30 downto 30):= BA(31 downto 31); R29(29 downto 29):= BA(31 downto 31); R29(28 downto 28):= BA(31 downto 31);
			R29(27 downto 27):= BA(31 downto 31); R29(26 downto 26):= BA(31 downto 31); R29(25 downto 25):= BA(31 downto 31); R29(24 downto 24):= BA(31 downto 31);
			R29(23 downto 23):= BA(31 downto 31); R29(22 downto 22):= BA(31 downto 31); R29(21 downto 21):= BA(31 downto 31); R29(20 downto 20):= BA(31 downto 31);
			R29(19 downto 19):= BA(31 downto 31); R29(18 downto 18):= BA(31 downto 31); R29(17 downto 17):= BA(31 downto 31); R29(16 downto 16):= BA(31 downto 31);
			R29(15 downto 15):= BA(31 downto 31); R29(14 downto 14):= BA(31 downto 31); R29(13 downto 13):= BA(31 downto 31); R29(12 downto 12):= BA(31 downto 31);
			R29(11 downto 11):= BA(31 downto 31); R29(10 downto 10):= BA(31 downto 31); R29(9 downto 9):= BA(31 downto 31);   R29(8 downto 8):= BA(31 downto 31);
			R29(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R29(31 downto 8):= (others => '0'); 
			R29(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R29(31 downto 31):= BA(31 downto 31); R29(30 downto 30):= BA(31 downto 31); R29(29 downto 29):= BA(31 downto 31); R29(28 downto 28):= BA(31 downto 31);
			R29(27 downto 27):= BA(31 downto 31); R29(26 downto 26):= BA(31 downto 31); R29(25 downto 25):= BA(31 downto 31); R29(24 downto 24):= BA(31 downto 31);
			R29(23 downto 23):= BA(31 downto 31); R29(22 downto 22):= BA(31 downto 31); R29(21 downto 21):= BA(31 downto 31); R29(20 downto 20):= BA(31 downto 31);
			R29(19 downto 19):= BA(31 downto 31); R29(18 downto 18):= BA(31 downto 31); R29(17 downto 17):= BA(31 downto 31); R29(16 downto 16):= BA(31 downto 31);
			R29(15 downto 0):= BA(31 downto 16);
		when "100" =>---ładowanie pół słowa bez znaku:
			R29(31 downto 16):= (others => '0'); 
			R29(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R29(31 downto 16):=(others => '0');
			R29(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "11110" => 
	case zapis is
		when "000" => R30 := BA; --ładowanie słowa word
		when "001" => --ładowanie bajtu ze znakiem:
			R30(31 downto 31):= BA(31 downto 31); R30(30 downto 30):= BA(31 downto 31); R30(29 downto 29):= BA(31 downto 31); R30(28 downto 28):= BA(31 downto 31);
			R30(27 downto 27):= BA(31 downto 31); R30(26 downto 26):= BA(31 downto 31); R30(25 downto 25):= BA(31 downto 31); R30(24 downto 24):= BA(31 downto 31);
			R30(23 downto 23):= BA(31 downto 31); R30(22 downto 22):= BA(31 downto 31); R30(21 downto 21):= BA(31 downto 31); R30(20 downto 20):= BA(31 downto 31);
			R30(19 downto 19):= BA(31 downto 31); R30(18 downto 18):= BA(31 downto 31); R30(17 downto 17):= BA(31 downto 31); R30(16 downto 16):= BA(31 downto 31);
			R30(15 downto 15):= BA(31 downto 31); R30(14 downto 14):= BA(31 downto 31); R30(13 downto 13):= BA(31 downto 31); R30(12 downto 12):= BA(31 downto 31);
			R30(11 downto 11):= BA(31 downto 31); R30(10 downto 10):= BA(31 downto 31); R30(9 downto 9):= BA(31 downto 31);   R30(8 downto 8):= BA(31 downto 31);
			R30(7 downto 0):= BA(31 downto 24);
		when "010" =>--ładowanie bajtu bez znaku:
			R30(31 downto 8):= (others => '0'); 
			R30(7 downto 0):= BA(31 downto 24);
		when "011" =>--ładowanie pół słowa ze znakiem:
			R30(31 downto 31):= BA(31 downto 31); R30(30 downto 30):= BA(31 downto 31); R30(29 downto 29):= BA(31 downto 31); R30(28 downto 28):= BA(31 downto 31);
			R30(27 downto 27):= BA(31 downto 31); R30(26 downto 26):= BA(31 downto 31); R30(25 downto 25):= BA(31 downto 31); R30(24 downto 24):= BA(31 downto 31);
			R30(23 downto 23):= BA(31 downto 31); R30(22 downto 22):= BA(31 downto 31); R30(21 downto 21):= BA(31 downto 31); R30(20 downto 20):= BA(31 downto 31);
			R30(19 downto 19):= BA(31 downto 31); R30(18 downto 18):= BA(31 downto 31); R30(17 downto 17):= BA(31 downto 31); R30(16 downto 16):= BA(31 downto 31);
			R30(15 downto 0):= BA(31 downto 16);
		when "100" =>--ładowanie pół słowa bez znaku:
			R30(31 downto 16):= (others => '0'); 
			R30(15 downto 0):= BA(31 downto 16);
		when "101" =>
			R30(31 downto 16):=(others => '0');
			R30(15 downto 0):=BA(15 downto 0);
		when others => null;
	end case;
when "11111" => R31 := R31 + BA; --ładuj słowo word		
when others => null;
end case;  -- koniec case Sba


case SIRa is
	when "01" => IR := BA;
	when "10" => IAR := BA;
	when "11" => PC := BA;
	when others => R0 := (others => '0');
end case; -- koniec case SIRa
end if;

case Sbb is
	when "00000" => BB1 <=	R0;
	when "00001" => BB1 <=	R1;
	when "00010" => BB1 <=	R2;
	when "00011" => BB1 <=	R3;
	when "00100" => BB1 <=	R4;
	when "00101" => BB1 <=	R5;
	when "00110" => BB1 <=	R6;
	when "00111" => BB1 <=	R7;
	when "01000" => BB1 <=	R8;
	when "01001" => BB1 <=	R9;
	when "01010" => BB1 <=	R10;
	when "01011" => BB1 <=	R11;
	when "01100" => BB1 <=	R12;
	when "01101" => BB1 <=	R13;
	when "01110" => BB1 <=	R14;
	when "01111" => BB1 <=	R15;
	when "10000" => BB1 <=	R16;
	when "10001" => BB1 <=	R17;
	when "10010" => BB1 <=	R18;
	when "10011" => BB1 <=	R19;
	when "10100" => BB1 <=	R20;
	when "10101" => BB1 <=	R21;
	when "10110" => BB1 <=	R22;
	when "10111" => BB1 <=	R23;
	when "11000" => BB1 <=	R24;
	when "11001" => BB1 <=	R25;
	when "11010" => BB1 <=	R26;
	when "11011" => BB1 <= 	R27;
	when "11100" => BB1 <=	R28;
	when "11101" => BB1 <=	R29;
	when "11110" => BB1 <=	R30;
	when "11111" => BB1 <=	R31;
	when others  => BB1 <= (others =>'0');
end case; -- koniec case Sbb

case SIRb is 
	when "01" => BB2 <= IR;
	when "10" => BB2 <= IAR;
	when "11" => BB2 <= DI;
	when others => BB2 <= (others =>'0');
end case; --koniec case SIRb

case Sbc is
when "00000" => 
	case odczyt is
		when "01" => BC1 <= R0; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R0(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word 
			BC1(31 downto 16) <= R0(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "00001" => 
	case odczyt is
		when "01" => BC1 <= R1; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R1(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R1(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "00010" =>
	case odczyt is
		when "01" => BC1 <= R2; -- word
		when "10" => -- byte 
			BC1(31 downto 24) <= R2(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R2(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "00011" => 
	case odczyt is
		when "01" => BC1 <= R3; -- word
		when "10" => -- byte 
			BC1(31 downto 24) <= R3(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R3(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "00100" => 
	case odczyt is
		when "01" => BC1 <= R4; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R4(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word 
			BC1(31 downto 16) <= R4(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "00101" => 
	case odczyt is
		when "01" => BC1 <= R5; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R5(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R5(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "00110" => 
	case odczyt is
		when "01" => BC1 <= R6; -- word
		when "10" => -- byte 
			BC1(31 downto 24) <= R6(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R6(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "00111" => 
	case odczyt is
		when "01" => BC1 <= R7; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R7(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R7(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "01000" => 
	case odczyt is
		when "01" => BC1 <= R8; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R8(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R8(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "01001" => 
	case odczyt is
		when "01" => BC1 <= R9; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R9(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R9(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "01010" =>
	case odczyt is
		when "01" => BC1 <= R10; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R10(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R10(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "01011" => 
	case odczyt is
		when "01" => BC1 <= R11; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R11(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R11(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "01100" => 
	case odczyt is
		when "01" => BC1 <= R12; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R12(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R12(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "01101" => 
	case odczyt is
		when "01" => BC1 <= R13; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R13(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R13(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "01110" => 
	case odczyt is
		when "01" => BC1 <= R14; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R14(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R14(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "01111" =>
	case odczyt is
		when "01" => BC1 <= R15; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R15(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R15(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "10000" => 
	case odczyt is
		when "01" => BC1 <= R16; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R16(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R16(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "10001" => 
	case odczyt is
		when "01" => BC1 <= R17; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R17(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R17(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "10010" => 
	case odczyt is
		when "01" => BC1 <= R18; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R18(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R18(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "10011" => 
	case odczyt is
		when "01" => BC1 <= R19; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R19(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R19(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "10100" => 
	case odczyt is
		when "01" => BC1 <= R20; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R20(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R20(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "10101" =>
	case odczyt is
		when "01" => BC1 <= R21; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R21(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R21(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "10110" =>
	case odczyt is
		when "01" => BC1 <= R22; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R22(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R22(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "10111" =>
	case odczyt is
		when "01" => BC1 <= R23; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R23(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R23(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "11000" => 
	case odczyt is
		when "01" => BC1 <= R24; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R24(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R24(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "11001" =>
	case odczyt is
		when "01" => BC1 <= R25; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R25(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R25(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "11010" => 
	case odczyt is
		when "01" => BC1 <= R26; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R26(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R26(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "11011" => 
	case odczyt is
		when "01" => BC1 <= R27; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R27(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R27(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "11100" => 
	case odczyt is
		when "01" => BC1 <= R28; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R28(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R28(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1<= (others =>'0');
	end case;
when "11101" =>
	case odczyt is
		when "01" => BC1 <= R29; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R29(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R29(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
when "11110" => 
	case odczyt is
		when "01" => BC1 <= R30; -- word
		when "10" => -- byte
			BC1(31 downto 24) <= R30(31 downto 24); BC1(23 downto 0) <= (others => '0');
		when "11" => -- half word
			BC1(31 downto 16) <= R30(31 downto 16); BC1(15 downto 0) <= (others => '0');
		when others =>  BC1 <= (others =>'0');
	end case;
	
when "11111" => BC1 <= R31; -- word
when others  => BC1 <= (others =>'0');
end case; -- koniec case Sbc


case SIRc is
	when "001" => BC2(15 downto 0) <= IR(15 downto 0);
				 BC2(31 downto 16) <= (others =>'0');
	when "010" => BC2 <= IAR;
	when "011" => BC2 <= DI;
	when "100" => BC2 <= PC;
	when "101" => BC2 <= PC + IR(25 downto 0);
	when "110" => BC2 <= PC + IR(15 downto 0);
	when others => BC2 <= (others =>'0');
end case; -- koniec case SIRc

case Sadr is
	when "00000" => ADR1 <= R0 + IR(15 downto 0);
	when "00001" => ADR1 <= R1 + IR(15 downto 0);
	when "00010" => ADR1 <= R2 + IR(15 downto 0);
	when "00011" => ADR1 <= R3 + IR(15 downto 0);
	when "00100" => ADR1 <= R4 + IR(15 downto 0);
	when "00101" => ADR1 <= R5 + IR(15 downto 0);
	when "00110" => ADR1 <= R6 + IR(15 downto 0);
	when "00111" => ADR1 <= R7 + IR(15 downto 0);
	when "01000" => ADR1 <= R8 + IR(15 downto 0);
	when "01001" => ADR1 <= R9 + IR(15 downto 0);
	when "01010" => ADR1 <= R10 + IR(15 downto 0);
	when "01011" => ADR1 <= R11 + IR(15 downto 0);
	when "01100" => ADR1 <= R12 + IR(15 downto 0);
	when "01101" => ADR1 <= R13 + IR(15 downto 0);
	when "01110" => ADR1 <= R14 + IR(15 downto 0);
	when "01111" => ADR1 <= R15 + IR(15 downto 0);
	when "10000" => ADR1 <= R16 + IR(15 downto 0);
	when "10001" => ADR1 <= R17 + IR(15 downto 0);
	when "10010" => ADR1 <= R18 + IR(15 downto 0);
	when "10011" => ADR1 <= R19 + IR(15 downto 0);
	when "10100" => ADR1 <= R20 + IR(15 downto 0);
	when "10101" => ADR1 <= R21 + IR(15 downto 0);
	when "10110" => ADR1 <= R22 + IR(15 downto 0);
	when "10111" => ADR1 <= R23 + IR(15 downto 0);
	when "11000" => ADR1 <= R24 + IR(15 downto 0);
	when "11001" => ADR1 <= R25 + IR(15 downto 0);
	when "11010" => ADR1 <= R26 + IR(15 downto 0);
	when "11011" => ADR1 <= R27 + IR(15 downto 0);
	when "11100" => ADR1 <= R28 + IR(15 downto 0);
	when "11101" => ADR1 <= R29 + IR(15 downto 0);
	when "11110" => ADR1 <= R30 + IR(15 downto 0);
	when "11111" => ADR1 <= PC;
	when others => ADR1 <= (others =>'0');
end case;   -- koniec case Sadr



case SIRadr is
	when "01" => ADR2 <= PC + IR(15 downto 0);
	when "10" => ADR2 <= PC + IR(25 downto 0);
	when "11" => ADR2 <= R31;
	when others => ADR2 <= (others =>'0');
end case;   -- koniec case Sadr




BC <= BC1 xor BC2;
BB <= BB1 xor BB2;
ADR <= ADR1 xor ADR2;

IRout <= IR;

end process;
end RTL;