`ifndef BASE_SEQ_SLAVE_SV
`define BASE_SEQ_SLAVE_SV

class base_seq_slave extends uvm_sequence#(seq_item_slave);

    `uvm_object_utils(base_seq_slave)
    `uvm_declare_p_sequencer(sequencer_axi_stream_slave)
    
	string letterData_1_file = "../../../../../../data/ver_data/letterData_1.txt";
	string letterData_2_file = "../../../../../../data/ver_data/letterData_2.txt";
	string letterData_3_file = "../../../../../../data/ver_data/letterData_3.txt";
	string letterData_4_file = "../../../../../../data/ver_data/letterData_4.txt";
	string letterData_5_file = "../../../../../../data/ver_data/letterData_5.txt";
	
	string possition_1_file = "../../../../../../data/ver_data/possition_1.txt";
	string possition_2_file = "../../../../../../data/ver_data/possition_2.txt";
	string possition_3_file = "../../../../../../data/ver_data/possition_3.txt";
	string possition_4_file = "../../../../../../data/ver_data/possition_4.txt";
	string possition_5_file = "../../../../../../data/ver_data/possition_5.txt";
	
	string letterMatrix_1_file = "../../../../../../data/ver_data/letterMatrix_1.txt";
	string letterMatrix_2_file = "../../../../../../data/ver_data/letterMatrix_2.txt";
	string letterMatrix_3_file = "../../../../../../data/ver_data/letterMatrix_3.txt";
	string letterMatrix_4_file = "../../../../../../data/ver_data/letterMatrix_4.txt";
	string letterMatrix_5_file = "../../../../../../data/ver_data/letterMatrix_5.txt";
	
	string input_image_1_file = "../../../../../../data/ver_data/input_image_640x360.txt";
	string input_image_2_file = "../../../../../../data/ver_data/input_image_960x540.txt";
	string input_image_3_file = "../../../../../../data/ver_data/input_image_1280x720.txt";
	string input_image_4_file = "../../../../../../data/ver_data/input_image_1600x900.txt";
	string input_image_5_file = "../../../../../../data/ver_data/input_image_1920x1080.txt";
	
	string text_file = "../../../../../../data/ver_data/text.txt";
	
	//Navesti putanje do fajlova !!!!
	
    int fd = 0;
    integer tmp;

	integer letterData_1[$];
	integer letterData_2[$];
	integer letterData_3[$];
	integer letterData_4[$];
	integer letterData_5[$];
	
	integer possition_1[$];
	integer possition_2[$];
	integer possition_3[$];
	integer possition_4[$];
	integer possition_5[$];
	
	integer letterMatrix_1[$];
	integer letterMatrix_2[$];
	integer letterMatrix_3[$];
	integer letterMatrix_4[$];
	integer letterMatrix_5[$];
	
	integer input_image_1[$];
	integer input_image_2[$];
	integer input_image_3[$];
	integer input_image_4[$];
	integer input_image_5[$];
	
	integer text[$];

    function new(string name = "base_seq_slave");
        super.new(name);
    endfunction

    // objections are raised in pre_body
    virtual task pre_body();
        uvm_phase phase = get_starting_phase();
           
            if (phase != null)
            phase.raise_objection(this, {"Running sequence '", get_full_name(), "'"});
    endtask : pre_body

    // objections are dropped in post_body
    virtual task post_body();
        uvm_phase phase = get_starting_phase();
            
            if (phase != null)
            phase.drop_objection(this, {"Completed sequence '", get_full_name(), "'"});
    endtask : post_body

