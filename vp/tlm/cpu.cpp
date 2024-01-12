#ifndef CPU_C
#define CPU_C
#include "cpu.hpp"

vector<sc_dt::sc_uint<16>> letterData;

Cpu::Cpu(sc_module_name name, char* input_video, char* input_titl):sc_module(name), input_video(input_video), input_titl(input_titl)
{
    SC_THREAD(sof);
    in_port0.bind(sig0);
    in_port1.bind(sig1);
    sig0 = sc_dt::SC_LOGIC_0;
    sig1 = sc_dt::SC_LOGIC_0;
    command = 0b00000000;
    
    frame_count = 0;
    sum_fps = 0;
	
    cout << "Cpu constucted" << endl;
}

void Cpu::sof()
{	
    unsigned char *buf;
    unsigned int LEN_MATRIX;
    unsigned int LEN_FRAME;
    sc_time start_time;
    sc_time end_time;
    sc_time transaction_time;
    sc_time time1;
    sc_time time2;
    
    int fps;
    

    // Učitaj video datoteku
    VideoCapture cap(input_video);

    // Provjeri da li se video uspješno otvorio
    if (!cap.isOpened()) 
        cout << "Error opening video file" << endl;

    ReadSrt Srb(input_titl);
    vector<int> startTime = Srb.getStartTimes();
    vector<int> endTime = Srb.getEndTimes();
    vector<string> text1 = Srb.getText1();
    vector<string> text2 = Srb.getText2();

    int max_index = startTime.size();
    int frame_per_secund = cap.get(CAP_PROP_FPS);    
    int delay = 1000 / frame_per_secund;
    int current_subtitle_index = 0;
    bool pom = true;
    bool pause = false;
    int width_frame = int(cap.get(CAP_PROP_FRAME_WIDTH));
    int height_frame = int(cap.get(CAP_PROP_FRAME_HEIGHT));
   
    int dimension;
    int bram_row;

    vector<sc_dt::sc_uint<16>> possition_letter;

    vector<vector<vector<sc_dt::sc_uint<1>>>> letterMatrix;

    if(width_frame + height_frame > 2750)
    {
        dimension = 4;
	letterMatrix = loadMatrix("../data/font_database1920.txt");
	LEN_MATRIX = D4_LETTER_MATRIX;
	LEN_FRAME = D4_FRAME_SIZE;
	bram_row = D4_BRAM;
	possition_letter = D4_possition;
    }
    else if(width_frame + height_frame > 2250)
    {
    	dimension = 3;
    	letterMatrix = loadMatrix("../data/font_database1600.txt");
    	LEN_MATRIX = D3_LETTER_MATRIX;
    	LEN_FRAME = D3_FRAME_SIZE;
    	bram_row = D3_BRAM;
    	possition_letter = D3_possition;
    }
    else if(width_frame + height_frame > 1750)
    {
    	dimension = 2;
    	letterMatrix = loadMatrix("../data/font_database1280.txt");
    	LEN_MATRIX = D2_LETTER_MATRIX;
    	LEN_FRAME = D2_FRAME_SIZE;
    	bram_row = D2_BRAM;
    	possition_letter = D2_possition;
    }
    else if(width_frame + height_frame > 1250)
    {
    	dimension = 1;
    	letterMatrix = loadMatrix("../data/font_database960.txt");
    	LEN_MATRIX = D1_LETTER_MATRIX;
    	LEN_FRAME = D1_FRAME_SIZE;
    	bram_row = D1_BRAM;
    	possition_letter = D1_possition;
    }
    else
    {
    	dimension = 0;
    	letterMatrix = loadMatrix("../data/font_database640.txt");
    	LEN_MATRIX = D0_LETTER_MATRIX;
    	LEN_FRAME = D0_FRAME_SIZE;
    	bram_row = D0_BRAM;
    	possition_letter = D0_possition;
    }


    vector<sc_dt::sc_uint<1>> transformedArray = transformMatrixArray(letterMatrix, letterData);
    letterData.push_back(dimension);

    pl_t pl;
    sc_time offset=SC_ZERO_TIME;

    #ifdef QUANTUM
    tlm_utils::tlm_quantumkeeper qk;
    qk.reset();
    #endif
	
    #ifdef QUANTUM
    qk.inc(sc_time(CLK_PERIOD, SC_NS));
    offset = qk.get_local_time();
    qk.set_and_sync(offset);
    #else
    offset += sc_time(CLK_PERIOD, SC_NS);
    #endif 

    ddr.clear();

    //***********************************************************************************
    //Proces slanje letterData u kome se nalaze informacije o slovima u BRAM(letterData)

    //Prvo saljemo u memory	
    ddr = letterData;
    buf=(unsigned char*)&ddr[0];

    pl.set_address(0);
    pl.set_data_length(SIZE_LETTER_DATA);
    pl.set_command(TLM_WRITE_COMMAND);
    pl.set_data_ptr(buf);
    s_cp_i1->b_transport(pl, offset);
    assert(pl.get_response_status() == TLM_OK_RESPONSE);
    qk.set_and_sync(offset);		

    ddr.clear();

    //Saljemo komandu da se letterData smesti u bram_letterData
    command = 0b00000001;
    buf = (unsigned char*)&command;

    pl.set_address(0x80000001);
    pl.set_data_length(1);
    pl.set_command(TLM_WRITE_COMMAND);
    pl.set_data_ptr(buf);
    s_cp_i0->b_transport(pl, offset);
    assert(pl.get_response_status() == TLM_OK_RESPONSE);
    qk.set_and_sync(offset);

    #ifdef QUANTUM
    qk.inc(sc_time(CLK_PERIOD, SC_NS));
    offset = qk.get_local_time();
    qk.set_and_sync(offset);
    #else
    offset += sc_time(CLK_PERIOD, SC_NS);
    #endif

    //Saljemo letterData iz memory u bram_letterData		
    pl.set_address(0x81000000);
    pl.set_data_length(SIZE_LETTER_DATA);
    pl.set_command(TLM_WRITE_COMMAND);
    s_cp_i0->b_transport(pl, offset);
    assert(pl.get_response_status() == TLM_OK_RESPONSE);
    qk.set_and_sync(offset);
    
    do{    
        #ifdef QUANTUM
        qk.inc(sc_time(CLK_PERIOD, SC_NS));
        offset = qk.get_local_time();
        qk.set_and_sync(offset);
        #endif
        tmp_sig0 = sig0.read();
    }while(tmp_sig0 == sc_dt::SC_LOGIC_0);

    //*******************************************************************************************

    //Slanje komande u ip, da se dodeli vrednost registrima frameWidth,..
    command = 0b01000000;
    buf = (unsigned char*)&command;

    pl.set_address(0x80000001);
    pl.set_data_length(1);
    pl.set_command(TLM_WRITE_COMMAND);
    pl.set_data_ptr(buf);
    s_cp_i0->b_transport(pl, offset);
    assert(pl.get_response_status() == TLM_OK_RESPONSE);
    qk.set_and_sync(offset);

    #ifdef QUANTUM
    qk.inc(sc_time(CLK_PERIOD, SC_NS));
    offset = qk.get_local_time();
    qk.set_and_sync(offset);
    #else
    offset += sc_time(CLK_PERIOD, SC_NS);
    #endif

    //*******************************************************************************************
    //Proces slanje matrica slova letterMatrix u BRAM

    for (const auto& value : transformedArray) {
        sc_dt::sc_uint<16> convertedValue = static_cast<sc_dt::sc_uint<16>>(value); // Konverzija vrednosti iz sc_uint<1> u sc_uint<16>
        ddr.push_back(convertedValue); // Dodavanje konvertovane vrednosti u vektor 'vecUint16'
    }

    //Saljemo letterMatrix u memory
    buf=(unsigned char*)&ddr[0];

    pl.set_address(0);
    pl.set_data_length(LEN_MATRIX);
    pl.set_command(TLM_WRITE_COMMAND);
    pl.set_data_ptr(buf);
    s_cp_i1->b_transport(pl, offset);
    assert(pl.get_response_status() == TLM_OK_RESPONSE);
    qk.set_and_sync(offset);	

    ddr.clear();

    //Slanje komande u ip
    command = 0b00000010;
    buf = (unsigned char*)&command;

    pl.set_address(0x80000001);
    pl.set_data_length(1);
    pl.set_command(TLM_WRITE_COMMAND);
    pl.set_data_ptr(buf);
    s_cp_i0->b_transport(pl, offset);
    assert(pl.get_response_status() == TLM_OK_RESPONSE);
    qk.set_and_sync(offset);

    #ifdef QUANTUM
    qk.inc(sc_time(CLK_PERIOD, SC_NS));
    offset = qk.get_local_time();
    qk.set_and_sync(offset);
    #else
    offset += sc_time(CLK_PERIOD, SC_NS);
    #endif

    //Slanje letterMatrix iz memory u bram_letterMatrix
    pl.set_address(0x81000000);
    pl.set_data_length(LEN_MATRIX);
    pl.set_command(TLM_WRITE_COMMAND);
    s_cp_i0->b_transport(pl, offset);
    assert(pl.get_response_status() == TLM_OK_RESPONSE);
    qk.set_and_sync(offset);


    do{    
        #ifdef QUANTUM
        qk.inc(sc_time(CLK_PERIOD, SC_NS));
        offset = qk.get_local_time();
        qk.set_and_sync(offset);
        #endif
        tmp_sig0 = sig0.read();
    }while(tmp_sig0 == sc_dt::SC_LOGIC_0);

    //*******************************************************************************************************
    //Proces slanja possition_letter u kome se nalaze informacije na kojoj adresi u bram_letterMatrix pocinje odgovarajuce slovo

    //Saljemo u memory prvo	
    ddr = possition_letter;
    buf=(unsigned char*)&ddr[0];

    pl.set_address(0);
    pl.set_data_length(SIZE_OF_POSSITION);
    pl.set_command(TLM_WRITE_COMMAND);
    pl.set_data_ptr(buf);
    s_cp_i1->b_transport(pl, offset);
    assert(pl.get_response_status() == TLM_OK_RESPONSE);
    qk.set_and_sync(offset);		

    ddr.clear();

    //Slanje komande da se possition_letter koji je poslat iz memory smesti u bram_possition
    command = 0b00001000;
    buf = (unsigned char*)&command;

    pl.set_address(0x80000001);
    pl.set_data_length(1);
    pl.set_command(TLM_WRITE_COMMAND);
    pl.set_data_ptr(buf);
    s_cp_i0->b_transport(pl, offset);
    assert(pl.get_response_status() == TLM_OK_RESPONSE);
    qk.set_and_sync(offset);

    #ifdef QUANTUM
    qk.inc(sc_time(CLK_PERIOD, SC_NS));
    offset = qk.get_local_time();
    qk.set_and_sync(offset);
    #else
    offset += sc_time(CLK_PERIOD, SC_NS);
    #endif

    //Saljemo letterData iz memory u bram_letterData		
    pl.set_address(0x81000000);
    pl.set_data_length(SIZE_OF_POSSITION);
    pl.set_command(TLM_WRITE_COMMAND);
    s_cp_i0->b_transport(pl, offset);
    assert(pl.get_response_status() == TLM_OK_RESPONSE);
    qk.set_and_sync(offset);

    do{    
        #ifdef QUANTUM
        qk.inc(sc_time(CLK_PERIOD, SC_NS));
        offset = qk.get_local_time();
        qk.set_and_sync(offset);
        #endif
        tmp_sig0 = sig0.read();
    }while(tmp_sig0 == sc_dt::SC_LOGIC_0);

    //*********************************************************************************************
    //Ucitavamo sliku i vrsimo modifikacu sliku u slucaju da je potrebno 

    Mat slika;
    bool send_text = true;
    while(cap.read(slika))
    {
        // Pokušaj dohvatiti trenutno vrijeme u video datoteci     
        int current_time = cap.get(CAP_PROP_POS_MSEC);

        //convert Mat to vector<sc_uint<16>> and added to ddr
        matToVector(slika);

        start_time = sc_time_stamp();

        //******************************************************************************************
        //Saljemo celu sliku u memory
        buf=(unsigned char*)&ddr[0];

        pl.set_address(0);
        pl.set_data_length(LEN_FRAME);
        pl.set_command(TLM_WRITE_COMMAND);
        pl.set_data_ptr(buf);
        s_cp_i1->b_transport(pl, offset);
        assert(pl.get_response_status() == TLM_OK_RESPONSE);
        qk.set_and_sync(offset);
		        
        #ifdef QUANTUM
        qk.inc(sc_time(CLK_PERIOD, SC_NS));
        offset = qk.get_local_time();
        qk.set_and_sync(offset);
        #else
        offset += sc_time(CLK_PERIOD, SC_NS);
        #endif

        ddr.clear();	

        //*****************************************************************************************
        //Slanje stringa koji treba da se ispise na slici i on je isti za vise slika, nije ga potrebno ponovo slati

        if (current_subtitle_index < max_index && current_time >= startTime[current_subtitle_index]) {
            if(send_text){
	        send_text = false;

	        string st1 = text1[current_subtitle_index];
	        string st2 = text2[current_subtitle_index];

	        vector<sc_dt::sc_uint<16>> text1_vector;
	        vector<sc_dt::sc_uint<16>> text2_vector;
	        vector<sc_dt::sc_uint<16>> text_splited;

	        stringToVector(st1,text1_vector);
	        stringToVector(st2,text2_vector);

	        text_splited = splitText(text1_vector, text2_vector, width_frame);
	        int size_text = text_splited.size();

                //*******************************************************************************
                //Proces slanja splitovanog texta u bram_text

	        //Transfer text_splited u memory
	        ddr = text_splited;
	        buf=(unsigned char*)&ddr[0];

	        pl.set_address(LEN_FRAME);
	        pl.set_data_length(size_text);
	        pl.set_command(TLM_WRITE_COMMAND);
	        pl.set_data_ptr(buf);
	        s_cp_i1->b_transport(pl, offset);
	        assert(pl.get_response_status() == TLM_OK_RESPONSE);
	        qk.set_and_sync(offset);

	        ddr.clear();

	        //Slanje size_text u ip
	        buf = (unsigned char*)&size_text;

	        pl.set_address(0x80000100);
	        pl.set_data_length(1);
	        pl.set_command(TLM_WRITE_COMMAND);
	        pl.set_data_ptr(buf);
	        s_cp_i0->b_transport(pl, offset);
	        assert(pl.get_response_status() == TLM_OK_RESPONSE);
	        qk.set_and_sync(offset);

	        #ifdef QUANTUM
	        qk.inc(sc_time(CLK_PERIOD, SC_NS));
	        offset = qk.get_local_time();
	        qk.set_and_sync(offset);
	        #else
	        offset += sc_time(CLK_PERIOD, SC_NS);
	        #endif

	        //Slanje komande za smestanje splitovanog teksta u bram_text
	        command = 0b00000100;
	        buf = (unsigned char*)&command;

	        pl.set_address(0x80000001);
	        pl.set_data_length(1);
	        pl.set_command(TLM_WRITE_COMMAND);
	        pl.set_data_ptr(buf);
	        s_cp_i0->b_transport(pl, offset);
	        assert(pl.get_response_status() == TLM_OK_RESPONSE);
	        qk.set_and_sync(offset);

	        #ifdef QUANTUM
	        qk.inc(sc_time(CLK_PERIOD, SC_NS));
	        offset = qk.get_local_time();
	        qk.set_and_sync(offset);
	        #else
	        offset += sc_time(CLK_PERIOD, SC_NS);
	        #endif

	        //Slanje text_splited u bram_text
	        pl.set_address(0x81000000 + LEN_FRAME);
	        pl.set_data_length(size_text);
	        pl.set_command(TLM_WRITE_COMMAND);
	        s_cp_i0->b_transport(pl, offset);
	        assert(pl.get_response_status() == TLM_OK_RESPONSE);
	        qk.set_and_sync(offset);

	        do{    
                    #ifdef QUANTUM
                    qk.inc(sc_time(CLK_PERIOD, SC_NS));
                    offset = qk.get_local_time();
                    qk.set_and_sync(offset);
                    #endif
                    tmp_sig0 = sig0.read();
                }while(tmp_sig0 == sc_dt::SC_LOGIC_0);

                //Kraj procesa slanja splitovanog texta
                //********************************************************************************************

            }

            // ********************************************************************************************
            //Slanje delova slike sve dok se ne ispise celi text na sliku

            int adress_row;
            int tmp_pic = 1;
            do
            {	
                adress_row = height_frame - bram_row * tmp_pic;

	        if(adress_row < 0)
	            adress_row = 0;

	        //comanda da dio slike smesti u bram_photo
	        command = 0b00010000;
	        buf = (unsigned char*)&command;

	        pl.set_address(0x80000001);
	        pl.set_data_length(1);
	        pl.set_command(TLM_WRITE_COMMAND);
	        pl.set_data_ptr(buf);
	        s_cp_i0->b_transport(pl, offset);
	        assert(pl.get_response_status() == TLM_OK_RESPONSE);
	        qk.set_and_sync(offset);

                #ifdef QUANTUM
                qk.inc(sc_time(CLK_PERIOD, SC_NS));
                offset = qk.get_local_time();
                qk.set_and_sync(offset);
                #else
                offset += sc_time(CLK_PERIOD, SC_NS);
                #endif
            
	        //Saljemo dio slike iz memory u bram_text
	        pl.set_address(0x81000000 + adress_row * width_frame * 3);
	        pl.set_data_length(bram_row * width_frame * 3);
	        pl.set_command(TLM_WRITE_COMMAND);
	        s_cp_i0->b_transport(pl, offset);
	        assert(pl.get_response_status() == TLM_OK_RESPONSE);
	        qk.set_and_sync(offset);

	        do{    
                    #ifdef QUANTUM
                    qk.inc(sc_time(CLK_PERIOD, SC_NS));
                    offset = qk.get_local_time();
                    qk.set_and_sync(offset);
                    #endif
                    tmp_sig0 = sig0.read();
                }while(tmp_sig0 == sc_dt::SC_LOGIC_0);

	        //Saljemo informaciju o kordinati y koja se odnosi na poslednji red slike koji je poslat
	        int tmp_y = height_frame - adress_row;
	        buf = (unsigned char*)&tmp_y;

	        pl.set_address(0x80000010);
	        pl.set_data_length(1);
	        pl.set_command(TLM_WRITE_COMMAND);
	        pl.set_data_ptr(buf);
	        s_cp_i0->b_transport(pl, offset);
	        assert(pl.get_response_status() == TLM_OK_RESPONSE);
	        qk.set_and_sync(offset);

                #ifdef QUANTUM
                qk.inc(sc_time(CLK_PERIOD, SC_NS));
                offset = qk.get_local_time();
                qk.set_and_sync(offset);
                #else
                offset += sc_time(CLK_PERIOD, SC_NS);
                #endif

	        //Saljemo komandu da pocne da obradjuje poslati deo slike
	        command = 0b00100000;
	        buf = (unsigned char*)&command;

            	time1 = sc_time_stamp();

	        pl.set_address(0x80000001);
	        pl.set_data_length(1);
	        pl.set_command(TLM_WRITE_COMMAND);
	        pl.set_data_ptr(buf);
	        s_cp_i0->b_transport(pl, offset);
	        assert(pl.get_response_status() == TLM_OK_RESPONSE);
	        qk.set_and_sync(offset);

                #ifdef QUANTUM
                qk.inc(sc_time(CLK_PERIOD, SC_NS));
                offset = qk.get_local_time();
                qk.set_and_sync(offset);
                #else
                offset += sc_time(CLK_PERIOD, SC_NS);
                #endif

	        do{
	            #ifdef QUANTUM
	            qk.inc(sc_time(CLK_PERIOD, SC_NS));
	            offset = qk.get_local_time();
	            qk.set_and_sync(offset);
	            #endif
	            tmp_sig0=sig0.read();
	        } while(tmp_sig0 == sc_dt::SC_LOGIC_0);

            	time2 = sc_time_stamp();
            	transaction_time = time2 - time1;
            	//cout << "Vreme provedeno u komadi 6: " << transaction_time << endl;

                //***********************************************************************************
                //Saljemo komandu da pocne da salje obradjeni deo slike
                command = 0b10000000;
                buf = (unsigned char*)&command;

                pl.set_address(0x80000001);
                pl.set_data_length(1);
                pl.set_command(TLM_WRITE_COMMAND);
                pl.set_data_ptr(buf);
                s_cp_i0->b_transport(pl, offset);
                assert(pl.get_response_status() == TLM_OK_RESPONSE);
                qk.set_and_sync(offset);

                
                #ifdef QUANTUM
                qk.inc(sc_time(CLK_PERIOD, SC_NS));
                offset = qk.get_local_time();
                qk.set_and_sync(offset);
                #else
                offset += sc_time(CLK_PERIOD, SC_NS);
                #endif

	        //Saljemo obradjeni dio slike nazad u memory
	        pl.set_address(0x81000000 + adress_row * width_frame * 3);
	        pl.set_data_length(bram_row * width_frame * 3);
	        pl.set_command(TLM_READ_COMMAND);
	        s_cp_i0->b_transport(pl, offset);
	        assert(pl.get_response_status() == TLM_OK_RESPONSE);	
	        qk.set_and_sync(offset);

	        do{
                    #ifdef QUANTUM
                    qk.inc(sc_time(CLK_PERIOD, SC_NS));
                    offset = qk.get_local_time();
                    qk.set_and_sync(offset);
                    #endif
                    tmp_sig0=sig0.read();
                } while(tmp_sig0 == sc_dt::SC_LOGIC_0);

	        tmp_sig1 = sig1.read();
	        
	    	//cout << "Poslato je " << tmp_pic << " dio slike" << endl;
	        tmp_pic++;

            }while(tmp_sig1 == sc_dt::SC_LOGIC_0 || adress_row == 0);

            if(current_time >= endTime[current_subtitle_index]){
      	        current_subtitle_index += 1;
              	send_text = true;
            }

            frame_count += 1;

            end_time = sc_time_stamp();
            transaction_time = end_time - start_time;
            fps = sc_time(1, SC_SEC) / transaction_time;
            sum_fps += fps;

            cout << "\tVREME OBRADE SLIKE: " << transaction_time << endl;
            cout << "\tFPS: " << fps << endl;
            
        }

        pl.set_address(0);
        pl.set_data_length(LEN_FRAME);
        pl.set_command(TLM_READ_COMMAND);
        s_cp_i1->b_transport(pl, offset);
        assert(pl.get_response_status() == TLM_OK_RESPONSE);
        qk.set_and_sync(offset);

        vector<sc_dt::sc_uint<16>> frame_uint8;
        buf = pl.get_data_ptr();

        for(unsigned int i=0; i<pl.get_data_length(); i++)
        {
            frame_uint8.push_back(((sc_dt::sc_uint<16>*)buf)[i]);
        }

        cv:Mat frame_finish;
        frame_finish = vectorToMat(frame_uint8, slika.cols, slika.rows);

        char c = cv::waitKey(delay);
        if (c == 27)  // ESC tipka
      	    pom = false;
        else if ( c == ' ' && pause)
            pause = false;
        else if ( c == ' ' && !pause)
            pause = true;

        if(pom){
  	    // Show video frame
    	    cv::imshow("Video", frame_finish);    		
	          
            while (pause){    			
                c = cv::waitKey(delay);
                if (c == ' ')
                    pause = false;
                else if (c == 27){
	            pause = false;
	            pom = false;
                }	
            }
        }
        else
            break;

        cout << "VREME SIMULACIJE: " << sc_time_stamp() << endl;
    }

    destroyAllWindows();

    cap.release();
    
    #ifdef QUANTUM
    qk.inc(sc_time(1, SC_SEC));
    offset = qk.get_local_time();
    qk.set_and_sync(offset);
    #endif    

}


