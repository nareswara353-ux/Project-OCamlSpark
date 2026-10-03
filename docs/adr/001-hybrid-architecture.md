# ADR-001: Hybrid Architecture OCaml + SPARK

## Status
Accepted

## Context
Sistem kontrol aktuator aerospace membutuhkan:
1. Verifikasi formal untuk safety-critical path (actuator commands, voting, health)
2. Optimasi lintasan fungsional yang cepat diiterasi
3. Waktu pengembangan yang wajar untuk kedua domain

Single-language approach tidak optimal:
- SPARK saja: iterasi lambat untuk algoritma optimasi
- OCaml saja: tidak ada jaminan formal untuk safety kernel

## Decision
Menggunakan arsitektur hybrid dua bahasa:
- **SPARK/Ada** untuk safety kernel: contract formal, `gnatprove` proof, zero runtime error
- **OCaml** untuk engine: optimasi lintasan, parser, utility, event bus
- **C ABI FFI** sebagai jembatan

## Consequences

### Positif
- Formal guarantee untuk safety kernel
- Iterasi cepat untuk engine (OCaml + Dune)
- Domain-specific language per layer
- Test suite terpisah per bahasa

### Negatif
- Kompleksitas build (dua toolchain)
- ABI boundary adalah titik risiko (sudah di-mitigasi dengan pointer-based)
- Learning curve lebih tinggi untuk kontributor

### Mitigasi
- Stub C untuk build lokal cepat
- Pointer-based ABI di FFI layer
- Dokumentasi ADR ini + test yang komprehensif

## Alternatives Considered
1. **Pure SPARK**: ditolak karena iterasi lambat
2. **Pure OCaml**: ditolak karena tidak ada proof formal
3. **Rust + Coq**: ditolak karena ekosistem aerospace kurang matang
4. **C++ + Frama-C**: ditolak karena tooling lebih kompleks
