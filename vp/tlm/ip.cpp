#ifndef IP_C
#define IP_C
#include "ip.hpp"

Ip::Ip(sc_module_name name) : sc_module(name) 
{
    SC_THREAD(proc);
    s_ip_t0.register_b_transport(this, &Ip::b_transport0);

    command = 0b00000000;
    possitionY = 0;

    number_character_text_bram = 0;
    number_rows = 0;
    number_character_row1 = 0;
    number_character_row2 = 0;
    number_character_row3 = 0;
    number_character_row4 = 0;

    tmp_sig0 = sc_dt::SC_LOGIC_0;
    tmp_sig1 = sc_dt::SC_LOGIC_0;

    bram_photo.reserve(D4_FRAME_SIZE);
    bram_letterData.reserve(SIZE_LETTER_DATA);
    bram_letterMatrix.reserve(D4_LETTER_MATRIX);
    bram_text.reserve(200);
    bram_possition.reserve(SIZE_OF_POSSITION);
    cout << "IP created" << endl;
}

void Ip::b_transport0(pl_t& pl, sc_time& offset) 
{
    tlm_command cmd = pl.get_command();
    sc_dt::uint64 adr = pl.get_address();
    const unsigned char* buf = pl.get_data_ptr();
    unsigned int len = pl.get_data_length();

    sc_dt::uint64 temp = adr - 0x80000000;

    switch (cmd) 
    {
        case TLM_WRITE_COMMAND:
            switch (temp) 
            {
                case 0x00000001:
                    command = int(*buf);
                    pl.set_response_status(TLM_OK_RESPONSE);
                    break;
                case 0x00000010:
                    possitionY = *(int*)buf;
                    pl.set_response_status(TLM_OK_RESPONSE);
                    break;
                case 0x00000100:
                    text_size = *(int*)buf;
                    pl.set_response_status(TLM_OK_RESPONSE);
                    break;
                default:
                    pl.set_response_status(TLM_COMMAND_ERROR_RESPONSE);
            }
            break;

        case TLM_READ_COMMAND:
            break;

        default:
            pl.set_response_status(TLM_COMMAND_ERROR_RESPONSE);
    }
    offset += sc_time(10, SC_NS);
}

