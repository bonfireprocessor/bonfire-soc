
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_textio.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library STD;
use STD.textio.all;
--use STD.textutil.all;


entity MainMemory is
    generic (RamFileName : string := "meminit.ram";
	          mode : string := "B";
             ADDR_WIDTH: integer;
             SIZE : integer
            );
    Port ( DBOut : out  STD_LOGIC_VECTOR (31 downto 0);
           DBIn : in  STD_LOGIC_VECTOR (31 downto 0);
           AdrBus : in  STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
           ENA : in  STD_LOGIC;
           WREN : in  STD_LOGIC_VECTOR (3 downto 0);        
              CLK : in  STD_LOGIC;
           -- Second Port ( read only)
              CLKB : in STD_LOGIC;
              ENB : in STD_LOGIC;
              AdrBusB : in  STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
              DBOutB : out  STD_LOGIC_VECTOR (31 downto 0)

              );
end MainMemory;

architecture Behavioral of MainMemory is

type tRam is array (0 to SIZE) of STD_LOGIC_VECTOR (31 downto 0);



signal b0,b1,b2,b3 : STD_LOGIC_VECTOR(7 downto 0); -- bytes 


-- Design time code...
 
impure function InitFromFile  return tRam is
FILE RamFile : text is in RamFileName;
variable RamFileLine : line;
variable word : STD_LOGIC_VECTOR(31 downto 0);
variable r : tRam;

begin
  for I in tRam'range loop
    if not endfile(RamFile) then
      readline (RamFile, RamFileLine);
		if mode="H" then 
		   hread (RamFileLine, word); -- alternative: HEX read 
		else  	
        read(RamFileLine,word);  -- Binary read
      end if;		  
      
       r(I) :=  word;
     else
       r(I) := (others=>'0'); 
    end if;     
  end loop;
  return r; 
end function;

signal ram : tRam:= InitFromFile;

begin

  process(WREN,DBIn,ram,AdrBus) begin
    if wren(0) = '1' then
         b0 <= DBIn(7 downto 0);
     else
         b0 <= ram(to_integer(unsigned(AdrBus)))(7 downto 0);
    end if;     

    if wren(1) = '1' then
           b1 <= DBIn(15 downto 8);
     else
            b1 <= ram(to_integer(unsigned(AdrBus)))(15 downto 8);
    end if;      

    if wren(2) = '1' then
        b2 <= DBIn(23 downto 16);
     else
        b2 <= ram(to_integer(unsigned(AdrBus)))(23 downto 16);
    end if; 
     
    if wren(3) = '1' then
        b3 <= DBIn(31 downto 24);
     else
        b3 <= ram(to_integer(unsigned(AdrBus)))(31 downto 24);
    end if;      
  end process;
  

  process(clk) begin
    if rising_edge(clk) then 
        if ena = '1' then
          ram(to_integer(unsigned(AdrBus))) <= b3 & b2 & b1 & b0;
           DBOut <= ram(to_integer(unsigned(AdrBus)));
         end if;    
     end if;
  
  end process;
  
  process(clkb) begin
     if rising_edge(clkb) then
         if ENB='1' then
            DBOutB <= ram(to_integer(unsigned(AdrBusB)));
          end if;    
      end if;
  end process;
  
   
end Behavioral;