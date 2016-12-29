----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:51:06 12/18/2016 
-- Design Name: 
-- Module Name:    wbs_sdram_interface - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.util.all;

entity wbs_sdram_interface is
generic (
   wbs_adr_high : natural := 27;  
   sdram_address_width : natural := 22;
   sdram_column_bits   : natural := 8;
   sdram_startup_cycles: natural := 10100; -- 100us, plus a little more
   cycles_per_refresh  : natural := (64000*100)/4196-1;
   wbs_burst_length : natural := 4 -- length of wishbone burst cylces
);     

port(
		clk_i: in std_logic;
		rst_i: in std_logic;
		
		wbs_cyc_i: in std_logic;
		wbs_stb_i: in std_logic;
		wbs_we_i: in std_logic;
		wbs_sel_i: in std_logic_vector(3 downto 0);
		wbs_ack_o: out std_logic;
		wbs_adr_i: in std_logic_vector(wbs_adr_high downto 2);
		wbs_dat_i: in std_logic_vector(31 downto 0);
		wbs_dat_o: out std_logic_vector(31 downto 0);
      wbs_cti_i: in std_logic_vector(2 downto 0);
      
      
     -- SDRAM signals
      SDRAM_CLK     : out   STD_LOGIC;
      SDRAM_CKE     : out   STD_LOGIC;
      SDRAM_CS      : out   STD_LOGIC;
      SDRAM_RAS     : out   STD_LOGIC;
      SDRAM_CAS     : out   STD_LOGIC;
      SDRAM_WE      : out   STD_LOGIC;
      SDRAM_DQM     : out   STD_LOGIC_VECTOR( 1 downto 0);
      SDRAM_ADDR    : out   STD_LOGIC_VECTOR(12 downto 0);
      SDRAM_BA      : out   STD_LOGIC_VECTOR( 1 downto 0);
      SDRAM_DATA    : inout STD_LOGIC_VECTOR(15 downto 0)
		
	);
   
end wbs_sdram_interface;

architecture Behavioral of wbs_sdram_interface is

 -- signals to interface with the memory controller
   signal cmd_address     : std_logic_vector(sdram_address_width-2 downto 0);
   signal cmd_wr          : std_logic;
   signal cmd_enable      : std_logic;
   signal cmd_byte_enable : std_logic_vector(3 downto 0);
   signal cmd_data_in     : std_logic_vector(31 downto 0);
   signal cmd_ready       : std_logic;
   signal data_out        : std_logic_vector(31 downto 0);
   signal data_out_ready   : std_logic;
   signal read_pending   : std_logic := '0';
   
   
   signal ram_adr : std_logic_vector(sdram_address_width-2 downto 0);   
   signal is_read : std_logic;
   
-- Wishbone Burst mode support   
   signal burst : std_logic := '0'; -- Wishbone burst active
   signal burstfetch_enable : std_logic;  -- prefetching enable in burst
   signal adr_reg : std_logic_vector(sdram_address_width-2 downto 0); -- for Burst mode support
   signal burst_counter : unsigned(log2(wbs_burst_length)-1 downto 0) := (others=>'0');
   signal pending_read_counter : unsigned(log2(wbs_burst_length)-1 downto 0) := (others=>'0');


begin

Inst_SDRAM_Controller: entity work.SDRAM_Controller
generic map (
   sdram_address_width =>sdram_address_width,
   sdram_column_bits =>  sdram_column_bits,
   sdram_startup_cycles => sdram_startup_cycles,
   cycles_per_refresh  => cycles_per_refresh
)

 PORT MAP(
		clk => clk_i,
		reset => rst_i,
		cmd_ready => cmd_ready,
		cmd_enable =>cmd_enable ,
		cmd_wr => cmd_wr,
		cmd_address => cmd_address,
		cmd_byte_enable =>cmd_byte_enable ,
		cmd_data_in => cmd_data_in,
		data_out => data_out,
		data_out_ready =>data_out_ready ,
		SDRAM_CLK => SDRAM_CLK,
		SDRAM_CKE => SDRAM_CKE,
		SDRAM_CS => SDRAM_CS,
		SDRAM_RAS => SDRAM_RAS,
		SDRAM_CAS => SDRAM_CAS,
		SDRAM_WE => SDRAM_WE,
		SDRAM_DQM => SDRAM_DQM,
		SDRAM_ADDR => SDRAM_ADDR,
		SDRAM_BA => SDRAM_BA,
		SDRAM_DATA => SDRAM_DATA
	);
  
    
   
   ram_adr <= wbs_adr_i(cmd_address'high+2 downto 2);
   
   cmd_byte_enable <= wbs_sel_i;
   cmd_wr <= wbs_we_i;
   cmd_enable <= wbs_cyc_i and wbs_stb_i and (not read_pending or burstfetch_enable);
   
   cmd_data_in <= wbs_dat_i;
   wbs_dat_o <= data_out;
  
   
   wbs_ack_o <= (wbs_stb_i and wbs_we_i and cmd_ready) -- Immediatly ack write
                or (wbs_stb_i and read_pending and data_out_ready); -- Ack read when data ready     
   
   
   is_read <= wbs_cyc_i and wbs_stb_i and not wbs_we_i;
   
   
   
     -- adr multiplexer
   process(ram_adr,adr_reg,is_read,burst,wbs_cti_i) is
   begin
     if is_read='1' and burst='1' and (wbs_cti_i="010" or wbs_cti_i="111") then
       cmd_address <=  adr_reg;
     else
       cmd_address <=  ram_adr;   
     end if;        
   end process;
   
   
   
   -- Burst Mode support
   
   process(burst,burst_counter) 
   begin
     if burst='1' and (burst_counter /= 0) then
       burstfetch_enable <= '1';
     else 
       burstfetch_enable <= '0';
     end if;       
   end process;
   

   process(clk_i) is
   begin
     if rising_edge(clk_i) then  
        if rst_i = '1' then
          burst <= '0';
        elsif is_read='1' and wbs_cti_i="010" then  -- burst cycle ??
          if read_pending='0' then -- begin of new cycle
            burst <= '1';
            adr_reg <= std_logic_vector(unsigned(ram_adr)+1);  
            burst_counter <= to_unsigned(wbs_burst_length-1,burst_counter'length);
          end if;
          if burstfetch_enable='1' and cmd_ready='1'  then
             adr_reg <= std_logic_vector(unsigned(adr_reg)+1); 
             burst_counter <= burst_counter - 1; 
          end if;             
        elsif  wbs_stb_i='0' or  wbs_cti_i="111" then
          burst <= '0';        
        end if;
	  end if;
   end process;
   
   
   -- Pending read counter 
  process(clk_i) is
  variable next_counter : unsigned(pending_read_counter'high downto 0);
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        next_counter := to_unsigned(0,pending_read_counter'length);
        read_pending <= '0';
      else
        if is_read='1' and cmd_ready='1' and cmd_enable='1' then
          next_counter := pending_read_counter + 1;
          read_pending <= '1';
        end if;  
        if read_pending = '1' and data_out_ready = '1' then 
          next_counter := next_counter - 1;
          if next_counter = 0 then
            read_pending <= '0';
          end if;  
        end if;  
      end if;  
      pending_read_counter <= next_counter;
    end if;
  end process;
   
      
   
end Behavioral;

