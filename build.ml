open Printf
open Nethtml
module Path = Weberizer.Path


(* Settings common to all pages. *)
let tpl = OCAML.search_name OCAML.empty "Search"
let tpl = OCAML.shortcut_icon tpl
  "https://static.ocamlcore.org/official/images/favicon.ico"

let menu = Weberizer.body_of(Weberizer.read "menu.html")

let add_menu tpl p =
  if not(Path.in_base p && Path.filename p = "index.html") then
    let tpl = OCAML.main_width tpl "84%" in
    OCAML.menu tpl (Weberizer.relative_url_are_from_base p menu)
  else
    OCAML.main_width tpl "100%"


let () =
  let b = Weberizer.Binding.make() in

  let re_filter = Str.regexp "\\(menu\\|OCAML\\).*" in
  let filter p = not(Str.string_match re_filter (Path.filename p) 0) in

  let langs = ["en"] in
  Weberizer.iter_html ~filter ~langs "." begin fun lang p ->
    printf "Processing %s\n" (Path.full p);
    let tpl = OCAML.url_base tpl (Weberizer.Path.to_base p) in
    let page = Weberizer.read (Path.full p) ~bindings:b in
    let tpl = OCAML.title tpl (Weberizer.title_of page) in
    let body = Weberizer.body_of page in
    let body = Weberizer.protect_emails body in
    let tpl = OCAML.main tpl body in

    let tpl = add_menu tpl p in

    let tpl = OCAML.navigation_of_path tpl p in

    OCAML.render tpl
  end
