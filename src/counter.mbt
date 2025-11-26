///|
enum CounterAction {
  Increment
}

///|
pub fn counter(_ : Unit) -> @react.Element {
  let (count, dispatch) = useReducer(
    (state : Int, action : CounterAction) => match action {
      CounterAction::Increment => state + 1
    },
    0,
  )
  let on_click = useCallback(
    _ => {
      dispatch(CounterAction::Increment)
      log("Counter clicked: \{count + 1}")
    },
    [count],
  )
  @react_element.button(on_click~, ["Count: \{count}"])
}
