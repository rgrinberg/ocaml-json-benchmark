open Core

module Event_type = struct
  type t = Login | Purchase | Logout | Cancel

  let to_string = function
    | Login -> "login"
    | Purchase -> "purchase"
    | Logout -> "logout"
    | Cancel -> "cancel"

  let of_string = function
    | "login" -> Login
    | "purchase" -> Purchase
    | "logout" -> Logout
    | "cancel" -> Cancel
    | _ -> assert false

  (* in this happy world *)
  let of_int = function
    | 0 -> Login
    | 1 -> Purchase
    | 2 -> Logout
    | 3 -> Cancel
    | _ -> assert false
end

(* this is the simple record we will be using to benchmark the json libs *)

type event =
  {username: string; date: int; event_type: Event_type.t; payload: string}

let random_string length =
  String.init length ~f:(fun _ ->
      let rnd = Random.int 34 in
      Char.of_int_exn (rnd + 65) )

module type Json_intf = sig
  type json

  val to_json : event -> json

  val of_json : json -> event
end

module Ez : sig
  include Json_intf with type json := Ezjsonm.value
end = struct
  open Ezjsonm

  let to_json {username; date; event_type; payload} =
    dict
      [ ("username", string username)
      ; ("date", int date)
      ; ("event_type", string @@ Event_type.to_string event_type)
      ; ("payload", string payload) ]

  let of_json = function
    | `O obj ->
        { username=
            get_string
            @@ List.Assoc.find_exn obj ~equal:String.equal "username"
        ; date= get_int @@ List.Assoc.find_exn obj ~equal:String.equal "date"
        ; event_type=
            Event_type.of_string @@ get_string
            @@ List.Assoc.find_exn obj ~equal:String.equal "event_type"
        ; payload=
            get_string @@ List.Assoc.find_exn obj ~equal:String.equal "payload"
        }
    | _ -> assert false
end

module Yo : sig
  include Json_intf with type json := Yojson.Basic.t
end = struct
  open Yojson.Basic

  let to_json {username; date; event_type; payload} =
    `Assoc
      [ ("username", `String username)
      ; ("date", `Int date)
      ; ("event_type", `String (Event_type.to_string event_type))
      ; ("payload", `String payload) ]

  let of_json : Yojson.Basic.t -> event = function
    | `Assoc obj ->
        { username=
            Util.to_string
            @@ List.Assoc.find_exn obj ~equal:String.equal "username"
        ; date=
            Util.to_int @@ List.Assoc.find_exn obj ~equal:String.equal "date"
        ; event_type=
            Event_type.of_string @@ Util.to_string
            @@ List.Assoc.find_exn obj ~equal:String.equal "event_type"
        ; payload=
            Util.to_string
            @@ List.Assoc.find_exn obj ~equal:String.equal "payload" }
    | _ -> assert false
end

module Jaf : sig
  include Json_intf with type json := Jsonaf.t
end = struct

  let extract_string = function
    | `String s -> s
    | `Number n -> n
    | _ -> assert false

  let to_json {username; date; event_type; payload} =
    `Object
      [ ("username", `String username)
      ; ("date", `Number (Int.to_string date))
      ; ("event_type", `String (Event_type.to_string event_type))
      ; ("payload", `String payload) ]

  let of_json : Jsonaf.t -> event = function
    | `Object obj ->
        { username=
            extract_string
            @@ List.Assoc.find_exn obj ~equal:String.equal "username"
        ; date=
            Int.of_string
              ( extract_string
              @@ List.Assoc.find_exn obj ~equal:String.equal "date" )
        ; event_type=
            Event_type.of_string @@ extract_string
            @@ List.Assoc.find_exn obj ~equal:String.equal "event_type"
        ; payload=
            extract_string
            @@ List.Assoc.find_exn obj ~equal:String.equal "payload" }
    | _ -> assert false
end

let random_event () =
  { username= random_string 10
  ; date= Random.int 100000
  ; event_type= 4 |> Random.int |> Event_type.of_int
  ; payload= random_string 60 }

let random_event_json () =
  let event = random_event () in
  event |> Ez.to_json |> Ezjsonm.wrap |> Ezjsonm.to_string
