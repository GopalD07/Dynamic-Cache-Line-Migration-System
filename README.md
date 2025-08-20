Dynamic Cache Line Migration System
A Verilog implementation of a multi-level cache hierarchy with intelligent dynamic cache line migration and LRU (Least Recently Used) replacement policy.
🎯 Overview
This project implements a 3-level cache system (L1, L2, L3) with dynamic data migration to optimize performance. When data is accessed from a lower-level cache (e.g., L3), it is automatically migrated to a higher-level cache (e.g., L2 or L1) for faster future access. The system uses an LRU replacement policy to manage cache evictions efficiently.
🏗 Architecture
Cache Hierarchy

L1 Cache: Fastest access, highest priority, smallest capacity.
L2 Cache: Intermediate access speed and capacity.
L3 Cache: Slowest access, largest capacity.

Key Features

Dynamic Migration: Automatically moves frequently accessed data to higher cache levels (L3 → L2 → L1).
LRU Replacement: Evicts the least recently used cache line when a cache level is full.
Hit/Miss Detection: Efficiently detects cache hits or misses across all levels.
Configurable Parameters: Adjustable cache size, line size, and address width.

📁 Project Structure
.
├── cache_controller.v    # Main cache controller and memory modules
├── tb_cache_controller.v # Comprehensive testbench
└── README.md             # This documentation

🔧 Module Details
cache_memory Module
The cache_memory module is the core component that implements a single cache level with LRU tracking.
Parameters:

CACHE_SIZE: Number of cache lines (default: 256).
LINE_SIZE: Data width in bits (default: 32).
ADDR_WIDTH: Address width in bits (default: 8).

Functionality:

Stores data in a cache array (cache), tags (tag), and valid bits (valid).
Tracks usage with LRU counters (lru_counter) for each cache line.
Implements hit/miss detection:
A hit occurs when the requested address matches a valid cache line's tag.
A miss occurs otherwise, triggering potential migration or eviction.


Updates LRU counters on every access to prioritize recently used lines.
Supports write and read operations:
Write: Stores data and updates tag, valid bit, and LRU counter.
Read: Outputs data if hit, otherwise sets hit signal to 0.



LRU Logic:

The find_lru_line function identifies the least recently used cache line by finding the line with the highest LRU counter value.
On access, the LRU counter for the accessed line is reset to 0, while others increment.

Code Explanation:

The module initializes all cache lines to invalid (valid = 0) on reset.
Write operations update the cache, tag, and valid bit at the specified address.
Read operations check for a valid tag match to determine hit/miss status.
LRU counters are updated on every clock cycle for valid lines, ensuring accurate tracking of usage patterns.

cache_controller Module
The cache_controller module integrates three cache_memory instances (L1, L2, L3) and manages data migration and coherency.
Functionality:

Instantiates L1, L2, and L3 caches with identical configurations.
Handles cache operations (read/write) across all levels.
Implements dynamic migration logic:
If data is found in L2 but not L1, it migrates to L1 by replacing the LRU line in L1.
If data is found in L3 but not L2, it migrates to L2 by replacing the LRU line in L2.


Combines hit signals from all levels using OR logic (hit = l1_hit | l2_hit | l3_hit).
Selects data output based on hit priority: L1 > L2 > L3.

Migration Logic:

Migration is triggered on a clock edge when a hit occurs in a lower-level cache (L2 or L3) but not in the higher level.
The LRU line in the target cache (L1 or L2) is replaced with data from the lower-level cache.
Migration ensures frequently accessed data moves closer to the processor for faster access.

Code Explanation:

The module monitors hit signals (l1_hit, l2_hit, l3_hit) to detect access patterns.
A combinational block sets migration enable (migration_en) and address (migration_addr) based on hit conditions.
A sequential block performs the migration by copying data, tag, and valid bit to the LRU line in the target cache.

🚀 Getting Started
Prerequisites

Verilog simulator (e.g., ModelSim, VCS, Icarus Verilog).
Basic understanding of cache architectures and Verilog HDL.

Running the Simulation

Clone the Repository:
git clone https://github.com/yourusername/dynamic-cache-migration.git
cd dynamic-cache-migration


Compile and Run:

Using Icarus Verilog:iverilog -o cache_sim cache_controller.v tb_cache_controller.v
./cache_sim


