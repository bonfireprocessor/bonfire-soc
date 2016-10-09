----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:39:44 09/04/2016 
-- Design Name: 
-- Module Name:    toplevel - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity toplevel is
   port(
        sysclk_32m  : in  std_logic;
        I_RESET   : in  std_logic;

        -- GPIOs:
        -- 4x LEDs                  
        leds : out   std_logic_vector(3 downto 0);


        -- UART0 signals:
        uart0_txd : out std_logic;
        uart0_rxd : in  std_logic :='1';
        
        -- LED on Papilio Pro Board
        led1 : out std_logic

        -- UART1 signals:
        --uart1_txd : out std_logic;
        --uart1_rxd : in  std_logic
    );
    
end toplevel;

architecture Behavioral of toplevel is
 
 constant ram_adr_width : natural := 12;
 constant ram_size : natural := 4096;
 
 
signal clk32Mhz,   -- buffered osc clock
       clk : std_logic;  -- logical CPU clock
         
signal reset,res1  : std_logic;

-- Instruction Bus
signal  ib_data : std_logic_vector(31 downto 0);
signal  ib_busy,ib_rden : std_logic;
signal  ib_adr : std_logic_vector(29 downto 0);  

-- Data Bus Master 
signal  dbus_cyc_o :  std_logic;
signal  dbus_stb_o :  std_logic;
signal  dbus_we_o :  std_logic;
signal  dbus_sel_o :  std_logic_vector(3 downto 0);
signal  dbus_adr_o :  std_logic_vector(31 downto 2);
signal  dbus_dat_o :  std_logic_vector(31 downto 0);
signal  dbus_ack_i :  std_logic;
signal  dbus_dat_i :  std_logic_vector(31 downto 0);

-- Slaves
constant slave_adr_high : natural := 27;
-- Memory bus
signal mem_cyc,mem_stb,mem_we,mem_ack : std_logic;
signal mem_sel :  std_logic_vector(3 downto 0);
signal mem_dat_rd,mem_dat_wr : std_logic_vector(31 downto 0);
signal mem_adr : std_logic_vector(27 downto 2);

-- gpio bus
signal gpio_cyc,gpio_stb,gpio_we,gpio_ack : std_logic;
signal gpio_sel :  std_logic_vector(3 downto 0);
signal gpio_dat_rd,gpio_dat_wr : std_logic_vector(31 downto 0);
signal gpio_adr : std_logic_vector(27 downto 2);


-- lpc bus
signal lpc_cyc,lpc_stb,lpc_stb0, lpc_we,lpc_ack : std_logic;
signal lpc_sel :  std_logic_vector(3 downto 0);
signal lpc_dat_rd,lpc_dat_wr : std_logic_vector(31 downto 0);
signal lpc_adr : std_logic_vector(27 downto 2);

signal lpcio_adr : std_logic_vector(27 downto 0);
signal lpc_dat_rd8, lpc_dat_wr8 : std_logic_vector(7 downto 0);

-- lpc slaves 
-- uart bus
signal uart_cyc,uart_stb,uart_we,uart_ack : std_logic;
signal uart_sel :  std_logic_vector(3 downto 0);
signal uart_dat_rd,uart_dat_wr : std_logic_vector(7 downto 0);
signal uart_adr : std_logic_vector(7 downto 0);
         
signal irq_i : std_logic_vector(7 downto 0);



