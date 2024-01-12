`ifndef SEQUENCER_AXI_LITE_SV
`define SEQUENCER_AXI_LITE_SV

class sequencer_axi_lite extends uvm_sequencer#(seq_item_lite);

   `uvm_component_utils(sequencer_axi_lite)
   
   function new(string name = "sequencer_axi_lite", uvm_component parent = null);
      super.new(name,parent);
   endfunction

endclass : sequencer_axi_lite

`endif