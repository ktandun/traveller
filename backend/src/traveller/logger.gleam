import birl

pub fn prepend_timestamp(message: String) {
  birl.to_date_string(birl.utc_now()) <> " " <> message
}
