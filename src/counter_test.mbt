///|
using @react {component, init_react_api}

///|
using @react_testing_library {render, fireEvent, screen}

///|
using @global_jsdom {register}

///|
test "increment by click" {
  register()
  init_react_api(@node.require("react"))
  render(component(counter, ())) |> ignore
  let scr = screen()
  let fire = fireEvent()
  fire.click(scr.getByText("Count: 0"))
  let target = scr.getByText("Count: 1")
  assert_eq(target.textContent(), "Count: 1")
}
