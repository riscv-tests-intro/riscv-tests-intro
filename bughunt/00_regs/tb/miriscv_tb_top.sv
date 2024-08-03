module miriscv_tb_top;

    // Clock period
    parameter CLK_PERIOD = 10;

    // Clock and reset
    logic clk;
    logic arstn;

    // Instruction memory signals
    logic        instr_rvalid;
    logic [31:0] instr_rdata;
    logic        instr_req;
    logic [31:0] instr_addr;

    // Data memory signals
    logic        data_rvalid;
    logic [31:0] data_rdata;
    logic        data_req;
    logic [31:0] data_wdata;
    logic [31:0] data_addr;
    logic        data_we;
    logic [31:0] data_be;

    // Main memory handle
    logic [31:0] mem [32];

    // Signature address
    logic [31:0] signature_addr;

    // Timeout in cycles
    int unsigned timeout_in_cycles = 1000000;

    initial begin
        clk <= 0;
        forever begin
            #(CLK_PERIOD/2) clk = ~clk;
        end
    end

    initial begin
        arstn <= 0;
        repeat(10) @(posedge clk);
        arstn <= 1;
    end

    // DUT
    miriscv_core #(
        .RVFI                 ( 0            )
    ) DUT (

        // Clock and Reset
        .clk_i                ( clk          ),
        .arstn_i              ( arstn        ),

        // Boot address
        .boot_addr_i          ( 'b0          ),

        // Instruction memory interface
        .instr_rvalid_i       ( instr_rvalid ),
        .instr_rdata_i        ( instr_rdata  ),
        .instr_req_o          ( instr_req    ),
        .instr_addr_o         ( instr_addr   ),

        // Data memory interface
        .data_rvalid_i        ( data_rvalid  ),
        .data_rdata_i         ( data_rdata   ),
        .data_req_o           ( data_req     ),
        .data_we_o            ( data_we      ),
        .data_be_o            ( data_be      ),
        .data_addr_o          ( data_addr    ),
        .data_wdata_o         ( data_wdata   )

    );

    function automatic void load_binary_to_mem();
        string bin;
        if(!$value$plusargs("bin=%0h", bin))
            $fatal("You must provide 'bin' via commandline!");
        $readmemh(bin, mem);
    endfunction

    initial begin
        string dump;
        // Save waveforms
        if(!$value$plusargs("dump=%s", dump)) begin
            dump = "waves.vcd";
        end
        $dumpfile(dump);
        $dumpvars;
        // Load program to the memory
        load_binary_to_mem();
        // Wait some clocks
        repeat(100) @(posedge clk);
        $finish();
    end

    logic [31:0] aligned_instr_addr;
    assign aligned_instr_addr = {2'b00, instr_addr [31:2]};

    always_ff @(posedge clk or negedge arstn) begin
        if(!arstn) begin
            instr_rvalid <= 0;
        end
        else begin
            if(instr_req) begin
                instr_rdata  <= mem[aligned_instr_addr];
                instr_rvalid <= 1;
            end
            else instr_rvalid <= 0;
        end
    end

    logic [31:0] aligned_data_addr;
    assign aligned_data_addr = {2'b00, data_addr [31:2]};

    always_ff @(posedge clk or negedge arstn) begin
        if(!arstn) begin
            data_rvalid <= 0;
        end
        else begin
            if(data_req) begin
                if (data_we) begin
                    for (int i = 0; i < 4; i++) begin
                        if (data_be[i]) begin
                            mem[aligned_data_addr][8*i+:8] <= data_wdata[8*i+:8];
                        end
                    end
                end
                else begin
                    data_rdata <= mem[aligned_data_addr];
                end
                data_rvalid <= 1;
            end
            else data_rvalid <= 0;
        end
    end

endmodule
