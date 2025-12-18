///|
using @react {component}

///|
using @testing_library_react {render, fireEvent, screen, expect, setup_matchers}

///|
using @global_jsdom {register}

///|
test "increment by click" {
  register()
  setup_matchers()
  render(component(counter, ())) |> ignore
  let scr = screen()
  let fire = fireEvent()
  let button = scr.getByText("Count: 0")
  expect(button)
  ..toBeInTheDocument()
  ..toHaveTextContent("Count: 0")
  fire.click(button) |> ignore
  let incremented = scr.getByText("Count: 1")
  expect(incremented)
  ..toBeInTheDocument()
  ..toHaveTextContent("Count: 1")
}
