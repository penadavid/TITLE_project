`ifndef SIMPLE_SEQ_SLAVE_SV
`define SIMPLE_SEQ_SLAVE_SV

class simple_seq_slave extends base_seq_slave;

    `uvm_object_utils(simple_seq_slave)
	
	parameter IMAGE_1_ROW = 101;
	parameter IMAGE_2_ROW = 67;
	parameter IMAGE_3_ROW = 50;
	parameter IMAGE_4_ROW = 40;
	parameter IMAGE_5_ROW = 33;
	
	parameter IMAGE_1_WIDTH = 640;
	parameter IMAGE_2_WIDTH = 960;
	parameter IMAGE_3_WIDTH = 1280;
	parameter IMAGE_4_WIDTH = 1600;
	parameter IMAGE_5_WIDTH = 1920;

    integer i = 0;
    seq_item_slave item;
	
    integer send_letterData_1, send_letterData_2, send_letterData_3, send_letterData_4, send_letterData_5;
    integer send_possition_1, send_possition_2, send_possition_3, send_possition_4, send_possition_5;
	integer send_letterMatrix_1, send_letterMatrix_2, send_letterMatrix_3, send_letterMatrix_4, send_letterMatrix_5;
	integer send_text;
	
	integer send_input_image_1 = 0; // adress_row = height_frame - bram_row * tmp_pic;  adress_row * width_frame * 3
	integer send_input_image_2 = 0;
	integer send_input_image_3 = 0;
	integer send_input_image_4 = 0;
	integer send_input_image_5 = 0;
	
	integer start_addr_image_1 = 0;
	integer start_addr_image_2 = 0;
	integer start_addr_image_3 = 0;
	integer start_addr_image_4 = 0;
	integer start_addr_image_5 = 0;
    
    

    function new(string name = "seq_item_slave");
        super.new(name);
        extract_data();
    endfunction

    virtual task body();   
        item = seq_item_slave::type_id::create("item");

        //`uvm_info(get_name(), $sformatf("SIZE OF input_image_1_FORMATED %d",input_image_1.size()),UVM_LOW)
        //`uvm_info(get_name(), $sformatf("SIZE OF input_image_2_FORMATED %d",input_image_2.size()),UVM_LOW)
        //`uvm_info(get_name(), $sformatf("SIZE OF input_image_3_FORMATED %d",input_image_3.size()),UVM_LOW)
		//`uvm_info(get_name(), $sformatf("SIZE OF input_image_4_FORMATED %d",input_image_4.size()),UVM_LOW)
		//`uvm_info(get_name(), $sformatf("SIZE OF input_image_5_FORMATED %d",input_image_5.size()),UVM_LOW)

        if(send_letterData_1) begin
            while(i < letterData_1.size) begin
                start_item(item);

                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = letterData_1[i];           
                
                if(i == letterData_1.size - 1)
                    item.axis_s_last = 1'b1;
                
                if(item.axis_s_valid == 1)
                    i++;

                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
        end
        send_letterData_1 = 0;
		
		if(send_letterData_2) begin
            while(i < letterData_2.size) begin
                start_item(item);

                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = letterData_2[i];           
                
                if(i == letterData_2.size - 1)
                    item.axis_s_last = 1'b1;
                
                if(item.axis_s_valid == 1)
                    i++;

                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
        end
        send_letterData_2 = 0;
		
		if(send_letterData_3) begin
            while(i < letterData_3.size) begin
                start_item(item);

                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = letterData_3[i];           
                
                if(i == letterData_3.size - 1)
                    item.axis_s_last = 1'b1;
                
                if(item.axis_s_valid == 1)
                    i++;

                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
        end
        send_letterData_3 = 0;
		
		if(send_letterData_4) begin
            while(i < letterData_4.size) begin
                start_item(item);

                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = letterData_4[i];           
                
                if(i == letterData_4.size - 1)
                    item.axis_s_last = 1'b1;
                
                if(item.axis_s_valid == 1)
                    i++;

                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
        end
        send_letterData_4 = 0;
		
		if(send_letterData_5) begin
            while(i < letterData_5.size) begin
                start_item(item);

                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = letterData_5[i];           
                
                if(i == letterData_5.size - 1)
                    item.axis_s_last = 1'b1;
                
                if(item.axis_s_valid == 1)
                    i++;

                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
        end
        send_letterData_5 = 0;
		
		if(send_possition_1) begin
            while(i < possition_1.size) begin
                start_item(item);

                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = possition_1[i];           
                
                if(i == possition_1.size - 1)
                    item.axis_s_last = 1'b1;
                
                if(item.axis_s_valid == 1)
                    i++;

                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
        end
        send_possition_1 = 0;
		
		if(send_possition_2) begin
            while(i < possition_2.size) begin
                start_item(item);

                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = possition_2[i];           
                
                if(i == possition_2.size - 1)
                    item.axis_s_last = 1'b1;
                
                if(item.axis_s_valid == 1)
                    i++;

                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
        end
        send_possition_2 = 0;
		
		if(send_possition_3) begin
            while(i < possition_3.size) begin
                start_item(item);

                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = possition_3[i];           
                
                if(i == possition_3.size - 1)
                    item.axis_s_last = 1'b1;
                
                if(item.axis_s_valid == 1)
                    i++;

                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
        end
        send_possition_3 = 0;
		
		if(send_possition_4) begin
            while(i < possition_4.size) begin
                start_item(item);

                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = possition_4[i];           
                
                if(i == possition_4.size - 1)
                    item.axis_s_last = 1'b1;
                
                if(item.axis_s_valid == 1)
                    i++;

                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
        end
        send_possition_4 = 0;
		
		if(send_possition_5) begin
            while(i < possition_5.size) begin
                start_item(item);

                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = possition_5[i];           
                
                if(i == possition_5.size - 1)
                    item.axis_s_last = 1'b1;
                
                if(item.axis_s_valid == 1)
                    i++;

                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
        end
        send_possition_5 = 0;
		
		if(send_letterMatrix_1) begin
            while(i < letterMatrix_1.size) begin
                start_item(item);

                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = letterMatrix_1[i];           
                
                if(i == letterMatrix_1.size - 1)
                    item.axis_s_last = 1'b1;
                
                if(item.axis_s_valid == 1)
                    i++;

                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
        end
        send_letterMatrix_1 = 0;
		
		if(send_letterMatrix_2) begin
            while(i < letterMatrix_2.size) begin
                start_item(item);

                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = letterMatrix_2[i];           
                
                if(i == letterMatrix_2.size - 1)
                    item.axis_s_last = 1'b1;
                
                if(item.axis_s_valid == 1)
                    i++;

                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
        end
        send_letterMatrix_2 = 0;
		
		if(send_letterMatrix_3) begin
            while(i < letterMatrix_3.size) begin
                start_item(item);

                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = letterMatrix_3[i];           
                
                if(i == letterMatrix_3.size - 1)
                    item.axis_s_last = 1'b1;
                
                if(item.axis_s_valid == 1)
                    i++;

                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
        end
        send_letterMatrix_3 = 0;
		
		if(send_letterMatrix_4) begin
            while(i < letterMatrix_4.size) begin
                start_item(item);

                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = letterMatrix_4[i];           
                
                if(i == letterMatrix_4.size - 1)
                    item.axis_s_last = 1'b1;
                
                if(item.axis_s_valid == 1)
                    i++;

                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
        end
        send_letterMatrix_4 = 0;
		
		if(send_letterMatrix_5) begin
            while(i < letterMatrix_5.size) begin
                start_item(item);

                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = letterMatrix_5[i];           
                
                if(i == letterMatrix_5.size - 1)
                    item.axis_s_last = 1'b1;
                
                if(item.axis_s_valid == 1)
                    i++;

                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
        end
        send_letterMatrix_5 = 0;
		
		if(send_text) begin
            while(i < text.size) begin
                start_item(item);

                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = text[i];           
                
                if(i == text.size - 1)
                    item.axis_s_last = 1'b1;
                
                if(item.axis_s_valid == 1)
                    i++;

                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
        end
        send_text = 0;
		


        if(send_input_image_1) begin 
            while(i < IMAGE_1_ROW * IMAGE_1_WIDTH * 3) begin
                start_item(item);
                
                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = input_image_1[start_addr_image_1 + i];
                
                if(i == IMAGE_1_ROW * IMAGE_1_WIDTH * 3 - 1)
                    item.axis_s_last = 1'b1;
                if(item.axis_s_valid == 1)
                    i++;
                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
            send_input_image_1 = 0;
			start_addr_image_1 = 0;
        end
		
		if(send_input_image_2) begin 
            while(i < IMAGE_2_ROW * IMAGE_2_WIDTH * 3) begin
                start_item(item);
                
                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = input_image_2[start_addr_image_2 + i];
                
                if(i == IMAGE_2_ROW * IMAGE_2_WIDTH * 3 - 1)
                    item.axis_s_last = 1'b1;
                if(item.axis_s_valid == 1)
                    i++;
                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
            send_input_image_2 = 0;
			start_addr_image_2 = 0;
        end
		
		if(send_input_image_3) begin 
            while(i < IMAGE_3_ROW * IMAGE_3_WIDTH * 3) begin
                start_item(item);
                
                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = input_image_3[start_addr_image_3 + i];
                
                if(i == IMAGE_3_ROW * IMAGE_3_WIDTH * 3 - 1)
                    item.axis_s_last = 1'b1;
                if(item.axis_s_valid == 1)
                    i++;
                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
            send_input_image_3 = 0;
			start_addr_image_3 = 0;
        end
		
		if(send_input_image_4) begin 
            while(i < IMAGE_4_ROW * IMAGE_4_WIDTH * 3) begin
                start_item(item);
                
                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = input_image_4[start_addr_image_4 + i];
                
                if(i == IMAGE_4_ROW * IMAGE_4_WIDTH * 3 - 1)
                    item.axis_s_last = 1'b1;
                if(item.axis_s_valid == 1)
                    i++;
                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
            send_input_image_4 = 0;
			start_addr_image_4 = 0;
        end
		
		if(send_input_image_5) begin 
            while(i < IMAGE_5_ROW * IMAGE_5_WIDTH * 3) begin
                start_item(item);
                
                assert(item.randomize());
                
                item.axis_s_last    = 1'b0;
                item.axis_s_data_in = input_image_5[start_addr_image_5 + i];
                
                if(i == IMAGE_5_ROW * IMAGE_5_WIDTH * 3 - 1)
                    item.axis_s_last = 1'b1;
                if(item.axis_s_valid == 1)
                    i++;
                finish_item(item);
            end
            `uvm_info(get_name(), $sformatf("i = %d    ",i),UVM_HIGH)
            i = 0;
            send_input_image_5 = 0;
			start_addr_image_5 = 0;
        end
        

endtask : body

endclass : simple_seq_slave
`endif
