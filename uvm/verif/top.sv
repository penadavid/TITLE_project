`ifndef TITLE_TOP_SV 
`define TITLE_TOP_SV

module title_top;

    import uvm_pkg::*;          // import the UVM library
    `include "uvm_macros.svh"   // Include the UVM macros
    import test_pkg::*;

    logic clk;

    // interface
    title_interface title_vif(clk);

    TITLE_IP_v1_0 DUT(
                .s00_axi_aclk                (clk),
                //AXI STREAM SLAVE
                .axis_s_data_in     (title_vif.axis_s_data_in),
                .axis_s_valid       (title_vif.axis_s_valid),
                .axis_s_last        (title_vif.axis_s_last),
                .axis_s_ready       (title_vif.axis_s_ready),
                //AXI STREAM MASTER
                .axim_s_valid       (title_vif.axim_s_valid),
                .axim_s_last        (title_vif.axim_s_last),
                .axim_s_ready       (title_vif.axim_s_ready),
                .axim_s_data_out    (title_vif.axim_s_data),
                              
                //AXI LITE
                .s00_axi_awaddr     (title_vif.s00_axi_awaddr),
                .s00_axi_awprot     (title_vif.s00_axi_awprot),
                .s00_axi_awvalid    (title_vif.s00_axi_awvalid),
                .s00_axi_awready    (title_vif.s00_axi_awready),
                .s00_axi_wdata      (title_vif.s00_axi_wdata),
                .s00_axi_wstrb      (title_vif.s00_axi_wstrb),
                .s00_axi_wvalid     (title_vif.s00_axi_wvalid),
                .s00_axi_wready     (title_vif.s00_axi_wready),
                .s00_axi_bresp      (title_vif.s00_axi_bresp),
                .s00_axi_bvalid     (title_vif.s00_axi_bvalid),
                .s00_axi_bready     (title_vif.s00_axi_bready),
                .s00_axi_araddr     (title_vif.s00_axi_araddr),
                .s00_axi_arprot     (title_vif.s00_axi_arprot),
                .s00_axi_arvalid    (title_vif.s00_axi_arvalid),
                .s00_axi_arready    (title_vif.s00_axi_arready),
                .s00_axi_rdata      (title_vif.s00_axi_rdata),
                .s00_axi_rresp      (title_vif.s00_axi_rresp),
                .s00_axi_rvalid     (title_vif.s00_axi_rvalid),
                .s00_axi_rready     (title_vif.s00_axi_rready),
                .s00_axi_aresetn    (title_vif.s00_axi_aresetn),
                //INTERUPT
                .end_command_interrupt    (title_vif.end_command_interrupt),
				.frame_finished_interrupt  (title_vif.frame_finished_interrupt)


                );

    // run test
    initial begin
        uvm_config_db#(virtual title_interface)::set(null, "uvm_test_top.env", "title_interface", title_vif);
        run_test();
    end

    // clock init
    initial begin
        clk = 1;        
    end

    //clock generation
    always #5 clk = ~clk;

    initial begin
    #100ms;
	$display("Sorry! Ran out of clock cycles!");
        $finish();
    end

endmodule : title_top

`endif 
