
let version = "0.1"

module Store = struct

  type t = (string, float) Hashtbl.t

  let empty () = Hashtbl.create 8

  module IO = struct

    let bracket x destroy f =
      let r = try f x with exn -> ( destroy x ; raise exn ) in
      ( destroy x ; r )

    let query ~db =
      try
        bracket (open_in db) close_in Marshal.from_channel
      with Sys_error _ -> empty ()

    let update ~db f =
      let (t : t) = query ~db in
      let ()      = f t in
      bracket (open_out db) close_out @@ fun oc ->
        Marshal.to_channel oc t []
  end

  let weighted ~db =
    let t = IO.query ~db in
    List.sort (fun (_, w1) (_, w2) -> compare w2 w1) @@
      Hashtbl.fold (fun p w pws -> (p, w)::pws) t []

  let add ~db path =
    IO.update ~db @@ fun t ->
      let w  = try Hashtbl.find t path with Not_found -> 0. in
      let w' = sqrt (w ** 2. +. 100.) in
      Hashtbl.replace t path w'

  let search ~db pattern =
    let rex = Re_pcre.regexp ~flags:[`CASELESS] (pattern ^ "[^/]*$") in
    let rec aux = function
      | []    -> None
      | p::ps ->
          try (let _ = Re_pcre.exec ~rex p in Some p)
          with Not_found -> aux ps
    in
    aux @@ List.map fst @@ weighted ~db

end

let home =
  try Unix.getenv "HOME" with Not_found ->
    failwith "$HOME not set"

let canonicalize s =
  let n = String.length s in
  if n > 1 && s.[n - 1] = '/' then
    String.sub s 0 (n - 1)
  else s

let cmd_add ~db ~path =
  if path <> home then
    Store.add ~db (canonicalize path)

let cmd_search ~db pattern =
  match Store.search ~db pattern with
  | None   -> ()
  | Some x -> print_endline x

let cmd_stat ~db =
  let open Printf in
  printf "[%s]\n\n%!" db ;
  List.iter
    (fun (p, w) -> printf "%.02f :  %s\n%!" w p)
    (Store.weighted ~db)


open Cmdliner

let cmd_term =
  let db =
    Arg.(value @@ opt string (home ^ "/.teleport")
               @@ info ["db"] ~docv:"PATH"
                    ~doc:"Use the database in $(docv).")
  and vote =
    Arg.(value @@ opt (some dir) None
               @@ info ["u"; "upvote"] ~docv:"DIR"
                    ~doc:"Upvote the directory $(docv) and quit.")
  and vote_cwd =
    Arg.(value @@ flag
               @@ info ["a"; "auto-upvote"]
                    ~doc:"Upvote the current directory and quit.")
  and stat =
    Arg.(value @@ flag
               @@ info ["s"; "stats"] ~doc:"Dump stats and quit.")
  and search =
    Arg.(value @@ pos 0 (some string) None
               @@ info [] ~docv:"PATTERN"
                    ~doc:"Find most-voted directory matching $(docv).")

  and command db vote vote_cwd stat search =
    match (vote, vote_cwd, stat, search) with
    | Some path, _, _, _    -> cmd_add ~db ~path
    | _, true, _, _         -> cmd_add ~db ~path:(Sys.getcwd ())
    | _, _, true, _         -> cmd_stat ~db
    | _, _, _, Some pattern -> cmd_search ~db pattern
    | _                     -> cmd_stat ~db
  in
  Term.(pure command $ db $ vote $ vote_cwd $ stat $ search)

let info =
  Term.info "teleport" ~version
    ~doc:"upvote some directories, then search for them"

let () =
  match Term.eval (cmd_term, info) with
  | `Error _ -> exit 1
  | _        -> exit 0