void Cpu::matToVector(const cv::Mat& mat)
{
    if(ddr.size() != 0) ddr.clear();

    // Provjera da li je Mat objekt trokanalna slika
    if (mat.channels() != 3) {
        // Greška - očekuje se trokanalna slika
    }

    // Kopiranje podataka iz Mat objekta u vektor
    if (mat.isContinuous()) {
        // Ako je Mat objekt kontinuiran, možemo jednostavno kopirati sve podatke u vektor
        const uchar* ptr = mat.ptr<uchar>(0);
        ddr.assign(ptr, ptr + mat.total() * mat.channels());
    }
    else {
        // Ako Mat objekt nije kontinuiran, moramo kopirati red po red
        for (int i = 0; i < mat.rows; i++) {
            const uchar* rowPtr = mat.ptr<uchar>(i);
            for (int j = 0; j < mat.cols; j++) {
                ddr.push_back(rowPtr[j * 3]);  // Plava komponenta piksela
                ddr.push_back(rowPtr[j * 3 + 1]);  // Zelena komponenta piksela
                ddr.push_back(rowPtr[j * 3 + 2]);  // Crvena komponenta piksela
            }
        }
    }    
}


cv::Mat Cpu::vectorToMat(const vector<sc_dt::sc_uint<16>>& data, int width, int height)
{
    // Provera veličine vektora
    if (data.size() != width * height * 3) {
        // Greška - veličina vektora se ne podudara sa očekivanom veličinom Mat objekta
        return cv::Mat();
    }

    // Kreiranje Mat objekta
    cv::Mat mat(height, width, CV_8UC3);

    // Kopiranje podataka iz vektora u Mat objekat
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            int idx = (i * width + j) * 3;
            mat.at<cv::Vec3b>(i, j) = cv::Vec3b(data[idx], data[idx + 1], data[idx + 2]);
        }
    }

    return mat;
}

