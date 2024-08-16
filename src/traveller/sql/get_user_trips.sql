select t.destination
from trips t
where t.tripid in (
  select ut.tripid
  from user_trips ut
  where ut.userid::varchar = $1
)
