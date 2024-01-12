`ifndef MONITOR_AXI_STREAM_SLAVE_SV
`define MONITOR_AXI_STREAM_SLAVE_SV

class monitor_axi_stream_slave extends uvm_monitor;

    `uvm_component_utils(monitor_axi_stream_slave)

    title_config cfg;
    seq_item_slave item;
    virtual interface title_interface vif;
    uvm_analysis_port #(seq_item_slave) port_axis; //sends items to scoreboard
	
	covergroup read_axi_stream_slave;
        option.per_instance = 1;
        cp_axis_s_valid: coverpoint vif.axis_s_valid{
            bins AXIS_S_VALID = {1'b1};
        }
        cp_axis_s_last: coverpoint vif.axis_s_last{
            bins AXIS_S_LAST =  {1'b1};
        }
        cp_axi_s_ready: coverpoint vif.axis_s_ready{
            bins AXIS_S_READY = {1'b1};
        }
    endgroup

    function new(string name = "monitor_axi_stream_slave", uvm_component parent = null);
        super.new(name,parent);  
        port_axis = new("port_axis", this);
		read_axi_stream_slave = new();
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (!uvm_config_db#(virtual title_interface)::get(this, "", "title_interface", vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
        
        if(!uvm_config_db#(title_config)::get(this, "", "title_config", cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})
    endfunction : connect_phase

    task main_phase(uvm_phase phase);
        forever begin
            @(negedge vif.clk) begin
                @(negedge vif.clk iff vif.axis_s_last) begin
                    //`uvm_info(get_name(), $sformatf("Dogodila se prva provera"),UVM_LOW)
					read_axi_stream_slave.sample();
                end
            end
        end    
    endtask : main_phase


endclass : monitor_axi_stream_slave

`endif