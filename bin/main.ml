open Core
open Cli_task_tracker
module TasksLoader = Domain.FileLoader (Domain.TasksStorage)

module Ops = struct
  (* *)
  let add_task task (t : TasksLoader.t) = { t with tasks = task :: t.tasks }

  (* *)
  let remove_task (id : string) (t : TasksLoader.t) =
    t.tasks |> List.filter ~f:(fun task -> not (String.equal id task.Task.id))
  ;;

  (* *)
  let update_task ~(id : string) ~(status : Task.status) (t : TasksLoader.t) =
    t.tasks
    |> List.map ~f:(fun task ->
      if String.equal task.Task.id id then Task.update_status ~status task else task)
  ;;
end

let print_tasks (tasks : Task.t list) : string =
  tasks
  |> List.sort ~compare:Task.compare
  |> List.fold ~init:[] ~f:(fun acc task ->
    let task = task |> Task.to_string |> Util.pad_left 4 in
    task :: acc)
  |> String.concat ~sep:"\n"
;;

let filter_print_tasks (tasks : Task.t list) (status : Task.status) : string =
  tasks
  |> List.filter ~f:(fun task -> not (Task.equal status task.Task.status))
  |> print_tasks
;;

let list_tasks ~status ~(file : TasksLoader.t) =
  let tasks =
    match Task.status_of_string status with
    | Ok status -> status |> filter_print_tasks file.tasks
    | Error other ->
      (match other with
       | "" -> print_tasks file.tasks
       | _ ->
         Printf.sprintf "filtering by other status not implemented: '%s'" other
         |> failwith)
  in
  Printf.printf "\n%s\n" tasks
;;

let add_task ~(file : TasksLoader.t) ~description ~filename =
  let file, id =
    let id = file.current_counter |> Int.to_string in
    { file with current_counter = file.current_counter + 1 }, id
  in
  let file = Ops.add_task (Task.make ~id ~description ()) file in
  TasksLoader.save ~filename file;
  Printf.printf "\n%s\n" (print_tasks file.tasks)
;;

let remove_task ~(file : TasksLoader.t) ~filename ~id =
  let file = { file with tasks = Ops.remove_task id file } in
  TasksLoader.save ~filename file;
  Printf.printf "\n%s\n" (print_tasks file.tasks)
;;

let update_task ~(file : TasksLoader.t) ~id ~filename ~status =
  match Task.status_of_string status with
  | Ok status ->
    let tasks = Ops.update_task ~id ~status file in
    let file = { file with tasks } in
    TasksLoader.save ~filename file;
    Printf.printf "\n%s\n" (print_tasks file.tasks)
  | Error e -> Printf.sprintf "Unrecognized status '%s'" e |> failwith
;;

let () =
  let args = Sys.get_argv () |> List.of_array in
  let filename = "storage.json" in
  let file =
    TasksLoader.load_with_default ~default:(Domain.TasksStorage.make ~tasks:[]) ~filename
  in
  let too_many_arguments opts =
    opts
    |> List.fold_right ~init:"" ~f:(fun acc opt -> opt ^ "; " ^ acc)
    |> Printf.sprintf "Too many arguments: %s"
    |> failwith
  in
  let match_commands (s : string) (opts : string list) =
    match Command.of_string s with
    | List ->
      (match opts with
       | [] -> Printf.printf "\n%s\n" (print_tasks file.tasks)
       | [ status ] -> list_tasks ~status ~file
       | opts -> too_many_arguments opts)
    | Add ->
      (match opts with
       | [] -> failwith "Adding task failed: You need to provide task description"
       | [ description ] -> add_task ~description ~file ~filename
       | opts -> too_many_arguments opts)
    | Remove ->
      (match opts with
       | [] -> failwith "Removing task failed: You need to provide task id"
       | [ id ] -> remove_task ~file ~id ~filename
       | opts -> too_many_arguments opts)
    | Update ->
      (match opts with
       | [] -> failwith "Updating task failed: You need to provide task status"
       | [ id; status ] -> update_task ~file ~filename ~id ~status
       | opts -> too_many_arguments opts)
  in
  match args with
  | _ :: s :: rest -> match_commands s rest
  | _ -> Command.print_instructions ()
;;
