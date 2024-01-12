`ifndef TITLE_SCOREBOARD
`define TITLE_SCOREBOARD

class title_scoreboard extends uvm_scoreboard; 
    `uvm_analysis_imp_decl(_lite)
    `uvm_analysis_imp_decl(_stream)

    `uvm_component_utils(title_scoreboard)
	
	parameter IMAGE_1_ROW = 101;
	parameter IMAGE_2_ROW = 67;
	parameter IMAGE_3_ROW = 50;
	parameter IMAGE_4_ROW = 40;
	parameter IMAGE_5_ROW = 33;

    logic[31:0] command_in_progress;  //promenljiva u koju se smesta komanda iz axi_monitora
	integer offset_in_progress;
   
    int     fd = 0;
    integer    tmp;
    logic[15:0] received_image[$];    //red u koji se smestaju podaci iz master_monitora u scoreboard

    integer index;
    integer miss = 0; 

    integer    converted_received_image[$]; // posle koverzije u integer

    seq_item_master item_master;
    seq_item_lite   item_lite;
    uvm_analysis_imp_stream#(seq_item_master, title_scoreboard) port_axis; // recieve item from monitor_axi_stream_master
    uvm_analysis_imp_lite#(seq_item_lite, title_scoreboard)     port_axi_lite;
    
    // redovi u koje ce biti smestani "Zlatni vektori" 
    integer expected_image_1[$];
	integer expected_image_2[$];
	integer expected_image_3[$];
	integer expected_image_4[$];
	integer expected_image_5[$];

    integer start_addr_image_1 = (360 - IMAGE_1_ROW) * 640 * 3;
    integer start_addr_image_2 = (540 - IMAGE_2_ROW) * 960 * 3;
    integer start_addr_image_3 = (720 - IMAGE_3_ROW) * 1280 * 3;
	integer start_addr_image_4 = (900 - IMAGE_4_ROW) * 1600 * 3;
	integer start_addr_image_5 = (1080 - IMAGE_5_ROW) * 1920 * 3;

    integer part_of_image_1 = 1;
    integer part_of_image_2 = 1;
    integer part_of_image_3 = 1;
	integer part_of_image_4 = 1;
	integer part_of_image_5 = 1;

    // Putanje do "Zlatnih vektora"  treba ih navesti!!!
    string output_image_1_file = "../../../../../../data/ver_data/output_image_640x360.txt";
	string output_image_2_file = "../../../../../../data/ver_data/output_image_960x540.txt";
	string output_image_3_file = "../../../../../../data/ver_data/output_image_1280x720.txt";
	string output_image_4_file = "../../../../../../data/ver_data/output_image_1600x900.txt";
	string output_image_5_file = "../../../../../../data/ver_data/output_image_1920x1080.txt";
       
    function new(string name = "title_scoreboard", uvm_component parent = null);
        super.new(name,parent);
        extract_golden_vectors();
        port_axis = new("port_axis",this);
        port_axi_lite = new("port_axi_lite",this);
    endfunction : new

    function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
	endfunction : connect_phase 

    function void write_stream(seq_item_master item);		

        logic[15:0] bin_value;
        integer     binaryValue_uint;     

		received_image = item.axim_s_data;

        for(int i = 0; i < received_image.size; i++) begin
		
            bin_value = received_image[i];
            binaryValue_uint = bin_value; 
			
            converted_received_image.push_back(binaryValue_uint);    
        end
        
        //===================================================================
        //=================== COMPARING PHOTO 640x360 =======================
        //===================================================================
        if(converted_received_image.size() == IMAGE_1_ROW * 640 * 3) begin
            `uvm_info(get_name(), $sformatf(" Size are equal_1"),UVM_LOW)
            
            for(int i = 0; i < IMAGE_1_ROW * 640 * 3; i++) begin
				if(converted_received_image[i] != expected_image_1[start_addr_image_1 + i]) begin
					miss++;
					//$display("ind miss %d", i );
					//$display("ind miss in file %d", start_addr_image_1 + i + 1 );
					
				end;
            end
            `uvm_info(get_name(), $sformatf("+----------------------------------------------"),UVM_LOW)
            `uvm_info(get_name(), $sformatf("| After processing photo 640x360"),UVM_LOW)
            `uvm_info(get_name(), $sformatf("| Part of image %d.",part_of_image_1),UVM_LOW)
			`uvm_info(get_name(), $sformatf("| Start adress %d.",start_addr_image_1),UVM_LOW)
            `uvm_info(get_name(), $sformatf("| Number of misses %d",miss),UVM_LOW) 
            //`uvm_info(get_name(), $sformatf("| Index       %d",index + image_number_0 + 1),UVM_LOW)// +1 jer linije u fajlovima krecu od 1
            `uvm_info(get_name(), $sformatf("+----------------------------------------------"),UVM_LOW)
            
            converted_received_image.delete();
            received_image.delete();
            
            start_addr_image_1 = start_addr_image_1 - (IMAGE_1_ROW * 640 * 3); //smanjujemo startnu adresu 
            part_of_image_1 ++; //broji koliko je delova slike posalto
			miss = 0;
        end
        else begin
            `uvm_info(get_name(), $sformatf("Size are not equal_1"),UVM_LOW)
        end
		
		//===================================================================
        //=================== COMPARING PHOTO 960x540 =======================
        //===================================================================
        if(converted_received_image.size() == IMAGE_2_ROW * 960 * 3) begin
            `uvm_info(get_name(), $sformatf(" Size are equal_2"),UVM_LOW)
            
            for(int i = 0; i < IMAGE_2_ROW * 960 * 3; i++) begin
				if(converted_received_image[i] != expected_image_2[start_addr_image_2 + i])
					miss++;
            end
            `uvm_info(get_name(), $sformatf("+----------------------------------------------"),UVM_LOW)
            `uvm_info(get_name(), $sformatf("| After processing photo 960x540"),UVM_LOW)
            `uvm_info(get_name(), $sformatf("| Part of image %d.",part_of_image_2),UVM_LOW)
			`uvm_info(get_name(), $sformatf("| Start adress %d.",start_addr_image_2),UVM_LOW)
            `uvm_info(get_name(), $sformatf("| Number of misses %d",miss),UVM_LOW) 
            //`uvm_info(get_name(), $sformatf("| Index       %d",index + image_number_0 + 1),UVM_LOW)// +1 jer linije u fajlovima krecu od 1
            `uvm_info(get_name(), $sformatf("+----------------------------------------------"),UVM_LOW)
            
            converted_received_image.delete();
            received_image.delete();
            
            start_addr_image_2 = start_addr_image_2 - (IMAGE_2_ROW * 960 * 3); //smanjujemo startnu adresu 
            part_of_image_2 ++; //broji koliko je delova slike posalto
			miss = 0;
        end
        else begin
            `uvm_info(get_name(), $sformatf("Size are not equal_2"),UVM_LOW)
        end
		
		//===================================================================
        //=================== COMPARING PHOTO 1280x720 =======================
        //===================================================================
        if(converted_received_image.size() == IMAGE_3_ROW * 1280 * 3) begin
            `uvm_info(get_name(), $sformatf(" Size are equal_3"),UVM_LOW)
            
            for(int i = 0; i < IMAGE_3_ROW * 1280 * 3; i++) begin
				if(converted_received_image[i] != expected_image_3[start_addr_image_3 + i])
					miss++;
            end
            `uvm_info(get_name(), $sformatf("+----------------------------------------------"),UVM_LOW)
            `uvm_info(get_name(), $sformatf("| After processing photo 1280x720"),UVM_LOW)
            `uvm_info(get_name(), $sformatf("| Part of image %d.",part_of_image_3),UVM_LOW)
			`uvm_info(get_name(), $sformatf("| Start adress %d.",start_addr_image_3),UVM_LOW)
            `uvm_info(get_name(), $sformatf("| Number of misses %d",miss),UVM_LOW) 
            //`uvm_info(get_name(), $sformatf("| Index       %d",index + image_number_0 + 1),UVM_LOW)// +1 jer linije u fajlovima krecu od 1
            `uvm_info(get_name(), $sformatf("+----------------------------------------------"),UVM_LOW)
            
            converted_received_image.delete();
            received_image.delete();
            
            start_addr_image_3 = start_addr_image_3 - (IMAGE_3_ROW * 1280 * 3); //smanjujemo startnu adresu 
            part_of_image_3 ++; //broji koliko je delova slike posalto
			miss = 0;
        end
        else begin
            `uvm_info(get_name(), $sformatf("Size are not equal_3"),UVM_LOW)
        end
		
		//===================================================================
        //=================== COMPARING PHOTO 1600x900 =======================
        //===================================================================
        if(converted_received_image.size() == IMAGE_4_ROW * 1600 * 3) begin
            `uvm_info(get_name(), $sformatf(" Size are equal_4"),UVM_LOW)
            
            for(int i = 0; i < IMAGE_4_ROW * 1600 * 3; i++) begin
				if(converted_received_image[i] != expected_image_4[start_addr_image_4 + i])
					miss++;
            end
            `uvm_info(get_name(), $sformatf("+----------------------------------------------"),UVM_LOW)
            `uvm_info(get_name(), $sformatf("| After processing photo 1600x900"),UVM_LOW)
            `uvm_info(get_name(), $sformatf("| Part of image %d.",part_of_image_4),UVM_LOW)
			`uvm_info(get_name(), $sformatf("| Start adress %d.",start_addr_image_4),UVM_LOW)
            `uvm_info(get_name(), $sformatf("| Number of misses %d",miss),UVM_LOW) 
            //`uvm_info(get_name(), $sformatf("| Index       %d",index + image_number_0 + 1),UVM_LOW)// +1 jer linije u fajlovima krecu od 1
            `uvm_info(get_name(), $sformatf("+----------------------------------------------"),UVM_LOW)
            
            converted_received_image.delete();
            received_image.delete();
            
            start_addr_image_4 = start_addr_image_4 - (IMAGE_4_ROW * 1600 * 3); //smanjujemo startnu adresu 
            part_of_image_4 ++; //broji koliko je delova slike posalto
			miss = 0;
        end
        else begin
            `uvm_info(get_name(), $sformatf("Size are not equal_4"),UVM_LOW)
        end
		
		//===================================================================
        //=================== COMPARING PHOTO 1920x1080 =======================
        //===================================================================
        if(converted_received_image.size() == IMAGE_5_ROW * 1920 * 3) begin
            `uvm_info(get_name(), $sformatf(" Size are equal_5"),UVM_LOW)
            
            for(int i = 0; i < IMAGE_5_ROW * 1920 * 3; i++) begin
				if(converted_received_image[i] != expected_image_5[start_addr_image_5 + i])
					miss++;
            end
            `uvm_info(get_name(), $sformatf("+----------------------------------------------"),UVM_LOW)
            `uvm_info(get_name(), $sformatf("| After processing photo 1920x1080"),UVM_LOW)
            `uvm_info(get_name(), $sformatf("| Part of image %d.",part_of_image_5),UVM_LOW)
			`uvm_info(get_name(), $sformatf("| Start adress %d.",start_addr_image_5),UVM_LOW)
            `uvm_info(get_name(), $sformatf("| Number of misses %d",miss),UVM_LOW) 
            //`uvm_info(get_name(), $sformatf("| Index       %d",index + image_number_0 + 1),UVM_LOW)// +1 jer linije u fajlovima krecu od 1
            `uvm_info(get_name(), $sformatf("+----------------------------------------------"),UVM_LOW)
            
            converted_received_image.delete();
            received_image.delete();
            
            start_addr_image_5 = start_addr_image_5 - (IMAGE_5_ROW * 1920 * 3); //smanjujemo startnu adresu 
            part_of_image_5 ++; //broji koliko je delova slike posalto
			miss = 0;
        end
        else begin
            `uvm_info(get_name(), $sformatf("Size are not equal_5"),UVM_LOW)
        end

    endfunction : write_stream

    function void write_lite(seq_item_lite item);
        command_in_progress = item.COM_OR_POS;
		offset_in_progress = item.offset;
    endfunction : write_lite
    
    function void extract_golden_vectors();
        expected_image_1.delete();
        expected_image_2.delete();
        expected_image_3.delete();
		expected_image_4.delete();
		expected_image_5.delete();
        
        received_image.delete();
    
        //---------------------- Getting golden vector for photo_1----------------------
        fd = $fopen(output_image_1_file,"r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED output_image_1.txt"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                expected_image_1.push_back(tmp);
            end
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening output_image_1.txt"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED output_image_1.txt\n"),UVM_HIGH)
		
		
		//---------------------- Getting golden vector for photo_2----------------------
        fd = $fopen(output_image_2_file,"r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED output_image_2.txt"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                expected_image_2.push_back(tmp);
            end
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening output_image_2.txt"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED output_image_2.txt\n"),UVM_HIGH)
		
		
		//---------------------- Getting golden vector for photo_3----------------------
        fd = $fopen(output_image_3_file,"r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED output_image_3.txt"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                expected_image_3.push_back(tmp);
            end
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening output_image_3.txt"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED output_image_3.txt\n"),UVM_HIGH)
		
		
		//---------------------- Getting golden vector for photo_4----------------------
        fd = $fopen(output_image_4_file,"r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED output_image_4.txt"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                expected_image_4.push_back(tmp);
            end
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening output_image_4.txt"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED output_image_4.txt\n"),UVM_HIGH)
		
		
		//---------------------- Getting golden vector for photo_5----------------------
        fd = $fopen(output_image_5_file,"r");
        if(fd) begin 
            `uvm_info(get_name(), $sformatf("Successfully OPENED output_image_5.txt"),UVM_HIGH)

            while(!$feof(fd)) begin
                $fscanf(fd ,"%d\n",tmp);
                expected_image_5.push_back(tmp);
            end
        end
        else begin
            `uvm_info(get_name(), $sformatf("Error opening output_image_5.txt"),UVM_HIGH)    
        end
        $fclose(fd);
        `uvm_info(get_name(), $sformatf("Successfully CLOSED output_image_5.txt\n"),UVM_HIGH)

    endfunction

endclass : title_scoreboard


`endif 
