`ifndef SIMPLE_SEQ_LITE_SV
`define SIMPLE_SEQ_LITE_SV

class simple_seq_lite extends base_seq_lite;

    `uvm_object_utils(simple_seq_lite)

    logic[31:0] command_or_possition;
    integer offset_reg;
	integer frame_interrupt;
	
    seq_item_lite item;

    function new(string name = "simple_seq_lite");
      super.new(name);  
    endfunction

    virtual task body();   
        item = seq_item_lite::type_id::create("item");
        `uvm_info(get_name(), $sformatf("SENDING COMMAND OR POSSITION"),   UVM_HIGH) 

        start_item(item);
        item.COM_OR_POS = command_or_possition;
        item.offset = offset_reg;
        finish_item(item);
		
		frame_interrupt = item.frame_end;
		//$display("frame_interrupt: %d",frame_interrupt);
		
        `uvm_info(get_name(), $sformatf("COMMAND OR POSSITION SENT %h, OFFSET: %d", command_or_possition, offset_reg),   UVM_HIGH) 
    endtask : body

endclass : simple_seq_lite
`endif
