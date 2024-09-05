pub type Route {
  Login
  Signup
  TripsDashboard
  TripDetails(trip_id: String)
  TripPlaceCreate(trip_id: String)
  TripPlaceActivities(trip_id: String, trip_place_id: String)
  TripUpdate(trip_id: String)
  TripCompanions(trip_id: String)
  TripCreate
  FourOFour
}
