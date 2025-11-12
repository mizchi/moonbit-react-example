///|
using @js {type Val}

///|
using @test {it, before_each}

///|
using @react {h, c, type EmptyProps}

///|
using @react_testing_library {type ReactTestingLibrary}

///|
test "increment by click" {
  let { render, fire_event, screen, .. } = ReactTestingLibrary::init()
  @react.init_react()
  render(c(counter, EmptyProps::default()))
  fire_event.click(screen.get_by_text("Count: 0"))
  let target = screen.get_by_text("Count: 1")
  assert_eq(target.textContent(), "Count: 1")
}
