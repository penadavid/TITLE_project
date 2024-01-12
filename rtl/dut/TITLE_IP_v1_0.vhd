library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TITLE_IP_v1_0 is
	generic (
		-- Users to add parameters here
         AXI_WIDTH: integer := 16;     
        --letterData   
        LETTER_DATA_RAM_WIDTH : integer := 8;
        LETTER_DATA_RAM_DEPTH : integer := 214;
        LETTER_DATA_ADDR_SIZE : integer := 8;
        --letterMatrix    
        LETTER_MATRIX_RAM_WIDTH : integer := 1;
        LETTER_MATRIX_RAM_DEPTH : integer := 46423;
        LETTER_MATRIX_ADDR_SIZE : integer := 16;
        --photo    
        PHOTO_RAM_WIDTH : integer := 8;
        PHOTO_RAM_DEPTH : integer := 195000;
        PHOTO_ADDR_SIZE : integer := 18;
        --text   
        TEXT_RAM_WIDTH : integer := 8;
        TEXT_RAM_DEPTH : integer := 200;
        TEXT_ADDR_SIZE : integer := 8;
        --possition  
        POSSITION_RAM_WIDTH : integer := 16;
        POSSITION_RAM_DEPTH : integer := 106;
        POSSITION_ADDR_SIZE : integer := 7;
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
        end_command_interrupt: out std_logic;
		frame_finished_interrupt: out std_logic;
		
        --AXI STREAM SLAVE SIGNALS
        axis_s_data_in: in std_logic_vector(15 downto 0);
        axis_s_valid:in std_logic;
        axis_s_last:in std_logic;
        axis_s_ready:out std_logic;
        --AXI STREAM MASTER SIGNALS
        axim_s_valid:out std_logic;
        axim_s_last:out std_logic;
        axim_s_ready:in std_logic;
        axim_s_data_out: out std_logic_vector(15 downto 0);
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end TITLE_IP_v1_0;

architecture arch_imp of TITLE_IP_v1_0 is

	-- component declaration
	component TITLE_IP_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		command: out std_logic_vector(7 downto 0);
        possition_y: out std_logic_vector(10 downto 0);
        end_command_interrupt: in std_logic;
        frame_finished_interrupt: in std_logic;
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component TITLE_IP_v1_0_S00_AXI;
    
    component TOP is
        generic (           
        --uvek saljemo primamo 16stobitne podatke pa ih rasporedjujemo posle           
        AXI_WIDTH: integer := 16;     
        --letterData   
        LETTER_DATA_RAM_WIDTH : integer := 8;
        LETTER_DATA_RAM_DEPTH : integer := 214;
        LETTER_DATA_ADDR_SIZE : integer := 8;
          --letterMatrix    
        LETTER_MATRIX_RAM_WIDTH : integer := 1;
        LETTER_MATRIX_RAM_DEPTH : integer := 46423;
        LETTER_MATRIX_ADDR_SIZE : integer := 16;
        --photo    
        PHOTO_RAM_WIDTH : integer := 8;
        PHOTO_RAM_DEPTH : integer := 195000;
        PHOTO_ADDR_SIZE : integer := 18;
        --text
        TEXT_RAM_WIDTH : integer := 8;
        TEXT_RAM_DEPTH : integer := 200;
        TEXT_ADDR_SIZE : integer := 8;
        --possition  
        POSSITION_RAM_WIDTH : integer := 16;
        POSSITION_RAM_DEPTH : integer := 106;
        POSSITION_ADDR_SIZE : integer := 7);
        port ( 
        clk: in std_logic;
        command: in std_logic_vector(7 downto 0);
        --axi slave
        axis_s_data_in: in std_logic_vector(AXI_WIDTH - 1 downto 0);
        axis_s_valid:in std_logic;
        axis_s_last:in std_logic;
        axis_s_ready:out std_logic;
        --axi master
        axim_s_data_out: out std_logic_vector(AXI_WIDTH - 1 downto 0);
        axim_s_valid:out std_logic;
        axim_s_last:out std_logic;
        axim_s_ready: in std_logic;
          
        possition_y: in std_logic_vector(10 downto 0);
        frame_finished_interrupt: out std_logic;
        end_command_interrupt: out std_logic);
	end component TOP;

signal command_s: std_logic_vector(7 downto 0);
signal possition_y_s: std_logic_vector(10 downto 0);
signal end_command_s: std_logic;
signal frame_finished_s: std_logic;
begin

-- Instantiation of Axi Bus Interface S00_AXI
TITLE_IP_v1_0_S00_AXI_inst : TITLE_IP_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	    command => command_s,
        possition_y => possition_y_s,
        end_command_interrupt => end_command_s,
        frame_finished_interrupt => frame_finished_s,
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

TOP_inst: TOP
	generic map(
             AXI_WIDTH=>AXI_WIDTH,
             LETTER_DATA_RAM_WIDTH=>LETTER_DATA_RAM_WIDTH, 
             LETTER_DATA_RAM_DEPTH=>LETTER_DATA_RAM_DEPTH,
             LETTER_DATA_ADDR_SIZE =>LETTER_DATA_ADDR_SIZE,
             LETTER_MATRIX_RAM_WIDTH=>LETTER_MATRIX_RAM_WIDTH, 
             LETTER_MATRIX_RAM_DEPTH=>LETTER_MATRIX_RAM_DEPTH,
             LETTER_MATRIX_ADDR_SIZE =>LETTER_MATRIX_ADDR_SIZE,
             TEXT_RAM_WIDTH=> TEXT_RAM_WIDTH, 
             TEXT_RAM_DEPTH=>TEXT_RAM_DEPTH,
             TEXT_ADDR_SIZE =>TEXT_ADDR_SIZE,
             PHOTO_RAM_WIDTH => PHOTO_RAM_WIDTH, 
             PHOTO_RAM_DEPTH => PHOTO_RAM_DEPTH,
             PHOTO_ADDR_SIZE => PHOTO_ADDR_SIZE,
             POSSITION_RAM_WIDTH => POSSITION_RAM_WIDTH,
             POSSITION_RAM_DEPTH => POSSITION_RAM_DEPTH,
             POSSITION_ADDR_SIZE => POSSITION_ADDR_SIZE)
    port map(
             clk => s00_axi_aclk,
             command => command_s,                                   
             axis_s_data_in => axis_s_data_in,
             axis_s_valid => axis_s_valid,
             axis_s_last => axis_s_last,
             axis_s_ready => axis_s_ready,
             possition_y => possition_y_s,
             axim_s_data_out => axim_s_data_out,
             axim_s_valid => axim_s_valid,
             axim_s_last => axim_s_last,
             axim_s_ready => axim_s_ready,
             frame_finished_interrupt => frame_finished_s,
             end_command_interrupt => end_command_s
    );

	-- Add user logic here
    end_command_interrupt <= end_command_s;
    frame_finished_interrupt <= frame_finished_s;
	-- User logic ends

end arch_imp;
