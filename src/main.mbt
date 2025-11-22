///|
using @react {
  type Context,
  type EmptyProps,
  h,
  c,
  fragment,
  provider,
  use_effect,
  use_state,
  use_callback,
  use_context,
  use_reducer,
  create_context,
}

///|
using @react_dom_client {import_react_dom_client}

///|
using @react_router {init_react_router_async, router_provider}

///|
using @js {log, sleep, run_async}

///|
using @react_element {
  h1,
  h2,
  hr,
  ul,
  form,
  input,
  div,
  textarea,
  svg,
  circle,
  rect,
  line,
  text,
}

///|
struct MyContextProps {
  v : String
}

///|
struct ItemViewProps {
  name : String
}

///|
fn item_view(props : ItemViewProps) -> @react.Element {
  h("div", style={ "padding": "5px", "borderBottom": "1px solid #ccc" }, [
    props.name,
  ])
}

///|
let myctx : Ref[Context[MyContextProps]?] = { val: None }

///|
fn init_myctx() -> Unit {
  myctx.val = Some(create_context(None))
}

///|
fn use_myctx() -> MyContextProps {
  guard myctx.val is Some(ctx)
  use_context(ctx)
}

///|
fn ctx_consumer(_ : EmptyProps) -> @react.Element {
  let ctx_value = use_myctx()
  div(["Context value: \{ctx_value.v}"], class="context-value")
}

///|
fn async_counter(_ : EmptyProps) -> @react.Element {
  let (count, dispatch, is_pending) = @react.use_action_state(
    async fn(state : Int, action : CounterAction) -> Int noraise {
      match action {
        CounterAction::Increment => state + 1
      }
    },
    0,
  )
  let on_click = use_callback(
    _ => run_async(async fn() noraise {
      sleep(500)
      @react.start_transition(() => dispatch(CounterAction::Increment))
    }),
    [count],
  )
  @react_element.button(
    ["Async Count: \{count}", if is_pending { " (Updating...)" } else { "" }],
    on_click~,
  )
}

///|
priv struct AppProps {
  x : Int
  items : Array[String]
}

///|
fn app(props : AppProps) -> @react.Element {
  let (cnt, set_cnt) = use_state(props.x)
  let textarea_ref : @react.ReactRef[@dom.HTMLTextAreaElement] = @react.use_ref(
    None,
  )
  let handler = use_callback(_ => set_cnt(cnt + 1), [cnt])
  use_effect(
    () => {
      log("mounted with x = \{props.x}")
      () => log("unmounted")
    },
    [cnt, textarea_ref],
  )
  use_effect(
    () => {
      run_async(async fn() noraise {
        sleep(300)
        if textarea_ref.get_current() is Some(textarea) {
          textarea.to_js().call("focus", []) |> ignore
        }
        log("Starting async operation...")
      })
      () => log("Component unmounted")
    },
    [],
  )
  let (input_text, set_text) = use_state("")
  let on_change = use_callback(
    (e : @dom.ChangeEvent) => {
      let target = e.target().to_js()
      let value : String = target.get("value") |> @js.unsafe_cast
      set_text(value)
      log("Textarea changed: \{value}")
    },
    [input_text],
  )
  guard myctx.val is Some(myctx)
  provider(myctx, value={ v: "xxx" }, [
    h1(class="text-3xl font-bold underline", ["Hello, Moonbit React!"]),
    div(
      id="foo",
      style={ "border": "1px solid black", "padding": "10px" },
      on_click=handler,
      [
        h2(["Counter: \{cnt}"]),
        "x = \{cnt}",
        fragment([h("h1", ["xxx"])]),
        div(id="textarea-container", [
          textarea(
            [],
            id="my-textarea",
            on_change~,
            rows=4,
            columns=40,
            ref_=textarea_ref,
            value=input_text,
          ),
          div(class="textarea-value", ["Textarea value: \{input_text}"]),
        ]),
        ul(
          props.items.mapi((idx, item) => h("li", key=idx.to_string(), [
            c(item_view, { name: item }, key=idx.to_string()),
          ])),
        ),
        c(ctx_consumer, EmptyProps::default()),
        c(counter, EmptyProps::default()),
        c(async_counter, EmptyProps::default()),
        hr(),
        form(
          [
            input(type_="text", name="username"),
            input(type_="submit", value="Submit"),
          ],
          method_="post",
          style={ "marginTop": "10px" },
          enc_type="application/x-www-form-urlencoded",
          action=form => {
            log(form.to_js())
            let v : String = form.to_js().call("get", ["username"])
              |> @js.unsafe_cast
            log("Username: \{v}")
          },
        ),
        svg(width=500, height=100, [
          circle(cx=50, cy=50, r=40, stroke="black", stroke_width=3, fill="red"),
          rect(
            x=120,
            y=10,
            width=80,
            height=80,
            stroke="blue",
            stroke_width=3,
            fill="green",
          ),
          text(x=100, y=30, dx="50%", dy="50%", ["Hello, SVG Text!"]),
          line(x1=220, y1=10, x2=300, y2=90, stroke="black", stroke_width=2),
        ]),
      ],
    ),
  ])
}

///|
fn main {
  guard @dom.document().getElementById("app") is Some(app_root)
  run_async(async fn() noraise {
    try {
      @react.init_react_async()
      let client = import_react_dom_client().wait()
      init_react_router_async()
      // TODO: use async init later
      init_myctx()

      // Entrypoint
      let home : (@react_router.RouteProps) -> @react.Element = _props => c(
        app,
        { x: 42, items: ["Item 1", "Item 2", "Item 3"] },
      )
      let routes = @react_router.create_browser_router([
        Component(path="/", component=home),
        Element(
          path="/about",
          element=h("div", [
            "About page",
            @react_router.link(to="/", ["Go to Top"]),
          ]),
        ),
      ])
      client.create_root(app_root).render(router_provider(routes))
    } catch {
      e => log(e)
    }
  })
}
