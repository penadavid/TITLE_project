`ifndef TITLE_CONFIG_SV
`define TITLE_CONFIG_SV

class title_config extends uvm_object;

   uvm_active_passive_enum is_active = UVM_ACTIVE;
   
   `uvm_object_utils_begin (title_config)
      `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
   `uvm_object_utils_end

   function new(string name = "title_config_config");
      super.new(name);
   endfunction

endclass : title_config
`endif