open Core
open Core_bench.Std

let random_json =
  let random_events =
    1_000
    |> List.init ~f:(fun _ -> Random_data.random_event ())
    |> List.map ~f:Random_data.Ez.to_json
  in
  `A random_events |> Ezjsonm.to_string

let () =
  Command.run
  @@ Bench.make_command
       [ (* Bench.Test.create ~name:"ezjsonm read raw" (fun () -> *)
         (*   random_json |> Ezjsonm.from_string |> ignore *)
         (* ); *)
         (* Bench.Test.create ~name:"yojson read raw basic" (fun () -> *)
         (*   random_json |> Yojson.Basic.from_string |> ignore *)
         (* ); *)
         (* Bench.Test.create ~name:"yojson read raw safe" (fun () -> *)
         (*   random_json |> Yojson.Safe.from_string |> ignore *)
         (* ); *)
         Bench.Test.create ~name:"ezjsonm read" (fun () ->
             let event_list : Random_data.event list =
               random_json |> Ezjsonm.from_string
               |> Ezjsonm.get_list Random_data.Ez.of_json
             in
             ignore event_list )
       ; Bench.Test.create ~name:"yojson read" (fun () ->
             let event_list : Random_data.event list =
               random_json |> Yojson.Basic.from_string
               |> Yojson.Basic.Util.to_list
               |> List.map ~f:Random_data.Yo.of_json
             in
             ignore event_list ) ]
