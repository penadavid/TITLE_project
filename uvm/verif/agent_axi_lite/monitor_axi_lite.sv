`ifndef MONITOR_AXI_LITE_SV
`define MONITOR_AXI_LITE_SV

class monitor_axi_lite extends uvm_monitor;

    `uvm_component_utils(monitor_axi_lite)

    title_config cfg;
    seq_item_lite item;
    virtual interface title_interface vif;
    uvm_analysis_port #(seq_item_lite) port_axi_lite; //sends items to scoreboard
	
	covergroup read_axi_lite;
        option.per_instance = 1;
        cp_cmd_or_pos: coverpoint vif.s00_axi_wdata{
		
			bins LOAD_LETTERDATA_COMMAND                  = {32'h00000001};
			bins LOAD_LETTERMATRIX_COMMAND                = {32'h00000002};
            bins LOAD_TEXT_COMMAND                        = {32'h00000004}; 															          
            bins LOAD_POSSITION_COMMAND                   = {32'h00000008}; 
            bins LOAD_PHOTO_COMMAND                       = {32'h00000010};
	
            bins START_PROCESSING_COMMAND                 = {32'h00000020}; 
            bins SEND_PHOTO_FROM_BRAM_COMMAND             = {32'h00000040};
            bins RESET_COMMAND                            = {32'h00000080};

			bins POSSITION_Y                              = default;

            
        }
		cp_offset: coverpoint vif.s00_axi_awaddr{
		
            bins OFFSET_COMMAND                            = {4'b0000};
            bins OFFSET_POSSITION_Y                        = {4'b0100};  
        }
		
		
		
    endgroup

    function new(string name = "monitor_axi_lite", uvm_component parent = null);
        super.new(name,parent);  
        port_axi_lite = new("port_axi_lite", this);
		read_axi_lite = new();
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (!uvm_config_db#(virtual title_interface)::get(this, "", "title_interface", vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
        
        if(!uvm_config_db#(title_config)::get(this, "", "title_config", cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})
    endfunction : connect_phase

    task main_phase(uvm_phase phase);
        item = seq_item_lite::type_id::create("item",this);
        
        forever begin
            @(negedge vif.clk iff (vif.s00_axi_awvalid && vif.s00_axi_wvalid)); 
            @(posedge vif.clk iff vif.s00_axi_awready); 
			
			read_axi_lite.sample();
            
            item.COM_OR_POS = vif.s00_axi_wdata;
			
			if (vif.s00_axi_awaddr == 4'b0100) begin
				item.offset = 1;
			end 
			else begin
				item.offset = 0;
			end
			
            port_axi_lite.write(item);
        end
    endtask : main_phase


endclass : monitor_axi_lite

`endif

