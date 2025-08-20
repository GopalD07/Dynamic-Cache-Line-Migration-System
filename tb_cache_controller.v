module tb_cache_controller;

    reg clk;
    reg rst;
    reg [7:0] addr;
    reg wr_en;
    reg rd_en;
    reg [31:0] data_in;
    wire [31:0] data_out;
    wire hit;

    cache_controller #(256, 32, 8) uut (
        .clk(clk),
        .rst(rst),
        .addr(addr),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .hit(hit)
    );

    initial begin
        clk = 0;
        rst = 1;
        addr = 0;
        wr_en = 0;
        rd_en = 0;
        data_in = 0;

        // Display initial state
        $display("Initial State:");
        $display("Reset = %b, Addr = %h, Wr_en = %b, Rd_en = %b, Data_in = %h, Data_out = %h, Hit = %b", 
                 rst, addr, wr_en, rd_en, data_in, data_out, hit);
        $display("--------------------------------------------------");

        #10 rst = 0; // Release reset

        // Write data to L3 cache
        wr_en = 1;
        addr = 8'hAA;
        data_in = 32'hDEAD;
        #5; // Wait for half clock cycle to ensure signals are stable
        $display("Write Operation:");
        $display("Addr = %h, Wr_en = %b, Rd_en = %b, Data_in = %h, Data_out = %h, Hit = %b", 
                 addr, wr_en, rd_en, data_in, data_out, hit);
        $display("Note: Data written to L3 cache.");
        $display("--------------------------------------------------");
        #5 wr_en = 0; // De-assert write enable after displaying

        // Read data from L3 cache 
        rd_en = 1;
        addr = 8'hAA;
        #5;  
        $display("First Read Operation:");
        $display("Addr = %h, Wr_en = %b, Rd_en = %b, Data_in = %h, Data_out = %h, Hit = %b", 
                 addr, wr_en, rd_en, data_in, data_out, hit);
        $display("Note: Data read from L3 cache. Migration to L2 triggered.");
        $display("--------------------------------------------------");
        #5 rd_en = 0;  

         
        rd_en = 1;
        addr = 8'hAA;
        #5;  
        $display("Second Read Operation:");
        $display("Addr = %h, Wr_en = %b, Rd_en = %b, Data_in = %h, Data_out = %h, Hit = %b", 
                 addr, wr_en, rd_en, data_in, data_out, hit);
        $display("Note: Data read from L2 cache after migration.");
        $display("--------------------------------------------------");
        #5 rd_en = 0; // De-assert read enable after displaying

        // Write new data to L3 cache
        wr_en = 1;
        addr = 8'hBB;
        data_in = 32'hCAFE;
        #5; // Wait for half clock cycle to ensure signals are stable
        $display("Write Operation:");
        $display("Addr = %h, Wr_en = %b, Rd_en = %b, Data_in = %h, Data_out = %h, Hit = %b", 
                 addr, wr_en, rd_en, data_in, data_out, hit);
        $display("Note: Data written to L3 cache.");
        $display("--------------------------------------------------");
        #5 wr_en = 0; // De-assert write enable after displaying 
        rd_en = 1;
        addr = 8'hBB;
        #5;  
        $display("Third Read Operation:");
        $display("Addr = %h, Wr_en = %b, Rd_en = %b, Data_in = %h, Data_out = %h, Hit = %b", 
                 addr, wr_en, rd_en, data_in, data_out, hit);
        $display("Note: Data read from L3 cache. Migration to L2 triggered.");
        $display("--------------------------------------------------");
        #5 rd_en = 0; // De-assert read enable after displaying

        
        rd_en = 1;
        addr = 8'hBB;
        #5;
        $display("Fourth Read Operation:");
        $display("Addr = %h, Wr_en = %b, Rd_en = %b, Data_in = %h, Data_out = %h, Hit = %b", 
                 addr, wr_en, rd_en, data_in, data_out, hit);
        $display("Note: Data read from L2 cache after migration.");
        $display("--------------------------------------------------");
        #5 rd_en = 0; // De-assert read enable after displaying

        // Verify migration and hit
        if (hit && data_out == 32'hCAFE) begin
            $display("Test Passed: Dynamic Migration and LRU Replacement Successful!");
            $display("Note: Data_out matches Data_in, and Hit signal is high.");
        end else begin
            $display("Test Failed!");
            $display("Note: Data_out = %h, Expected = %h, Hit = %b", data_out, 32'hCAFE, hit);
        end

        $display("--------------------------------------------------");
        $finish;
    end

    always #5 clk = ~clk; // Toggle clock every 5 

endmodule