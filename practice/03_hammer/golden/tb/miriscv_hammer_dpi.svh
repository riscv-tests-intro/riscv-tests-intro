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
