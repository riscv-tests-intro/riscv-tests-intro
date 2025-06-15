#include <svdpi.h>
#include <vector>
#include "Vmiriscv_tb_top__Dpi.h"
#include "hammer.h"

void* hammer_init(const char* target_binary) {
    std::vector<mem_cfg_t> memory_layout;
    memory_layout.push_back(mem_cfg_t(reg_t(DRAM_BASE), reg_t(2048) << 20));

    std::vector<size_t> hart_ids{0};

    Hammer *hammer = new Hammer("RV32I", "M", "vlen:512,elen:32",
        hart_ids, memory_layout, target_binary, std::nullopt);

    return static_cast<Hammer *>(hammer);
}

void hammer_release(void* hammer) {
    Hammer *hammer_ptr;
    hammer_ptr = static_cast<Hammer *>(hammer);
    delete hammer_ptr;
}

svBitVecVal hammer_get_PC(void* hammer) {
    Hammer *hammer_ptr;
    hammer_ptr = static_cast<Hammer *>(hammer);
    uint64_t current_pc = hammer_ptr->get_PC(0);
    return static_cast<svBitVecVal>(current_pc);
}

void hammer_set_PC(void* hammer, const svBitVecVal* new_pc_value) {
    Hammer *hammer_ptr;
    hammer_ptr = static_cast<Hammer *>(hammer);
    reg_t* pc_value = (reg_t*) new_pc_value;
    hammer_ptr->set_PC(0, *pc_value);
}

void hammer_single_step(void* hammer) {
    Hammer *hammer_ptr;
    hammer_ptr = static_cast<Hammer *>(hammer);
    hammer_ptr->single_step(0);
}

const char* hammer_get_insn_str(void* hammer) {
    Hammer *hammer_ptr; std::string insn;
    hammer_ptr = static_cast<Hammer *>(hammer);
    insn = hammer_ptr->get_insn_str(0);
    return insn.c_str();
}

svBitVecVal hammer_get_insn_bits(void* hammer) {
    Hammer *hammer_ptr;
    hammer_ptr = static_cast<Hammer *>(hammer);
    return hammer_ptr->get_insn_bits(0);
}

svBitVecVal hammer_get_gpr(void* hammer, const svBitVecVal* gpr_id) {
    Hammer *hammer_ptr;
    hammer_ptr = static_cast<Hammer *>(hammer);
    uint8_t* id = (uint8_t*) gpr_id;
    return hammer_ptr->get_gpr(0, *id);
}

