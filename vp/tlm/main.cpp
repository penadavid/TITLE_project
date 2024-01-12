#include <systemc>
#include "cpu.hpp"
#include "memory.hpp"
#include "intcon.hpp"
#include "dma.hpp"
#include "ip.hpp"

int sc_main(int argc, char* argv[])
{
    char* input_video = argv[1];
    char* input_titl = argv[2];

    sc_fifo<sc_dt::sc_uint<16>> fifo1(2);
    sc_fifo<sc_dt::sc_uint<16>> fifo2(2);

    Cpu cpu("Cpu", input_video, input_titl);
    Mem memory("memory");
    InterCon intcon("intcon");
    DMA dma("dma");
    Ip ip("ip");

    ip.out_port0(cpu.in_port0);
    ip.out_port1(cpu.in_port1);
    cpu.s_cp_i1.bind(memory.s_mem_t1);
    cpu.s_cp_i0.bind(intcon.s_ic_t);
    intcon.s_ic_i1.bind(dma.s_dma_t);
    intcon.s_ic_i0.bind(ip.s_ip_t0);
    dma.s_dma_i0.bind(memory.s_mem_t0);

    dma.p_fifo_out.bind(fifo1);
    ip.p_fifo_in.bind(fifo1);

    dma.p_fifo_in.bind(fifo2);
    ip.p_fifo_out.bind(fifo2);

    
    #ifdef QUANTUM
    tlm_global_quantum::instance().set(sc_time(10, SC_NS));
    #endif

    cout << "Starting simulation..." << endl;

    sc_start(1, SC_SEC);

    cout << "Simulation finished at " << sc_time_stamp() <<endl;
    
    int fps;
    fps = cpu.sum_fps / cpu.frame_count;
    cout << "Prosecan FPS za ovaj video: " << fps << endl;
	
    return 0;
}


