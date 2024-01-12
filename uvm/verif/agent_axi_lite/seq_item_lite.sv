`ifndef SEQ_ITEM_LITE_SV
`define SEQ_ITEM_LITE_SV

class seq_item_lite extends uvm_sequence_item;

    //AXI LITE
    logic [31:0] COM_OR_POS;
    integer offset;
	integer frame_end;
    
	//ovde dodati polje za detekciju interapra
	
    `uvm_object_utils_begin(seq_item_lite)
            `uvm_field_int(COM_OR_POS,  UVM_DEFAULT)
            `uvm_field_int(offset,    UVM_DEFAULT)
			`uvm_field_int(frame_end,    UVM_DEFAULT)
    `uvm_object_utils_end

    
    function new (string name = "seq_item_lite");
       super.new(name);
    endfunction // new
	
endclass : seq_item_lite

`endif