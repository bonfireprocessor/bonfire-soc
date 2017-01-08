-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2016 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <https://github.com/skordal/potato/issues>

library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL;

library STD;
use STD.textio.all;

use work.txt_util.all;

entity tb_soc_uart_xmodem is
end entity tb_soc_uart_xmodem;

architecture testbench of tb_soc_uart_xmodem is
   -- constants 
   constant clk_period : time := 10.41  ns;  --Clock 96Mhz
   
   constant Teststr : string :="The quick brown fox";
   constant xm_packsize : natural := 128;
   constant numpacks : natural := 2;
   
   constant baudrate : natural := 115200;
   constant bit_time : time := 8.68 us; 
   

	-- Clock signal:
	signal clk : std_logic := '0';
	

	-- Reset signal:
	signal reset : std_logic := '1';

	-- UART ports:
	signal txd : std_logic;
	signal rxd : std_logic := '1';

	-- interrupt signals:
	signal irq : std_logic;

	-- Wishbone ports:
	signal wb_adr_in  : std_logic_vector(7 downto 0) := (others => '0');
	signal wb_dat_in  : std_logic_vector( 7 downto 0) := (others => '0');
	signal wb_dat_out : std_logic_vector( 7 downto 0);
	signal wb_we_in   : std_logic := '0';
	signal wb_cyc_in  : std_logic := '0';
	signal wb_stb_in  : std_logic := '0';
	signal wb_ack_out : std_logic;
   
  
   
   signal cbyte : std_logic_vector(7 downto 0);
   signal bitref : integer :=0;
   
   signal finish : boolean := false;
   
   constant log_file : string := "receive.log";
   
  
   
   type t_xm_state is (s_idle,s_h1,s_pack,s_chk);
   signal xm_state : t_xm_state := s_idle;

begin

	uut: entity work.wb_uart_interface
      generic map(
        FIFO_DEPTH => 32 )
		port map(
			clk => clk,
			reset => reset,
			txd => txd,
			rxd => rxd,
			irq => irq,
			wb_adr_in => wb_adr_in,
			wb_dat_in => wb_dat_in,
			wb_dat_out => wb_dat_out,
			wb_we_in => wb_we_in,
			wb_cyc_in => wb_cyc_in,
			wb_stb_in => wb_stb_in,
			wb_ack_out => wb_ack_out
		);

	clock: process
	begin
		clk <= '1';
		wait for clk_period / 2;
		clk <= '0';
		wait for clk_period / 2;
	end process clock;
   
   
   send:  process
      procedure send_byte(v: std_logic_vector(7 downto 0)) is
         variable bi : natural;
         variable t : std_logic_vector(7 downto 0);
         begin
           
           bi:=7;
           for i in 0 to 7 loop
            t(bi) := v(i); -- for debugging purposes
            bi:=bi-1;
           end loop;
           cbyte <= t;
          
           bitref<= 0;
           
           rxd <= '0'; -- start bit
           for i in 0 to 7 loop
             wait for bit_time;
             rxd<=v(i);
             bitref<=bitref+1;          
           end loop;
           wait for bit_time;
           rxd <= '1'; -- stop bit
           bitref<=bitref+1;
           wait for bit_time;
         end;
         
         procedure sendstring(s:string) is
         begin
           for i in 1 to s'length loop
             send_byte(std_logic_vector(to_unsigned(character'pos(s(i)),8)));
           end loop;
         end;  
         
         
   variable checksum : unsigned(7 downto 0); 
   variable byte : std_logic_vector(7 downto 0);
  
   begin
   
      wait for bit_time*10;
      -- Calculate xmodem packet
     
      for p in 0 to numpacks loop
         -- Header
         byte:=std_logic_vector(to_unsigned(p,8)); 
         send_byte(byte);
         send_byte(not byte);
         checksum:=to_unsigned(0,checksum'length);
         for i in 0 to xm_packsize-1 loop
           byte := char_to_ascii_byte(Teststr(i mod Teststr'length +1));
           send_byte(byte);
           checksum:=checksum+unsigned(byte);
         end loop;
         send_byte(std_logic_vector(checksum));
      end loop;
   
      wait for bit_time*10;
      finish<=true; -- signal end of send simulation 
      wait;
   
   end process;
   
   

	stimulus: process
       procedure uart_write(address : in std_logic_vector(7 downto 0); data : in std_logic_vector(7 downto 0)) is
		begin
			wb_adr_in <= address;
         wait until rising_edge(clk);
			wb_dat_in <= data;
			wb_we_in <= '1';
			wb_cyc_in <= '1';
			wb_stb_in <= '1';

			wait until wb_ack_out = '1';
			wait  until rising_edge(clk);
			wb_stb_in <= '0';
			wb_cyc_in <= '0';
			
		end procedure;
      
      procedure uart_read(address : in std_logic_vector(7 downto 0);
                          data: out std_logic_vector(7 downto 0) )  is
		begin
			wb_adr_in <= address;
         wait until rising_edge(clk);
			wb_we_in <= '1';
			wb_cyc_in <= '1';
			wb_stb_in <= '1';
         wb_we_in <= '0';
			wait until wb_ack_out = '1';
			data:= wb_dat_out;
         wait until rising_edge(clk);
			wb_stb_in <= '0';
			wb_cyc_in <= '0';
		   --wait for clk_period;
		end procedure;
      
      variable status,rx_byte,h1 : std_logic_vector(7 downto 0);
      variable cnt: natural;
      
      file l_file: TEXT open write_mode is log_file;
   
      variable chksum : unsigned(7 downto 0);
      variable s: string(1 to 1);
     
	begin
		wait for clk_period * 2;
		reset <= '0';

	
       uart_write(x"0C",std_logic_vector(to_unsigned(51,8))); -- Divisor 51 for 115200 Baud

		-- Enable the data received interrupt:
		--uart_write(x"10", x"01");
    
       while not finish loop
          -- Check Status Register
           status := X"01";
           while (status and X"01") = X"01"  and not finish loop
             uart_read(X"08",status); 
           end loop;     
           -- Get byte
           if (status and X"01") = X"00" then
             uart_read(X"04",rx_byte);
            
             case xm_state is 
               when s_idle=>
                 print(l_file,"Seq: " & hstr(rx_byte));
                 h1:=rx_byte;
                 xm_state<=s_h1;
               when s_h1=>
                 print(l_file,"~Seq: " & hstr(rx_byte));
                 if rx_byte /= not h1 then 
                    report "Packet header error" severity error;
                  end if;
                  xm_state<=s_pack;    
                  cnt:=1;
                  chksum:=X"00";
              when s_pack=>
                s(1):=character'val(to_integer(unsigned(rx_byte)));
               
                write(l_file,s);
                --print(l_file,hstr(rx_byte));
                chksum:=chksum+unsigned(rx_byte);
                if cnt=xm_packsize then
                  print(l_file,"");
                  xm_state <= s_chk;                
                end if;
                cnt := cnt + 1;
              when s_chk=>
                print(l_file,"Checksum: " & hstr(std_logic_vector(chksum)) & " <-> " & hstr(rx_byte));
                if std_logic_vector(chksum) /= rx_byte then 
                  report "Packet checksum error" severity error;
                end if;
                xm_state <= s_idle;
             end case;                
           end if;
            
       end loop;
       print("Simulation finished");
       wait;
  
	end process stimulus;

end architecture testbench;
