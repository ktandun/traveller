pub type Route {
  Login
  Signup
  TripsDashboard
  TripDetails(trip_id: String)
  TripPlaceCreate(trip_id: String)
  TripCompanions(trip_id: String)
  TripCreate
  FourOFour
}
