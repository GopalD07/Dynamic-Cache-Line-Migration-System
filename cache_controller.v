module cache_memory #(parameter CACHE_SIZE = 256, LINE_SIZE = 32, ADDR_WIDTH = 8) (
    input wire clk,
    input wire rst,
    input wire [ADDR_WIDTH-1:0] addr,
    input wire wr_en,
    input wire rd_en,
    input wire [LINE_SIZE-1:0] data_in,
    output reg [LINE_SIZE-1:0] data_out,
    output reg hit
);
    reg [LINE_SIZE-1:0] cache [0:CACHE_SIZE-1];
    reg [ADDR_WIDTH-1:0] tag [0:CACHE_SIZE-1];
    reg valid [0:CACHE_SIZE-1];
    reg [31:0] lru_counter [0:CACHE_SIZE-1]; // LRU counters

    integer i;
    function integer find_lru_line(input integer dummy);
        integer i, lru_index;
        begin
            lru_index = 0;
            for (i = 1; i < CACHE_SIZE; i = i + 1) begin
                if (lru_counter[i] > lru_counter[lru_index]) begin
                    lru_index = i;
                end
            end
            find_lru_line = lru_index;
        end
    endfunction



    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < CACHE_SIZE; i = i + 1) begin
                valid[i] <= 0;
                tag[i] <= 0;
                cache[i] <= 0;
                lru_counter[i] <= 0; // Reset LRU counters
            end
            hit <= 0;
            data_out <= 0;
        end else begin
            // Update LRU counters
            for (i = 0; i < CACHE_SIZE; i = i + 1) begin
                if (valid[i] && (tag[i] == addr) && (wr_en || rd_en)) begin
                    lru_counter[i] <= 0; // Reset counter for accessed line
                end else if (valid[i]) begin
                    lru_counter[i] <= lru_counter[i] + 1; // Increment counter for others
                end
            end

            if (wr_en) begin
                cache[addr] <= data_in;
                tag[addr] <= addr;
                valid[addr] <= 1;
                lru_counter[addr] <= 0; // Reset LRU counter for written line
            end
            if (rd_en) begin
                if (valid[addr] && tag[addr] == addr) begin
                    data_out <= cache[addr];
                    hit <= 1;
                end else begin
                    hit <= 0;
                end
            end
        end
    end
endmodule

module cache_controller #(parameter CACHE_SIZE = 256, LINE_SIZE = 32, ADDR_WIDTH = 8) (
    input wire clk,
    input wire rst,
    input wire [ADDR_WIDTH-1:0] addr,
    input wire wr_en,
    input wire rd_en,
    input wire [LINE_SIZE-1:0] data_in,
    output wire [LINE_SIZE-1:0] data_out,
    output wire hit
);
    // Cache instances for L1, L2, and L3
    wire [LINE_SIZE-1:0] l1_data_out, l2_data_out, l3_data_out;
    wire l1_hit, l2_hit, l3_hit;

    cache_memory #(CACHE_SIZE, LINE_SIZE, ADDR_WIDTH) l1_cache (
        .clk(clk),
        .rst(rst),
        .addr(addr),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(l1_data_out),
        .hit(l1_hit)
    );

    cache_memory #(CACHE_SIZE, LINE_SIZE, ADDR_WIDTH) l2_cache (
        .clk(clk),
        .rst(rst),
        .addr(addr),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(l2_data_out),
        .hit(l2_hit)
    );

    cache_memory #(CACHE_SIZE, LINE_SIZE, ADDR_WIDTH) l3_cache (
        .clk(clk),
        .rst(rst),
        .addr(addr),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(l3_data_out),
        .hit(l3_hit)
    );

    // Hit detection and data output
    assign hit = l1_hit | l2_hit | l3_hit;
    assign data_out = l1_hit ? l1_data_out : (l2_hit ? l2_data_out : l3_data_out);

    // Dynamic Cache Line Migration Logic with LRU
    reg [ADDR_WIDTH-1:0] migration_addr;
    reg migration_en;
    integer lru_line; // Declare lru_line outside the always block

    always @(posedge clk) begin
        if (rst) begin
            migration_en <= 0;
            migration_addr <= 0;
        end else begin
            // Monitor access patterns and trigger migration
            if (l2_hit && !l1_hit) begin
                // Migrate from L2 to L1
                migration_en <= 1;
                migration_addr <= addr;
            end else if (l3_hit && !l2_hit) begin
                // Migrate from L3 to L2
                migration_en <= 1;
                migration_addr <= addr;
            end else begin
                migration_en <= 0;
            end
        end
    end

    // Perform migration using LRU
    always @(posedge clk) begin
        if (migration_en) begin
            if (l2_hit && !l1_hit) begin
                // Find LRU line in L1
                lru_line = l1_cache.find_lru_line(0); // Pass a dummy input
                // Migrate from L2 to L1
                l1_cache.cache[lru_line] <= l2_cache.cache[migration_addr];
                l1_cache.tag[lru_line] <= l2_cache.tag[migration_addr];
                l1_cache.valid[lru_line] <= 1;
                l1_cache.lru_counter[lru_line] <= 0; // Reset LRU counter
            end else if (l3_hit && !l2_hit) begin
                // Find LRU line in L2
                lru_line = l2_cache.find_lru_line(0); // Pass a dummy input
                // Migrate from L3 to L2
                l2_cache.cache[lru_line] <= l3_cache.cache[migration_addr];
                l2_cache.tag[lru_line] <= l3_cache.tag[migration_addr];
                l2_cache.valid[lru_line] <= 1;
                l2_cache.lru_counter[lru_line] <= 0; // Reset LRU counter
            end
        end
    end
endmodule