vector<vector<vector<sc_dt::sc_uint<1>>>> Cpu::loadMatrix(const string& fileName) {
    ifstream file(fileName);
    vector<vector<vector<sc_dt::sc_uint<1>>>> matrixArray;
    vector<vector<sc_dt::sc_uint<1>>> currentMatrix;

    if (file) {
        string line;
        while (getline(file, line)) {
            if (line.empty()) {
                if (!currentMatrix.empty()) {
                    matrixArray.push_back(currentMatrix);
                    currentMatrix.clear();
                }
            }
            else {
                vector<sc_dt::sc_uint<1>> row;
                istringstream lineStream(line);
                int number;
                while (lineStream >> number) 
                    row.push_back(static_cast<sc_dt::sc_uint<1>>(number));

                currentMatrix.push_back(row);
            }
        }

        // Add the last matrix if not added due to end of file
        if (!currentMatrix.empty()) {
            matrixArray.push_back(currentMatrix);
        }

        file.close();
    }
    else {
    	cerr << "Failed to open file: " << fileName << endl;
    }

    return matrixArray;
}

vector<sc_dt::sc_uint<1>> Cpu::transformMatrixArray(const vector<vector<vector<sc_dt::sc_uint<1>>>>& matrixArray, vector<sc_dt::sc_uint<16>>& letterData) {
    vector<sc_dt::sc_uint<1>> transformedArray;

    int maxHeight = 0; // Najveća visina slova

    for (const auto& matrix : matrixArray) {
        //int startPos = transformedArray.size(); // Početna pozicija trenutne matrice u transformisanom nizu

        // Dodajemo elemente matrice slova
        for (const auto& row : matrix) {
            transformedArray.insert(transformedArray.end(), row.begin(), row.end());
        }

        sc_dt::sc_uint<16> width = matrix[0].size(); // Širina matrice
        sc_dt::sc_uint<16> height = matrix.size(); // Visina matrice

        // letterData.push_back(startPos); // Dodajemo početnu poziciju
        letterData.push_back(width); // Dodajemo širinu
        letterData.push_back(height); // Dodajemo visinu

        // Ažuriramo najveću visinu slova
        if (height > maxHeight) {
            maxHeight = height;
        }
    }

    letterData.push_back(maxHeight); // Dodajemo najveću visinu slova

    return transformedArray;
}

