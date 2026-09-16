## Deskripsi

Jelaskan perubahan yang diajukan dan alasan teknisnya.

## Jenis Perubahan

- [ ] Feat (fitur baru)
- [ ] Fix (perbaikan bug)
- [ ] Proof (kontrak formal)
- [ ] Test (penambahan/perbaikan test)
- [ ] Build / CI
- [ ] Docs / Refactor / Chore

## Checklist

- [ ] Tidak ada komentar di file baru (`.ml`, `.mli`, `.ads`, `.adb`, `.c`, `.h`)
- [ ] Setiap fungsi SPARK publik memiliki Pre/Post
- [ ] Setiap modul OCaml memiliki `.mli`
- [ ] `gnatprove --level=1` hijau
- [ ] `dune build` hijau
- [ ] Test baru ditambahkan dan lulus
- [ ] Commit message mengikuti konvensi
- [ ] Tidak ada kredensial atau data sensitif

## Issue Terkait

Fixes #(nomor issue)
