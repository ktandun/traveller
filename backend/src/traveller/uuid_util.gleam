import youid/uuid

/// Ensure validation has been called first before using this util
pub fn from_string(s: String) {
  let assert Ok(uuid) = uuid.from_string(s)

  uuid
}
