open Core.Std


let handle_command output_src filenames () =
    let texts = Array.map
        (Array.of_list filenames)
        ~f:(fun filename ->
            Str.global_replace
                (Str.regexp "\n\n+")
                "\n"
                (String.strip (In_channel.read_all filename))
    ) in
    let normalized = Array.map texts ~f:(fun text ->
        Array.of_list (String.split text '\n')
    ) in
    (* consistency check *)
    let total_paragraphs = try 
        Array.fold normalized
            ~init: (-1)
            ~f: (fun prev text_by_paragraph -> 
                let prev_paragraphs_len = match prev with
                    (* initial value of -1 means that we analyze the first text *)
                    | -1 -> Array.length text_by_paragraph
                    | _ -> prev
                in
                let curr_text_paragraphs_len = Array.length text_by_paragraph in
                if prev_paragraphs_len = curr_text_paragraphs_len then
                    curr_text_paragraphs_len
                else
                    invalid_arg "Texts have different number of paragraphs."
            )
        with invalid_arg -> eprintf "Texts have different number of paragraphs.\n%!";
                            exit 1
    in
    let out = match output_src with
                  | None -> stdout
                  | Some filename -> Out_channel.create filename
    in 
    fprintf out "<html><body><table>";
    for paragraph = 0 to (total_paragraphs - 1) do
        fprintf out "<tr>";
        for text = 0 to ((Array.length texts) - 1) do
            fprintf out "<td>%s</td>" normalized.(text).(paragraph)
        done;
        fprintf out "</tr>";
    done;
    fprintf out "</table></body></html>";
    Out_channel.close out


(* define a custom input argument type *)
let text_file_t = 
    Command.Spec.Arg_type.create
        (fun filename -> match Sys.is_file filename with
                        | `Yes -> filename
                        | `No | `Unknown ->
                            eprintf "'%s' is not a regular file.\n%!" filename;
                            exit 1
        )


let cmd_spec = 
    let open Command.Spec in
        (* verify input parameters *)
        step
            (fun m output_src filenames ->
                 (* The first m argument to the step callback is the next callback function in the chain. *)
                 match filenames with
                 | [] | _ :: [] -> eprintf "You must specify at least two files.\n%!";
                                   exit 1
                 | _ -> m output_src filenames
            )

        +> flag "-o" (optional string) ~doc: "string Output to file rather than stdout"
        +> anon (sequence ("filename" %: text_file_t))

let cmd =
    Command.basic
        ~summary: "Merge chapters in different languages into one html table"
        ~readme: (fun () -> "Merge chapters in different languages into one html table")
        cmd_spec
        handle_command

let () =
    Command.run
        ~version: "1.0"
        ~build_info: "by Maxim Avanov"
        cmd
