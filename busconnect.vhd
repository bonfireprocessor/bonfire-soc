---------------------------------------------------------------------
-- Simple WISHBONE interconnect
--
-- Generated by wigen at 09/04/16 20:46:57
--
-- Configuration:
--     Number of masters:     1
--     Number of slaves:      3
--     Master address width:  32
--     Slave address width:   28
--     Port size:             32
--     Port granularity:      8
--     Entity name:           busconnect
--     Pipelined arbiter:     no
--     Registered feedback:   no
--     Unsafe slave decoder:  no
--
-- Command line:
--     wigen -e busconnect 1 3 32 28 32 8
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity busconnect is
	port(
		clk_i: in std_logic;
		rst_i: in std_logic;

		s0_cyc_i: in std_logic;
		s0_stb_i: in std_logic;
		s0_we_i: in std_logic;
		s0_sel_i: in std_logic_vector(3 downto 0);
		s0_ack_o: out std_logic;
		s0_adr_i: in std_logic_vector(31 downto 2);
		s0_dat_i: in std_logic_vector(31 downto 0);
		s0_dat_o: out std_logic_vector(31 downto 0);

		m0_cyc_o: out std_logic;
		m0_stb_o: out std_logic;
		m0_we_o: out std_logic;
		m0_sel_o: out std_logic_vector(3 downto 0);
		m0_ack_i: in std_logic;
		m0_adr_o: out std_logic_vector(27 downto 2);
		m0_dat_o: out std_logic_vector(31 downto 0);
		m0_dat_i: in std_logic_vector(31 downto 0);

		m1_cyc_o: out std_logic;
		m1_stb_o: out std_logic;
		m1_we_o: out std_logic;
		m1_sel_o: out std_logic_vector(3 downto 0);
		m1_ack_i: in std_logic;
		m1_adr_o: out std_logic_vector(27 downto 2);
		m1_dat_o: out std_logic_vector(31 downto 0);
		m1_dat_i: in std_logic_vector(31 downto 0);

		m2_cyc_o: out std_logic;
		m2_stb_o: out std_logic;
		m2_we_o: out std_logic;
		m2_sel_o: out std_logic_vector(3 downto 0);
		m2_ack_i: in std_logic;
		m2_adr_o: out std_logic_vector(27 downto 2);
		m2_dat_o: out std_logic_vector(31 downto 0);
		m2_dat_i: in std_logic_vector(31 downto 0)
	);
end entity;

architecture rtl of busconnect is

signal select_slave: std_logic_vector(3 downto 0);

signal cyc_mux: std_logic;
signal stb_mux: std_logic;
signal we_mux: std_logic;
signal sel_mux: std_logic_vector(3 downto 0);
signal adr_mux: std_logic_vector(31 downto 2);
signal wdata_mux: std_logic_vector(31 downto 0);

signal ack_mux: std_logic;
signal rdata_mux: std_logic_vector(31 downto 0);

begin

-- MASTER->SLAVE MUX

cyc_mux<=s0_cyc_i;
stb_mux<=s0_stb_i;
we_mux<=s0_we_i;
sel_mux<=s0_sel_i;
adr_mux<=s0_adr_i;
wdata_mux<=s0_dat_i;

-- MASTER->SLAVE DEMUX

select_slave<="0001" when adr_mux(31 downto 28)="0000" else
	"0010" when adr_mux(31 downto 28)="0001" else
	"0100" when adr_mux(31 downto 28)="0010" else
	"1000"; -- fallback slave

m0_cyc_o<=cyc_mux and select_slave(0);
m0_stb_o<=stb_mux and select_slave(0);
m0_we_o<=we_mux;
m0_sel_o<=sel_mux;
m0_adr_o<=adr_mux(m0_adr_o'range);
m0_dat_o<=wdata_mux;

m1_cyc_o<=cyc_mux and select_slave(1);
m1_stb_o<=stb_mux and select_slave(1);
m1_we_o<=we_mux;
m1_sel_o<=sel_mux;
m1_adr_o<=adr_mux(m1_adr_o'range);
m1_dat_o<=wdata_mux;

m2_cyc_o<=cyc_mux and select_slave(2);
m2_stb_o<=stb_mux and select_slave(2);
m2_we_o<=we_mux;
m2_sel_o<=sel_mux;
m2_adr_o<=adr_mux(m2_adr_o'range);
m2_dat_o<=wdata_mux;

-- SLAVE->MASTER MUX

ack_mux<=(m0_ack_i and select_slave(0)) or
	(m1_ack_i and select_slave(1)) or
	(m2_ack_i and select_slave(2)) or
	(cyc_mux and stb_mux and select_slave(3)); -- fallback slave

rdata_mux_gen: for i in rdata_mux'range generate
	rdata_mux(i)<=(m0_dat_i(i) and select_slave(0)) or
		(m1_dat_i(i) and select_slave(1)) or
		(m2_dat_i(i) and select_slave(2));
end generate;

-- SLAVE->MASTER DEMUX

s0_ack_o<=ack_mux;
s0_dat_o<=rdata_mux;

end architecture;
