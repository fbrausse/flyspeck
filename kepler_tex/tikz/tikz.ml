(* ========================================================================== *)
(* FLYSPECK - BOOK PREPARATION                                                *)
(*                                                                            *)
(* Chapter: Graphics                                                          *)
(* Author: Thomas C. Hales                                                    *)
(* Date: 2011-11-26                                                           *)
(* ========================================================================== *)

(* 
Some procedures to facilitate the generation of tikz graphics.
Tikz.execute produces output in /tmp/x.txt
Read in by fig.tex to produce graphics.

This is mostly independent of the flyspeck .hl files, but it might make
light use of HOL's lib.ml functions, such as sort.

Lessons learned:

Tikz is almost totally unusable for 3D graphics.
Generate 3D coordinates with OCAML, then project to 2D at the very end.
Use --plot[smooth] coordinates { ... } rather than try to use tikz elliptical
arc routines.

   At the beginning, I used Mathematica to generate tikz files, but
   eventually almost everything was done with Ocaml rather than Math'ca.

*)

module Tikz = struct

let map = List.map;;

let filter= List.filter;;

let hd = List.hd;;

(* from HOL LIGHT lib.ml . *)

(* let (o) = fun f g x -> f(g x);; *)

let rec (--) = fun m n -> if m > n then [] else m::((m + 1) -- n);;

let rec funpow n f x =
  if n < 1 then x else funpow (n-1) f (f x);;

let rec forall p l =
  match l with
    [] -> true
  | h::t -> p(h) & forall p t;;

let rec mem x lis =
  match lis with
    [] -> false
  | (h::t) -> Pervasives.compare x h = 0 or mem x t;;

let subtract l1 l2 = filter (fun x -> not (mem x l2)) l1;;

let intersect l1 l2 = filter (fun x -> mem x l2) l1;;

let subset l1 l2 = forall (fun t -> mem t l2) l1;;

let rec partition p l =
  match l with
    [] -> [],l
  | h::t -> let yes,no = partition p t in
            if p(h) then (if yes == t then l,[] else h::yes,no)
            else (if no == t then [],l else yes,h::no);;

let rec sort cmp lis =
  match lis with
    [] -> []
  | piv::rest ->
      let r,l = partition (cmp piv) rest in
      (sort cmp l) @ (piv::(sort cmp r));;

let rec zip l1 l2 =
  match (l1,l2) with
        ([],[]) -> []
      | (h1::t1,h2::t2) -> (h1,h2)::(zip t1 t2)
      | _ -> failwith "zip";;

let rec end_itlist f l =
  match l with
        []     -> failwith "end_itlist"
      | [x]    -> x
      | (h::t) -> f h (end_itlist f t);;

let rec assoc a l =
  match l with
    (x,y)::t -> if Pervasives.compare x a = 0 then y else assoc a t
  | [] -> failwith "find";;


(* I/O *)

let output_filestring tmpfile a = 
  let outs = open_out tmpfile in
  let _ = try (Printf.fprintf outs "%s" a) 
  with _ as t -> (close_out outs; raise t) in
   close_out outs ;;

let unsplit d f = function
  | (x::xs) ->  List.fold_left (fun s t -> s^d^(f t)) (f x) xs
  | [] -> "";;

let join_comma  = unsplit "," (fun x-> x);;

let join_lines  = unsplit "\n" (fun x-> x);;

let join_space  = unsplit " " (fun x-> x);;



(* math *)

let cos = Pervasives.cos;;
let sin = Pervasives.sin;;
let cot x = cos x /. sin x;;
let sqrt = Pervasives.sqrt;;
let pi = 4.0 *. atan(1.0);;
let nth = List.nth;;

(* arg between 0 and 2pi *)

let arg x y = if (y<0.0) then atan2 y x +. 2.0 *. pi else atan2 y x;;

let degree x = 180.0 *. x /. pi;;

let radian x = pi *. x /. 180.0;;

let eta x y z =
  let s = (x +. y +. z)/. 2.0 in
   x *. y *. z /. ( 4. *. sqrt(s *. (s -. x) *. ( s -. y) *. (s -. z)));;

let orig3 = (0.0,0.0,0.0);;

let orig2 = (0.0,0.0);;

(* vector sum, difference, scalar product, dot product *)

let map3 f (x,y,z) = (f x,f y,f z);;

let map2 f (x,y) = (f x , f y);;

let (+..) (x1,x2) (y1,y2) = (x1+. y1,x2+. y2);;

let (-..)  (x1,x2) (y1,y2) = (x1-. y1,x2-. y2);;

let uminus3 (x1,x2,x3) = (-. x1,-.x2,-.x3);;

let uminus2 (x1,x2) = (-. x1,-.x2);;

let ( %.. ) s (x1,x2) = (s *. x1, s *. x2);; 

let ( *.. ) (x1,x2) (y1,y2) = (x1 *. y1 +. x2 *. y2);;

let (+...) (x1,x2,x3) (y1,y2,y3) = (x1 +. y1, x2 +. y2, x3+. y3);;

let (-...) (x1,x2,x3) (y1,y2,y3) = (x1 -. y1, x2 -. y2, x3-. y3);;

let ( %... ) s (x1,x2,x3) = (s *. x1, s *. x2, s*. x3);; 

let ( *... ) (x1,x2,x3) (y1,y2,y3) = (x1 *. y1 +. x2 *. y2 +. x3 *. y3);;

let cross (x1,x2,x3) (y1,y2,y3) = 
  (x2 *. y3 -. x3 *. y2, x3 *. y1 -. x1 *. y3, x1 *. y2 -. x2 *. y1);;

let det3 x y z = x *... (cross y z);;

let det2 (x1,y1) (x2,y2) = (x1 *. y2 -. y1 *. x2);;

let conj (x,y) = (x,-. y);;

let cmul (x1,y1) (x2,y2) = (x1 *. x2 -. y1 *. y2, x1 *. y2 +. x2 *. y1);;

let cinv v = (1.0/. (v *.. v)) %.. (conj v);;

let cdiv u v = cmul u (cinv v);;



let delta1 = (1.0,0.0,0.0);;

let delta2 = (0.0,1.0,0.0);;

let delta3 = (0.0,0.0,1.0);;

let proj e1 e2 x = (x *... e1) , (x *... e2);;

let perp p x  =  x -... (((x *... p) /. (p *... p)) %... p) ;; (* ortho to p *)

let transpose ((a11,a12,a13),(a21,a22,a23),(a31,a32,a33)) = 
  ((a11,a21,a31),(a12,a22,a32),(a13,a23,a33));;

let transpose2 ((x1,y1),(x2,y2)) = ((x1,x2),(y1,y2));;

let mul3 (e1,e2,e3) x = 
     (e1 *... x,  e2 *... x, e3 *... x);;

let tuple3 [v1;v2;v3] = (v1,v2,v3);;

let list3 (v1,v2,v3) = [v1;v2;v3];;

let tuple2 [v1;v2] = (v1,v2);;

let list2 (v1,v2) = [v1;v2];;

let norm2 x = sqrt(x *.. x);;

let norm3 x = sqrt(x *... x);;

let normalize3 x = (1.0 /. sqrt(x *... x)) %... x;;

let normalize2 x = (1.0 /. sqrt(x *.. x)) %.. x;;

let dist3 x y = 
  let z = x -... y in sqrt (z *... z);;

let dist2 x y = 
  let z = x -.. y in sqrt (z *.. z);;

let rec outer x y = 
  match x with
    | [] -> []
    | a::r -> (map (fun i -> (a,i)) y) @ (outer r y);;

let solve33 (m1,m2,m3) c =    (* solve m.x ==c for x by Cramer *)
  let d = det3 m1 m2 m3 in
  let (t1,t2,t3) = transpose (m1,m2,m3) in
   map3 (fun t -> t/. d) (det3 c t2 t3, det3 t1 c t3, det3 t1 t2 c);;

let solve22 (m1,m2) c = 
  let d = det2 m1 m2 in
  let (t1,t2) = transpose2 (m1,m2) in
   map2 (fun t -> t/. d) (det2 c t2, det2 t1 c);;

let extreme_point m' = 
  solve33 m' (map3 (fun m -> 0.5 *. (m *... m)) m');;

