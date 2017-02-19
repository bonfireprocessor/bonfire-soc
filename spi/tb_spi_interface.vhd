--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:47:34 02/18/2017
-- Design Name:   
-- Module Name:   /home/thomas/riscv/lxp32soc/spi/tb_spi_interface.vhd
-- Project Name:  bonfire
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: wb_spi_interface
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
USE ieee.numeric_std.ALL;
 
ENTITY tb_spi_interface IS
END tb_spi_interface;
 
ARCHITECTURE behavior OF tb_spi_interface IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT wb_spi_interface
    PORT(
         clk_i : IN  std_logic;
         reset_i : IN  std_logic;
         slave_cs_o : OUT  std_logic;
         slave_clk_o : OUT  std_logic;
         slave_mosi_o : OUT  std_logic;
         slave_miso_i : IN  std_logic;
         irq : OUT  std_logic;
         wb_adr_in : IN  std_logic_vector(7 downto 0);
         wb_dat_in : IN  std_logic_vector(7 downto 0);
         wb_dat_out : OUT  std_logic_vector(7 downto 0);
         wb_we_in : IN  std_logic;
         wb_cyc_in : IN  std_logic;
         wb_stb_in : IN  std_logic;
         wb_ack_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal reset_i : std_logic := '0';
   signal slave_miso_i : std_logic := '0';
   signal wb_adr_in : std_logic_vector(7 downto 0) := (others => '0');
   signal wb_dat_in : std_logic_vector(7 downto 0) := (others => '0');
   signal wb_we_in : std_logic := '0';
   signal wb_cyc_in : std_logic := '0';
   signal wb_stb_in : std_logic := '0';

 	--Outputs
   signal slave_cs_o : std_logic;
   signal slave_clk_o : std_logic;
   signal slave_mosi_o : std_logic;
   signal irq : std_logic;
   signal wb_dat_out : std_logic_vector(7 downto 0);
   signal wb_ack_out : std_logic;
   

   -- Clock period definitions
   constant clk_i_period : time := 10 ns;
 
BEGIN
 
  slave_miso_i <= slave_mosi_o; -- loop back
 
	-- Instantiate the Unit Under Test (UUT)
   uut: wb_spi_interface PORT MAP (
          clk_i => clk_i,
          reset_i => reset_i,
          slave_cs_o => slave_cs_o,
          slave_clk_o => slave_clk_o,
          slave_mosi_o => slave_mosi_o,
          slave_miso_i => slave_miso_i,
          irq => irq,
          wb_adr_in => wb_adr_in,
          wb_dat_in => wb_dat_in,
          wb_dat_out => wb_dat_out,
          wb_we_in => wb_we_in,
          wb_cyc_in => wb_cyc_in,
          wb_stb_in => wb_stb_in,
          wb_ack_out => wb_ack_out
        );

   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '0';
		wait for clk_i_period/2;
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   variable d,t : std_logic_vector(7 downto 0);
   procedure wb_write(address : in std_logic_vector(7 downto 0); data : in std_logic_vector(7 downto 0)) is
		begin
			wb_adr_in <= address;
         wait until rising_edge(clk_i);
			wb_dat_in <= data;
			wb_we_in <= '1';
			wb_cyc_in <= '1';
			wb_stb_in <= '1';

			wait until wb_ack_out = '1';
			wait  until rising_edge(clk_i);
			wb_stb_in <= '0';
			wb_cyc_in <= '0';
			
		end procedure;
      
      procedure wb_read(address : in std_logic_vector(7 downto 0);
                          data: out std_logic_vector(7 downto 0) )  is
		begin
			wb_adr_in <= address;
         wait until rising_edge(clk_i);
			wb_we_in <= '1';
			wb_cyc_in <= '1';
			wb_stb_in <= '1';
         wb_we_in <= '0';
			wait until wb_ack_out = '1';
			data:= wb_dat_out;
         wait until rising_edge(clk_i);
			wb_stb_in <= '0';
			wb_cyc_in <= '0';
		   --wait for clk_period;
		end procedure;
   
   
   
   
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_i_period*10;

      wb_write(X"10",X"01"); -- Clock Diviider
      wb_write(X"00",X"FE"); -- Chip Select
      -- send 10 bytes
      for i in 0 to 255 loop
        t:=std_logic_vector(to_unsigned(i,t'length));
        wb_write(X"08",t);
        wb_read(X"0C",d);
        if d /= t then
          report "Failure";
          wait;
        end if;
        
      end loop;  
      report "Success";

      wait;
   end process;

END;
