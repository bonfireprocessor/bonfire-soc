--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   23:29:26 12/18/2016
-- Design Name:
-- Module Name:   tb_dramtest.vhd
-- Project Name:  bonfire
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: papilio_pro_dram_toplevel

--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY tb_dramtest IS
generic (
     RamFileName : string := "../src/bonfire-soc_0/compiled_code/monitor.hex";
     mode : string := "H";       -- only used when UseBRAMPrimitives is false
     Swapbytes : boolean := true; -- SWAP Bytes in RAM word in low byte first order to use data2mem
     FakeDRAM : boolean := false; -- Use Block RAM instead of DRAM
     InstructionBurstSize : natural := 8;
     CacheSizeWords : natural := 4096; -- 16KB Instruction Cache
     EnableDCache : boolean := true;
     DCacheSizeWords : natural := 2048
   );
END tb_dramtest;

ARCHITECTURE behavior OF tb_dramtest IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT papilio_pro_dram_toplevel
     generic (

     RamFileName : string;
     mode : string;
     Swapbytes : boolean := true;
     FakeDRAM : boolean := false;
     InstructionBurstSize : natural := 8;

     CacheSizeWords : natural := 2048; -- 8KB Instruction Cache
     EnableDCache : boolean := true;
     DCacheSizeWords : natural := 2048
     );
    PORT(
        sysclk_32m : IN std_logic;
        I_RESET : IN std_logic;
        uart0_rxd : IN std_logic;
        flash_spi_miso : IN std_logic;
        SDRAM_DATA : INOUT std_logic_vector(15 downto 0);
        leds : OUT std_logic_vector(3 downto 0);
        uart0_txd : OUT std_logic;
        flash_spi_cs : OUT std_logic;
        flash_spi_clk : OUT std_logic;
        flash_spi_mosi : OUT std_logic;
        led1 : OUT std_logic;
        SDRAM_CLK : OUT std_logic;
        SDRAM_CKE : OUT std_logic;
        SDRAM_CS : OUT std_logic;
        SDRAM_RAS : OUT std_logic;
        SDRAM_CAS : OUT std_logic;
        SDRAM_WE : OUT std_logic;
        SDRAM_DQM : OUT std_logic_vector(1 downto 0);
        SDRAM_ADDR : OUT std_logic_vector(12 downto 0);
        SDRAM_BA : OUT std_logic_vector(1 downto 0)
        );
    END COMPONENT;

   COMPONENT sdram_model
   GENERIC (
     mode : string := "N" -- no init file
   );
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

   signal flash_spi_cs,flash_spi_clk,flash_spi_loopback : std_logic;

   -- Clock period definitions
  constant clock_period : time := 31.25ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
   uut: papilio_pro_dram_toplevel

    generic map (

        RamFileName => RamFileName,

        mode=>mode,
        FakeDRAM=>FakeDRAM,
        Swapbytes=>Swapbytes,
        CacheSizeWords => CacheSizeWords,
        InstructionBurstSize =>InstructionBurstSize,
        EnableDCache => EnableDCache,
        DCacheSizeWords=>DCacheSizeWords

     )


   PORT MAP (
          sysclk_32m => sysclk_32m,
          I_RESET => I_RESET,
          leds => leds,
          uart0_txd => uart0_txd,
          uart0_rxd => uart0_rxd,
          led1 => led1,
          flash_spi_cs =>flash_spi_cs ,
            flash_spi_clk => flash_spi_clk,
            flash_spi_mosi => flash_spi_loopback,
            flash_spi_miso => flash_spi_loopback,

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
    GENERIC MAP (
       mode=>"N" -- no init file
    )
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
