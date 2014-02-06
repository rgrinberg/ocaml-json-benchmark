open Core.Std
open Core_bench.Std

let random_events =
  1_000 |> List.init ~f:(fun _ -> Random_data.random_event ())

let () =
  Command.run @@
  Bench.make_command [
    Bench.Test.create ~name:"ezjsonm write to string" (fun () ->
      let json = `A (random_events
                     |> List.map ~f:Random_data.Ez.to_json) in
      json |> Ezjsonm.to_string |> ignore
    );
    Bench.Test.create ~name:"yojson write to string" (fun () ->
      let json = `List (random_events
                        |> List.map ~f:Random_data.Yo.to_json) in
      ignore @@ Yojson.Basic.to_string json
    );
  ]