begin
 
   irq_i <= (others=>'0'); -- currently no interrupts
   led1<='1';	
    
    

    Inst_lxp32u_top: entity work.lxp32u_top 
	 generic map (
	    USE_RISCV => true
	 )

	 PORT MAP(
        clk_i => clk,
        rst_i => reset,
        lli_re_o => ib_rden,
        lli_adr_o =>ib_adr ,
        lli_dat_i => ib_data,
        lli_busy_i => ib_busy,
        dbus_cyc_o => dbus_cyc_o,
        dbus_stb_o => dbus_stb_o,
        dbus_we_o => dbus_we_o,
        dbus_sel_o => dbus_sel_o,
        dbus_ack_i => dbus_ack_i,
        dbus_adr_o => dbus_adr_o,
        dbus_dat_o => dbus_dat_o,
        dbus_dat_i => dbus_dat_i,
        irq_i  => irq_i
    );
    
     
   Inst_memory_interface:  entity work.memory_interface 
    GENERIC MAP (
        ram_adr_width => ram_adr_width,
        ram_size => ram_size,
		--  RamFileName => "../../lxp32soc/riscv/software/cpptest/hello.hex",
        --RamFileName => "../../lxp32-cpu/riscv_test/mult.hex",
        RamFileName => "../../lxp32soc/riscv/software/cpptest/uart.hex",

        mode => "H"		 
    )
    
    PORT MAP(
        clk_i =>clk ,
        rst_i => reset,
        wbs_cyc_i =>  mem_cyc,
        wbs_stb_i =>  mem_stb,
        wbs_we_i =>    mem_we,
        wbs_sel_i =>  mem_sel,
        wbs_ack_o =>  mem_ack,
        wbs_adr_i =>  mem_adr,
        wbs_dat_i =>  mem_dat_wr,
        wbs_dat_o =>  mem_dat_rd,
        lli_re_i =>    ib_rden,
        lli_adr_i =>  ib_adr,
        lli_dat_o =>   ib_data,
        lli_busy_o =>  ib_busy
    );  
	 
	 
	 Inst_gpio: entity work.gpio PORT MAP(
		leds => leds ,
		clk_i =>clk ,
		rst_i => reset,
		wbs_cyc_i => gpio_cyc ,
		wbs_stb_i => gpio_stb,
		wbs_we_i => gpio_we,
		wbs_sel_i => gpio_sel,
		wbs_ack_o => gpio_ack,
		wbs_adr_i => gpio_adr,
		wbs_dat_i => gpio_dat_wr,
		wbs_dat_o => gpio_dat_rd
	);

    lpc_dat_wr8<= lpc_dat_wr(7 downto 0);
    lpc_dat_rd<=	X"000000"&lpc_dat_rd8;
    
	 
    -- extend Adress bus with lower two bits 
   process(lpc_adr,lpc_sel)
	  variable lowadr : std_logic_vector( 1 downto 0);
	  begin		 
	    case lpc_sel is 
		   when "0001" => lowadr:="00";
		   when "0010" =>lowadr:="01";
		   when "0100"=>lowadr:="10";
		   when "1000"=>lowadr:="11";
		   when others => lowadr:="00";
	    end case;	
       lpcio_adr<=lpc_adr & lowadr;
    end process;	
     	
	
   inst_lpcbus:  entity work.lpcbus PORT MAP(
		clk_i => clk,
		rst_i => reset,
		s0_cyc_i => lpc_cyc,
		s0_stb_i => lpc_stb,
		s0_we_i =>  lpc_we,
		s0_ack_o => lpc_ack,
		s0_adr_i =>  lpcio_adr,
		s0_dat_i =>  lpc_dat_wr8,
		s0_dat_o =>  lpc_dat_rd8,
		m0_cyc_o =>  uart_cyc,
		m0_stb_o => uart_stb,
		m0_we_o =>  uart_we,
		m0_ack_i => uart_ack,
		m0_adr_o => uart_adr,
		m0_dat_o => uart_dat_wr ,
		m0_dat_i => uart_dat_rd
	);
    
	
   inst_uart:  entity work.pp_soc_uart PORT MAP(
		clk =>clk ,
		reset => reset,
		txd => uart0_txd,
		rxd => uart0_rxd,
		irq => open,
		wb_adr_in => uart_adr,
		wb_dat_in => uart_dat_wr,
		wb_dat_out => uart_dat_rd,
		wb_we_in => uart_we,
		wb_cyc_in => uart_cyc,
		wb_stb_in => uart_stb,
		wb_ack_out => uart_ack
	);	
	 

   inst_busconnect:   entity  work.busconnect PORT MAP(
        clk_i => clk,
        rst_i => reset,
        s0_cyc_i => dbus_cyc_o,
        s0_stb_i => dbus_stb_o,
        s0_we_i =>  dbus_we_o,
        s0_sel_i => dbus_sel_o,
        s0_ack_o => dbus_ack_i,
        s0_adr_i => dbus_adr_o,
        s0_dat_i => dbus_dat_o,
        s0_dat_o => dbus_dat_i,
		  -- Memory at Adress 0XXXXXXX
        m0_cyc_o =>  mem_cyc,
        m0_stb_o =>  mem_stb,
        m0_we_o =>    mem_we,
        m0_sel_o =>  mem_sel,
        m0_ack_i =>  mem_ack,
        m0_adr_o =>  mem_adr,
        m0_dat_o =>  mem_dat_wr,
        m0_dat_i =>  mem_dat_rd,
		  --GPIO starts at address 1XXXXXXX
        m1_cyc_o => gpio_cyc,
        m1_stb_o => gpio_stb,
        m1_we_o =>  gpio_we,
        m1_sel_o =>  gpio_sel,
        m1_ack_i =>  gpio_ack,
        m1_adr_o =>  gpio_adr,
        m1_dat_o =>  gpio_dat_wr,
        m1_dat_i =>  gpio_dat_rd,
		  -- LPC starts at address 2XXXXXXX
        m2_cyc_o => lpc_cyc,
        m2_stb_o => lpc_stb,
        m2_we_o =>   lpc_we,
        m2_sel_o =>  lpc_sel,
        m2_ack_i =>  lpc_ack,
        m2_adr_o => lpc_adr,
        m2_dat_o =>  lpc_dat_wr,
        m2_dat_i => lpc_dat_rd
    );


-- Clock Buffer

 -- Input buffering
  --------------------------------------
  clkin1_buf : IBUFG
  port map
   (O => clk32Mhz,
    I => sysclk_32m);
     

    clk<=clk32Mhz; -- for the moment we set the CPU clock to the OSC.    
    
    
    process(clk) begin
      if rising_edge(clk) then 
         res1<= I_RESET;
         reset <= res1;
      end if; 

    end process;    


end Behavioral;

