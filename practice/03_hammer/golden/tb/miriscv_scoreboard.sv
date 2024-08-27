import "DPI-C" function chandle hammer_init(
  string target_binary
);

import "DPI-C" function void hammer_release(
  chandle hammer
);

import "DPI-C" function void hammer_single_step(
  chandle hammer
);

import "DPI-C" function bit [31:0] hammer_get_PC(
  chandle hammer
);

import "DPI-C" function void hammer_set_PC(
  chandle    hammer,
  bit [31:0] new_pc_value
);

import "DPI-C" function string hammer_get_insn_str(
  chandle hammer
);

import "DPI-C" function bit [31:0] hammer_get_insn_bits(
  chandle hammer
);

import "DPI-C" function bit [31:0] hammer_get_gpr(
  chandle   hammer,
  bit [4:0] gpr_id
);

class miriscv_scoreboard;

  mailbox#(miriscv_rvfi_item) rvfi_mbx;

  chandle hammer;

  protected int unsigned retire_cnt;

  virtual function void init(string elf, bit [31:0] pc);
    hammer = hammer_init(elf);
    hammer_set_PC(hammer, pc);
    $display("Hammer was initialized with PC: %8h", pc);
  endfunction

  virtual function int unsigned get_retire_cnt();
    return retire_cnt;
  endfunction

  virtual task run();
    miriscv_rvfi_item t;
    forever begin
      rvfi_mbx.get(t);
      void'(check(t));
      hammer_single_step(hammer);
      retire_cnt = retire_cnt + 1;
    end
  endtask

  virtual function bit check(miriscv_rvfi_item t);
    return check_pc_and_instr(t);
  endfunction

  virtual function bit check_pc_and_instr(miriscv_rvfi_item t);
    bit result = 1; string msg;
    bit [31:0] hammer_pc, hammer_insn;
    hammer_pc   = hammer_get_PC(hammer);
    hammer_insn = hammer_get_insn_bits(hammer);
    if( hammer_pc !== t.rvfi_pc_rdata ) begin
      msg = "PC mismatch! "; result = 0;
    end
    if( hammer_insn !== t.rvfi_insn ) begin
      msg = {msg, "Instruction mismatch!"}; result = 0;
    end
    if( !result ) begin
      msg = {msg, $sformatf("\nHammer  PC: %8h insn: %8h \nMIRISCV PC: %8h insn: %8h",
        hammer_pc, hammer_insn, t.rvfi_pc_rdata, t.rvfi_insn)};
      $display(msg);
    end
    return result;
  endfunction
  
endclass