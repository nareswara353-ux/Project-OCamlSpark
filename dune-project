(lang dune 3.12)
(name actuator_controller)
(using ctypes 0.1)
(package
 (name actuator_controller)
 (depends
  (alcotest :with-test)
  (ctypes-foreign)
  (core :with-test)))
(generate_opam_files true)
