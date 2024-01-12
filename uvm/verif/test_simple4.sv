`ifndef TEST_SIMPLE4_SV
`define TEST_SIMPLE4_SV

class test_simple4 extends test_base;
    `uvm_component_utils(test_simple4)

	parameter IMAGE_4_ROW = 40;
	
	logic[31:0] poss_tmp = 32'h00000028;
	int i = 1;
	int start_tmp;
	int end_while = 0;
	
    simple_seq_lite lite_seq; 
    simple_seq_slave slave_seq; 
    simple_seq_master master_seq;
    
    function new(string name = "test_simple4", uvm_component parent = null);
        super.new(name,parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        lite_seq = simple_seq_lite::type_id::create("lite_seq");
        slave_seq = simple_seq_slave::type_id::create("slave_seq");
        master_seq = simple_seq_master::type_id::create("master_seq");
    endfunction : build_phase

    task main_phase(uvm_phase phase);
        phase.raise_objection(this);

        lite_seq.command_or_possition = 32'h00000080;             //CMD:RESET IP
        lite_seq.offset_reg = 0;
		lite_seq.start(env.agent_lite.seqr);
		
        lite_seq.command_or_possition = 32'h00000001;             //CMD:LOAD LETTERDATA
        lite_seq.offset_reg = 0;
		lite_seq.start(env.agent_lite.seqr);
    
        slave_seq.send_letterData_4 = 1;                          //LOAD LETTERDATA
        slave_seq.start(env.agent_slave.seqr);
		
		
		lite_seq.command_or_possition = 32'h00000002;             //CMD:LOAD LETTERMATRIX
        lite_seq.offset_reg = 0;
		lite_seq.start(env.agent_lite.seqr);
    
        slave_seq.send_letterMatrix_4 = 1;                        //LOAD LETTERMATRIX
        slave_seq.start(env.agent_slave.seqr);
		
		
		lite_seq.command_or_possition = 32'h00000008;             //CMD:LOAD POSSITION
        lite_seq.offset_reg = 0;
		lite_seq.start(env.agent_lite.seqr);
    
        slave_seq.send_possition_4 = 1;                           //LOAD POSSITION
        slave_seq.start(env.agent_slave.seqr);
		
		
		lite_seq.command_or_possition = 32'h00000004;             //CMD:LOAD TEXT
        lite_seq.offset_reg = 0;
		lite_seq.start(env.agent_lite.seqr);
    
        slave_seq.send_text = 1;                                  //LOAD TEXT
        slave_seq.start(env.agent_slave.seqr);
		
		
		
		`uvm_info(get_name(), $sformatf("================== START TEST_4 =================="),UVM_LOW)

		do
		begin
			
			start_tmp = IMAGE_4_ROW * i;
			poss_tmp = poss_tmp * i;
			
			lite_seq.command_or_possition = 32'h00000010;                   //CMD:LOAD PHOTO
			lite_seq.offset_reg = 0;
			lite_seq.start(env.agent_lite.seqr);
    
			slave_seq.start_addr_image_4 = (900 - start_tmp) * 1600 * 3;     //LOAD PHOTO
			slave_seq.send_input_image_4 = 1;
			slave_seq.start(env.agent_slave.seqr);
		
			
			lite_seq.command_or_possition = poss_tmp;                       //SEND POS
			lite_seq.offset_reg = 1;
			lite_seq.start(env.agent_lite.seqr);
		

			lite_seq.command_or_possition = 32'h00000020;                   //PROCESSING
			lite_seq.offset_reg = 0;
			lite_seq.start(env.agent_lite.seqr);
				
			if(lite_seq.frame_interrupt) 
				end_while = 1;
			else
				i++;
			
			//$display("In test int_frame: %d", lite_seq.frame_interrupt);
		
			lite_seq.command_or_possition = 32'h00000040;                   //CMD:SEND DATA FROM BRAM
			lite_seq.offset_reg = 0;
			lite_seq.start(env.agent_lite.seqr);
		
			master_seq.number_of_data = IMAGE_4_ROW * 1600 * 3;		    //SEND DATA FROM BRAM
			master_seq.start(env.agent_master.seqr);
			
		end
		while (!end_while);
		
		`uvm_info(get_name(), $sformatf("================== FINISHED TEST_4 =================="),UVM_LOW)
		
        #30ms;
        phase.drop_objection(this);
    endtask : main_phase

endclass

`endif


//00000001 letterData  32'h00000001
//00000010 letterMatrix  32'h00000002
//00000100 text  32'h00000004
//00001000 possition  32'h00000008
//00010000 photo  32'h00000010
//00100000 processing  32'h00000020
//01000000 sendPhoto from bram  32'h00000040
//10000000 reset  32'h00000080

