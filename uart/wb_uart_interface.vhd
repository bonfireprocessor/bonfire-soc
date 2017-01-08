----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:42:56 01/07/2017 
-- Design Name: 
-- Module Name:    wb_uart_interface - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 

--! The following registers are defined:
--! |--------------------|--------------------------------------------|
--! | Address            | Description                                |
--! |--------------------|--------------------------------------------|
--! | 0x00               | Transmit register (write-only)             |
--! | 0x04               | Receive register (read-only)               |
--! | 0x08               | Status register (read-only)                |
--! | 0x0c               | Sample clock divisor register (read/write) |
--! | 0x10               | Interrupt enable register (read/write)     |
--! | 0x14               | Revision Code                              |
--! |--------------------|--------------------------------------------|
--!
--! The status register contains the following bits:
--! - Bit 0: receive buffer empty
--! - Bit 1: transmiter idle
--! - Bit 2: receive buffer full
--! - Bit 3: transmit buffer full

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

use work.util.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity wb_uart_interface is
generic(
      FIFO_DEPTH : natural := 64; --! Depth of the input FIFO
      CLK_FREQUENCY : natural := (96 * 1000000)
      
   );
   port(
      clk : in std_logic;
      reset : in std_logic;

      -- UART ports:
      txd : out std_logic;
      rxd : in  std_logic;

      -- Interrupt signal:
      irq : out std_logic;

      -- Wishbone ports:
      wb_adr_in  : in  std_logic_vector(7 downto 0);
      wb_dat_in  : in  std_logic_vector( 7 downto 0);
      wb_dat_out : out std_logic_vector( 7 downto 0);
      wb_we_in   : in  std_logic;
      wb_cyc_in  : in  std_logic;
      wb_stb_in  : in  std_logic;
      wb_ack_out : out std_logic 
    );  
end wb_uart_interface;

architecture Behavioral of wb_uart_interface is

   constant uart_revsion : std_logic_vector(7 downto 0) :=X"12";

  --  signal uart_data_in         : std_logic_vector(7 downto 0);
    signal uart_data_out        : std_logic_vector(7 downto 0);
    signal fifo_data_out        : std_logic_vector(7 downto 0);
    signal fifo_data_ready      : std_logic;
    signal uart_rx_ready        : std_logic;
    signal uart_tx_busy         : std_logic;
    signal uart_badbit          : std_logic;
    signal uart_data_load       : std_logic;
    signal fifo_data_ack        : std_logic;
    signal fifo_nearly_full     : std_logic;
    signal can_transmit         : std_logic :='1'; -- constant value at the moment
    signal status_register, 
           sample_clk_divisor_register,
           transmit_register    : std_logic_vector(7 downto 0);
    signal interrupt_register   : std_logic_vector(1 downto 0); 
           
    signal wb_read_buffer :  std_logic_vector(7 downto 0); -- register for wishbone reads      
    signal ack_read : std_logic :='0';
    
    signal tx_reg_pending : std_logic :='0';  -- Indicates that data is loaded into tx register 
    
    signal divisor_wen : std_logic :='0';
    
    

begin

    wb_dat_out <= wb_read_buffer;
    wb_ack_out <= ack_read or (wb_we_in and wb_stb_in);
    
    -- assert uart_data_load only when uart is not busy anymore, so we know that data will be taken by the UART on the next clock
    uart_data_load <= tx_reg_pending and not uart_tx_busy;
   
   
    process(ack_read,wb_adr_in) 
    begin
      if ack_read='1' and  wb_adr_in(4 downto 2)="001" then
        fifo_data_ack<='1';
      else
        fifo_data_ack<='0';
      end if;
    end process;      
    
    -- Read register assignments
   
   -- - Bit 0: receive buffer empty
   -- - Bit 1: transmitter idle
   -- - Bit 2: receive buffer full 
   -- - Bit 3: transmit buffer full
  
   
   status_register<= "0000" &  tx_reg_pending & fifo_nearly_full & not uart_tx_busy  & not fifo_data_ready;     
    
    
    -- we do registered read to not induce combinatorial complexity to the wishbone bus
    -- for a slow device like an UART it does not care that this will create an additonal clock of latency
    
    process(clk) begin
    
      if rising_edge(clk) then
      
           if ack_read='1' then
             ack_read<='0';
           end if;   
           
           -- see above
           if uart_data_load='1' then
             tx_reg_pending <= '0';
           end if;  
           
           if divisor_wen='1' then
             divisor_wen <= '0';
           end if;  
        
           if wb_cyc_in ='1' and wb_stb_in='1' then
             if wb_we_in='0' and ack_read='0' then -- read access
                -- Wishbone Read Multiplexer
                -- Address bits 1..0 don't care 
               case wb_adr_in(4 downto 2) is
                  when  "001"  => -- Addr 0x4  UART receive register 
                    wb_read_buffer <= fifo_data_out;
                  when  "010"  => -- Addr 0x8
                    wb_read_buffer <= status_register;
                  when  "011"   =>  -- Addr 0xC
                    wb_read_buffer <= sample_clk_divisor_register;
                  when  "100"   => -- Addr 0x10
                    wb_read_buffer <= "000000"&interrupt_register;
                  when  "101"   => -- Addr 0x14
                     wb_read_buffer <= uart_revsion;
                  when others  => -- others don't care...
                    wb_read_buffer <=  (others => 'X'); 
               end case;
               ack_read <='1'; 
             elsif wb_we_in='1'  then
               case wb_adr_in(4 downto 2) is
                 when "000" => -- Adr 0x0 transmit register 
                   transmit_register <= wb_dat_in;
                   tx_reg_pending<='1';
                 when  "011"   =>-- Addr 0xC 
                   sample_clk_divisor_register <= wb_dat_in;
                   divisor_wen <= '1';
                 when  "100"   => -- Addr 0x10
                   interrupt_register <=  wb_dat_in(1 downto 0);
                 when others => -- do nothing  
               end case; 
             end if;              
           end if;
      end if;
    
    end process;
    

fifo_instance: entity work.fifo
    generic map (
       depth_log2 => log2(FIFO_DEPTH)
    )
    PORT MAP(
        clk => clk,
        reset => reset,
        data_in => uart_data_out,
        data_out => fifo_data_out,
        read_ready => fifo_data_ready,
        read_en => fifo_data_ack,
        write_ready => open,
        write_en => uart_rx_ready,
        high_water_mark => fifo_nearly_full
    );

    uart_instance: entity work.uart 
    GENERIC MAP(
        CLK_FREQUENCY => CLK_FREQUENCY
    )
    PORT MAP(
        clk => clk,
        serial_out => txd,
        serial_in => rxd,
        data_in => transmit_register,
        data_in_load => uart_data_load,
        data_out => uart_data_out,
        data_out_ready => uart_rx_ready,
        bad_bit => uart_badbit,
        transmitter_busy => uart_tx_busy,
        can_transmit => can_transmit,
        sample_clock_divisor => sample_clk_divisor_register,
        divisor_wen => divisor_wen
    );


end Behavioral;