void Ip::proc() 
{
    sc_time offset = SC_ZERO_TIME;
    sc_dt::sc_uint<16> fifo_read;

    #ifdef QUANTUM
    tlm_utils::tlm_quantumkeeper qk;
    qk.reset();
    #endif

    while (1) 
    {
        while (command != 0b00000001 && command != 0b00000010 && command != 0b00000100 && command != 0b00001000 && command != 0b00010000 && command != 0b00100000 && command != 0b01000000 && command != 0b10000000) 
        {
            #ifdef QUANTUM
            qk.inc(sc_time(10, SC_NS));
            offset = qk.get_local_time();
            qk.set_and_sync(offset);
            #else
            offset += sc_time(10, SC_NS);
            #endif
        }

        switch (command) 
        {
            case 0b00000001:
                bram_letterData.clear();
                tmp_sig0 = sc_dt::SC_LOGIC_0;
                out_port0->write(tmp_sig0);

                tmp_sig1 = sc_dt::SC_LOGIC_0;
                out_port1->write(tmp_sig1);

                for (int i = 0; i < SIZE_LETTER_DATA; i++)
                {
                    while(!p_fifo_in->nb_read(fifo_read))
                    {
                        #ifdef QUANTUM
                        qk.inc(sc_time(CLK_PERIOD, SC_NS));
                        offset = qk.get_local_time();
                        qk.set_and_sync(offset);
                        #else
                        offset += sc_time(CLK_PERIOD, SC_NS);
                        #endif
                    }

                    bram_letterData[i] = (sc_dt::sc_uint<8>)fifo_read;                    
                
                }
                tmp_sig0 = sc_dt::SC_LOGIC_1;
                out_port0->write(tmp_sig0);
                break;

            case 0b00000010:
                bram_letterMatrix.clear();
                tmp_sig0 = sc_dt::SC_LOGIC_0;
                out_port0->write(tmp_sig0);

                tmp_sig1 = sc_dt::SC_LOGIC_0;
                out_port1->write(tmp_sig1);

                for (int i = 0; i < LEN_MATRIX; i++)
                {
                    while(!p_fifo_in->nb_read(fifo_read))
                    {
                        #ifdef QUANTUM
                        qk.inc(sc_time(CLK_PERIOD, SC_NS));
                        offset = qk.get_local_time();
                        qk.set_and_sync(offset);
                        #else
                        offset += sc_time(CLK_PERIOD, SC_NS);
                        #endif
                    }

                    bram_letterMatrix[i] = (sc_dt::sc_uint<1>)fifo_read;                    
                
                }
                tmp_sig0 = sc_dt::SC_LOGIC_1;
                out_port0->write(tmp_sig0);
                break;

            case 0b00000100:
                number_character_text_bram = 0;
                number_rows = 0;
                number_character_row1 = 0;
                number_character_row2 = 0;
                number_character_row3 = 0;
                number_character_row4 = 0;

                bram_text.clear();
                tmp_sig0 = sc_dt::SC_LOGIC_0;
                out_port0->write(tmp_sig0);

                tmp_sig1 = sc_dt::SC_LOGIC_0;
                out_port1->write(tmp_sig1);

                for (int i = 0; i < text_size; i++)
                {
                    while(!p_fifo_in->nb_read(fifo_read))
                    {
                        #ifdef QUANTUM
                        qk.inc(sc_time(CLK_PERIOD, SC_NS));
                        offset = qk.get_local_time();
                        qk.set_and_sync(offset);
                        #else
                        offset += sc_time(CLK_PERIOD, SC_NS);
                        #endif
                    }

                    bram_text[i] = (sc_dt::sc_uint<8>)fifo_read;  

                    number_character_text_bram++;
                    if (bram_text[i] == 255) {
                        number_rows++;
                    }

                    if (number_rows == 1) {
                        number_character_row1++;
                    } 
                    else if (number_rows == 2) {
                        number_character_row2++;
                    } 
                    else if (number_rows == 3) {
                        number_character_row3++;
                    } 
                    else if (number_rows == 4) {
                        number_character_row4++;
                    }
                }
                tmp_sig0 = sc_dt::SC_LOGIC_1;
                out_port0->write(tmp_sig0);
                break;

            case 0b00001000:
                bram_possition.clear();
                tmp_sig0 = sc_dt::SC_LOGIC_0;
                out_port0->write(tmp_sig0);

                tmp_sig1 = sc_dt::SC_LOGIC_0;
                out_port1->write(tmp_sig1);

                for (int i = 0; i < SIZE_OF_POSSITION; i++)
                {
                    while(!p_fifo_in->nb_read(fifo_read))
                    {
                        #ifdef QUANTUM
                        qk.inc(sc_time(CLK_PERIOD, SC_NS));
                        offset = qk.get_local_time();
                        qk.set_and_sync(offset);
                        #else
                        offset += sc_time(CLK_PERIOD, SC_NS);
                        #endif
                    }

                    bram_possition[i] = fifo_read;                    
                
                }
                tmp_sig0 = sc_dt::SC_LOGIC_1;
                out_port0->write(tmp_sig0);
                break;

            case 0b00010000:
                bram_photo.clear();
                tmp_sig0 = sc_dt::SC_LOGIC_0;
                out_port0->write(tmp_sig0);

                tmp_sig1 = sc_dt::SC_LOGIC_0;
                out_port1->write(tmp_sig1);

                for (int i = 0; i < frameWidth*bram_row*3; i++)
                {
                    while(!p_fifo_in->nb_read(fifo_read))
                    {
                        #ifdef QUANTUM
                        qk.inc(sc_time(CLK_PERIOD, SC_NS));
                        offset = qk.get_local_time();
                        qk.set_and_sync(offset);
                        #else
                        offset += sc_time(CLK_PERIOD, SC_NS);
                        #endif
                    }

                    bram_photo[i] = (sc_dt::sc_uint<8>)fifo_read;                    
                
                }
                tmp_sig0 = sc_dt::SC_LOGIC_1;
                out_port0->write(tmp_sig0);
                break;

            case 0b01000000:
                // MOZE NA POCETKU KOMANDE 2, KADA SE PRIMAJU PODACI ZA letterMatrix
                if (bram_letterData[213] == 0) {
                    frameWidth = D0_WIDTH;
                    frameHeight = D0_HEIGHT;
                    bram_row = D0_BRAM;
                    LEN_MATRIX = D0_LETTER_MATRIX;
                }
                else if (bram_letterData[213] == 1) {
                    frameWidth = D1_WIDTH;
                    frameHeight = D1_HEIGHT;
                    bram_row = D1_BRAM;
                    LEN_MATRIX = D1_LETTER_MATRIX;
                }
                else if (bram_letterData[213] == 2) {
                    frameWidth = D2_WIDTH;
                    frameHeight = D2_HEIGHT;
                    bram_row = D2_BRAM;
                    LEN_MATRIX = D2_LETTER_MATRIX;
                }
                else if (bram_letterData[213] == 3) {
                    frameWidth = D3_WIDTH;
                    frameHeight = D3_HEIGHT;
                    bram_row = D3_BRAM;
                    LEN_MATRIX = D3_LETTER_MATRIX;
                }
                else {
                    frameWidth = D4_WIDTH;
                    frameHeight = D4_HEIGHT;
                    bram_row = D4_BRAM;
                    LEN_MATRIX = D4_LETTER_MATRIX;
                }
                break;

            case 0b10000000:
                tmp_sig0 = sc_dt::SC_LOGIC_0;
                out_port0->write(tmp_sig0);

                for (unsigned int j = 0; j < frameWidth*bram_row*3; j++)
                {
                    #ifdef QUANTUM
                    qk.inc(sc_time(CLK_PERIOD, SC_NS));
                    offset = qk.get_local_time();
                    qk.set_and_sync(offset);
                    #else
                    offset += sc_time(CLK_PERIOD, SC_NS);
                    #endif

                    while(!p_fifo_out->nb_write(bram_photo[j]))
                    {
                        #ifdef QUANTUM
                        qk.inc(sc_time(CLK_PERIOD, SC_NS));
                        offset = qk.get_local_time();
                        qk.set_and_sync(offset);
                        #else
                        offset += sc_time(CLK_PERIOD, SC_NS);
                        #endif
                    }
                    
                }
                // WAIT 10ns MORE TO DMA GET LAST NUMBER, AFTER THAT SIGNAL TO PROCESSOR THAT TRANSFER IS FINISHED
                #ifdef QUANTUM
                qk.inc(sc_time(CLK_PERIOD, SC_NS));
                offset = qk.get_local_time();
                qk.set_and_sync(offset);
                #else
                offset += sc_time(CLK_PERIOD, SC_NS);
                #endif

                bram_photo.clear();

                tmp_sig0 = sc_dt::SC_LOGIC_1;
                out_port0->write(tmp_sig0);
                break;

            case 0b00100000:

                tmp_sig0 = sc_dt::SC_LOGIC_0;
                out_port0->write(tmp_sig0);

                tmp_sig1 = sc_dt::SC_LOGIC_0;
                out_port1->write(tmp_sig1);

                max_height_letter = bram_letterData[212];
                spacing = bram_letterData[213] + 1;

                endCol = possitionY;
                startCol = endCol - bram_row;

                #ifdef QUANTUM
                qk.inc(sc_time(10, SC_NS));
                offset = qk.get_local_time();
                qk.set_and_sync(offset);
                #endif

                for (z = 0; z < number_rows; z++) 
                {
                    if (z == 0) 
                    {
                        start = 1;
                        end = number_character_row1;
                    } 
                    else if (z == 1) 
                    {
                        start = number_character_row1 + 1;
                        end = number_character_row1 + number_character_row2;
                    } 
                    else if (z == 2) 
                    {
                        start = number_character_row1 + number_character_row2 + 1;
                        end = number_character_row1 + number_character_row2 + number_character_row3;
                    } 
                    else if (z == 3) 
                    {
                        start = number_character_row1 + number_character_row2 + number_character_row3 + 1;
                        end = number_character_row1 + number_character_row2 + number_character_row3 + number_character_row4;
                    }

                    #ifdef QUANTUM
                    qk.inc(sc_time(10, SC_NS));
                    offset = qk.get_local_time();
                    qk.set_and_sync(offset);
                    #endif

                    pom = getStringWidth(bram_text, start, end, bram_letterData[213] + 1);

                    #ifdef QUANTUM
                    qk.inc(sc_time(20, SC_NS));
                    offset = qk.get_local_time();
                    qk.set_and_sync(offset);
                    #endif

                    currX = (frameWidth - pom) / 2;
                    currY = max_height_letter / 2 + z * max_height_letter;

                    #ifdef QUANTUM
                    qk.inc(sc_time(20, SC_NS));
                    offset = qk.get_local_time();
                    qk.set_and_sync(offset);
                    #endif

                    if (currY >= endCol)
                        continue;
                    else if (currY + max_height_letter <= startCol)
                        continue;

                    #ifdef QUANTUM
                    qk.inc(sc_time(10, SC_NS));
                    offset = qk.get_local_time();
                    qk.set_and_sync(offset);
                    #endif

                    for (k = start; k < end; k++) 
                    {

                        if (bram_text[k] >= 106) 
                            ascii = 31;
                        else
                            ascii = bram_text[k];

                        startPos = bram_possition[ascii];
                        letterWidth = bram_letterData[ascii * 2];
                        letterHeight = bram_letterData[ascii * 2 + 1];

                        #ifdef QUANTUM
                        qk.inc(sc_time(10, SC_NS));
                        offset = qk.get_local_time();
                        qk.set_and_sync(offset);
                        #endif

                        if (ascii == 71 || ascii == 74 || ascii == 80 || ascii == 81 || ascii == 89)
                            tmp_currY = currY - (letterHeight / 4);
                        else
                            tmp_currY = currY;

                        #ifdef QUANTUM
                        qk.inc(sc_time(10, SC_NS));
                        offset = qk.get_local_time();
                        qk.set_and_sync(offset);
                        #endif

                        startY = 0;
                        endY = letterHeight;

                        if (tmp_currY < startCol) 
                        {
                            if (tmp_currY + letterHeight > startCol && tmp_currY + letterHeight <= endCol) 
                            {
                                endY = tmp_currY + letterHeight - startCol;
                            } 
                            else if (tmp_currY + letterHeight > endCol) 
                            {
                                startY = tmp_currY + letterHeight - endCol;
                                endY = tmp_currY + letterHeight - startCol;
                            } 
                            else 
                            {
                                currX += letterWidth + spacing;
                                continue;
                            }
                        } 
                        else if (tmp_currY >= startCol) 
                        {
                            if (tmp_currY + letterHeight > endCol)
                                startY = tmp_currY + letterHeight - endCol;
                        }

                        #ifdef QUANTUM
                        qk.inc(sc_time(20, SC_NS));
                        offset = qk.get_local_time();
                        qk.set_and_sync(offset);
                        #endif

                        for (i = startY; i < endY; i++) 
                        {
                            rowIndex = letterHeight - 1 - i;

                            #ifdef QUANTUM
                            qk.inc(sc_time(20, SC_NS));
                            offset = qk.get_local_time();
                            qk.set_and_sync(offset);
                            #endif

                            for (j = 0; j < letterWidth; j++) 
                            {
                                #ifdef QUANTUM
                                qk.inc(sc_time(10, SC_NS));
                                offset = qk.get_local_time();
                                qk.set_and_sync(offset);
                                #endif

                                if (bram_letterMatrix[i * letterWidth + j + startPos] == 1) 
                                {
                                    idx = ((endCol - 1 - tmp_currY - rowIndex) * frameWidth + (currX + j)) * 3;
                                    bram_photo[idx] = 255;    // Plava komponenta piksela
                                    bram_photo[idx + 1] = 255;  // Zelena komponenta piksela
                                    bram_photo[idx + 2] = 255;  // Crvena komponenta piksela

                                    #ifdef QUANTUM
                                    qk.inc(sc_time(40, SC_NS));
                                    offset = qk.get_local_time();
                                    qk.set_and_sync(offset);
                                    #endif
                                }
                            }
                        }
                        currX += letterWidth + spacing;
                    }
                }

                #ifdef QUANTUM
                qk.inc(sc_time(20, SC_NS));
                offset = qk.get_local_time();
                qk.set_and_sync(offset);
                #else
                offset += sc_time(20, SC_NS);
                #endif

                tmp_sig0 = sc_dt::SC_LOGIC_1;
                out_port0->write(tmp_sig0);

                if (currY + max_height_letter <= endCol) 
                {
                    tmp_sig1 = sc_dt::SC_LOGIC_1;
                    out_port1->write(tmp_sig1);
                }
                break;

        }
        command = 0;
    }
}

int Ip::getStringWidth(vector<sc_dt::sc_uint<8>>& st, int start, int end, int space) 
{
    int width = 0;

    for (int i = start; i < end; i++) 
    {
        int ascii = static_cast<int>(st[i]);

        width += bram_letterData[ascii * 2] + space;
    }
    return width;
}

#endif // IP_C