void Cpu::stringToVector(const string& str, vector<sc_dt::sc_uint<16>>& asciiVec){
    for (int i = 0; i < str.length(); i++)
    {
	char c = str[i];   	
        unsigned char uc = static_cast<unsigned char>(c);
	int ascii = static_cast<int>(uc);

        if( ascii > 195)
	    continue;

	if( ascii == 161)
          ascii = 96;
        else if( ascii == 160)
          ascii = 97;
        else if ( ascii == 145)
          ascii = 98;
        else if( ascii == 144)
          ascii = 99;
        else if ( ascii == 141)
          ascii = 100; 
        else if( ascii == 140)
          ascii = 101;
        else if ( ascii == 135)
          ascii = 102;
        else if( ascii == 134)
          ascii = 103;
        else if ( ascii == 190)
          ascii = 104; 
        else if( ascii == 189)
          ascii = 105;
        else 
          ascii = ascii - 32;

	asciiVec.push_back(static_cast<sc_dt::sc_uint<16>>(ascii));
    }
}


vector<sc_dt::sc_uint<16>> Cpu::splitText(const vector<sc_dt::sc_uint<16>>& text1, const vector<sc_dt::sc_uint<16>>& text2, int photoWidth){
    int space = letterData[0];
    int rowLen1 = 0, rowLen2 = 0;
    int razmak = letterData[213] + 1;

    vector<sc_dt::sc_uint<16>> result;  // Koristi result umesto reversedResult
    vector<sc_dt::sc_uint<16>> currentRow1, currentRow2;
    int lenR1, lenR2;
    int i = 0;

    while (i < text1.size()) {
        int j = i;
        while (j < text1.size() && text1[j] != 0) {
            j++;
        }

        vector<sc_dt::sc_uint<16>> rijec1(text1.begin() + i, text1.begin() + j);
        lenR1 = getStringWidth(rijec1, razmak);

        if (currentRow1.empty()) {
            currentRow1 = rijec1;
            rowLen1 = lenR1 ;
        } 
        else {
            if (rowLen1 + lenR1 + space + razmak > photoWidth) {
                result.insert(result.begin(), currentRow1.begin(), currentRow1.end());
                result.insert(result.begin(), 255); // Dodavanje vrednosti 255 za razdvajanje redova
                currentRow1 = rijec1;
                rowLen1 = lenR1;
            }
            else {
                currentRow1.insert(currentRow1.end(), rijec1.begin(), rijec1.end());
                rowLen1 += lenR1;
            }
        }

        if (j < text1.size()) {
            currentRow1.push_back(text1[j]);
            rowLen1 += 2*razmak + space;
        }

        i = j + 1;
    }

    if (!currentRow1.empty()) {
        result.insert(result.begin(), currentRow1.begin(), currentRow1.end());
        result.insert(result.begin(), 255); // Dodavanje vrednosti 255 na kraju poslednjeg reda
    }

    int k = 0;
    while (k < text2.size()) {
        int j = k;
        while (j < text2.size() && text2[j] != 0) {
            j++;
        }

        vector<sc_dt::sc_uint<16>> rijec2(text2.begin() + k, text2.begin() + j);
        lenR2 = getStringWidth(rijec2, razmak);

        if (currentRow2.empty()) {
            currentRow2 = rijec2;
            rowLen2 = lenR2 ;
        }
        else {
            if (rowLen2 + lenR2 + space + razmak > photoWidth) {
                result.insert(result.begin(), currentRow2.begin(), currentRow2.end());
                result.insert(result.begin(), 255); // Dodavanje vrednosti 255 za razdvajanje redova
                currentRow2 = rijec2;
                rowLen2 = lenR2;
            }
            else {
                currentRow2.insert(currentRow2.end(), rijec2.begin(), rijec2.end());
                rowLen2 += lenR2;
            }
        }

        if (j < text2.size()) {
            currentRow2.push_back(text2[j]);
            rowLen2 += 2*razmak + space;
        }

        k = j + 1;
    }

    if (!currentRow2.empty()) {
        result.insert(result.begin(), currentRow2.begin(), currentRow2.end());
        result.insert(result.begin(), 255); // Dodavanje vrednosti 255 na kraju poslednjeg reda
    }

    return result;
}

int Cpu::getStringWidth(vector<sc_dt::sc_uint<16>> st, int space)
{
    int width = 0;
  
    for (int i = 0; i < st.size(); i++)
    {
        int ascii = static_cast<int>(st[i]);

	width += letterData[ascii*2] + space;		
    }
    return width;
}


#endif //CPU_C
