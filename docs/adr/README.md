
# Architecture Decision Records

Index keputusan arsitektur penting dalam proyek.

## Format

Setiap ADR mengikuti struktur:
- **Status** — Proposed / Accepted / Deprecated / Superseded
- **Context** — Masalah dan constraint yang dihadapi
- **Decision** — Keputusan yang diambil
- **Consequences** — Positif, negatif, dan mitigasi
- **Alternatives Considered** — Opsi yang ditolak

## Daftar ADR

| # | Judul | Status | Tanggal |
|---|---|---|---|
| 001 | [Hybrid Architecture OCaml + SPARK](001-hybrid-architecture.md) | Accepted | 2026-10-03 |
| 002 | [Pointer-Based FFI ABI](002-pointer-based-ffi.md) | Accepted | 2026-10-03 |
| 003 | [Stub-Based CI Pipeline](003-stub-based-ci.md) | Accepted | 2026-10-03 |

## Kapan Menulis ADR?

Tulis ADR saat:
- Memilih bahasa/framework/library utama
- Menentukan boundary antar layer
- Trade-off performa vs correctness
- Perubahan besar pada build system
- Keputusan yang sulit dibalik (irreversible)

## Kapan Tidak Perlu ADR?

- Refactor kecil tanpa perubahan API
- Perbaikan bug
- Penambahan test
- Perubahan formatting/style
- Update dependency minor

## Template

```markdown
# ADR-NNN: Judul Singkat

## Status
Proposed | Accepted | Deprecated

## Context
Masalah, constraint, dan kondisi saat keputusan diambil.

## Decision
Apa yang diputuskan.

## Consequences

### Positif
- keuntungan 1
- keuntungan 2

### Negatif
- kerugian 1
- kerugian 2

### Mitigasi
- cara mengurangi kerugian

## Alternatives Considered
1. Alternatif A: alasan ditolak
2. Alternatif B: alasan ditolaks