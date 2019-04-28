(* ocaml -init "load3.ml" *)

#load "unix.cma";;
#load "str.cma";;

(* The following line allows import of theorems formalized in other
   sessions of HOL Light. Import is required for the thm
   `the_nonlinear_inequalities`.  Remove this line to require all
   verifications to be done in the current session of HOL Light. *)

(* Unix.putenv "FLYSPECK_SERIALIZATION" "1";;  *)

let hollight_dir =
  (try Sys.getenv "HOLLIGHT_DIR" with Not_found -> Sys.getcwd());;

(* Add the HOL Light directory *)
Topdirs.dir_directory hollight_dir;;

(* Load HOL Light *)

#use "hol.ml";;

hol_version;;

(* from build/strictbuild.hl *)
type_invention_warning:= false;;

let flyspeck_dir =
  (try Sys.getenv "FLYSPECK_DIR" with Not_found -> Sys.getcwd());;

