class miriscv_mem_seq;

    mailbox#(miriscv_mem_item) reactive_mbx;
    mailbox#(miriscv_mem_item) mbx;

    mem_model mem;
  
    virtual task run();

        miriscv_mem_item t, t_;

        bit [31:0] data_wdata;
        bit [31:0] data_aligned_addr;

        forever begin

            t_ = new();
            t_.data_rvalid  = 0;
            t_.instr_rvalid = 0;

            reactive_mbx.get(t);

            if(t.instr_req) begin
                t_.instr_rdata = mem.read(t.instr_addr);
                t_.instr_rvalid = 1;
            end

            if(t.data_req) begin
                data_aligned_addr = {t.data_addr[31:2], 2'b00};
                if (t.data_we) begin
                    data_wdata = t.data_wdata;
                    for (int i = 0; i < 4; i++) begin
                        if (t.data_be[i])
                            mem.write_byte(data_aligned_addr + i, data_wdata[7:0]);
                        data_wdata = data_wdata >> 8;
                    end
                end
                else begin
                    t_.data_rdata = mem.read(data_aligned_addr);
                end
                t_.data_rvalid = 1;
            end

            mbx.put(t_);

        end 

    endtask

endclass