import frontend/events.{type AppEvent}
import gleam/list
import gleam/option.{type Option}
import lustre/attribute.{type Attribute}
import lustre/element
import lustre/element/html
import lustre/event

pub type FormType {
  TextInput
  DateInput
  UrlInput
  TimeInput
  MoneyInput
  SingleSelect
  Checkbox
}

pub type SelectOption {
  SelectOption(value: String, label: String, selected: Bool)
}

pub opaque type HtmlForm {
  HtmlForm(
    form_type: FormType,
    select_options: List(SelectOption),
    label: Option(String),
    name: Option(String),
    hint: Option(String),
    required: Bool,
    on_input: fn(String) -> events.AppEvent,
    on_check: fn(Bool) -> events.AppEvent,
    value: String,
    checked: Bool,
    min: Option(String),
    max: Option(String),
    placeholder: Option(String),
    attributes: List(Attribute(AppEvent)),
  )
}

pub fn new() {
  HtmlForm(
    form_type: TextInput,
    select_options: [],
    label: option.None,
    name: option.None,
    hint: option.None,
    required: False,
    on_input: fn(_) { events.NoEvent },
    on_check: fn(_) { events.NoEvent },
    value: "",
    checked: False,
    min: option.None,
    max: option.None,
    placeholder: option.None,
    attributes: [],
  )
}

pub fn with_form_type(form, form_type) {
  HtmlForm(..form, form_type:)
}

pub fn with_select_options(form, select_options) {
  HtmlForm(..form, select_options:)
}

pub fn with_label(form, label) {
  HtmlForm(..form, label: option.Some(label))
}

pub fn with_name(form, name) {
  HtmlForm(..form, name: option.Some(name))
}

pub fn with_hint(form, hint) {
  HtmlForm(..form, hint: option.Some(hint))
}

pub fn with_required(form) {
  HtmlForm(..form, required: True)
}

pub fn with_on_input(form, on_input) {
  HtmlForm(..form, on_input:)
}

pub fn with_on_check(form, on_check) {
  HtmlForm(..form, on_check:)
}

pub fn with_value(form, value) {
  HtmlForm(..form, value:)
}

pub fn with_checked(form, checked) {
  HtmlForm(..form, checked:)
}

pub fn with_placeholder(form, placeholder) {
  HtmlForm(..form, placeholder: option.Some(placeholder))
}

pub fn with_min(form, min) {
  HtmlForm(..form, min: option.Some(min))
}

pub fn with_max(form, max) {
  HtmlForm(..form, min: option.Some(max))
}

pub fn with_attributes(form, attributes) {
  HtmlForm(..form, attributes:)
}

pub fn build(form: HtmlForm) {
  let input_attributes = [
    case form.name {
      option.Some(name) -> attribute.name(name)
      _ -> attribute.none()
    },
    case form.placeholder {
      option.Some(placeholder) -> attribute.placeholder(placeholder)
      _ -> attribute.none()
    },
    attribute.value(form.value),
    attribute.checked(form.checked),
    event.on_input(form.on_input),
    event.on_check(form.on_check),
    attribute.required(form.required),
    ..form.attributes
  ]

  html.div([attribute.class("form-input")], [
    html.label([], case form.label {
      option.Some(label) -> [element.text(label)]
      _ -> []
    }),
    case form.form_type {
      TextInput -> html.input([attribute.type_("text"), ..input_attributes])
      Checkbox -> html.input([attribute.type_("checkbox"), ..input_attributes])
      DateInput -> html.input([attribute.type_("date"), ..input_attributes])
      UrlInput -> html.input([attribute.type_("url"), ..input_attributes])
      TimeInput -> html.input([attribute.type_("time"), ..input_attributes])
      MoneyInput ->
        html.input([
          attribute.type_("text"),
          attribute.step("0.01"),
          attribute.pattern("^\\d*(\\.\\d{0,2})?$"),
          attribute.type_("text"),
          ..input_attributes
        ])
      SingleSelect ->
        html.select(
          input_attributes,
          list.map(form.select_options, fn(option) {
            let SelectOption(value, label, selected) = option

            html.option(
              [attribute.value(value), attribute.selected(selected)],
              label,
            )
          }),
        )
    },
    html.span([attribute.class("validity")], []),
    html.small(
      [
        case form.hint {
          option.Some(_) -> attribute.class("hint")
          _ -> attribute.none()
        },
      ],
      case form.hint {
        option.Some(hint) -> [element.text(hint)]
        _ -> []
      },
    ),
  ])
}

