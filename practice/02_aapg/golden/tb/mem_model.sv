class mem_model #(parameter ADDR_WIDTH = 32, parameter DATA_WIDTH = 32);

    typedef bit [ADDR_WIDTH-1:0] mem_addr_t;
    typedef bit [DATA_WIDTH-1:0] mem_data_t;

    bit [7:0] system_memory [mem_addr_t];

    function bit [7:0] read_byte(mem_addr_t addr);
        bit [7:0] data;
        if(system_memory.exists(addr)) begin
        data = system_memory[addr];
            `ifdef MEM_DEBUG
               $display("%0t Read Mem  : Addr[0x%0h], Data[0x%0h]", $time(), addr, data);
            `endif
        end
        else begin
            data = 'x;
            `ifdef READ_UNINIT
                $display("%0t Read by uninitialzed address 0x%0h", $time(), addr);
            `endif
        end
        return data;
    endfunction

    function void write_byte(mem_addr_t addr, bit[7:0] data);
        `ifdef MEM_DEBUG
            $display("%0t Write Mem : Addr[0x%0h], Data[0x%0h]", $time(), addr, data);
        `endif
        system_memory[addr] = data;
    endfunction

    function void write(input mem_addr_t addr, mem_data_t data);
        bit [7:0] byte_data;
        for(int i=0; i<DATA_WIDTH/8; i++) begin
            byte_data = data[7:0];
            write_byte(addr+i, byte_data);
            data = data >> 8;
        end
    endfunction

    function mem_data_t read(mem_addr_t addr);
        mem_data_t data;
        for(int i=DATA_WIDTH/8-1; i>=0;  i--) begin
            data = data << 8;
            data[7:0] = read_byte(addr+i);
        end
        return data;
    endfunction

endclass
