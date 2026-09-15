1. **Zero Comments Policy**
   Seluruh kode (`.ml`, `.mli`, `.ads`, `.adb`, `.c`, `.h`) dilarang mengandung komentar dalam bentuk apapun. Tidak ada `(* *)`, `--`, `//`, `/* */`, atau placeholder `TODO`. Semua logika harus self-documenting melalui penamaan yang ekspresif dan tipe yang ketat.

2. **Formal Contracts First**
   Setiap fungsi SPARK wajib memiliki `Pre`, `Post`, dan (jika perlu) loop `Invariant`. Subtype dengan `Dynamic_Predicate` digunakan untuk menegakkan invariant global. `pragma Ghost` digunakan untuk properti yang hanya ada saat proof.

3. **Explicit Interfaces**
   Setiap modul OCaml wajib memiliki `.mli`. Setiap paket SPARK wajib memiliki `.ads`. Tidak ada implementasi tanpa deklarasi eksplisit.

4. **Single Responsibility**
   Setiap file memiliki satu tanggung jawab. Nama file mencerminkan domainnya (`actuator_commands`, `redundancy_voter`, `health_monitor`, `power_distribution`).

## Alur Kerja Git

### Branch Naming
main stable, protected
feat/<scope>-<short-description> fitur baru
fix/<scope>-<short-description> perbaikan bug
proof/<scope>-<property> penambahan kontrak formal
ci/<scope>-<change> perubahan pipeline
docs/<scope>-<change> dokumentasi

text

### Commit Convention
Format: `<type>(<scope>): <subject>`

Tipe yang diizinkan:
- `feat` — fitur baru
- `fix` — perbaikan bug
- `proof` — penambahan/perbaikan kontrak formal
- `test` — penambahan/perbaikan test
- `build` — perubahan build system (dune, gpr, alire)
- `ci` — perubahan pipeline CI
- `docs` — dokumentasi
- `refactor` — refactor tanpa perubahan perilaku
- `chore` — pemeliharaan umum

Contoh:
feat(spark): add triple-redundant voter with formal consensus checks
proof(actuator): strengthen post-condition on apply_limits
fix(bindings): declare spark_* symbols as extern for linker compatibility
ci(github): split into spark-build and ocaml-build jobs

text

## Kriteria Penerimaan File Baru

Setiap file yang ditambahkan ke repositori harus memenuhi:

1. **Lokasi yang benar** — sesuai struktur (`core_spark/`, `bindings/`, `engine_ocaml/`, `tests/`, `.github/`)
2. **Tanpa komentar** — verifikasi dengan `grep -rnE '\(\*|--|//|/\*' <file>`
3. **Kontrak formal** (untuk SPARK) — setiap fungsi publik memiliki `Pre`/`Post`
4. **Interface eksplisit** (untuk OCaml) — setiap `.ml` memiliki `.mli` pasangan
5. **Test yang sesuai** — setiap modul baru harus memiliki test di `tests/`
6. **Passing proof** — `gnatprove --level=1` hijau untuk unit SPARK
7. **Passing test** — `dune exec -- tests/ocaml_tests.exe` hijau
8. **Build bersih** — `make all` selesai tanpa error

## Quality Gates

| Gate | Tool | Perintah |
|------|------|----------|
| Formal Proof | gnatprove | `alr exec -- gnatprove -P actuator_controller.gpr --level=1` |
| SPARK Build | gprbuild | `alr exec -- gprbuild -P spark_lib.gpr -p` |
| SPARK Unit Tests | AUnit | `./bin/spark_runner` |
| OCaml Build | dune | `dune build` |
| OCaml Unit Tests | Alcotest | `dune exec -- tests/ocaml_tests.exe` |
| Integration Tests | Alcotest | `dune exec -- tests/integration_test.exe` |
| Full Pipeline | Make | `make all && make test` |

## Checklist Sebelum Push
[ ] Tidak ada komentar di file baru
[ ] Setiap fungsi SPARK memiliki Pre/Post
[ ] Setiap modul OCaml memiliki .mli
[ ] Test tersedia dan lulus
[ ] gnatprove hijau
[ ] dune build hijau
[ ] Commit message mengikuti konvensi
[ ] Branch tidak langsung ke main (kecuali hotfix)

text

## Review Checklist untuk Pull Request

Reviewer wajib memverifikasi:

1. **Zero comments** — scan cepat seluruh diff
2. **Contract completeness** — tidak ada `Pre => True` atau `Post => True` yang trivial
3. **Proof status** — CI hijau untuk job `spark-build`
4. **Test coverage** — setiap modul baru diuji minimal satu kali
5. **Naming consistency** — mengikuti pola yang sudah ada (snake_case untuk OCaml, Mixed_Case untuk SPARK)
6. **No regression** — test lama tetap lulus

## Struktur Kontribusi
core_spark/ — hanya SPARK/Ada, kontrak formal wajib
bindings/ — C glue, tanpa logic bisnis
engine_ocaml/ — OCaml murni, functional style, immutable data
tests/ — test terpisah untuk SPARK (AUnit) dan OCaml (Alcotest)
.github/ — hanya CI, tidak ada kode produksi
scripts/ — otomasi lokal, tidak ada logic produksi

text

## Pelaporan Bug

Sertakan:
1. Deskripsi bug
2. Langkah reproduksi
3. Expected vs actual behavior
4. Output `dune build` / `gnatprove` jika relevan
5. Commit hash yang bermasalah

## Keamanan & Kerahasiaan

Karena proyek ini menyentuh ranah mission-critical:
- Jangan commit kredensial, kunci, atau sertifikat
- Jangan ekspos data sensor nyata
- Jangan sertakan konfigurasi hardware spesifik
- Gunakan data sintetis untuk semua test

## Lisensi Kontribusi

Dengan mengirimkan pull request, Anda menyetujui bahwa kontribusi Anda dilisensikan di bawah GPL-3.0-only sesuai file `LICENSE` di repositori ini.