let lex3 (i,j,k) (i',j',k') = (i<i') or ((i=i') &&(j<j')) or ((i=i')&&(j=j')&&(k<k'));;

let etaV u v w = 
  let x = dist2 (u -.. v) orig2 in
  let y = dist2 (v -.. w) orig2 in
  let z = dist2 (u -.. w) orig2 in
   eta x y z;;

(* BUGGED SOMEHOW.
let circum3 (a,b,c) = 
  let [a';b';c']= map norm3 [a;b;c] in
  let e = eta a' b' c' in
  let u = a -... c in
  let v = b -... c in
  let w = (cross u v) in
  let n = normalize3 (cross w u) in
  let t = sqrt (e *. e -. a' *. a' /. 4.0) in
    c +... (0.5 %... u) +... (t %... n);;
*)

let circumcenter (a,b,c) = 
  let a' = a -.. c in
  let b' = b -.. c in
  c +.. (0.5 %.. (solve22 (a',b') (a' *.. a', b' *.. b')));;

let frame_of v1 v2 = 
  let e1 = normalize3 (v1) in
  let e2 = normalize3 (perp e1 v2) in
  let e3 = cross e1 e2 in
    (e1,e2,e3);;
  
let random_SO3 seed = 
  let _ = Random.init seed in
  let v3 () = tuple3 (map (fun _ -> -1.0 +. Random.float 2.0) [0;0;0]) in
    frame_of (v3()) (v3());;


(* TIKZ OUTPUT *)

let ppair (x,y) = Printf.sprintf "(%f,%f)" x y;;

let pcoord s (x,y) = 
  Printf.sprintf "\\coordinate (%s) at (%f,%f) " s x y;;

let plet s y = 
  Printf.sprintf "\\pgfmathsetmacro\\%s{%s}" s y;;



(* specific cases *)

(* CLOSE PACKING CHAPTER FIGURES *)

(* SEYIMIE *)

let fcc_fun_domain = 
  let v1 = (1.0,0.0,0.0) in
  let v2 = (0.5,sqrt(3.0)/.2.0,0.0) in
  let v3 = (0.5,1.0 /. sqrt(12.0),sqrt(2.0/.3.0)) in
  let v12 = v1 +... v2 in
  let v23 = v2 +... v3 in
  let v13 = v1 +... v3 in
  let v123 = v1 +... v2 +... v3 in
  let f = frame_of (1.0,0.1,0.1) (0.3,0.5,1.0) in (* 0.3 0.5 1.0 *)
  let p v = proj delta1 delta2 (mul3 f v) in
  let [w1;w2;w3;w12;w23;w13;w123] = map p [v1;v2;v3;v12;v23;v13;v123] in
  let coord (s,u) = Printf.sprintf "\\coordinate (%s) at (%f,%f);" s (fst u) (snd u) in
    join_lines (map coord [("w1",w1);("w2",w2);("w3",w3);("w12",w12);("w23",w23);("w13",w13);("w123",w123)]);;

(*  figAZGXQWC *)

let tet_oct_ratio = 
  let v0 = (0.0,0.0,0.0) in
  let v1 = (1.0,0.0,0.0) in
  let v2 = (0.5,sqrt(3.0)/.2.0,0.0) in
  let v3 = (0.5,1.0 /. sqrt(12.0),sqrt(2.0/.3.0)) in
  let v12 = 0.5 %... (v1 +... v2) in
  let v02 = 0.5 %...( v0 +... v2) in
  let v01 = 0.5 %... v1 in
  let v03 = 0.5 %... v3 in
  let v13 = 0.5 %... (v1 +... v3) in
  let v23 = 0.5 %... (v2 +... v3) in
  let f = frame_of (1.0,0.1,0.1) (0.3,0.5,1.0) in (* 0.3 0.5 1.0 *)
  let p v = proj delta1 delta2 (mul3 f v) in
  let  [w0;w1;w2;w3;w12;w02;w01;w03;w13;w23] = map p [v0;v1;v2;v3;v12;v02;v01;v03;v13;v23] in 
  let coord (s,u) = Printf.sprintf "\\coordinate (%s) at (%f,%f);" s (fst u) (snd u) in
    join_lines (map coord [("w0",w0);("w1",w1);("w2",w2);("w3",w3);("w12",w12);("w02",w02);("w01",w01);("w03",w03);("w13",w13);("w23",w23)]);;

(* SGIWBEN *)

let fcc_hcp_pattern = 
  let f = frame_of 
(*     (0.3,0.4,0.1) (-0.1,0.1,0.4) in *)
     (0.4,0.3,0.1) (-0.2,0.1,0.4) in 
  let g = mul3 f in
  let u = g delta3 in
  let v0 = (0.0,0.0,0.0) in
  let v1 = g(1.0,0.0,0.0) in
  let v2 = g(0.5,sqrt(3.0)/.2.0,0.0) in
  let v3 = g(0.5,1.0 /. sqrt(12.0),sqrt(2.0/.3.0)) in
  let v4 = v2 -... v1 in
  let v5 = v0 -... v1 in
  let v6 = v0 -... v2 in
  let v7 = v0 -... v4 in
  let v8 = v3 +... v5 in
  let v9 = v3 +... v6 in
  let v10 = v0 -... v3 in
  let v11 = v0 -... v8 in
  let v12 = v0 -...  v9 in
  let n v = v -... (2.0 *. (u *... v) ) %... u in
  let v13 = v0 -... n v3 in
  let v14 = v0 -... n v8 in
  let v15 = v0 -... n v9 in
  let p v = proj delta1 delta2 (v) in
  let  [w0;w1;w2;w3;w4;w5;w6;w7;w8;w9;w10;w11;w12;w13;w14;w15] = map p 
    [v0;v1;v2;v3;v4;v5;v6;v7;v8;v9;v10;v11;v12;v13;v14;v15] in
  let coord (s,u) = Printf.sprintf "\\coordinate (%s) at (%f,%f);" s (fst u) (snd u) in
    join_lines (map coord [("w0",w0);("w1",w1);("w2",w2);("w3",w3);
     ("w4",w4);("w5",w5);("w6",w6);("w7",w7);("w8",w8);("w9",w9);("w10",w10);("w11",w11);("w12",w12);("w13",w13);("w14",w14);("w15",w15)]);;


let fcc_packing = 
  let f = frame_of 
(*     (0.4,0.3,0.1) (-0.2,0.1,0.4) in  *)
     (0.5,0.4,0.) (-. 0.0,0.1,0.4) in 
  let g = mul3 f in
  let u = g delta3 in
  let v0 = (0.0,0.0,0.0) in
  let v1 = g(1.0,0.0,0.0) in
  let v2 = g(0.5,sqrt(3.0)/.2.0,0.0) in
  let e1 = g delta1 in
  let e2 = g delta2 in
  let e3 = u in
  let v3 = g(0.5,1.0 /. sqrt(12.0),sqrt(2.0/.3.0)) in
  let e12 = e1 +... e2 in
  let e13 = e1 +... e3 in
  let e23 = e2 +... e3 in
  let e123 = e1 +... e2 +... e3 in
  let p v = proj delta1 delta2 (v) in
  let  [w0;w1;w2;w3;e1;e2;e3;e12;e13;e23;e123] = map p [v0;v1;v2;v3;e1;e2;u;e12;e13;e23;e123] in
  let coord (s,u) = Printf.sprintf "\\coordinate (%s) at (%f,%f);" s (fst u) (snd u) in
    join_lines (map coord [("w0",w0);("w1",w1);("w2",w2);("w3",w3);("e1",e1);("e2",e2);("e3",e3);("e12",e12);("e13",e13);("e23",e23);("e123",e123)]);;

let pascal_packing = 
  let f = frame_of 
(*     (0.5,0.4,0.0) (-0.0,0.1,0.4) in  *)
     (0.5,0.4,0.) (-0.2,0.1,0.4) in 
  let g = mul3 f in
  let v0 = (0.0,0.0,0.0) in
  let v1 = g(1.0,0.0,0.0) in
  let v2 = g(0.5,sqrt(3.0)/.2.0,0.0) in
  let v3 = g(0.5,1.0 /. sqrt(12.0),sqrt(2.0/.3.0)) in
  let p v = proj delta1 delta2 (v) in
  let  [w0;w1;w2;w3] = map p [v0;v1;v2;v3] in
  let coord (s,u) = Printf.sprintf "\\coordinate (%s) at (%f,%f);" s (fst u) (snd u) in
    join_lines (map coord [("w0",w0);("w1",w1);("w2",w2);("w3",w3)]);;




(* TCFVGTS % fig:face-centered-cubic *)

let circle_point r u v = 
    u +... r %... normalize3 (v -... u);;

let circle_interpolate r s u v1 v2 = 
  let v = (s %... v2) +... ((1.0 -. s) %... v1) in
    circle_point r u v;;

let pcircle r n v u1 u2 label = 
  let p1 = map (fun s -> circle_interpolate r (float_of_int s /. float_of_int n) v u1 u2) (0--n) in
  let q1 = map (proj delta1 delta2) p1 in
  let w1 = join_space (map (fun (x,y)-> Printf.sprintf "(%f,%f) " x y) q1) in
    Printf.sprintf "\\def\\%s{%s}" label w1 ;;

let cubic_layers = 
  let f = frame_of (1.0,0.1,0.4) (-0.5,1.0,0.0) in 
  let g = mul3 f in
  let r = sqrt(8.0) in
  let v0 =  (0.0,0.0,0.0) in
  let v1 = g(r %... delta1) in
  let v2 = g(r %... delta2) in 
  let v3 = g(r %... delta3) in 
  let v12 = (v1 +... v2) in
  let v13 = ( v1 +... v3) in
  let v23 = (v2+... v3) in
  let v123 = (v1 +... v2 +... v3) in
  let vfront = (0.5 %... (v12)) in
  let vtop = (0.5 %... (v2 +... v123)) in
  let vright = (0.5 %... (v1 +... v123)) in
  let p v = proj delta1 delta2 v in
  let   [w0;w1;w2;w3;w12;w13;w23;w123;wfront;wtop;wright]  = map p 
    [v0;v1;v2;v3;v12;v13;v23;v123;vfront;vtop;vright] in 
  let coord (s,u) = Printf.sprintf "\\coordinate (%s) at (%f,%f);" s (fst u) (snd u) in
  let cc =   (map coord 
			  [("w0",w0);("w1",w1);("w2",w2);("w3",w3);("w12",w12);("w13",w13);
			   ("w23",w23);("w123",w123);("wfront",wfront);("wtop",wtop);
			   ("wright",wright)]) in
  let b s = "tcf"^s in
  let paths = [(v0,v1,v2,b "a");(v1,v12,v0,b "b");(v12,v2,v1,b "c");
	      (v2,v0,v12,b "d");
	      (vfront,v12,v2,b"e");(vfront,v2,v0,b"f");(vfront,v0,v1,b"g");
              (vfront,v1,v12,b"h");
	      (v1,v13,v12,b"i");(v13,v123,v1,b"j");(v123,v12,v13,b"k");
	      (v12,v1,v123,b"l");
	      (vright,v123,v12,b"m");(vright,v12,v1,b"n");(vright,v1,v13,b"o");
	      (vright,v13,v123,b"p");
	      (v2,v12,v23,b"q");(v12,v123,v2,b"r");(v123,v12,v23,b"s");
	      (v23,v123,v2,b"t");
	      (vtop,v12,v123,b"u");(vtop,v123,v23,b"v");(vtop,v23,v2,b"w");
	      (vtop,v2,v12,b"x");] in
  let pc = map (fun (u,v1,v2,s)-> pcircle 1.0 5 u v1 v2 s) paths in
    join_lines (cc @ pc);;


(* NTNKMGO *)

let square_layers = 
  let f = frame_of (1.0,0.1,0.4) (-0.5,1.0,0.0) in 
  let g = mul3 f in
  let v0 =  (0.0,0.0,0.0) in
  let v1 = g( delta1) in
  let v2 = g( delta2) in 
  let v3 = g( delta3) in 
  let p v = proj delta1 delta2 v in
  let   [w0;w1;w2;w3]  = map p   [v0;v1;v2;v3] in 
  let coord (s,u) = Printf.sprintf "\\coordinate (%s) at (%f,%f);" s (fst u) (snd u) in
  let cc = map coord  [("w0",w0);("w1",w1);("w2",w2);("w3",w3)] in
    join_lines (cc);;



(* PQJIJGE *)

let rhombic_dodec = 
  let f = frame_of (1.0,0.1,0.4) (-0.5,1.0,0.0) in 
  let g = mul3 f in
  let r = 2.0 in 
  let v0 =  (0.0,0.0,0.0) in
  let v1 = g(r %... delta1) in
  let v2 = g(r %... delta2) in 
  let v3 = g(r %... delta3) in 
  let v12 = (v1 +... v2) in
  let v13 = ( v1 +... v3) in
  let v23 = (v2+... v3) in
  let v123 = (v1 +... v2 +... v3) in
  let center = 0.5 %... v123 in
  let vfront = (0.5 %... (v12 -... v3)) in
  let vtop = (0.5 %... (v2 +... v123)) +... 0.5 %... v2 in
  let vright = (0.5 %... (v1 +... v123)) +... 0.5 %... v1 in
  let vback = vfront +... 2.0 %... v3 in
  let vleft = vright -... 2.0 %... v1 in
  let vbottom = vtop -... 2.0 %... v2 in
  let p v = proj delta1 delta2 v in
  let   [w0;w1;w2;w3;w12;w13;w23;w123;wfront;wtop;wright;wback;wleft;wbottom;wcenter]  = map p 
    [v0;v1;v2;v3;v12;v13;v23;v123;vfront;vtop;vright;vback;vleft;vbottom;center] in 
  let coord (s,u) = Printf.sprintf "\\coordinate (%s) at (%f,%f);" s (fst u) (snd u) in
  let cc =   (map coord 
			  [("w0",w0);("w1",w1);("w2",w2);("w3",w3);("w12",w12);("w13",w13);
			   ("w23",w23);("w123",w123);("wfront",wfront);("wtop",wtop);
			   ("wright",wright);
			    ("wback",wback);("wleft",wleft);("wbottom",wbottom);
			  ("wcenter",wcenter)]) in
    join_lines cc;;


    


(* PACKING CHAPTER FIGURES *)

(* figDEQCVQL *)

let rec mindist2 r w = function 
  | [] -> r
  | l::ls -> if (dist2 l w < r) then mindist2 (dist2 l w) w ls else mindist2 r w ls;;

let randompacking radius seed xdim ydim = (* seed=5 works well *)
  let _ = Random.init seed in 
(*  let radius = 0.15 in *)
  let v () = (Random.float xdim,Random.float ydim) in
  let add len ls = 
    let w = v() in
      if (mindist2 100.0 w ls < 2.0 *. radius) or List.length ls > len then ls else w::ls in
  let unsat = funpow 40 (add 15) [] in
  let sat = funpow 100000 (add 20000) unsat in
   (unsat,sat);;

let print_satunsat seed =
  let radius = 0.15 in
  let (unsat,sat) = randompacking radius seed 2.0 2.0 in
  let line d (x,y)  = Printf.sprintf "\\draw[gray,fill=black!%d] (%f,%f) circle (0.15);" d x y in
  let punsat = map (line 30) unsat in
  let psat = map (line 10) sat in
    join_lines (["\\begin{scope}[shift={(0,0)}]"] @ punsat @
      ["\\end{scope}\\begin{scope}[shift={(3.0,0)}]"] @ psat @ punsat @ ["\\end{scope}"]);;

(* \figXOHAZWO Voronoi cells of a random saturated packing. Start with Delaunay triangles. *)



let center2 s (i,j,k) =  circumcenter (s i , s j , s k);; 
(*
  let si = s i -.. s k in
  let sj = s j -.. s k in
    s k +.. (0.5 %.. (solve22 (si,sj) (si *.. si, sj *.. sj)));;
*)

let sat_triples sat =
  let radius = 0.15 in
  let r = List.length sat in
  let s = nth sat in
  let rr = 0--(r-1) in
  let allt = outer rr (outer rr rr) in
  let triple =  (map (fun (i,(j,k))->(i,j,k)) (filter(fun (i,(j,k))->(i<j && j<k))  allt)) in
  let allpair = filter (fun (i,j) -> i< j) (outer rr rr) in
  let shortpair = filter (fun (i,j) -> dist2 (s i) (s j) < 4.0 *. radius +. 1.0e-5) allpair in
  let ftriple = filter (fun (i,j,k) -> mem (i,j) shortpair && mem(i,k) shortpair && mem(j,k) shortpair) triple in
  let fit (i,j,k) = 
    let c = center2 s (i,j,k) in
    let rad = dist2 c (s k) in
    let rest = subtract sat [s i;s j;s k] in
    let vals = filter (fun v -> dist2 v c < rad) rest in
      List.length vals = 0 in
    filter fit ftriple;;

let print_satst seed= 
  let radius = 0.15 in
  let (_,sat) =  randompacking radius seed 5.0 2.0 in
  let satst = sat_triples sat in
  let s = nth sat in
  let prs = filter (fun ((i,j,k),(i',j',k')) -> 
		      List.length (intersect [i;j;k] [i';j';k'])=2 && lex3 (i,j,k) (i',j',k'))   
    (outer satst satst) in
  let pp = map (fun (t, t') -> 
		  let (x,y) = center2 s t in
		  let (x',y') = center2 s t' in
		    Printf.sprintf "\\draw (%f,%f) -- (%f,%f) ;" x y x' y') prs in
  let smalldot (x,y)  = Printf.sprintf "%c\\draw[gray!10,fill=gray!30] (%f,%f) circle (0.15);\n\\smalldot{%f,%f};" '%' x y x y in
  let psmalldot = map (smalldot) sat in
    join_lines (psmalldot @ pp);;

(* autoBUGZBTW *)

let print_rogers seed=
  let radius = 0.15 in
  let (_,sat) = randompacking radius seed 3.0 1.4 in (* 3,1.4 *)
  let satst = sat_triples sat in
  let s = nth sat in
  let coord_triple t = center2 (nth sat) t in
  let prs = filter (fun ((i,j,k),(i',j',k')) -> 
		      List.length (intersect [i;j;k] [i';j';k'])=2 && lex3 (i,j,k) (i',j',k'))   
    (outer satst satst) in
  let pp = map (fun (t, t') -> 
		  let (x,y) = coord_triple t in
		  let (x',y') = coord_triple t' in
		    Printf.sprintf "\\draw[very thick] (%f,%f) -- (%f,%f) ;" x y x' y') prs in
  let smalldot (x,y)  = Printf.sprintf "%c\\draw[gray!10,fill=gray!30] (%f,%f) circle (0.15);\n\\smalldot{%f,%f};" '%' x y x y in
  let psmalldot = map (smalldot) sat in
  let draw ((ux,uy),(vx,vy)) = Printf.sprintf "\\draw (%f,%f)--(%f,%f);" ux uy vx vy in
  let drawc (ax,ay) (bx,by) (cx,cy) (dx,dy)=	
      Printf.sprintf "\\draw[fill=gray] (%f,%f)--(%f,%f)--(%f,%f)--(%f,%f)--cycle;" ax ay bx by cx cy dx dy in
  let draw_radial (i,j,k) = 
    let c = coord_triple (i,j,k) in
    let (u1,u2,u3)=(s i,s j,s k) in
    let vv = map draw  [(c,u1);(c,u2);(c,u3);] in
      join_lines vv in
  let radial = map draw_radial satst in
  let draw_dedge (t,t') =
    let c = coord_triple t in
    let c'= coord_triple t' in
    let (i,j) = tuple2 (intersect (list3 t) (list3 t')) in
    let u1 = s i in
    let u2 = s j in
    let w = u2 -.. u1 in
    let d = c -.. u1 in
    let d' = c' -.. u1 in
      if (det2 d w  *. det2 w d' > 0.0) then draw (u1, u2) else drawc u1 c u2 c' in
  let dedge = map draw_dedge prs in
    join_lines (psmalldot @ radial @ dedge @ pp);;

(* EVIAIQP
*)
let print_voronoi seed=
  let radius = 0.15 in
  let (_,sat) = randompacking radius seed 3.0 1.4 in (* 3,1.4 *)
  let satst = sat_triples sat in
  let coord_triple t = center2 (nth sat) t in
  let prs = filter (fun ((i,j,k),(i',j',k')) -> 
		      List.length (intersect [i;j;k] [i';j';k'])=2 && lex3 (i,j,k) (i',j',k'))   
    (outer satst satst) in
  let pp = map (fun (t, t') -> 
		  let (x,y) = coord_triple t in
		  let (x',y') = coord_triple t' in
		    Printf.sprintf "\\draw[very thick] (%f,%f) -- (%f,%f) ;" x y x' y') prs in
  let dot (x,y)  = Printf.sprintf "\\smalldot{%f,%f};" x y  in
  let psmalldot = map (dot) sat in
    join_lines (psmalldot @  pp);;

(* ANNTKZP *)

let print_delaunay seed=
  let radius = 0.15 in
  let (_,sat) = randompacking radius seed 3.0 1.4 in (* 3,1.4 *)
  let satst = sat_triples sat in
  let delaunay_edge = List.flatten (map (fun (i,j,k) -> [(i,j);(j,k);(k,i)]) satst) in
    
  let s = nth sat in
  let smalldot (x,y)  = Printf.sprintf "\\smalldot{%f,%f};"  x y  in
  let psmalldot = map (smalldot) sat in
  let draw ((ux,uy),(vx,vy)) = Printf.sprintf "\\draw (%f,%f)--(%f,%f);" ux uy vx vy in
  let pdraw = map (fun (i,j) -> draw (s i,s j)) delaunay_edge in
    join_lines ( psmalldot @ (* radial @ dedge @  pp @ *) pdraw);;



(* figYAJOTSL *)

let mk_tetrahedron seed = 
  let rot v = mul3 (random_SO3 seed) ( sqrt(3.0 /. 2.0) %... v) in
  let v1 = rot (0.0,0.0,1.0) in
  let v2 = rot (sqrt(8.0)/. 3.0,0.0,-. 1.0/. 3.0) in
  let v3 = rot (-. sqrt(8.0)/. 6.0, sqrt(2.0/. 3.0), -. 1.0/. 3.0) in
  let v4 = rot (-. sqrt(8.0)/. 6.0,-. sqrt(2.0 /. 3.0),-. 1.0/. 3.0) in
     (v1,v2,v3,v4);;

let print_tetra  = 
  let (v1,v2,v3,v4) = (mk_tetrahedron 50) in
  let [w1;w2;w3;w4]= map (proj delta1 delta2) [v1;v2;v3;v4] in
  let draw ((ux,uy),(vx,vy)) = Printf.sprintf "\\draw (%f,%f)--(%f,%f);" ux uy vx vy in
  let drawv ((ux,uy),(vx,vy)) = Printf.sprintf "\\draw[very thick] (%f,%f)--(%f,%f);" ux uy vx vy in
  let face (s, (ux,uy),(vx,vy),(wx,wy)) = 
    Printf.sprintf "\\draw[fill=black!%s] (%f,%f)--(%f,%f)--(%f,%f)--cycle;" s ux uy vx vy wx wy in
  let vertex (x,y) = Printf.sprintf "\\smalldot{%f,%f};" x y in
  let vertices = map vertex [w1;w2;w3;w4] in
  let vv = map draw [(w1,w2);(w1,w3);(w1,w4);(w2,w3);(w3,w4);(w2,w4)] in
  let shade = join_lines (map face [("45",w1,w2,w4); ("30",w1,w2,w3);("10",w2,w3,w4)]) in 
  let edges=  join_lines vv in
  let triangulate (u,v,w) = 
    let c = proj delta1 delta2 (0.3333 %... (u +... v +... w)) in 
    let [muv;mvw;muw] = map (fun (u,v)-> proj delta1 delta2 (0.5 %... (u +... v))) 
      [(u,v);(v,w);(u,w)] in
    let [pu;pv;pw] = map (proj delta1 delta2) [u;v;w] in
    let vv = map draw [(c,pu);(c,pv);(c,pw)] in
    let ww = map drawv [(c,muv);(c,mvw);(c,muw)] in
      join_lines (vv @ ww) in
    join_lines (edges :: shade :: (map triangulate [(v1,v2,v4);(v1,v2,v3);(v2,v3,v4)]) @ vertices);;

(* autoBWEYURN *)

let print_marchal seed=
  let radius = 0.15 in 
  let radius_sqrt2 = 0.212 in 
  let (_,sat) = randompacking radius seed 3.0 1.4 in (* 3,1.4 *)
  let satst = sat_triples sat in
  let rr = 0-- (List.length sat - 1) in
  let allpair = (outer rr rr) in
  let s = nth sat in
  let shortpair =filter(fun (i,j)-> (i<j)&& dist2 (s i) (s j) < 2.0 *. radius_sqrt2 -. 1.0e-4)  
    allpair in
  let coord_triple t = center2 (nth sat) t in
  let prs = filter (fun ((i,j,k),(i',j',k')) -> 
		      List.length (intersect [i;j;k] [i';j';k'])=2 && lex3 (i,j,k) (i',j',k'))   
    (outer satst satst) in
  let pp = map (fun (t, t') -> 
		  let (x,y) = coord_triple t in
		  let (x',y') = coord_triple t' in
		    Printf.sprintf "\\draw[very thick] (%f,%f) -- (%f,%f) ;" x y x' y') prs in
  let line (x,y)  = Printf.sprintf "\\draw[black,fill=black!20] (%f,%f) circle (%f);" 
    x y radius_sqrt2  in
  let dot_line (x,y) = Printf.sprintf "\\smalldot{%f,%f};" x y  in
  let psmalldot = map (line) sat in
  let dot = map (dot_line) sat in
  let draw ((ux,uy),(vx,vy)) = Printf.sprintf "\\draw (%f,%f)--(%f,%f);" ux uy vx vy in
  let draw_radial (i,j,k) = 
    let c = coord_triple (i,j,k) in
    let (u1,u2,u3)=(s i,s j,s k) in
    let vv = map draw  [(c,u1);(c,u2);(c,u3);] in
      join_lines vv in
  let radial = map draw_radial satst in
  let draw_dedge (t,t') =
    let c = coord_triple t in
    let c'= coord_triple t' in
    let (i,j) = tuple2 (intersect (list3 t) (list3 t')) in
    let u1 = s i in
    let u2 = s j in
    let w = u2 -.. u1 in
    let d = c -.. u1 in
    let d' = c' -.. u1 in
      if (det2 d w  *. det2 w d' > 0.0) then draw (u1, u2) else "%" in
  let dedge = map draw_dedge prs in
  let fill_tri (s,(ux,uy),(vx,vy),(wx,wy)) = 
    Printf.sprintf "\\draw[black,fill=black!%s] (%f,%f)--(%f,%f)--(%f,%f)--cycle;" 
      s ux uy vx vy wx wy in
  let rotate u v x = 
    v +.. cmul (normalize2 (u -.. v)) x in
  let drawc (ax,ay) (bx,by) (cx,cy) (dx,dy) =	
      Printf.sprintf "\\draw[fill=black!35] (%f,%f)--(%f,%f)--(%f,%f)--(%f,%f)--cycle;\n\\draw (%f,%f)--(%f,%f);" 
	ax ay bx by cx cy dx dy ax ay cx cy in
  let draw_cell2 (i,j) = 
    let u1 = s i in
    let u2 = s j in
    let r = dist2 u1 u2 in
    let h2 = radius_sqrt2 *. radius_sqrt2 -. r *. r /. 4.0 in
    let _ = (h2 >= 0.0) or failwith (Printf.sprintf "expected pos %d %d %f" i j h2) in
    let h = sqrt(h2) in
    let c = rotate u1 u2 (r /. 2.0,h) in
    let c' = rotate u1 u2 (r /. 2.0, -. h) in
      drawc u1 c u2 c' in
  let cell2 = map draw_cell2 shortpair in
  let draw_cell3 (i,j,k) = 
    let (u,v,w) = (s i,s j,s k) in fill_tri ("60",u,v,w) in
  let cell3filter (i,j,k) = 
    etaV (s i) (s j) (s k) < radius *. sqrt(2.0) in
  let cell3 = map draw_cell3 (filter cell3filter satst) in
    join_lines (psmalldot @ pp @ radial @ dedge @ cell2 @ cell3 @ dot);;

(* FIFJALK *)

let print_ferguson_hales seed=
  let radius = 0.15 in 
  let radius_h = 1.255 *. radius  in 
  let radius_h2 = 2.51 *. radius  in 
  let radius_s = sqrt(8.0) *. radius in
  let (_,sat) = randompacking radius seed 3.0 1.4 in (* 3,1.4 *)
  let s = nth sat in
  let satst = sat_triples sat in
  let qrtet = filter (fun (i,j,k) -> dist2 (s i) (s j) <  radius_h2 &&
		     dist2 (s j) (s k) < radius_h2 &&
		     dist2 (s i) (s k) < radius_h2) satst in
  let quarter = filter (fun (i,j,k) ->
			  let [a;b;c] = 
			    sort (<) [dist2 (s i) (s j);dist2 (s j) (s k);dist2 (s i) (s k)] in
			  (a < radius_h2 && b < radius_h2 && c < radius_s)) satst in
  let satst = sat_triples sat in
  let rr = 0-- (List.length sat - 1) in
  let allpair = (outer rr rr) in
  let coord_triple t = center2 (nth sat) t in
  let prs = filter (fun ((i,j,k),(i',j',k')) -> 
		      List.length (intersect [i;j;k] [i';j';k'])=2 && lex3 (i,j,k) (i',j',k'))   
    (outer satst satst) in
  let pp = map (fun (t, t') -> 
		  let (x,y) = coord_triple t in
		  let (x',y') = coord_triple t' in
		    Printf.sprintf "\\draw[very thick] (%f,%f) -- (%f,%f) ;" x y x' y') prs in
  let shortpair =filter(fun (i,j)-> (i<j)&& dist2 (s i) (s j) < radius_h2 -. 1.0e-4)  
    allpair in
  let circle (x,y)  = Printf.sprintf "\\draw[black,fill=black!20] (%f,%f) circle (%f);" 
    x y radius_h  in
  let dot_line (x,y) = Printf.sprintf "\\smalldot{%f,%f};" x y  in
  let pcircle = map (circle) sat in
  let dot = map (dot_line) sat in
  let fill_tri (s,(ux,uy),(vx,vy),(wx,wy)) = 
    Printf.sprintf "\\draw[black,fill=black!%s] (%f,%f)--(%f,%f)--(%f,%f)--cycle;" 
      s ux uy vx vy wx wy in
  let rotate u v x = 
    v +.. cmul (normalize2 (u -.. v)) x in
  let drawc (ax,ay) (bx,by) (cx,cy) (dx,dy) =	
      Printf.sprintf "\\draw[fill=black!35] (%f,%f)--(%f,%f)--(%f,%f)--(%f,%f)--cycle;\n\\draw (%f,%f)--(%f,%f) (%f,%f)--(%f,%f);" 
	ax ay bx by cx cy dx dy ax ay cx cy bx by dx dy in
  let draw_cell2 (i,j) = 
    let u1 = s i in
    let u2 = s j in
    let r = dist2 u1 u2 in
    let h2 = radius_h *. radius_h -. r *. r /. 4.0 in
    let _ = (h2 >= 0.0) or failwith (Printf.sprintf "expected pos %d %d %f" i j h2) in
    let h = sqrt(h2) in
    let c = rotate u1 u2 (r /. 2.0,h) in
    let c' = rotate u1 u2 (r /. 2.0, -. h) in
      drawc u1 c u2 c' in
  let cell2 = map draw_cell2 shortpair in
  let draw_cell3 (i,j,k) = 
    let (u,v,w) = (s i,s j,s k) in fill_tri ("60",u,v,w) in
  let cell3 = map draw_cell3 (qrtet @ quarter) in
    join_lines (pp @ pcircle  @ cell2 @ cell3 @ dot);;



(*
SENQMWT
*)

let print_thue seed=
  let radius = 0.15 in 
  let radius_2_div_sqrt3 = radius *. 2.0 /. sqrt(3.0) in 
  let (_,sat) = randompacking radius seed 3.0 1.4 in (* 3,1.4 *)
  let rr = 0-- (List.length sat - 1) in
  let allpair = (outer rr rr) in
  let s = nth sat in
  let shortpair =filter(fun (i,j)-> (i<j)&& dist2 (s i) (s j) < 2.0 *. radius_2_div_sqrt3 -. 1.0e-4)  
    allpair in
  let line (x,y)  = Printf.sprintf "\\draw[black,fill=black!20] (%f,%f) circle (%f);" 
    x y radius_2_div_sqrt3  in
  let dot_line (x,y) = Printf.sprintf "\\smalldot{%f,%f};" x y  in
  let psmalldot = map (line) sat in
  let dot = map (dot_line) sat in
  let rotate u v x = 
    v +.. cmul (normalize2 (u -.. v)) x in
  let drawc (ax,ay) (bx,by) (cx,cy) (dx,dy) =	
      Printf.sprintf "\\draw[fill=black!35] (%f,%f)--(%f,%f)--(%f,%f)--(%f,%f)--cycle;\n\\draw (%f,%f)--(%f,%f);" 
	ax ay bx by cx cy dx dy bx by dx dy in
  let draw_cell2 (i,j) = 
    let u1 = s i in
    let u2 = s j in
    let r = dist2 u1 u2 in
    let h2 = radius_2_div_sqrt3 *. radius_2_div_sqrt3 -. r *. r /. 4.0 in
    let _ = (h2 >= 0.0) or failwith (Printf.sprintf "expected pos %d %d %f" i j h2) in
    let h = sqrt(h2) in
    let c = rotate u1 u2 (r /. 2.0,h) in
    let c' = rotate u1 u2 (r /. 2.0, -. h) in
      drawc u1 c u2 c' in
  let cell2 = map draw_cell2 shortpair in
    join_lines (psmalldot  (* @  dedge *) @ cell2  @ dot);;



(* figKVIVUOT *)

let kv_inter r2 u v = 
  let nu = norm3 u in
  let nvu = norm3 (v-...u) in 
  let t = sqrt ( (r2 -. nu *. nu) /. (nvu *. nvu)) in
    u +... t %... (v-... u);;

(*
let kv_interp s u v1 v2 = 
  let r2 = 2.0 in
  let v = (s %... v2) +... ((1.0 -. s) %... v1) in
  let nu = norm3 u in
  let nvu = norm3 (v-...u) in 
  let t = sqrt ( (r2 -. nu *. nu) /. (nvu *. nvu)) in
    u +... t %... (v-... u)
  ;;
*)

let kv_interp r2 s u v1 v2 = 
  let v = (s %... v2) +... ((1.0 -. s) %... v1) in
    kv_inter r2 u v;;


let kv_proj rho (x,y,z) =  x %.. (1.0,0.0) +.. y %.. (0.0,1.0) +.. z %.. rho;;

let rx u1 u2 label = 
  let r2 = 2.0 in
  let rho = (0.33,0.66) in
  let null3 = (0.0,0.0,0.0) in
  let p1 = map (fun s -> kv_interp r2 (float_of_int s /. 5.0) null3 u1 u2) (0--5) in
  let q1 = map (kv_proj rho) p1 in
  let w1 = join_space (map (fun (x,y)-> Printf.sprintf "(%f,%f) " x y) q1) in
    Printf.sprintf "\\def\\kv%s{%s}" label w1 ;;

let col1 = 
  let a = 1.5 in
  let b = 2.0 in
  let c = b +. 0.2 in
  let bb = sqrt(b*.b -. a*.a) in
  let cc = sqrt(c*.c -. b*.b) in
  let r2 = 2.0 in
  let r = sqrt(r2) in
  let omega1 = a %... delta2 in 
  let omega2 = omega1 +... bb %... delta1 in
  let omega3 = omega2 +... cc %... delta3 in
  let v1 = r %... normalize3 omega1 in
  let v2 = r %... normalize3 omega2 in
  let v3 = r %... normalize3 omega3 in
  let w12 = rx v1 v2 "oneab" in
  let w13 = rx v1 v3 "oneac" in
  let w32 = rx v3 v2 "onecb" in
    join_lines [w12;w13;w32];;

let col2 = 
  let a = 1.0 in
  let b = 2.0 in
  let c = b +. 0.2 in
  let bb = sqrt(b*.b -. a*.a) in
  let cc = sqrt(c*.c -. b*.b) in
  let r2 = 2.0 in
  let r = sqrt(r2) in
  let omega1 = a %... delta2 in 
  let omega2 = omega1 +... bb %... delta1 in
  let omega3 = omega2 +... cc %... delta3 in
  let v13 = kv_inter r2 omega1 omega3 in
  let v12 = kv_inter r2 omega1 omega2 in
  let v3 = r %... normalize3 omega3 in
  let v2 = r %... normalize3 omega2 in
  let wab = rx v13 v3 "Bab" in
  let wbc = rx v3 v2 "Bbc" in
  let wcd = rx v2 v12 "Bcd" in
  let wda = rx v12 v13 "Bda" in
    join_lines [wab;wbc;wcd;wda];;


let col3 = 
  let a = 1.0 in
  let b = 1.35 in
  let c = 2.0 in
  let bb = sqrt(b*.b -. a*.a) in
  let cc = sqrt(c*.c -. b*.b) in
  let r2 = 2.0 in
  let r = sqrt(r2) in
  let omega1 = a %... delta2 in 
  let omega2 = omega1 +... bb %... delta1 in
  let omega3 = omega2 +... cc %... delta3 in
  let v13 = kv_inter r2 omega1 omega3 in
  let v23 = kv_inter r2 omega2 omega3 in
  let v3 = r %... normalize3 omega3 in
  let wab = rx v13 v3 "Cab" in
  let wbc = rx v3 v23 "Cbc" in
  let wca = rx v23 v13 "Cca" in
    join_lines [wab;wbc;wca];;



(*
figDEJKNQK

v0 = {0, 0, 1};
null = {0, 0, 0};
v1 = {0, 0.85, Sqrt[1 - 0.85^2]};
v2 = FarFrom[{1, 0, 0}, Vertex[{v0, 1}, {v1, 1}, {null, 1}]]
v3 = FarFrom[{0, 0, -1}, Vertex[{null, 1}, {v1, 1}, {v2, 1.26}]]
v4 = FarFrom[v1, Vertex[{null, 1}, {v2, 1}, {v3, 1.26}]]
v5 = FarFrom[v2, Vertex[{null, 1}, {v4, 1}, {v3, 1.26}]]
w4 = FarFrom[v1, Vertex[{null, 1}, {v2, 1}, {v3, 1}]]
w5 = FarFrom[v2, Vertex[{null, 1}, {v4, 1}, {v3, 1}]]
w6 = FarFrom[v4, Vertex[{null, 1}, {v3, 1}, {v5, 1}]]
*)


let vws = 
  let v1=( 0.0, 0.85, 0.526783) in
  let v2=( -0.820069, 0.278363, 0.5) in
  let v3=( 0.32578, 0.00230249, 0.945443) in
  let  v4=( -0.586928, -0.690949, 0.422025) in
  let v5=( 0.329363, -0.938133, 0.106892) in
  let w4=( -0.409791, -0.617314, 0.671562) in
  let w5=(0.40333, -0.826891, 0.391887) in
  let  w6=(0.965333, -0.171655, 0.196637) in
		       (v1,v2,v3,v4,v5,w4,w5,w6);;

let rxdej(u1,u2,label) = 
  let r2 = 1.0 in
  let rho = (0.0,0.0) in
  let null3 = (0.0,0.0,0.0) in
  let p1 = map (fun s -> kv_interp r2 (float_of_int s /. 5.0) null3 u1 u2) (0--5) in
  let q1 = map (kv_proj rho) p1 in
  let w1 = join_space (map (fun (x,y)-> Printf.sprintf "(%f,%f) " x y) q1) in
    Printf.sprintf "\\def\\dejk%s{%s}" label w1 ;;

let mkdejA = 
  let (v1,v2,v3,v4,v5,w4,w5,w6) = vws in
  let vv = join_lines (map rxdej 
      [(v1,v2,"a");(v2,v4,"b");(v4,v5,"c");(v5,w6,"d");(w6,v3,"e");(v3,v1,"f");
       (v2,v3,"g");(v4,v3,"h");(v5,v3,"i");(v4,w5,"j");(w5,v3,"k");(v2,w4,"l");
      (w4,v3,"m")]) in 
    vv;;

let mkdejB = 
  let rho = (0.0,0.0) in
  let (v1,v2,v3,v4,v5,w4,w5,w6) = vws in
  let a ((x,y),s) = Printf.sprintf "\\coordinate (%s) at (%f,%f);" s x y in
  let ww = join_lines (map (fun (v,s) -> a ((kv_proj rho v),s))
     [(v1,"v1");(v2,"v2");(v3,"v3");(v4,"v4");(v5,"v5");(w4,"w4");(w5,"w5");(w6,"w6")]) in
    ww;;


(* QTICQYN

Mathematica:
v0 = {0, 0, 1};
null = {0, 0, 0};
v1 = {0, 0.85, Sqrt[1 - 0.85^2]};
v2 = FarFrom[{1, 0, 0}, Vertex[{v0, 1}, {v1, 1}, {null, 1}]];
v3 = FarFrom[{0, 0, -1}, Vertex[{null, 1}, {v1, 1}, {v2, 1.5}]];
v4 = FarFrom[v1, Vertex[{null, 1}, {v2, 1}, {v3, 1.5}]];
v5 = FarFrom[v2, Vertex[{null, 1}, {v4, 1}, {v3, 1}]];
*)

let qtvv = 
  let v1=(0.0, 0.85, 0.526783) in 
  let v2=(-0.820069, 0.278363,   0.5) in 
  let v3=(0.651104, 0.124197,       0.748758) in 
  let v4=(-0.572254, -0.688878, 0.444941) in 
  let v5=(0.421862, -0.796553, 0.433055) in
    (v1,v2,v3,v4,v5);;


let rxqt(u1,u2,label) = 
  let r2 = 1.0 in
  let rho = (0.0,0.0) in
  let null3 = (0.0,0.0,0.0) in
  let p1 = map (fun s -> kv_interp r2 (float_of_int s /. 5.0) null3 u1 u2) (0--5) in
  let q1 = map (kv_proj rho) p1 in
  let w1 = join_space (map (fun (x,y)-> Printf.sprintf "(%f,%f) " x y) q1) in
    Printf.sprintf "\\def\\qt%s{%s}" label w1 ;;

let mkqtA = 
  let (v1,v2,v3,v4,v5) = qtvv in
  let vv = join_lines (map rxqt
      [(v1,v2,"a");(v2,v4,"b");(v4,v5,"c");(v5,v3,"d");(v3,v1,"e");(v2,v3,"f");
       (v4,v3,"g")]) in
    vv;;

let mkqtB = 
  let rho = (0.0,0.0) in
  let (v1,v2,v3,v4,v5) = qtvv in
  let a ((x,y),s) = Printf.sprintf "\\coordinate (%s) at (%f,%f);" s x y in
  let ww = join_lines (map (fun (v,s) -> a ((kv_proj rho v),s))
     [(v1,"v1");(v2,"v2");(v3,"v3");(v4,"v4");(v5,"v5")]) in
    ww;;

(*
HEABLRG
*)

let vvhe = 
  let (a,b,c) = (0.45,0.6,0.4) in
    map normalize3 [(a,b,c);(-. a,b,c);(-.a,-.b,c);(a,-.b,c)];;

let dualhe = 
  let [v1;v2;v3;v4] = vvhe in 
  let nc (u,v) = normalize3 (cross u v) in
   map nc [(v1,v2);(v2,v3);(v3,v4);(v4,v1)];;

let mkhe = 
  let rho = (0.0,0.0) in
  let [v1;v2;v3;v4] = vvhe in
  let [w1;w2;w3;w4] = dualhe in 
  let vv = join_lines (map rxqt
      [(v1,v2,"a");(v2,v3,"b");(v3,v4,"c");(v4,v1,"d");(w1,w2,"e");(w2,w3,"f");
       (w3,w4,"g");(w4,w1,"h")]) in
  let a ((x,y),s) = Printf.sprintf "\\coordinate (%s) at (%f,%f);" s x y in
  let ww = join_lines (map (fun (v,s) -> a ((kv_proj rho v),s))
     [(v1,"v1");(v2,"v2");(v3,"v3");(v4,"v4");(w1,"w1");(w2,"w2");(w3,"w3");
      (w4,"w4")]) in
    join_lines [ww;vv];;



(* figYAHDBVO *)

let vv i = (72.0*.i +. (-.40.0) +. Random.float 80.0,Random.float 1.5 +. 1.0);;

(* map (vv o float_of_int) [0;1;2;3;4];; *)

let vout =[ (-1.40573615605411817, 2.43152527011496122);
   (62.2310998421659392, 1.50101500229540341);
   (166.419445012932584, 1.80579527399678152);
   (206.27916875919712, 1.73501080990908485);
   (293.766402309343221, 1.59228179599956721)];;

let midangles = 
  let mm = map fst vout in
  let suc i = ((i+1) mod 5) in
  let mm1 i = nth mm (suc i) +. if (nth mm i < nth mm (suc i)) then 0.0 else 360. in
  let mm' i = 0.5 *. (nth  mm i  +. mm1 i ) in
  let f =   map mm' (0--4) in
  let mm' i = 1.0/. cos( (pi /. 180.0) *.(0.5 *. (mm1 i -. nth mm i))) in
  let g = map mm' (0--4) in
   zip f g;;

let poly2_extreme = 
  let m = map (fun (theta,r)-> (r *. cos (radian theta), r*. sin (radian theta))) vout in
  let v i = nth m i in
  let suc i = v ((i+1) mod 5) in
  let inter i = solve22 (v i, suc i) (v i *.. v i, suc i *.. suc i) in
    map inter (0--4);;

(* figZXEVDCA *)


let fix_SO3 =  (*  random_SO3 () ;;  *)
  ((-0.623709278332764572, -0.768294961660169751, -0.143908262477248777),
   (-0.592350038826666592, 0.34445174255424732, 0.728336754910384077),
   (-0.510008007411323683, 0.539514456654259789, -0.669937298138706616));;


(* vertices of an icosahedron, vector lengths sqrt3. *)

let icos_vertex =
  let sqrt3 = sqrt(3.0) in
  let v = sqrt3 %... (1.0,0.0,0.0) in
(*  let d0 = 2.10292 in *)  (* 20 Solid[2,2,2,d0,d0,d0] = 4 Pi *)
  let theta = 1.10715 in (* arc[2,2,d0] = theta *)
  let ct = cos theta in
  let st = sin theta in 
  let p5 = pi/. 5.0 in
  let vv =    map (mul3 fix_SO3)  
    ( v :: map 
       (fun i->  (sqrt3 %... (ct, st *. cos (i *. p5), st *. sin (i *. p5)))) 
       [2.0;4.0;6.0;8.0;10.0]) in
   (vv @ (map ( uminus3 ) vv));;

let iv  = nth icos_vertex;;

let icos_edge = 
  let v i = nth icos_vertex i in
  let dall = filter (fun (i,j) -> (i<j)) (outer (0--11) (0--11)) in
   filter (fun (i,j) -> dist3 (v i) (v j) < 2.2) dall;;  (* note 2.2 cutoff *)

let icos_face = 
  let micos (i,j) = mem ( i, j ) icos_edge in
  let balance (i,(j,k)) = (i,j,k) in
    map balance (filter (fun (i,(j,k)) -> micos (i,j) && micos (i,k) && micos (j,k)) 
     (outer (0--11) (outer (0--11) (0--11))));;

let dodec_vertex = 
  map (fun (i,j,k) -> extreme_point (iv i,iv j,iv k)) icos_face;;  (* voronoi cell vertices *)

let next_icos_face (a,b,u3)=  (* input flag: [a] subset u2 subset u3 *)
  let v3 = list3 u3  in
  let _ = mem a v3 or failwith "next_dodec_face a" in
  let _ = mem b v3 or failwith "next_dodec_face b" in
  let ifc = map (tuple3) (filter (subset [a;b]) (map list3 icos_face)) in
  let ifc' = subtract ifc [u3] in
  let _ = List.length ifc' = 1 or failwith "next_dodec_face c" in
  let w3 = nth ifc' 0 in
  let cx = subtract (list3 w3) [a;b] in 
  let _ = List.length cx = 1 or failwith "next_dodec_face d" in
  let c = hd cx in
  let w2x = filter (fun (i,j)->(i<j)) [(a,c);(c,a)] in
  let _ = List.length w2x = 1 or failwith "next_dodec_face e" in
    (a,c,w3);;

let icos_vertex_cycle a = 
  let [i;j;k] = hd (filter (mem a) (map list3 icos_face)) in
  let startp = (a,(if (a=i) then j else i),(i,j,k)) in
  let t = map (fun i -> funpow i next_icos_face startp) [0;1;2;3;4] in
    map (fun (_,_,u) -> u) t;;

let icos_cycles = map icos_vertex_cycle (0--11);;

let ht xxs = 
  let (_,_,z) = end_itlist ( +... ) xxs in
    z;;

let sort_dodec_face = 
  let t = icos_cycles in
  let lookup = zip icos_face dodec_vertex in
  let htc cycle = ht (map (fun i -> assoc i lookup) cycle) in
  let hts = map htc t in
  let z = zip hts t in
  let z' = filter (fun (h,_) -> (h>0.0)) z in
  let t' = map snd (sort (fun (a,_) (b,_) -> a<b) z') in
    t';;

let center_face cycle = 
  let lookup = zip icos_face dodec_vertex in
  let coords = map (fun i -> assoc i lookup) cycle in
    (1.0 /. float_of_int (List.length cycle)) %... (end_itlist (+...) coords);;

let pname (i,j,k) = Printf.sprintf "V%d-%d-%d" i j k;;

let print_cycles = 
  let lookup = zip icos_face (map (proj delta1 delta2) dodec_vertex) in
    map (fun (r,(x,y)) -> Printf.sprintf "\\coordinate (%s) at (%f,%f);" (pname r) x y) lookup;;

let print_dodec_face = 
  let opt = "fill=white" in
  let pdraw = Printf.sprintf "\\draw[%s] " opt in
  let cycle m = join_space (map (fun s -> Printf.sprintf "(%s)--" ( pname s)) m) in
  let s m = pdraw ^ (cycle m) ^ "cycle;" in 
    map s sort_dodec_face;;

(* let print_dodec = join_lines (print_cycles @ print_dodec_face);; *)



(* printing spherical caps.
   Parameters: 
     R = radius of sphere at the origin
     v =(_,_,_) norm 1 vector pointing to center of cap.
     theta = arclength on unit sphere of cap.

*)



let frame_cap v = 
  let v = normalize3 v in
  let (x,y,z) = v in
  let w = normalize3 (-. y,x,0.0) in
  frame_of v w;;
    
let ellipse_param v rad theta = 
  let (v,w,u) = frame_cap v in
  let q = (rad *. cos theta) %... v in
  let qbar = proj delta1 delta2 q in
  let p = ((rad *. cos theta) %... v) +... ((rad *. sin theta) %... u) in
  let pbar = proj delta1 delta2 p in
  let h = dist2 qbar pbar in
  let k = rad *. sin theta in
    (qbar,h,k);;

let calc_psi theta v = 
  let (x,y,_) = normalize3 v in
  let cospsi = cos theta /. sqrt( x *. x +. y *. y) in
    if (abs_float cospsi <= 1.0) then acos cospsi else 0.0;;

let calc_alpha rad psi qbar =
  let nqbar = normalize2 qbar in 
  let rtrue = cmul (rad *. cos psi, rad *. sin psi) nqbar in
  let a = normalize2 (rtrue -.. qbar) in
    acos (a *.. nqbar);;

let adjust_alpha h k alpha =  (* compensate for TIKZ BUG in arc specs *)
  let ca = cos alpha in
  let sa = sin alpha in
  let t = 1.0 /. sqrt(ca *. ca /. (h *. h) +. sa *. sa /. (k *. k)) in
    acos (t *. ca /. h);;

let print_ellipse rad qbar h k psi = 
  let nqbar = normalize2 qbar in
  let r = (rad *. cos psi, rad *. sin psi) in
  let (qbx,qby) = qbar in
  let (px,py) = cmul r nqbar in
  let (px',py') = cmul (conj r) nqbar in
  let alpha = adjust_alpha h k (calc_alpha rad psi qbar) in
  let endangle = 2.0 *. pi -. alpha in
  let rotateAngle = degree (arg qbx qby) in
  let cstart = degree (arg px' py') in
  let delta = 2.0 *. psi in 
  let s = "\\draw[ball color=gray!10,shading=ball] (0,0) circle (1);\n\\end{scope}" in
    if (psi<0.01) then
       Printf.sprintf
	"\\begin{scope} \\clip (%f,%f) circle[x radius=%f,y radius=%f,rotate=%f];\n%s"
	qbx qby h k rotateAngle s
    else
      Printf.sprintf 
	"\\begin{scope}\\clip (%f,%f) arc[x radius=%f,y radius = %f,start angle=%f,end angle=%f,rotate=%f] arc[radius=1.0,start angle=%f,delta angle=%f];\\pgfpathclose;\n%s"
	px py h k  (degree alpha) (degree endangle) rotateAngle
        cstart (degree delta)
	s;;

let print_dodec_ellipse = 
  let vs = map center_face sort_dodec_face in
  let theta = pi /. 6.0 in
  let rad = 1.0 in
  let one_ellipse v = 
    let (q,h,k) = ellipse_param v rad theta in
    let psi = calc_psi theta v in
     print_ellipse rad q h k psi in
    map one_ellipse vs;;





(* output *)

let outfilestring = "/tmp/x.txt";;

let execute() = 
  let outs = open_out outfilestring in
  let write_out s = try (Printf.fprintf outs "%s" s) 
  with _ as t -> (close_out outs; raise t) in
  let _ = write_out  "% AUTO GENERATED BY tikz.ml. Do not edit.\n" in
  let wrap s s' = Printf.sprintf "\\def\\%s{%s}\n\n\n" s s' in
  let add name s = write_out (wrap name s) in 
  let _ =  add "autoZXEVDCA"   
    (join_lines (print_cycles @ print_dodec_face @ print_dodec_ellipse)) in
  let voronoi_seed = 12345678 in (* 50, 300 good, *)
  let _ = add "autoDEQCVQL" (print_satunsat 5) in
(* ok to here. In ML mode next line causes stack overflow. *)
  let _ = add "autoXOHAZWO" (print_satst voronoi_seed) in
  let _ = add "autoBUGZBTW" (print_rogers voronoi_seed) in
  let _ = add "autoORQISJR" (print_rogers 45) in
  let _ =  add "autoSENQMWT" (print_thue 45) in 
  let _ =  add "autoEVIAIQP" (print_voronoi 45) in 
  let _ =  add "autoANNTKZP" (print_delaunay 45) in 
  let _ =  add "autoFIFJALK" (print_ferguson_hales 45) in 
  let _ =  add "autoBWEYURN" (print_marchal 45) in
  let _ =  add "autoYAJOTSL" (print_tetra) in
  let _ =  add "autoKVIVUOT" (join_lines[col1;col2;col3]) in
  let _ =  add "autoDEJKNQK" (mkdejA) in
  let _ =  add "autocDEJKNQK" (mkdejB) in
  let _ =  add "autoQTICQYN" (join_lines [mkqtA;mkqtB]) in 
  let _ =  add "autoHEABLRG" (mkhe) in 
  let _ =  add "autoSEYIMIE" (fcc_fun_domain) in 
  let _ =  add "autoAZGXQWC" (tet_oct_ratio) in 
  let _ =  add "autoTCFVGTS" (cubic_layers) in 
  let _ =  add "autoPQJIJGE" (rhombic_dodec) in 
  let _ =  add "autoSGIWBEN" (fcc_hcp_pattern) in 
  let _ =  add "autoDHQRILO" (fcc_packing) in 
  let _ =  add "autoBDCABIA" (pascal_packing) in 
  let _ =  add "autoNTNKMGO" (square_layers) in 
  let _ = close_out outs in
  "to save results move /tmp/x.txt to kepler_tex/x.txt"
    ;;

(*
let gen2_out = 
  let wrap s s' = Printf.sprintf "\\def\\%s{%s}\n\n\n" s s' in
  let outstring = ref "" in
  let add name s = outstring:= !outstring ^ wrap name s in
  let _ =  add "autoYAJOTSL" (print_tetra) in
  let _ =  add "autoKVIVUOT" (join_lines[col1;col2;col3]) in
  let _ =  add "autoDEJKNQK" (mkdejA) in
  let _ =  add "autocDEJKNQK" (mkdejB) in
  let _ =  add "autoQTICQYN" (join_lines [mkqtA;mkqtB]) in 
  let _ =  add "autoHEABLRG" (mkhe) in 
  let _ =  add "autoSEYIMIE" (fcc_fun_domain) in 
  let _ =  add "autoAZGXQWC" (tet_oct_ratio) in 
  let _ =  add "autoTCFVGTS" (cubic_layers) in 
  let _ =  add "autoPQJIJGE" (rhombic_dodec) in 
  let _ =  add "autoSGIWBEN" (fcc_hcp_pattern) in 
  let _ =  add "autoDHQRILO" (fcc_packing) in 
  let _ =  add "autoBDCABIA" (pascal_packing) in 
  let _ =  add "autoNTNKMGO" (square_layers) in 
    output_filestring "/tmp/y.txt" (!outstring);;

let genz_out  = 
  let wrap s s' = Printf.sprintf "\\def\\%s{%s}\n\n\n" s s' in
  let outstring = ref "" in
  let add name s = outstring:= !outstring ^ wrap name s in
  let _ =  add "autoNTNKMGO" (square_layers) in 
    output_filestring "/tmp/z.txt" (!outstring);;
*)

end;;
