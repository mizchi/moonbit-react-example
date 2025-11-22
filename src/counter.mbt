///|
enum CounterAction {
  Increment
}

///|
pub fn counter(_ : EmptyProps) -> @react.Element {
  let (count, dispatch) = use_reducer(
    (state : Int, action : CounterAction) => match action {
      CounterAction::Increment => state + 1
    },
    0,
  )
  let on_click = use_callback(
    _ => {
      dispatch(CounterAction::Increment)
      log("Counter clicked: \{count + 1}")
    },
    [count],
  )
  @react_element.button(["Count: \{count}"], on_click=on_click)
}
