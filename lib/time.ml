open Core

let get_current_time () = Time_float.now () |> Time_float.to_string_utc
