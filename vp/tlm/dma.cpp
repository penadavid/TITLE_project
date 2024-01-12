#ifndef DMA_C
#define DMA_C
#include "dma.hpp"

DMA::DMA(sc_module_name name) : sc_module(name)
{
    s_dma_t.register_b_transport(this, &DMA::b_transport);
    SC_THREAD(send_to_fifo);
    SC_THREAD(read_from_fifo);
    sig_send = sc_dt::SC_LOGIC_0;
    sig_read = sc_dt::SC_LOGIC_0;

    cout << "DMA constructed" << endl;
}

void DMA::b_transport(pl_t& pl, sc_time& offset)
{
    cmd = pl.get_command();
    adr = pl.get_address();
    length = pl.get_data_length();
    buf = pl.get_data_ptr();
    begin = adr - 0x81000000;

    switch (cmd)
    {
        case TLM_WRITE_COMMAND:
            //cout << "dma: cita podatke iz mem" << endl;
            pl.set_command(TLM_READ_COMMAND);
            pl.set_address(begin);
            s_dma_i0->b_transport(pl, offset);
            assert(pl.get_response_status() == TLM_OK_RESPONSE);

            buf = pl.get_data_ptr();
            pom_mem.clear();

            for (unsigned int i = 0; i < length; i++)
            {
                pom_mem.push_back(((sc_dt::sc_uint<16>*)buf)[i]);
            }

            //cout << "dma: salje podatke u ip" << endl;

            //Start sending to fifo
            sig_send = sc_dt::SC_LOGIC_1;
            //End sending to fifo

            pl.set_response_status(TLM_OK_RESPONSE);
            offset += sc_time(20, SC_NS);
            break;

        case TLM_READ_COMMAND:
            //cout << "dma: cita podatke iz ip" << endl;
            
            //Start reading from fifo
            sig_read = sc_dt::SC_LOGIC_1;
            //End reading from fifo

            offset += sc_time(20, SC_NS);
            break;

        default:
            pl.set_response_status(TLM_COMMAND_ERROR_RESPONSE);
    }
}

void DMA::send_to_fifo()
{
    sc_time offset = SC_ZERO_TIME;
    #ifdef QUANTUM
    tlm_utils::tlm_quantumkeeper qk;
    qk.reset();
    #endif
    while(1)
    {
        while(sig_send == sc_dt::SC_LOGIC_0)
        {
            #ifdef QUANTUM
            qk.inc(sc_time(10, SC_NS));
            offset = qk.get_local_time();
            #else
            offset += sc_time(10, SC_NS);
            #endif

            #ifdef QUANTUM
            qk.set_and_sync(offset);
            #endif
        }

        sig_send = sc_dt::SC_LOGIC_0;
        for(unsigned int i = 0; i < length; i++)
        {
            #ifdef QUANTUM
            qk.inc(sc_time(10, SC_NS));
            offset = qk.get_local_time();
            qk.set_and_sync(offset);
            #else
            offset += sc_time(10, SC_NS);
            #endif

            while(!p_fifo_out->nb_write(pom_mem[i]))
            {
                #ifdef QUANTUM
                qk.inc(sc_time(10, SC_NS));
                offset = qk.get_local_time();
                qk.set_and_sync(offset);
                #else
                offset += sc_time(10, SC_NS);
                #endif
            }

        }

    }

}

void DMA::read_from_fifo()
{
    pl_t pl;
    sc_time offset = SC_ZERO_TIME;
    sc_dt::sc_uint<16> fifo_read;
    #ifdef QUANTUM
    tlm_utils::tlm_quantumkeeper qk;
    qk.reset();
    #endif
    while(1)
    {
        while(sig_read == sc_dt::SC_LOGIC_0)
        {
            #ifdef QUANTUM
            qk.inc(sc_time(10, SC_NS));
            offset = qk.get_local_time();
            #else
            offset += sc_time(10, SC_NS);
            #endif

            #ifdef QUANTUM
            qk.set_and_sync(offset);
            #endif
        }
        pom_mem.clear();
        sig_read = sc_dt::SC_LOGIC_0;

        for (unsigned int i = 0; i < length; i++)
        {
            while(!p_fifo_in->nb_read(fifo_read))
            {
                #ifdef QUANTUM
                qk.inc(sc_time(10, SC_NS));
                offset = qk.get_local_time();
                qk.set_and_sync(offset);
                #else
                offset += sc_time(10, SC_NS);
                #endif
            }
            pom_mem.push_back(fifo_read);
        }

        buf = (unsigned char *)&pom_mem[0];
        pl.set_address(begin);
        pl.set_data_length(length);
        pl.set_command(TLM_WRITE_COMMAND);
        pl.set_data_ptr(buf);
        s_dma_i0->b_transport(pl, offset);
        qk.set_and_sync(offset);
    }

}

#endif // DMA_C
