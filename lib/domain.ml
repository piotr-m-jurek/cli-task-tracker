open Core

module TasksStorage = struct
  type t =
    { current_counter : int
    ; tasks : Task.t list
    }
  [@@deriving yojson { strict = true }]

  let of_yojson json = of_yojson json

  (* *)
  let to_yojson t = to_yojson t

  (* *)
  let empty = { current_counter = 0; tasks = [] }

  (* *)
  let make ~tasks = { empty with tasks }
end

module type FileContent = sig
  type t

  (* *)
  val of_yojson : Yojson.Safe.t -> (t, string) result

  (* *)
  val to_yojson : t -> Yojson.Safe.t
end

module FileLoader (Content : FileContent) = struct
  type t = Content.t

  let save ~filename (value : t) : unit =
    value |> Content.to_yojson |> Yojson.Safe.to_file filename
  ;;

  let load ~filename =
    let json = Yojson.Safe.from_file filename in
    match Content.of_yojson json with
    | Ok json -> json
    | Error msg -> failwith ("Error parsing file " ^ filename ^ " , with msg: " ^ msg)
  ;;

  let load_with_default ~filename ~default =
    try
      let loaded = load ~filename in
      loaded
    with
    | Sys_error _ | Yojson.Json_error _ ->
      let data = default |> Content.to_yojson |> Yojson.Safe.to_string in
      Out_channel.write_all filename ~data;
      default
  ;;

  let _validate (_value : t) : bool =
    (* Example validation logic; override this if needed *)
    true
  ;;
end
