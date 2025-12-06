///|
using @react {component, init_react_api}

///|
using @testing_library_react {render, fireEvent, screen}

///|
using @global_jsdom {register}

///|
test "increment by click" {
  register()
  init_react_api(@node.require("react"))
  render(component(counter, ())) |> ignore
  let scr = screen()
  let fire = fireEvent()
  fire.click(scr.getByText("Count: 0")) |> ignore
  scr.getByText("Count: 1") |> ignore
}
