# Dynamic Cache Line Migration System

A Verilog implementation of a multi-level cache hierarchy with intelligent dynamic cache line migration and LRU (Least Recently Used) replacement policy.

## 🎯 Overview

This project implements a sophisticated 3-level cache system (L1, L2, L3) with automatic data migration capabilities. When data is accessed from a lower-priority cache level, it's automatically migrated to a higher-priority level for faster future access, optimizing cache performance through intelligent data placement.

## 🏗️ Architecture

### Cache Hierarchy
- **L1 Cache**: Highest priority, fastest access
- **L2 Cache**: Medium priority, intermediate access speed  
- **L3 Cache**: Lowest priority, slowest access but largest capacity

### Key Features
- **Dynamic Migration**: Automatic data movement from L3→L2→L1 based on access patterns
- **LRU Replacement**: Intelligent eviction of least recently used cache lines
- **Hit Detection**: Comprehensive hit/miss detection across all cache levels
- **Configurable Parameters**: Customizable cache size, line size, and address width

## 📁 Project Structure

```
.
├── cache_controller.v    # Main cache controller and memory modules
├── tb_cache_controller.v # Comprehensive testbench
└── README.md            # This file
```

## 🔧 Module Details

### `cache_memory`
Core cache memory module with LRU tracking:
- Configurable cache size (default: 256 lines)
- 32-bit data lines
- 8-bit address width
- Built-in LRU counter mechanism
- Automatic hit/miss detection

### `cache_controller`
Top-level controller managing the 3-level cache hierarchy:
- Instantiates L1, L2, and L3 cache memories
- Implements dynamic migration logic
- Handles cache coherency across levels
- Provides unified interface for cache operations

## 🚀 Getting Started

### Prerequisites
- Verilog simulator (ModelSim, VCS, Icarus Verilog, etc.)
- Basic understanding of cache architectures and Verilog HDL

### Running the Simulation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/dynamic-cache-migration.git
   cd dynamic-cache-migration
   ```

2. **Compile and run with your preferred simulator:**
   
   **Using Icarus Verilog:**
   ```bash
   iverilog -o cache_sim cache_controller.v tb_cache_controller.v
   ./cache_sim
   ```
   
   **Using ModelSim:**
   ```bash
   vlog cache_controller.v tb_cache_controller.v
   vsim -c tb_cache_controller -do "run -all; quit"
   ```

### Expected Output
The testbench demonstrates:
- Initial cache state after reset
- Write operations to L3 cache
- Read operations triggering automatic migration
- LRU replacement policy in action
- Hit/miss status across different cache levels

Sample output:
```
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
```

## ⚙️ Configuration

The cache system is highly configurable through module parameters:

```verilog
cache_controller #(
    .CACHE_SIZE(256),    // Number of cache lines
    .LINE_SIZE(32),      // Data width in bits
    .ADDR_WIDTH(8)       // Address width in bits
) cache_inst (
    // ... port connections
);
```

## 🧪 Testing

The included testbench (`tb_cache_controller.v`) provides comprehensive testing scenarios:

1. **Basic Write/Read Operations**: Verifies fundamental cache functionality
2. **Migration Testing**: Confirms automatic data migration between cache levels
3. **LRU Verification**: Tests the least recently used replacement policy
4. **Hit/Miss Detection**: Validates cache hit/miss logic across all levels

## 📊 Performance Features

- **Automatic Data Migration**: Frequently accessed data automatically moves to faster cache levels
- **LRU Replacement**: Optimal cache line replacement based on usage patterns
- **Multi-Level Hit Detection**: Comprehensive search across L1, L2, and L3 caches
- **Zero-Wait State Access**: Immediate data availability on cache hits

## 🔄 Migration Logic

The system implements intelligent migration patterns:

1. **L3 → L2 Migration**: When data is accessed from L3, it's copied to L2
2. **L2 → L1 Migration**: When data is accessed from L2, it's copied to L1
3. **LRU Eviction**: When target cache is full, LRU line is replaced

## 🐛 Known Issues & Limitations

- Migration occurs on the next clock cycle after access
- All cache levels currently have the same size (configurable)
- Write operations always target the addressed cache line directly

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for:
- Performance optimizations
- Additional replacement policies (FIFO, Random, etc.)
- Write-back vs write-through policies
- Cache coherency protocols

## 📄 License

This project is open source. Feel free to use, modify, and distribute according to your needs.



