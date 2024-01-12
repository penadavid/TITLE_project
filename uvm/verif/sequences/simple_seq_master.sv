`ifndef SIMPLE_SEQ_MASTER_SV
`define SIMPLE_SEQ_MASTER_SV

class simple_seq_master extends base_seq_master;

    `uvm_object_utils(simple_seq_master)

    integer i = 0;
    seq_item_master item;
    integer number_of_data;
    

    function new(string name = "simple_seq_master");
      super.new(name);
      number_of_data = 0;
    endfunction

    virtual task body(); 
        item = seq_item_master::type_id::create("item");
        `uvm_info(get_name(), $sformatf("Broj podataka iz IP: %d", number_of_data),   UVM_HIGH) 

        while(i < number_of_data) begin
            start_item(item); 
                assert(item.randomize());
                
                if(item.axim_s_ready == 1) begin
                    i = i+1;     
                end
            finish_item(item);
        end
        //$display("(seq_master)vrednost iteracije i je i = %d",i); 
        i = 0;

        start_item(item);
            item.axim_s_ready = 1'b0; 
        finish_item(item);
    
    endtask : body

endclass : simple_seq_master
`endif
