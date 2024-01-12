#ifndef IP_H
#define IP_H

#include <iostream>
#include <systemc>
#include <string>
#include <fstream>
#include <sstream>
#include "types.hpp"
#include "address.hpp"
#include "tlm_utils/tlm_quantumkeeper.h"

using namespace std;
using namespace sc_core;

SC_MODULE(Ip)
{
public:
    SC_HAS_PROCESS(Ip);
    Ip(sc_module_name name);
    tlm_utils::simple_target_socket<Ip> s_ip_t0;

    sc_port<sc_fifo_in_if<sc_dt::sc_uint<16>>> p_fifo_in;
    sc_port<sc_fifo_out_if<sc_dt::sc_uint<16>>> p_fifo_out;

    sc_out<sc_dt::sc_logic> out_port0;
    sc_out<sc_dt::sc_logic> out_port1;

protected:
    void b_transport0(pl_t&, sc_time&);
    void proc();

    vector<sc_dt::sc_uint<8>> bram_photo;
    vector<sc_dt::sc_uint<8>> bram_text;
    vector<sc_dt::sc_uint<8>> bram_letterData;
    vector<sc_dt::sc_uint<1>> bram_letterMatrix;
    vector<sc_dt::sc_uint<16>> bram_possition;

    sc_dt::sc_logic tmp_sig0;
    sc_dt::sc_logic tmp_sig1;

    int command;
    int possitionY;
    int text_size;

    int number_character_text_bram;
    int number_rows;
    int number_character_row1;
    int number_character_row2;
    int number_character_row3;
    int number_character_row4;

    //komanda 7 registri
    int frameWidth;
    int frameHeight;
    int bram_row;
    unsigned int LEN_MATRIX;
		    
    int max_height_letter;
    int spacing;
    int currX;
    int currY;
    int endCol;
    int startCol;
    int start;
    int end;

    sc_dt::sc_uint<8> letterWidth;
    sc_dt::sc_uint<8> letterHeight;

    int z;
    int pom;

    int k;
    int ascii;
    int startPos;
    int tmp_currY;

    int startY;
    int endY;

    int i;
    int rowIndex;

    int j;
    int idx;

    int getStringWidth(vector<sc_dt::sc_uint<8>>&, int, int, int);

};

#endif // IP_H
