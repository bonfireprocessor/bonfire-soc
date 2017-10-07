--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:21:25 12/06/2016
-- Design Name:   
-- Module Name:   /home/thomas/riscv/lxp32soc/tb_papro.vhd
-- Project Name:  lxp32riscv
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: papilio_pro_dram_toplevel
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
 
ENTITY tb_papro IS
END tb_papro;
 
ARCHITECTURE behavior OF tb_papro IS 
 
   -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT papilio_pro_dram_toplevel
     generic (
     -- generics are set by the simulator only, when instaniating from a testbench
     -- when Design is physically build than the defaults are used
     RamFileName : string;-- only used when UseBRAMPrimitives is false
	  mode : string;       -- only used when UseBRAMPrimitives is false
     Swapbytes : boolean := true; -- SWAP Bytes in RAM word in low byte first order to use data2mem
     FakeDRAM : boolean := false -- Use Block RAM instead of DRAM
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
   signal uart0_rxd : std_logic := '1';

 	--Outputs
   signal leds : std_logic_vector(3 downto 0);
   signal uart0_txd : std_logic;
   signal led1 : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant clock_period : time := 31.25ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: papilio_pro_dram_toplevel 
     generic map (
        --RamFileName => "../../lxp32soc/software/wildfire/test/ledsim.hex",
        RamFileName => "../../lxp32soc/software/wildfire/test/memsim.hex",
        --RamFileName => "../../lxp32soc/software/wildfire/test/sim_hello.hex",
        --RamFileName => "../../lxp32soc/riscv/software/cpptest/counter.hex",
         --RamFileName => "../../lxp32-cpu/riscv_test/branch.hex",
        --RamFileName => "../../lxp32-cpu/riscv_test/trap01.hex",
        --RamFileName => "../../lxp32-cpu/riscv_test/mult.hex",
        mode=>"H",
        FakeDRAM=>true,
        Swapbytes=>false
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