function void extract_data();
        
        //Inicijalno brisemo redove 
        letterData_1.delete();
		letterData_2.delete();
		letterData_3.delete();
		letterData_4.delete();
		letterData_5.delete();
		
		possition_1.delete();
		possition_2.delete();
		possition_3.delete();
		possition_4.delete();
		possition_5.delete();
		
		letterMatrix_1.delete();
		letterMatrix_2.delete();
		letterMatrix_3.delete();
		letterMatrix_4.delete();
		letterMatrix_5.delete();
		
		input_image_1.delete();
		input_image_2.delete();
		input_image_3.delete();
		input_image_4.delete();
		input_image_5.delete();
		
		text.delete();
		

        //---------------------- Getting numbers for letterData_1 ----------------------
        fd = $fopen(letterData_1_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED letterData_1_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                letterData_1.push_back(tmp);
            end
           
           
         //$display("Uspesno OTVORIO letterData_1_file");
        //`uvm_info(get_name(),$sformatf("Number of letterData_1 parameters in queue is: %d",letterData_1.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of letterData_1.txt: '%d' '%d' '%d'",letterData_1[0],letterData_1[1],letterData_1[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening letterData_1_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED letterData_1_file\n"),UVM_HIGH)
		
		
		//---------------------- Getting numbers for letterData_2 ----------------------
        fd = $fopen(letterData_2_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED letterData_2_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                letterData_2.push_back(tmp);
            end
           
           
        // $display("First three parameters of letterData_2.txt: '%d' '%d' '%d' ",letterData_2[0],letterData_2[1],letterData_2[2]);
        //`uvm_info(get_name(),$sformatf("Number of letterData_2 parameters in queue is: %d",letterData_2.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of letterData_2.txt: '%d' '%d' '%d'",letterData_2[0],letterData_2[1],letterData_2[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening letterData_2_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED letterData_2_file\n"),UVM_HIGH)
	
	
		//---------------------- Getting numbers for letterData_3 ----------------------
        fd = $fopen(letterData_3_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED letterData_3_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                letterData_3.push_back(tmp);
            end
           
           
        // $display("First three parameters of letterData_3.txt: '%d' '%d' '%d' ",letterData_3[0],letterData_3[1],letterData_3[2]);
        //`uvm_info(get_name(),$sformatf("Number of letterData_3 parameters in queue is: %d",letterData_3.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of letterData_3.txt: '%d' '%d' '%d'",letterData_3[0],letterData_3[1],letterData_3[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening letterData_3_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED letterData_3_file\n"),UVM_HIGH)
		
		
		//---------------------- Getting numbers for letterData_4 ----------------------
        fd = $fopen(letterData_4_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED letterData_4_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                letterData_4.push_back(tmp);
            end
           
           
        // $display("First three parameters of letterData_4.txt: '%d' '%d' '%d' ",letterData_4[0],letterData_4[1],letterData_4[2]);
        //`uvm_info(get_name(),$sformatf("Number of letterData_4 parameters in queue is: %d",letterData_4.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of letterData_4.txt: '%d' '%d' '%d'",letterData_4[0],letterData_4[1],letterData_4[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening letterData_4_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED letterData_4_file\n"),UVM_HIGH)
		
		
		//---------------------- Getting numbers for letterData_5 ----------------------
        fd = $fopen(letterData_5_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED letterData_5_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                letterData_5.push_back(tmp);
            end
           
       
        // $display("First three parameters of letterData_5.txt: '%d' '%d' '%d' ",letterData_5[0],letterData_5[1],letterData_5[2]);
        //`uvm_info(get_name(),$sformatf("Number of letterData_5 parameters in queue is: %d",letterData_5.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of letterData_5.txt: '%d' '%d' '%d'",letterData_5[0],letterData_5[1],letterData_5[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening letterData_5_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED letterData_5_file\n"),UVM_HIGH)
		
		
		
		//---------------------- Getting numbers for possition_1 ----------------------
        fd = $fopen(possition_1_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED possition_1_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                possition_1.push_back(tmp);
            end
           
       
        //`uvm_info(get_name(),$sformatf("Number of possition_1 parameters in queue is: %d",possition_1.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of possition_1.txt: '%d' '%d' '%d'",possition_1[0],possition_1[1],possition_1[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening possition_1_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED possition_1_file\n"),UVM_HIGH)
		
		
		//---------------------- Getting numbers for possition_2 ----------------------
        fd = $fopen(possition_2_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED possition_2_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                possition_2.push_back(tmp);
            end
           
       
        //`uvm_info(get_name(),$sformatf("Number of possition_2 parameters in queue is: %d",possition_2.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of possition_2.txt: '%d' '%d' '%d'",possition_2[0],possition_2[1],possition_2[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening possition_2_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED possition_2_file\n"),UVM_HIGH)
		
		
		//---------------------- Getting numbers for possition_3 ----------------------
        fd = $fopen(possition_3_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED possition_3_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                possition_3.push_back(tmp);
            end
           
       
        //`uvm_info(get_name(),$sformatf("Number of possition_3 parameters in queue is: %d",possition_3.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of possition_3.txt: '%d' '%d' '%d'",possition_3[0],possition_3[1],possition_3[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening possition_3_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED possition_3_file\n"),UVM_HIGH)
		
		
		//---------------------- Getting numbers for possition_4 ----------------------
        fd = $fopen(possition_4_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED possition_4_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                possition_4.push_back(tmp);
            end
           
       
        //`uvm_info(get_name(),$sformatf("Number of possition_4 parameters in queue is: %d",possition_4.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of possition_4.txt: '%d' '%d' '%d'",possition_4[0],possition_4[1],possition_4[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening possition_4_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED possition_4_file\n"),UVM_HIGH)
		
		
		//---------------------- Getting numbers for possition_5 ----------------------
        fd = $fopen(possition_5_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED possition_5_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                possition_5.push_back(tmp);
            end
           
       
        //`uvm_info(get_name(),$sformatf("Number of possition_5 parameters in queue is: %d",possition_5.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of possition_5.txt: '%d' '%d' '%d'",possition_5[0],possition_5[1],possition_5[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening possition_5_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED possition_5_file\n"),UVM_HIGH)
		
		
		
		//---------------------- Getting numbers for letterMatrix_1 ----------------------
        fd = $fopen(letterMatrix_1_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED letterMatrix_1_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                letterMatrix_1.push_back(tmp);
            end
           
       
        //`uvm_info(get_name(),$sformatf("Number of letterMatrix_1 parameters in queue is: %d",letterMatrix_1.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of letterMatrix_1.txt: '%d' '%d' '%d'",letterMatrix_1[0],letterMatrix_1[1],letterMatrix_1[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening letterMatrix_1_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED letterMatrix_1_file\n"),UVM_HIGH)
		
		
		//---------------------- Getting numbers for letterMatrix_2 ----------------------
        fd = $fopen(letterMatrix_2_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED letterMatrix_2_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                letterMatrix_2.push_back(tmp);
            end
           
       
        //`uvm_info(get_name(),$sformatf("Number of letterMatrix_2 parameters in queue is: %d",letterMatrix_2.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of letterMatrix_2.txt: '%d' '%d' '%d'",letterMatrix_2[0],letterMatrix_2[1],letterMatrix_2[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening letterMatrix_2_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED letterMatrix_2_file\n"),UVM_HIGH)
		
		
		//---------------------- Getting numbers for letterMatrix_3 ----------------------
        fd = $fopen(letterMatrix_3_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED letterMatrix_3_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                letterMatrix_3.push_back(tmp);
            end
           
       
        //`uvm_info(get_name(),$sformatf("Number of letterMatrix_3 parameters in queue is: %d",letterMatrix_3.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of letterMatrix_3.txt: '%d' '%d' '%d'",letterMatrix_3[0],letterMatrix_3[1],letterMatrix_3[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening letterMatrix_3_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED letterMatrix_3_file\n"),UVM_HIGH)
		
		
		//---------------------- Getting numbers for letterMatrix_4 ----------------------
        fd = $fopen(letterMatrix_4_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED letterMatrix_4_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                letterMatrix_4.push_back(tmp);
            end
           
       
        //`uvm_info(get_name(),$sformatf("Number of letterMatrix_4 parameters in queue is: %d",letterMatrix_4.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of letterMatrix_4.txt: '%d' '%d' '%d'",letterMatrix_4[0],letterMatrix_4[1],letterMatrix_4[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening letterMatrix_4_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED letterMatrix_4_file\n"),UVM_HIGH)
		
		
		//---------------------- Getting numbers for letterMatrix_5 ----------------------
        fd = $fopen(letterMatrix_5_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED letterMatrix_5_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                letterMatrix_5.push_back(tmp);
            end
           
       
        //`uvm_info(get_name(),$sformatf("Number of letterMatrix_5 parameters in queue is: %d",letterMatrix_5.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of letterMatrix_5.txt: '%d' '%d' '%d'",letterMatrix_5[0],letterMatrix_5[1],letterMatrix_5[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening letterMatrix_5_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED letterMatrix_5_file\n"),UVM_HIGH)
		
		
		
		//---------------------- Getting numbers for input_image_1 ----------------------
        fd = $fopen(input_image_1_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED input_image_1_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                input_image_1.push_back(tmp);
            end
           
       
        //`uvm_info(get_name(),$sformatf("Number of input_image_1 parameters in queue is: %d",input_image_1.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of input_image_1.txt: '%d' '%d' '%d'",input_image_1[0],input_image_1[1],input_image_1[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening input_image_1_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED input_image_1_file\n"),UVM_HIGH)
		
		
		//---------------------- Getting numbers for input_image_2 ----------------------
        fd = $fopen(input_image_2_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED input_image_2_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                input_image_2.push_back(tmp);
            end
           
       
        //`uvm_info(get_name(),$sformatf("Number of input_image_2 parameters in queue is: %d",input_image_2.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of input_image_2.txt: '%d' '%d' '%d'",input_image_2[0],input_image_2[1],input_image_2[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening input_image_2_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED input_image_2_file\n"),UVM_HIGH)
		
		
		//---------------------- Getting numbers for input_image_3 ----------------------
        fd = $fopen(input_image_3_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED input_image_3_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                input_image_3.push_back(tmp);
            end
           
       
        //`uvm_info(get_name(),$sformatf("Number of input_image_3 parameters in queue is: %d",input_image_3.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of input_image_3.txt: '%d' '%d' '%d'",input_image_3[0],input_image_3[1],input_image_3[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening input_image_3_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED input_image_3_file\n"),UVM_HIGH)
		
		
		//---------------------- Getting numbers for input_image_4 ----------------------
        fd = $fopen(input_image_4_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED input_image_4_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                input_image_4.push_back(tmp);
            end
           
       
        //`uvm_info(get_name(),$sformatf("Number of input_image_4 parameters in queue is: %d",input_image_4.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of input_image_4.txt: '%d' '%d' '%d'",input_image_4[0],input_image_4[1],input_image_4[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening input_image_4_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED input_image_4_file\n"),UVM_HIGH)
		
		
		//---------------------- Getting numbers for input_image_5 ----------------------
        fd = $fopen(input_image_5_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED input_image_5_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                input_image_5.push_back(tmp);
            end
           
       
        //`uvm_info(get_name(),$sformatf("Number of input_image_5 parameters in queue is: %d",input_image_5.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of input_image_5.txt: '%d' '%d' '%d'",input_image_5[0],input_image_5[1],input_image_5[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening input_image_5_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED input_image_5_file\n"),UVM_HIGH)
        
		
		//---------------------- Getting numbers for text ----------------------
        fd = $fopen(text_file, "r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED text_file"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                text.push_back(tmp);
            end
           
       
        //`uvm_info(get_name(),$sformatf("Number of text parameters in queue is: %d",text.size),UVM_HIGH)
        //`uvm_info(get_name(),$sformatf("First three parameters of text.txt: '%d' '%d' '%d'",text[0],text[1],text[2]),UVM_HIGH)
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening text_file"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED text_file\n"),UVM_HIGH)

    endfunction
    

endclass : base_seq_slave

`endif
