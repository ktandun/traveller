select t.destination
from trips t
where t.trip_id in (
  select ut.trip_id
  from user_trips ut
  where ut.user_id::varchar = $1
)
