let version_major = 0
let version_minor = 1
let version_patch = 0

let version_string =
  Printf.sprintf "%d.%d.%d" version_major version_minor version_patch

let build_timestamp () = Unix.gettimeofday ()

let build_info () = [
  ("name", "actuator_engine");
  ("version", version_string);
  ("language", "OCaml");
  ("safety_kernel", "SPARK/Ada");
  ("ffi", "Ctypes + C ABI");
  ("license", "GPL-3.0-only");
]

let banner () =
  Printf.sprintf
    "Flight Control Surface Actuator Controller v%s\nHybrid OCaml + SPARK\nBuild: %s"
    version_string
    (let t = build_timestamp () in
     let tm = Unix.gmtime t in
     Printf.sprintf "%04d-%02d-%02dT%02d:%02d:%02dZ"
       (tm.Unix.tm_year + 1900) (tm.Unix.tm_mon + 1) tm.Unix.tm_mday
       tm.Unix.tm_hour tm.Unix.tm_min tm.Unix.tm_sec)
