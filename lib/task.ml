type status =
  | Todo
  | InProgress
  | Done
[@@deriving yojson]

let status_to_string status =
  match status with
  | Todo -> "Todo"
  | InProgress -> "In Progress"
  | Done -> "Done"
;;

let status_of_string = function
  | "Todo" -> Ok Todo
  | "InProgress" -> Ok InProgress
  | "Done" -> Ok Done
  | s -> Error s
;;

type t =
  { id : string
  ; description : string
  ; status : status
  ; created_at : string
  ; updated_at : string option
  }
[@@deriving yojson { strict = true }]

let update_updated_at payload t = { t with updated_at = Some payload }

(* *)
let update_created_at t = { t with created_at = Time.get_current_time () }

let update_description payload t =
  { t with description = payload; updated_at = Some (Time.get_current_time ()) }
;;

(* let update_description payload t =
  { t with description = payload } |> update_updated_at (Time.get_current_time ())
;; *)

let update_status ~status t =
  { t with status; updated_at = Some (Time.get_current_time ()) }
;;

let make ~id ?(status = Todo) ~description () =
  { id; description; status; updated_at = None; created_at = "" } |> update_created_at
;;

let to_string (task : t) =
  Printf.sprintf "#%s (%s) -> %s" task.id (status_to_string task.status) task.description
;;

let rank = function
  | Done -> 1
  | InProgress -> 2
  | Todo -> 3
;;

let equal s1 s2 = Int.equal (rank s1) (rank s2)
let compare t1 t2 = compare (rank t1.status) (rank t2.status)

(* *)
let is_done (task : t) = task.status = Done
