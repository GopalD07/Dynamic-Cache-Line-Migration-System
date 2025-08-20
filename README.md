Got it 👍 Here’s the **copy-paste ready README** for your repo.

---

```markdown
# Dynamic Cache Line Migration (Verilog, 3-Level, LRU)

A didactic multi-level cache **simulation model** with automatic line migration and an **LRU** replacement heuristic.  
The design is intentionally compact for teaching and experimentation; it is not yet synthesis-ready.

---

## ✨ Highlights

- **3-level hierarchy** (L1, L2, L3) with unified I/O  
- **Read-triggered migration**: L3→L2, L2→L1  
- **LRU replacement**: oldest line replaced on migration  
- **Verbose testbench** that logs hit/miss and migration behavior  

⚠️ **Note**: In this version, `wr_en` updates **all caches in parallel**. Migration is demonstrated on **reads** only.

---

## 🧱 Repository

```

.
├── cache\_controller.v     # 3-level controller, migration, top-level wiring
├── tb\_cache\_controller.v  # Testbench with console logging
└── README.md              # This file

````

---

## ⚙️ Parameters

```verilog
parameter CACHE_SIZE = 256,    // number of lines
          LINE_SIZE  = 32,     // data width in bits
          ADDR_WIDTH = 8       // address width in bits
````

* `addr` doubles as index and tag (simplification for this model).
* All caches have the same geometry (configurable).

---

## 🔍 Module Walkthrough

### 1) `cache_memory`

Implements a small direct-mapped cache array:

* **Storage arrays**: `cache`, `tag`, `valid`, and `lru_counter` per line
* **Reset**: clears valid bits and counters
* **Reads**: hit when `valid[addr]` and `tag[addr]==addr`
* **Writes**: store `data_in`, set valid, reset counter
* **LRU**: increments unused counters; `find_lru_line()` returns victim index

### 2) `cache_controller`

Top-level that instantiates **L1/L2/L3 caches**:

* Aggregates hits:

  ```verilog
  assign hit      = l1_hit | l2_hit | l3_hit;
  assign data_out = l1_hit ? l1_data_out :
                    l2_hit ? l2_data_out :
                    l3_data_out ;
  ```
* **Migration logic**:

  * If L2 hit but L1 miss → migrate line to L1
  * If L3 hit but L2 miss → migrate line to L2
* Uses LRU victim index at destination, then copies `{data, tag, valid}`

⚠️ Migration copies use **hierarchical references** (`l1_cache.cache[...] <= ...`).
This works in simulation but **not in synthesis**.

---

## 🧪 Testbench

The testbench (`tb_cache_controller.v`) demonstrates:

1. Reset state
2. Write operation (to all levels in this version)
3. First read hit in L3 → triggers migration to L2
4. Second read → served from L2
5. Repeat for another address to verify flow

Run with:

```bash
# Icarus Verilog
iverilog -o cache_sim cache_controller.v tb_cache_controller.v
./cache_sim

# ModelSim / Questa
vlog cache_controller.v tb_cache_controller.v
vsim -c tb_cache_controller -do "run -all; quit"
```

Sample console output:

```
Write Operation: Addr=AA ... Note: Data written
First Read Operation: Addr=AA ... Note: Migration to L2 triggered
Second Read Operation: Addr=AA ... Note: Data read after migration
```

---

## 📈 How LRU Works Here

* Each valid line increments its `lru_counter` unless accessed.
* Accessed lines reset counter = 0.
* On migration, the **largest counter** is evicted in the target cache.

---

## 🚧 Limitations & TODO

* Hierarchical migration assignments → **simulation only**
* All writes hit every cache (no write policy)
* Tags == index (no real address decomposition)
* Direct-mapped array (no associativity)
* No backing memory on miss

---

## 📚 How to Extend

* Add proper `{tag, index, offset}` fields
* Implement set-associativity with per-set LRU
* Add **write policies** (write-through, write-back with dirty bits)
* Replace hierarchical migration with synthesizable ports
* Add a backing memory + fill FSM for real misses

---

## ✅ What’s Working

* Hit detection across all levels
* Read-triggered migration (L3→L2, L2→L1)
* LRU victim replacement
* Testbench logs showing migration sequence

---

```

---

Do you also want me to **shrink this into a very concise “academic project style” README** (about 1/3rd the length) so you can use it in reports or submissions, or keep it detailed for GitHub?
```
