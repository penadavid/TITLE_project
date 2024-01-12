`ifndef TITLE_ENV_SV
`define TITLE_ENV_SV

class title_env extends uvm_env;

   `uvm_component_utils(title_env)

   agent_axi_lite agent_lite;
   agent_axi_stream_master agent_master;
   agent_axi_stream_slave agent_slave;

   title_config cfg;
   title_scoreboard scoreboard;
   virtual interface title_interface vif;

   function new(string name = "title_env", uvm_component parent = null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      if (!uvm_config_db#(virtual title_interface)::get(this, "", "title_interface", vif))
        `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
      if(!uvm_config_db#(title_config)::get(this, "", "title_config", cfg))
        `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})

      //Setting to configuration database
      uvm_config_db#(title_config)::set(this, "*", "title_config", cfg);
      uvm_config_db#(virtual title_interface)::set(this, "*", "title_interface", vif);

      
      agent_lite = agent_axi_lite::type_id::create("agent_lite",this);
      agent_master = agent_axi_stream_master::type_id::create("agent_master",this);
      agent_slave = agent_axi_stream_slave::type_id::create("agent_slave",this);

      scoreboard = title_scoreboard::type_id::create("scoreboard",this);

   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      
      agent_master.mon.port_axis.connect(scoreboard.port_axis);
      agent_lite.mon.port_axi_lite.connect(scoreboard.port_axi_lite);
      
   endfunction : connect_phase
   
endclass : title_env


`endif 