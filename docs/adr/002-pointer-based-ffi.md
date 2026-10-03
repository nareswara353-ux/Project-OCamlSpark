# ADR-002: Pointer-Based FFI ABI

## Status
Accepted

## Context
Ctypes-foreign (OCaml) dan C memiliki ABI berbeda untuk struct-by-value:
- OCaml `Ctypes.float` = C `float` (32-bit), bukan `double` (64-bit)
- Struct by-value di XMM registers tidak konsisten antara libffi dan GCC
- Awalnya menyebabkan garbage values (`-3.67e+23`) dan NaN

Error awal:
Expected: 0.5' Received:-3.67154e+23'

text

## Decision
Gunakan **pointer-based ABI** untuk semua struct argument:
- Struct lewat pointer (`const command_t* cmd`)
- Out-param sebagai pointer (`command_t* out`)
- Semua scalar `double` (bukan `float`)
- Field struct di OCaml pakai `Ctypes.double`

## Consequences

### Positif
- ABI 100% portabel antara ctypes-foreign dan GCC
- Debug lebih mudah (pointer address jelas)
- Tidak ada alignment surprise

### Negatif
- API C sedikit lebih verbose
- Butuh alokasi manual di OCaml (`make`, `addr`)
- Extra indirection (~10ns per call)

### Mitigasi
- Wrapper OCaml menyembunyikan pointer dari caller
- Benchmark menunjukkan overhead tidak signifikan
- Test round-trip memverifikasi correctness

## Alternatives Considered
1. **By-value dengan `Ctypes.float`**: gagal karena ABI mismatch
2. **`Ctypes.float` + cast di C**: rapuh, tidak portabel
3. **Shared memory**: overkill untuk skala ini
4. **JSON marshal**: terlalu lambat untuk hot path