pub fn with_countries_options(form, selected: String) {
  let countries = [
    SelectOption(value: "Afghanistan", label: "Afghanistan", selected: False),
    SelectOption(
      value: "Åland Islands",
      label: "Åland Islands",
      selected: False,
    ),
    SelectOption(value: "Albania", label: "Albania", selected: False),
    SelectOption(value: "Algeria", label: "Algeria", selected: False),
    SelectOption(
      value: "American Samoa",
      label: "American Samoa",
      selected: False,
    ),
    SelectOption(value: "Andorra", label: "Andorra", selected: False),
    SelectOption(value: "Angola", label: "Angola", selected: False),
    SelectOption(value: "Anguilla", label: "Anguilla", selected: False),
    SelectOption(value: "Antarctica", label: "Antarctica", selected: False),
    SelectOption(
      value: "Antigua and Barbuda",
      label: "Antigua and Barbuda",
      selected: False,
    ),
    SelectOption(value: "Argentina", label: "Argentina", selected: False),
    SelectOption(value: "Armenia", label: "Armenia", selected: False),
    SelectOption(value: "Aruba", label: "Aruba", selected: False),
    SelectOption(value: "Australia", label: "Australia", selected: False),
    SelectOption(value: "Austria", label: "Austria", selected: False),
    SelectOption(value: "Azerbaijan", label: "Azerbaijan", selected: False),
    SelectOption(value: "Bahamas", label: "Bahamas", selected: False),
    SelectOption(value: "Bahrain", label: "Bahrain", selected: False),
    SelectOption(value: "Bangladesh", label: "Bangladesh", selected: False),
    SelectOption(value: "Barbados", label: "Barbados", selected: False),
    SelectOption(value: "Belarus", label: "Belarus", selected: False),
    SelectOption(value: "Belgium", label: "Belgium", selected: False),
    SelectOption(value: "Belize", label: "Belize", selected: False),
    SelectOption(value: "Benin", label: "Benin", selected: False),
    SelectOption(value: "Bermuda", label: "Bermuda", selected: False),
    SelectOption(value: "Bhutan", label: "Bhutan", selected: False),
    SelectOption(value: "Bolivia", label: "Bolivia", selected: False),
    SelectOption(
      value: "Bosnia and Herzegovina",
      label: "Bosnia and Herzegovina",
      selected: False,
    ),
    SelectOption(value: "Botswana", label: "Botswana", selected: False),
    SelectOption(
      value: "Bouvet Island",
      label: "Bouvet Island",
      selected: False,
    ),
    SelectOption(value: "Brazil", label: "Brazil", selected: False),
    SelectOption(
      value: "British Indian Ocean Territory",
      label: "British Indian Ocean Territory",
      selected: False,
    ),
    SelectOption(
      value: "British Virgin Islands",
      label: "British Virgin Islands",
      selected: False,
    ),
    SelectOption(value: "Brunei", label: "Brunei", selected: False),
    SelectOption(value: "Bulgaria", label: "Bulgaria", selected: False),
    SelectOption(value: "Burkina Faso", label: "Burkina Faso", selected: False),
    SelectOption(value: "Burundi", label: "Burundi", selected: False),
    SelectOption(value: "Cambodia", label: "Cambodia", selected: False),
    SelectOption(value: "Cameroon", label: "Cameroon", selected: False),
    SelectOption(value: "Canada", label: "Canada", selected: False),
    SelectOption(value: "Cape Verde", label: "Cape Verde", selected: False),
    SelectOption(
      value: "Caribbean Netherlands",
      label: "Caribbean Netherlands",
      selected: False,
    ),
    SelectOption(
      value: "Cayman Islands",
      label: "Cayman Islands",
      selected: False,
    ),
    SelectOption(
      value: "Central African Republic",
      label: "Central African Republic",
      selected: False,
    ),
    SelectOption(value: "Chad", label: "Chad", selected: False),
    SelectOption(value: "Chile", label: "Chile", selected: False),
    SelectOption(value: "China", label: "China", selected: False),
    SelectOption(
      value: "Christmas Island",
      label: "Christmas Island",
      selected: False,
    ),
    SelectOption(
      value: "Cocos (Keeling) Islands",
      label: "Cocos (Keeling) Islands",
      selected: False,
    ),
    SelectOption(value: "Colombia", label: "Colombia", selected: False),
    SelectOption(value: "Comoros", label: "Comoros", selected: False),
    SelectOption(value: "Cook Islands", label: "Cook Islands", selected: False),
    SelectOption(value: "Costa Rica", label: "Costa Rica", selected: False),
    SelectOption(value: "Croatia", label: "Croatia", selected: False),
    SelectOption(value: "Cuba", label: "Cuba", selected: False),
    SelectOption(value: "Curaçao", label: "Curaçao", selected: False),
    SelectOption(value: "Cyprus", label: "Cyprus", selected: False),
    SelectOption(value: "Czechia", label: "Czechia", selected: False),
    SelectOption(value: "DR Congo", label: "DR Congo", selected: False),
    SelectOption(value: "Denmark", label: "Denmark", selected: False),
    SelectOption(value: "Djibouti", label: "Djibouti", selected: False),
    SelectOption(value: "Dominica", label: "Dominica", selected: False),
    SelectOption(
      value: "Dominican Republic",
      label: "Dominican Republic",
      selected: False,
    ),
    SelectOption(value: "Ecuador", label: "Ecuador", selected: False),
    SelectOption(value: "Egypt", label: "Egypt", selected: False),
    SelectOption(value: "El Salvador", label: "El Salvador", selected: False),
    SelectOption(
      value: "Equatorial Guinea",
      label: "Equatorial Guinea",
      selected: False,
    ),
    SelectOption(value: "Eritrea", label: "Eritrea", selected: False),
    SelectOption(value: "Estonia", label: "Estonia", selected: False),
    SelectOption(value: "Eswatini", label: "Eswatini", selected: False),
    SelectOption(value: "Ethiopia", label: "Ethiopia", selected: False),
    SelectOption(
      value: "Falkland Islands",
      label: "Falkland Islands",
      selected: False,
    ),
    SelectOption(
      value: "Faroe Islands",
      label: "Faroe Islands",
      selected: False,
    ),
    SelectOption(value: "Fiji", label: "Fiji", selected: False),
    SelectOption(value: "Finland", label: "Finland", selected: False),
    SelectOption(value: "France", label: "France", selected: False),
    SelectOption(
      value: "French Guiana",
      label: "French Guiana",
      selected: False,
    ),
    SelectOption(
      value: "French Polynesia",
      label: "French Polynesia",
      selected: False,
    ),
    SelectOption(
      value: "French Southern and Antarctic Lands",
      label: "French Southern and Antarctic Lands",
      selected: False,
    ),
    SelectOption(value: "Gabon", label: "Gabon", selected: False),
    SelectOption(value: "Gambia", label: "Gambia", selected: False),
    SelectOption(value: "Georgia", label: "Georgia", selected: False),
    SelectOption(value: "Germany", label: "Germany", selected: False),
    SelectOption(value: "Ghana", label: "Ghana", selected: False),
    SelectOption(value: "Gibraltar", label: "Gibraltar", selected: False),
    SelectOption(value: "Greece", label: "Greece", selected: False),
    SelectOption(value: "Greenland", label: "Greenland", selected: False),
    SelectOption(value: "Grenada", label: "Grenada", selected: False),
    SelectOption(value: "Guadeloupe", label: "Guadeloupe", selected: False),
    SelectOption(value: "Guam", label: "Guam", selected: False),
    SelectOption(value: "Guatemala", label: "Guatemala", selected: False),
    SelectOption(value: "Guernsey", label: "Guernsey", selected: False),
    SelectOption(value: "Guinea", label: "Guinea", selected: False),
    SelectOption(
      value: "Guinea-Bissau",
      label: "Guinea-Bissau",
      selected: False,
    ),
    SelectOption(value: "Guyana", label: "Guyana", selected: False),
    SelectOption(value: "Haiti", label: "Haiti", selected: False),
    SelectOption(
      value: "Heard Island and McDonald Islands",
      label: "Heard Island and McDonald Islands",
      selected: False,
    ),
    SelectOption(value: "Honduras", label: "Honduras", selected: False),
    SelectOption(value: "Hong Kong", label: "Hong Kong", selected: False),
    SelectOption(value: "Hungary", label: "Hungary", selected: False),
    SelectOption(value: "Iceland", label: "Iceland", selected: False),
    SelectOption(value: "India", label: "India", selected: False),
    SelectOption(value: "Indonesia", label: "Indonesia", selected: False),
    SelectOption(value: "Iran", label: "Iran", selected: False),
    SelectOption(value: "Iraq", label: "Iraq", selected: False),
    SelectOption(value: "Ireland", label: "Ireland", selected: False),
    SelectOption(value: "Isle of Man", label: "Isle of Man", selected: False),
    SelectOption(value: "Israel", label: "Israel", selected: False),
    SelectOption(value: "Italy", label: "Italy", selected: False),
    SelectOption(value: "Ivory Coast", label: "Ivory Coast", selected: False),
    SelectOption(value: "Jamaica", label: "Jamaica", selected: False),
    SelectOption(value: "Japan", label: "Japan", selected: False),
    SelectOption(value: "Jersey", label: "Jersey", selected: False),
    SelectOption(value: "Jordan", label: "Jordan", selected: False),
    SelectOption(value: "Kazakhstan", label: "Kazakhstan", selected: False),
    SelectOption(value: "Kenya", label: "Kenya", selected: False),
    SelectOption(value: "Kiribati", label: "Kiribati", selected: False),
    SelectOption(value: "Kosovo", label: "Kosovo", selected: False),
    SelectOption(value: "Kuwait", label: "Kuwait", selected: False),
    SelectOption(value: "Kyrgyzstan", label: "Kyrgyzstan", selected: False),
    SelectOption(value: "Laos", label: "Laos", selected: False),
    SelectOption(value: "Latvia", label: "Latvia", selected: False),
    SelectOption(value: "Lebanon", label: "Lebanon", selected: False),
    SelectOption(value: "Lesotho", label: "Lesotho", selected: False),
    SelectOption(value: "Liberia", label: "Liberia", selected: False),
    SelectOption(value: "Libya", label: "Libya", selected: False),
    SelectOption(
      value: "Liechtenstein",
      label: "Liechtenstein",
      selected: False,
    ),
    SelectOption(value: "Lithuania", label: "Lithuania", selected: False),
    SelectOption(value: "Luxembourg", label: "Luxembourg", selected: False),
    SelectOption(value: "Macau", label: "Macau", selected: False),
    SelectOption(value: "Madagascar", label: "Madagascar", selected: False),
    SelectOption(value: "Malawi", label: "Malawi", selected: False),
    SelectOption(value: "Malaysia", label: "Malaysia", selected: False),
    SelectOption(value: "Maldives", label: "Maldives", selected: False),
    SelectOption(value: "Mali", label: "Mali", selected: False),
    SelectOption(value: "Malta", label: "Malta", selected: False),
    SelectOption(
      value: "Marshall Islands",
      label: "Marshall Islands",
      selected: False,
    ),
    SelectOption(value: "Martinique", label: "Martinique", selected: False),
    SelectOption(value: "Mauritania", label: "Mauritania", selected: False),
    SelectOption(value: "Mauritius", label: "Mauritius", selected: False),
    SelectOption(value: "Mayotte", label: "Mayotte", selected: False),
    SelectOption(value: "Mexico", label: "Mexico", selected: False),
    SelectOption(value: "Micronesia", label: "Micronesia", selected: False),
    SelectOption(value: "Moldova", label: "Moldova", selected: False),
    SelectOption(value: "Monaco", label: "Monaco", selected: False),
    SelectOption(value: "Mongolia", label: "Mongolia", selected: False),
    SelectOption(value: "Montenegro", label: "Montenegro", selected: False),
    SelectOption(value: "Montserrat", label: "Montserrat", selected: False),
    SelectOption(value: "Morocco", label: "Morocco", selected: False),
    SelectOption(value: "Mozambique", label: "Mozambique", selected: False),
    SelectOption(value: "Myanmar", label: "Myanmar", selected: False),
    SelectOption(value: "Namibia", label: "Namibia", selected: False),
    SelectOption(value: "Nauru", label: "Nauru", selected: False),
    SelectOption(value: "Nepal", label: "Nepal", selected: False),
    SelectOption(value: "Netherlands", label: "Netherlands", selected: False),
    SelectOption(
      value: "New Caledonia",
      label: "New Caledonia",
      selected: False,
    ),
    SelectOption(value: "New Zealand", label: "New Zealand", selected: False),
    SelectOption(value: "Nicaragua", label: "Nicaragua", selected: False),
    SelectOption(value: "Niger", label: "Niger", selected: False),
    SelectOption(value: "Nigeria", label: "Nigeria", selected: False),
    SelectOption(value: "Niue", label: "Niue", selected: False),
    SelectOption(
      value: "Norfolk Island",
      label: "Norfolk Island",
      selected: False,
    ),
    SelectOption(value: "North Korea", label: "North Korea", selected: False),
    SelectOption(
      value: "North Macedonia",
      label: "North Macedonia",
      selected: False,
    ),
    SelectOption(
      value: "Northern Mariana Islands",
      label: "Northern Mariana Islands",
      selected: False,
    ),
    SelectOption(value: "Norway", label: "Norway", selected: False),
    SelectOption(value: "Oman", label: "Oman", selected: False),
    SelectOption(value: "Pakistan", label: "Pakistan", selected: False),
    SelectOption(value: "Palau", label: "Palau", selected: False),
    SelectOption(value: "Palestine", label: "Palestine", selected: False),
    SelectOption(value: "Panama", label: "Panama", selected: False),
    SelectOption(
      value: "Papua New Guinea",
      label: "Papua New Guinea",
      selected: False,
    ),
    SelectOption(value: "Paraguay", label: "Paraguay", selected: False),
    SelectOption(value: "Peru", label: "Peru", selected: False),
    SelectOption(value: "Philippines", label: "Philippines", selected: False),
    SelectOption(
      value: "Pitcairn Islands",
      label: "Pitcairn Islands",
      selected: False,
    ),
    SelectOption(value: "Poland", label: "Poland", selected: False),
    SelectOption(value: "Portugal", label: "Portugal", selected: False),
    SelectOption(value: "Puerto Rico", label: "Puerto Rico", selected: False),
    SelectOption(value: "Qatar", label: "Qatar", selected: False),
    SelectOption(
      value: "Republic of the Congo",
      label: "Republic of the Congo",
      selected: False,
    ),
    SelectOption(value: "Romania", label: "Romania", selected: False),
    SelectOption(value: "Russia", label: "Russia", selected: False),
    SelectOption(value: "Rwanda", label: "Rwanda", selected: False),
    SelectOption(value: "Réunion", label: "Réunion", selected: False),
    SelectOption(
      value: "Saint Barthélemy",
      label: "Saint Barthélemy",
      selected: False,
    ),
    SelectOption(
      value: "Saint Helena, Ascension and Tristan da Cunha",
      label: "Saint Helena, Ascension and Tristan da Cunha",
      selected: False,
    ),
    SelectOption(
      value: "Saint Kitts and Nevis",
      label: "Saint Kitts and Nevis",
      selected: False,
    ),
    SelectOption(value: "Saint Lucia", label: "Saint Lucia", selected: False),
    SelectOption(value: "Saint Martin", label: "Saint Martin", selected: False),
    SelectOption(
      value: "Saint Pierre and Miquelon",
      label: "Saint Pierre and Miquelon",
      selected: False,
    ),
    SelectOption(
      value: "Saint Vincent and the Grenadines",
      label: "Saint Vincent and the Grenadines",
      selected: False,
    ),
    SelectOption(value: "Samoa", label: "Samoa", selected: False),
    SelectOption(value: "San Marino", label: "San Marino", selected: False),
    SelectOption(value: "Saudi Arabia", label: "Saudi Arabia", selected: False),
    SelectOption(value: "Senegal", label: "Senegal", selected: False),
    SelectOption(value: "Serbia", label: "Serbia", selected: False),
    SelectOption(value: "Seychelles", label: "Seychelles", selected: False),
    SelectOption(value: "Sierra Leone", label: "Sierra Leone", selected: False),
    SelectOption(value: "Singapore", label: "Singapore", selected: False),
    SelectOption(value: "Sint Maarten", label: "Sint Maarten", selected: False),
    SelectOption(value: "Slovakia", label: "Slovakia", selected: False),
    SelectOption(value: "Slovenia", label: "Slovenia", selected: False),
    SelectOption(
      value: "Solomon Islands",
      label: "Solomon Islands",
      selected: False,
    ),
    SelectOption(value: "Somalia", label: "Somalia", selected: False),
    SelectOption(value: "South Africa", label: "South Africa", selected: False),
    SelectOption(
      value: "South Georgia",
      label: "South Georgia",
      selected: False,
    ),
    SelectOption(value: "South Korea", label: "South Korea", selected: False),
    SelectOption(value: "South Sudan", label: "South Sudan", selected: False),
    SelectOption(value: "Spain", label: "Spain", selected: False),
    SelectOption(value: "Sri Lanka", label: "Sri Lanka", selected: False),
    SelectOption(value: "Sudan", label: "Sudan", selected: False),
    SelectOption(value: "Suriname", label: "Suriname", selected: False),
    SelectOption(
      value: "Svalbard and Jan Mayen",
      label: "Svalbard and Jan Mayen",
      selected: False,
    ),
    SelectOption(value: "Sweden", label: "Sweden", selected: False),
    SelectOption(value: "Switzerland", label: "Switzerland", selected: False),
    SelectOption(value: "Syria", label: "Syria", selected: False),
    SelectOption(
      value: "São Tomé and Príncipe",
      label: "São Tomé and Príncipe",
      selected: False,
    ),
    SelectOption(value: "Taiwan", label: "Taiwan", selected: False),
    SelectOption(value: "Tajikistan", label: "Tajikistan", selected: False),
    SelectOption(value: "Tanzania", label: "Tanzania", selected: False),
    SelectOption(value: "Thailand", label: "Thailand", selected: False),
    SelectOption(value: "Timor-Leste", label: "Timor-Leste", selected: False),
    SelectOption(value: "Togo", label: "Togo", selected: False),
    SelectOption(value: "Tokelau", label: "Tokelau", selected: False),
    SelectOption(value: "Tonga", label: "Tonga", selected: False),
    SelectOption(
      value: "Trinidad and Tobago",
      label: "Trinidad and Tobago",
      selected: False,
    ),
    SelectOption(value: "Tunisia", label: "Tunisia", selected: False),
    SelectOption(value: "Turkey", label: "Turkey", selected: False),
    SelectOption(value: "Turkmenistan", label: "Turkmenistan", selected: False),
    SelectOption(
      value: "Turks and Caicos Islands",
      label: "Turks and Caicos Islands",
      selected: False,
    ),
    SelectOption(value: "Tuvalu", label: "Tuvalu", selected: False),
    SelectOption(value: "Uganda", label: "Uganda", selected: False),
    SelectOption(value: "Ukraine", label: "Ukraine", selected: False),
    SelectOption(
      value: "United Arab Emirates",
      label: "United Arab Emirates",
      selected: False,
    ),
    SelectOption(
      value: "United Kingdom",
      label: "United Kingdom",
      selected: False,
    ),
    SelectOption(
      value: "United States",
      label: "United States",
      selected: False,
    ),
    SelectOption(
      value: "United States Minor Outlying Islands",
      label: "United States Minor Outlying Islands",
      selected: False,
    ),
    SelectOption(
      value: "United States Virgin Islands",
      label: "United States Virgin Islands",
      selected: False,
    ),
    SelectOption(value: "Uruguay", label: "Uruguay", selected: False),
    SelectOption(value: "Uzbekistan", label: "Uzbekistan", selected: False),
    SelectOption(value: "Vanuatu", label: "Vanuatu", selected: False),
    SelectOption(value: "Vatican City", label: "Vatican City", selected: False),
    SelectOption(value: "Venezuela", label: "Venezuela", selected: False),
    SelectOption(value: "Vietnam", label: "Vietnam", selected: False),
    SelectOption(
      value: "Wallis and Futuna",
      label: "Wallis and Futuna",
      selected: False,
    ),
    SelectOption(
      value: "Western Sahara",
      label: "Western Sahara",
      selected: False,
    ),
    SelectOption(value: "Yemen", label: "Yemen", selected: False),
    SelectOption(value: "Zambia", label: "Zambia", selected: False),
    SelectOption(value: "Zimbabwe", label: "Zimbabwe", selected: False),
  ]

  HtmlForm(
    ..form,
    select_options: list.map(countries, fn(country) {
      case country.value == selected {
        True -> SelectOption(..country, selected: True)
        False -> country
      }
    }),
  )
}
