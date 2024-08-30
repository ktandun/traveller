import radiate
import wisp

fn print_radiate_update(_state: state, path: String) {
  wisp.log_info("Change in " <> path <> ", reloading")
}

pub fn radiate() {
  let assert Ok(_) =
    radiate.new()
    |> radiate.add_dir(".")
    |> radiate.on_reload(print_radiate_update)
    |> radiate.start()

  wisp.log_debug("Watching src to change.")
}
