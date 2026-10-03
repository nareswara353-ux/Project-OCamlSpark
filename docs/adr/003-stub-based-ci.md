# ADR-003: Stub-Based CI Pipeline

## Status
Accepted

## Context
CI awal (GNAT + Alire + gnatprove + OCaml) memakan waktu 13–18 menit per push karena:
- Download GNAT toolchain (~500 MB)
- Install Alire toolchain
- `gnatprove` menjalankan SMT solver untuk ratusan proof obligation
- opam compile dari source

Untuk iterasi harian, feedback 15 menit terlalu lambat.

## Decision
CI utama menggunakan **C stubs** (`spark_stubs.c`) yang mengimplementasikan
semua simbol `spark_*` tanpa memerlukan GNAT. Formal proof dijalankan:
- **Lokal** saat developer mau
- **Nightly** via workflow terpisah (opsional)
- **Manual trigger** via `workflow_dispatch`

## Consequences

### Positif
- CI hijau dalam 3–5 menit
- Tidak ada flakiness dari toolchain SPARK
- Kontributor tidak butuh install GNAT untuk kontribusi OCaml
- Proof formal tetap tersedia via nightly

### Negatif
- CI tidak menjalankan proof formal otomatis
- Stub bisa "diverge" dari real SPARK implementation (mitigasi: test contract)
- Job `spark-build` terpisah tetap ada tapi tidak blocking

### Mitigasi
- Stub ditulis berdasarkan kontrak yang sama
- Test OCaml memverifikasi perilaku contract
- Nightly workflow menjalankan `gnatprove` real

## Alternatives Considered
1. **Full proof di setiap push**: 15 menit per iterasi, ditolak
2. **Proof untuk PR saja**: masih 10+ menit untuk PR review
3. **Proof only on tagged release**: feedback terlalu lambat
4. **Cache GNAT toolchain**: membantu tapi masih 8+ menit
5. **Self-hosted runner**: butuh infra + maintenance
