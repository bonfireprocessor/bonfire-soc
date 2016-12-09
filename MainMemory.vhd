
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
             SIZE : integer;
             Swapbytes : boolean -- SWAP Bytes in RAM word in low byte first order to use data2mem  
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
subtype tWord is std_logic_vector(31 downto 0);


signal b0,b1,b2,b3 : STD_LOGIC_VECTOR(7 downto 0); -- bytes 

signal DOA,DOB,DIA : tWord;
signal WEA : STD_LOGIC_VECTOR (3 downto 0);  


function doSwapBytes(d : tWord) return tWord is
begin
  
    return d(7 downto 0)&d(15 downto 8)&d(23 downto 16)&d(31 downto 24);
  
end;


-- Design time code...
 
impure function InitFromFile  return tRam is
FILE RamFile : text is in RamFileName;
variable RamFileLine : line;
variable word : tWord;
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
       if SwapBytes then 
         r(I) :=  DoSwapBytes(word);
       else
         r(I) := word;
       end if;         
     else
       r(I) := (others=>'0'); 
    end if;     
  end loop;
  return r; 
end function;

signal ram : tRam:= InitFromFile;




begin
   swap: if SwapBytes generate
     DIA<=DoSwapBytes(DBIn);
     DBOut<=DoSwapBytes(DOA);
     DBOutB<=DoSwapBytes(DOB);
     WEA(0)<=WREN(3);
     WEA(1)<=WREN(2);
     WEA(2)<=WREN(1);
     WEA(3)<=WREN(0);
     
   end generate;   

   noswap: if not SwapBytes generate
     DIA<=DBIn;
     DBOut<=DOA;
     DBOutB<=DOB;
     WEA<=WREN;
   end generate;   



  process(WEA,DIA,ram,AdrBus) 
  
  
  begin
    if WEA(0) = '1' then
         b0 <= DIA(7 downto 0);
     else
         b0 <= ram(to_integer(unsigned(AdrBus)))(7 downto 0);
    end if;     

    if WEA(1) = '1' then
           b1 <= DIA(15 downto 8);
     else
            b1 <= ram(to_integer(unsigned(AdrBus)))(15 downto 8);
    end if;      

    if WEA(2) = '1' then
        b2 <= DIA(23 downto 16);
     else
        b2 <= ram(to_integer(unsigned(AdrBus)))(23 downto 16);
    end if; 
     
    if WEA(3) = '1' then
        b3 <= DIA(31 downto 24);
     else
        b3 <= ram(to_integer(unsigned(AdrBus)))(31 downto 24);
    end if;      
  end process;
  

  process(clk) 
  begin
    if rising_edge(clk) then 
        if ena = '1' then         
           ram(to_integer(unsigned(AdrBus))) <= b3 & b2 & b1 & b0;                      
           DOA <= ram(to_integer(unsigned(AdrBus)));
         end if;    
     end if;
  
  end process;
  
  process(clkb) begin
     if rising_edge(clkb) then
         if ENB='1' then
            DOB <= ram(to_integer(unsigned(AdrBusB)));
          end if;    
      end if;
  end process;
  
   
end Behavioral;