let repeat_str i str =
  let rec inner sym i acc = if i = 0 then acc else inner sym (i - 1) acc ^ sym in
  inner str i ""
;;

let pad_left i str = repeat_str i " " ^ str
