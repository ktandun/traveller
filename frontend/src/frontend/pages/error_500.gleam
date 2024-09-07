import lustre/element
import lustre/element/html

pub fn error_five_hundred() {
  html.div([], [
    html.h1([], [
    element.text("Error from our side")
  ]),
    html.pre([], [
      element.text("
        /\\_____/\\    How did you get here meow?
       /  o   o  \\
      ( ==  ^  == )
       )         (
      (           )
     ( (  )   (  ) )
    (__(__)___(__)__)
      ")
    ])
  ])
}
