library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
port( A : in signed(31 downto 0);
	  B : in signed(31 downto 0);
	  Przes : in signed(31 downto 0);
	  Salu : in signed(4 downto 0);
	  clk : in bit;
	  
	  Y : out signed (31 downto 0);
	  C,Z,S,P : out std_logic);
end entity;

architecture RTL of ALU is
begin

process (Salu, A, B, clk, Przes)
variable wy, AA, BB: signed(32 downto 0);
variable CF,ZF,SF,PF : std_logic;

variable wyU, AAU, BBU: unsigned(32 downto 0);

begin
AA(32) := A(31);
AA(31 downto 0) := A;
BB(32) := B(31);
BB(31 downto 0) := B;

AAU(32) := A(31);
AAU(31 downto 0) := unsigned(A);
BBU(32) := B(31);
BBU(31 downto 0) := unsigned(B);


case Salu is
when "00000" => wy := BB; wyU := (others => '0');      																-- MOV
when "00001" => wy := AA + BB;	wyU := (others => '0');																-- ADD
when "00010" => wyU := AAU + BBU;	wy := (others => '0');															-- ADDU
when "00011" => wy := AA - BB;	wyU := (others => '0');																-- SUB
when "00100" => wyU := AAU - BBU;	wy := (others => '0');															-- SUBU
when "00101" => wy(31 downto 0) := AA(15 downto 0) * BB(15 downto 0);	wyU := (others => '0');						-- MULT
when "00110" => wyU(31 downto 0) := AAU(15 downto 0) * BBU(15 downto 0); wy := (others => '0');						-- MULTU
when "00111" => wy := AA / BB;		wyU := (others => '0');															-- DIV
when "01000" => wyU := AAU / BBU;	wy := (others => '0');															-- DIVU
when "01001" => wy := AA and BB;	wyU := (others => '0');															-- SI
when "01010" => wy := AA or BB;		wyU := (others => '0');															-- SAU
when "01011" => wy := AA xor BB;	wyU := (others => '0');															-- XSAU	
when "01100" => wy := AA sll to_integer(Przes);		wyU := (others => '0');															-- SLL
when "01101" => wy := AA srl to_integer(Przes);		wyU := (others => '0');															-- SRL
when "01110" => wy := signed(to_stdlogicvector(to_bitvector(std_logic_vector(AA)) sra to_integer(Przes)));wyU := (others => '0');		-- SRA
when "01111" =>						
		if (AA < BB) then 
			wy := "000000000000000000000000000000001";
		else																					--SLT
			wy := "000000000000000000000000000000000";
		end if;	
wyU := (others => '0');
when "10000" => 
		if (AA > BB) then 
			wy := "000000000000000000000000000000001";
		else																					--SGT
			wy := "000000000000000000000000000000000";
		end if;	
wyU := (others => '0');
when "10001" => 
		if (AA <= BB) then 
			wy := "000000000000000000000000000000001";
		else																					--SLE
			wy := "000000000000000000000000000000000";
		end if;	
wyU := (others => '0');
when "10010" => 
		if (AA >= BB) then 
			wy := "000000000000000000000000000000001";
		else																					--SGE
			wy := "000000000000000000000000000000000";
		end if;	
wyU := (others => '0');
when "10011" => 
		if (AA = BB) then 
			wy := "000000000000000000000000000000001";
		else																					--SEQ
			wy := "000000000000000000000000000000000";
		end if;	
wyU := (others => '0');	
when "10100" => 
		if (AA /= BB) then 
			wy := "000000000000000000000000000000001";
		else																					--SNE
			wy := "000000000000000000000000000000000";
		end if;	
wyU := (others => '0');	

when others => 
wy := (others => '0');
wyU := (others => '0');

end case;


Y <= wy(31 downto 0) xor signed(wyU(31 downto 0));

Z <= ZF;
S <= SF;
C <= CF;
P <= PF;


if (clk'event and clk='1') then
		if (wy = "000000000000000000000000000000000" and wyU = "000000000000000000000000000000000") then ZF:='1';
			else ZF:='0';
		end if;
		if (wy(31)='1') then SF:='1';
			else SF:='0';
		end if;
		if  ( ((wy(31 downto 0) mod 2)=0) and (wy(31 downto 0) /= "000000000000000000000000000000000" ) ) or  ( ((wyU(31 downto 0) mod 2)=0) and (wyU(31 downto 0) /= "000000000000000000000000000000000" ) ) then PF:='1';
			 else PF:='0';
		end if; 

		
		CF := (wy(32) xor wy(31)) or (wyU(32) xor wyU(31));
end if;


end process;
end RTL;