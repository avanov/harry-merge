open Core.Std



let handle_command output_src filenames () =
    ()

(* define a custom input argument type *)
let text_file_t = 
    Command.Spec.Arg_type.create(
        fun filename -> match Sys.is_file filename with
        | `Yes -> filename
        | `No | `Unknown ->
            eprintf "'%s' is not a regular file.\n%!" filename;
            exit 1
    )


let cmd_spec = 
    let open Command.Spec in
        (* verify input parameters *)
        step (fun m output_src filenames ->
              match filenames with
              | [] | _ :: [] -> eprintf "You must specify at least two files.\n%!";
                                exit 1
              | _ -> m output_src filenames
        )
        +> flag "-o" (optional string) ~doc: "string Output to file rather than stdout"
        +> anon (sequence ("filename" %: text_file_t))

let cmd =
    Command.basic
        ~summary: "Merge chapters in different into one html table"
        ~readme: (fun () -> "More detailed information")
        cmd_spec
        handle_command

let () =
    Command.run
        ~version: "1.0"
        ~build_info: "by Maxim Avanov"
        cmd