--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:29:26 12/18/2016
-- Design Name:   
-- Module Name:   /home/thomas/riscv/lxp32soc/tb_dramtest.vhd
-- Project Name:  wildfire
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
 
ENTITY tb_dramtest IS
END tb_dramtest;
 
ARCHITECTURE behavior OF tb_dramtest IS 
 
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
         led1 : OUT  std_logic;
         SDRAM_CLK : OUT  std_logic;
         SDRAM_CKE : OUT  std_logic;
         SDRAM_CS : OUT  std_logic;
         SDRAM_RAS : OUT  std_logic;
         SDRAM_CAS : OUT  std_logic;
         SDRAM_WE : OUT  std_logic;
         SDRAM_DQM : OUT  std_logic_vector(1 downto 0);
         SDRAM_ADDR : OUT  std_logic_vector(12 downto 0);
         SDRAM_BA : OUT  std_logic_vector(1 downto 0);
         SDRAM_DATA : INOUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    
   COMPONENT sdram_model
	PORT(
		CLK : IN std_logic;
		CKE : IN std_logic;
		CS_N : IN std_logic;
		RAS_N : IN std_logic;
		CAS_N : IN std_logic;
		WE_N : IN std_logic;
		BA : IN std_logic_vector(1 downto 0);
		DQM : IN std_logic_vector(1 downto 0);
		ADDR : IN std_logic_vector(12 downto 0);       
		DQ : INOUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;
    

   --Inputs
   signal sysclk_32m : std_logic := '0';
   signal I_RESET : std_logic := '0';
   signal uart0_rxd : std_logic := '0';

	--BiDirs
   signal SDRAM_DATA : std_logic_vector(15 downto 0);

 	--Outputs
   signal leds : std_logic_vector(3 downto 0);
   signal uart0_txd : std_logic;
   signal led1 : std_logic;
   signal SDRAM_CLK : std_logic;
   signal SDRAM_CKE : std_logic;
   signal SDRAM_CS : std_logic;
   signal SDRAM_RAS : std_logic;
   signal SDRAM_CAS : std_logic;
   signal SDRAM_WE : std_logic;
   signal SDRAM_DQM : std_logic_vector(1 downto 0);
   signal SDRAM_ADDR : std_logic_vector(12 downto 0);
   signal SDRAM_BA : std_logic_vector(1 downto 0);

   -- Clock period definitions
  constant clock_period : time := 31.25ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: papilio_pro_dram_toplevel 
   
    generic map (
        --RamFileName => "../../lxp32soc/software/wildfire/test/ledsim.hex",
        --RamFileName => "../../lxp32soc/software/wildfire/test/dram_codesim.hex",
         RamFileName => "../../lxp32soc/software/wildfire/monitor/monitor.hex",
        --RamFileName => "../../lxp32soc/software/wildfire/test/memsim.hex",
        --RamFileName => "../../lxp32soc/software/wildfire/test/sim_hello.hex",
        --RamFileName => "../../lxp32soc/riscv/software/cpptest/counter.hex",
         --RamFileName => "../../lxp32-cpu/riscv_test/branch.hex",
        --RamFileName => "../../lxp32-cpu/riscv_test/trap01.hex",
        --RamFileName => "../../lxp32-cpu/riscv_test/mult.hex",
        mode=>"H",
        FakeDRAM=>false,
        Swapbytes=>false
     )     
   
   
   PORT MAP (
          sysclk_32m => sysclk_32m,
          I_RESET => I_RESET,
          leds => leds,
          uart0_txd => uart0_txd,
          uart0_rxd => uart0_rxd,
          led1 => led1,
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
        
        
  Inst_sdram_model: sdram_model 
    PORT MAP(
		CLK => SDRAM_CLK,
		CKE => SDRAM_CKE,
		CS_N => SDRAM_CS,
		RAS_N => SDRAM_RAS,
		CAS_N => SDRAM_CAS,
		WE_N => SDRAM_WE,
		BA => SDRAM_BA,
		DQM => SDRAM_DQM,
		ADDR => SDRAM_ADDR,
		DQ => SDRAM_DATA
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
