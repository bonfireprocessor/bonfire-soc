----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:54:55 10/16/2016 
-- Design Name: 
-- Module Name:    MainMemorySpartan6 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.util.all;


entity MainMemorySpartan6 is
  generic (
             NUMBANKS: natural:=1 -- number of RAM16B Banks, each Bank has 4*2K*8 BRAMS
             
            );
    Port ( DBOut : out  STD_LOGIC_VECTOR (31 downto 0);
           DBIn : in  STD_LOGIC_VECTOR (31 downto 0);
           AdrBus : in  STD_LOGIC_VECTOR (10+log2(NUMBANKS) downto 0);
           ENA : in  STD_LOGIC;
           WREN : in  STD_LOGIC_VECTOR (3 downto 0);        
           CLK : in  STD_LOGIC;
           -- Second Port ( read only)
           CLKB : in STD_LOGIC;
           ENB : in STD_LOGIC;
           AdrBusB : in  STD_LOGIC_VECTOR (10+log2(NUMBANKS) downto 0);
           DBOutB : out  STD_LOGIC_VECTOR (31 downto 0)

              );
end MainMemorySpartan6;

architecture Behavioral of MainMemorySpartan6 is

subtype word is STD_LOGIC_VECTOR (31 downto 0);

type tBusMux is array (0 to NUMBANKS-1) of  STD_LOGIC_VECTOR (31 downto 0);

signal ena_v,enb_v : std_logic_vector (NUMBANKS-1 downto 0);
signal upper_adr_a,upper_adr_b : std_logic_vector   (log2(NUMBANKS)-1 downto 0);

signal BusMuxA,BusMuxB : tBusMux;


   COMPONENT ram2048x8
	PORT(
		DInA : IN std_logic_vector(7 downto 0);
		AdrA : IN std_logic_vector(10 downto 0);
		ENA : IN std_logic;
		WRENA : IN std_logic;
		CLKA : IN std_logic;
		AdrB : IN std_logic_vector(10 downto 0);
		ENB : IN std_logic;
		CLKB : IN std_logic;          
		DOutA : OUT std_logic_vector(7 downto 0);
		DoutB : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

begin
  
  upper_adr_a <= AdrBus(AdrBus'length-1 downto 11);
  upper_adr_b <= AdrBusB(AdrBusB'length-1 downto 11);
  
   genmem: for i in 0 to NUMBANKS-1 generate
    
   begin 

     Inst_ram2048x8_0: ram2048x8 PORT MAP(
		DOutA => BusMuxA(i)(7 downto 0),
		DInA =>  DBIn(7 downto 0),
		AdrA =>  AdrBus(10 downto 0),
		ENA => ena_v(i),
		WRENA => wren(0),
		CLKA => clk,
		DoutB =>  BusMuxB(i)(7 downto 0),
		AdrB => AdrBusB(10 downto 0),
		ENB => enb_v(i),
		CLKB => clkb
	  );
     
     Inst_ram2048x8_1: ram2048x8 PORT MAP(
		DOutA => BusMuxA(i)(15 downto 8),
		DInA =>  DBIn(15 downto 8),
		AdrA =>  AdrBus(10 downto 0),
		ENA => ena_v(i),
		WRENA => wren(1),
		CLKA => clk,
		DoutB =>  BusMuxB(i)(15 downto 8),
		AdrB => AdrBusB(10 downto 0),
		ENB => enb_v(i),
		CLKB => clkb
	  );
     Inst_ram2048x8_2: ram2048x8 PORT MAP(
		DOutA => BusMuxA(i)(23 downto 16),
		DInA =>  DBIn(23 downto 16),
		AdrA =>  AdrBus(10 downto 0),
		ENA => ena_v(i),
		WRENA => wren(2),
		CLKA => clk,
		DoutB =>  BusMuxB(i)(23 downto 16),
		AdrB => AdrBusB(10 downto 0),
		ENB => enb_v(i),
		CLKB => clkb
	  );
     Inst_ram2048x8_3: ram2048x8 PORT MAP(
		DOutA => BusMuxA(i)(31 downto 24),
		DInA =>  DBIn(31 downto 24),
		AdrA =>  AdrBus(10 downto 0),
		ENA => ena_v(i),
		WRENA => wren(3),
		CLKA => clk,
		DoutB =>  BusMuxB(i)(31 downto 24),
		AdrB => AdrBusB(10 downto 0),
		ENB => enb_v(i),
		CLKB => clkb
	  );
     
       
   end generate;

   MuxA: process(upper_adr_a,ena,BusMuxA) 
   variable env: std_logic_vector (NUMBANKS-1 downto 0);
   variable mux: std_logic_vector(31 downto 0);  
   begin
       mux:=(others=>'0');
       for i in 0 to NUMBANKS-1 loop
          if upper_adr_a=CONV_STD_LOGIC_VECTOR(i,upper_adr_a'length) and ena='1' then
            env(i):='1';
          else 
             env(i):='0';            
          end if;
          for k in DBOut'range  loop
            mux(k) := mux(k) or (BusMuxA(i)(k) and env(i));
          end loop;  
       end loop;
       
       ena_v<=env;
       DBOut<=mux;
   end process;
   
   
   MuxB: process(upper_adr_b,enb,BusMuxB) 
   variable env: std_logic_vector (NUMBANKS-1 downto 0);
   variable mux: std_logic_vector(31 downto 0);  
   begin
       mux:=(others=>'0');
       for i in 0 to NUMBANKS-1 loop
          if upper_adr_b=CONV_STD_LOGIC_VECTOR(i,upper_adr_b'length) and enb='1' then
            env(i):='1';
          else 
             env(i):='0';            
          end if;
          for k in DBOut'range  loop
            mux(k) := mux(k) or (BusMuxB(i)(k) and env(i));
          end loop;  
       end loop;
       
       enb_v<=env;
       DBOutB<=mux;
   end process;
   
   
   
end Behavioral;