Using ModelSim:vlog cache_controller.v tb_cache_controller.v
vsim -c tb_cache_controller -do "run -all; quit"





Expected Output
The testbench (tb_cache_controller.v) simulates:

Cache reset and initial state.
Write operations to L3 cache.
Read operations triggering migrations (L3 → L2, L2 → L1).
LRU replacement in action.

Sample Output:
Initial State:
Reset = 1, Addr = 00, Wr_en = 0, Rd_en = 0, Data_in = 00000000, Data_out = xxxxxxxx, Hit = x
--------------------------------------------------
Write Operation:
Addr = aa, Wr_en = 1, Rd_en = 0, Data_in = 0000dead, Data_out = xxxxxxxx, Hit = x
Note: Data written to L3 cache.
--------------------------------------------------
First Read Operation:
Addr = aa, Wr_en = 0, Rd_en = 1, Data_in = 0000dead, Data_out = 0000dead, Hit = 1
Note: Data read from L3 cache. Migration to L2 triggered.
--------------------------------------------------
Second Read Operation:
Addr = aa, Wr_en = 0, Rd_en = 1, Data_in = 0000dead, Data_out = 0000dead, Hit = 1
Note: Data read from L2 cache after migration.
--------------------------------------------------
Write Operation:
Addr = bb, Wr_en = 1, Rd_en = 0, Data_in = 0000cafe, Data_out = xxxxxxxx, Hit = x
Note: Data written to L3 cache.
--------------------------------------------------
Third Read Operation:
Addr = bb, Wr_en = 0, Rd_en = 1, Data_in = 0000cafe, Data_out = 0000cafe, Hit = 1
Note: Data read from L3 cache. Migration to L2 triggered.
--------------------------------------------------
Fourth Read Operation:
Addr = bb, Wr_en = 0, Rd_en = 1, Data_in = 0000cafe, Data_out = 0000cafe, Hit = 1
Note: Data read from L2 cache after migration.
--------------------------------------------------
Test Passed: Dynamic Migration and LRU Replacement Successful!
Note: Data_out matches Data_in, and Hit signal is high.
--------------------------------------------------

⚙ Configuration
Customize the cache system via parameters in the cache_controller module:
cache_controller #(
    .CACHE_SIZE(256),    // Number of cache lines
    .LINE_SIZE(32),      // Data width in bits
    .ADDR_WIDTH(8)       // Address width in bits
) cache_inst (
    // ... port connections
);

🧪 Testing
The testbench (tb_cache_controller.v) verifies:

Basic Operations: Write and read functionality across cache levels.
Migration: Data movement from L3 to L2 and L2 to L1.
LRU Policy: Correct replacement of least recently used lines.
Hit/Miss Detection: Accurate hit/miss signaling.

Testbench Explanation:

Initializes the system with a reset.
Writes data (0xDEAD) to address 0xAA in L3, then reads it to trigger L3 → L2 migration.
Reads again to verify data in L2.
Writes new data (0xCAFE) to address 0xBB in L3, then reads to trigger migration.
Verifies final read and hit status, confirming successful migration and LRU functionality.
Uses a clock with a 10-unit period (toggle every 5 units).

📊 Performance Features

Dynamic Migration: Moves frequently accessed data to faster caches.
LRU Replacement: Optimizes cache usage by evicting least-used lines.
Multi-Level Hit Detection: Searches all cache levels for data.
Zero-Wait State Access: Immediate data retrieval on cache hits.

🔄 Migration Logic

L3 → L2: Data accessed in L3 is copied to L2’s LRU line.
L2 → L1: Data accessed in L2 is copied to L1’s LRU line.
LRU Eviction: Replaces the least recently used line when migrating data to a full cache.

🐛 Known Issues & Limitations

Migration occurs on the next clock cycle, introducing a slight delay.
All cache levels have the same size (configurable but uniform).
Write operations target the addressed cache line directly without multi-level coherency checks.

🤝 Contributing
Contributions are welcome! Please submit pull requests or open issues for:

Performance optimizations (e.g., faster migration).
Additional replacement policies (e.g., FIFO, Random).
Enhanced coherency protocols.
Support for write-back or write-through policies.

📄 License
This project is open source. Use, modify, and distribute as needed.
