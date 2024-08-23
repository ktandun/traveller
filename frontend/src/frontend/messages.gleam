import frontend/routes.{type Route}

pub type Msg {
  UserSubmitsLogin
  OnRouteChange(Route)
}

pub type AppMsgModel {
  LoginRequestModel(email: String, password: String)
}
