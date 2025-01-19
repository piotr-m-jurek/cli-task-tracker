open Core

type t =
  | List
  | Add
  | Remove
  | Update

let to_string = function
  | List -> Printf.sprintf "list -> list all the tasks"
  | Add -> Printf.sprintf "add -> add task by providing description (add 'feed my cat')"
  | Remove -> Printf.sprintf "remove -> remove task by providing id (remove 4)"
  | Update ->
    Printf.sprintf
      "update -> update task by providing id and status (update 4 InProgress)"
;;

let of_string = function
  | "list" -> List
  | "add" -> Add
  | "remove" -> Remove
  | "update" -> Update
  | a -> failwith (Printf.sprintf "Buddy: Command '%s' not found" a)
;;

let print_instructions () =
  [ "\nWelcome to CLI Task Tracker!"
  ; "List of commands: "
  ; to_string List |> Util.pad_left 4
  ; to_string Add |> Util.pad_left 4
  ; to_string Remove |> Util.pad_left 4
  ; to_string Update |> Util.pad_left 4
  ]
  |> List.iter ~f:print_endline
;;
