--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:33:00 09/05/2016
-- Design Name:   
-- Module Name:   C:/daten/development/fpga/lxp32proj/lxp32_soc/tb_soc.vhd
-- Project Name:  lxp32_01
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: toplevel
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_soc IS
END tb_soc;
 
ARCHITECTURE behavior OF tb_soc IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT toplevel
     generic (
     -- generics are set by the simulator only, when instaniating from a testbench
     -- when Design is physically build than the defaults are used
     UseBRAMPrimitives : boolean; -- Synthesize Boot RAM with BRAM primitives for Data2Mem tool
     RamFileName : string;-- only used when UseBRAMPrimitives is false
	  mode : string       -- only used when UseBRAMPrimitives is false
     );
    PORT(
         sysclk_32m : IN  std_logic;
         I_RESET : IN  std_logic;
         leds : OUT  std_logic_vector(3 downto 0);
         uart0_txd : OUT  std_logic;
         uart0_rxd : IN  std_logic;
         led1 : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal sysclk_32m : std_logic := '0';
   signal I_RESET : std_logic := '0';
   signal uart0_rxd : std_logic := '0';

 	--Outputs
   signal leds : std_logic_vector(3 downto 0);
   signal uart0_txd : std_logic;
   signal led1 : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant clock_period : time := 31.25ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: toplevel 
     generic map (
        UseBRAMPrimitives => false,
        RamFileName => "../../lxp32soc/riscv/software/cpptest/uart.hex",
        mode=>"H"
     )     
   
     PORT MAP (
          sysclk_32m => sysclk_32m,
          I_RESET => I_RESET,
          leds => leds,
          uart0_txd => uart0_txd,
          uart0_rxd => uart0_rxd,
          led1 => led1
        );

   -- Clock process definitions
   clock_process :process
   begin
		sysclk_32m <= '0';
		wait for clock_period/2;
		sysclk_32m <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

     

      -- insert stimulus here 

      wait;
   end process;

END;
