`ifndef SEQUENCER_AXI_STREAM_SLAVE_SV
`define SEQUENCER_AXI_STREAM_SLAVE_SV

class sequencer_axi_stream_slave extends uvm_sequencer#(seq_item_slave);

   `uvm_component_utils(sequencer_axi_stream_slave)
   
   function new(string name = "sequencer_axi_stream_slave", uvm_component parent = null);
      super.new(name,parent);
   endfunction

endclass : sequencer_axi_stream_slave

`endif