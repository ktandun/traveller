// build/dev/javascript/prelude.mjs
var CustomType = class {
  withFields(fields) {
    let properties = Object.keys(this).map(
      (label2) => label2 in fields ? fields[label2] : this[label2]
    );
    return new this.constructor(...properties);
  }
};
var List = class {
  static fromArray(array3, tail) {
    let t = tail || new Empty();
    for (let i = array3.length - 1; i >= 0; --i) {
      t = new NonEmpty(array3[i], t);
    }
    return t;
  }
  [Symbol.iterator]() {
    return new ListIterator(this);
  }
  toArray() {
    return [...this];
  }
  // @internal
  atLeastLength(desired) {
    for (let _ of this) {
      if (desired <= 0)
        return true;
      desired--;
    }
    return desired <= 0;
  }
  // @internal
  hasLength(desired) {
    for (let _ of this) {
      if (desired <= 0)
        return false;
      desired--;
    }
    return desired === 0;
  }
  countLength() {
    let length4 = 0;
    for (let _ of this)
      length4++;
    return length4;
  }
};
function prepend(element2, tail) {
  return new NonEmpty(element2, tail);
}
function toList(elements, tail) {
  return List.fromArray(elements, tail);
}
var ListIterator = class {
  #current;
  constructor(current) {
    this.#current = current;
  }
  next() {
    if (this.#current instanceof Empty) {
      return { done: true };
    } else {
      let { head, tail } = this.#current;
      this.#current = tail;
      return { value: head, done: false };
    }
  }
};
var Empty = class extends List {
};
var NonEmpty = class extends List {
  constructor(head, tail) {
    super();
    this.head = head;
    this.tail = tail;
  }
};
var BitArray = class _BitArray {
  constructor(buffer) {
    if (!(buffer instanceof Uint8Array)) {
      throw "BitArray can only be constructed from a Uint8Array";
    }
    this.buffer = buffer;
  }
  // @internal
  get length() {
    return this.buffer.length;
  }
  // @internal
  byteAt(index5) {
    return this.buffer[index5];
  }
  // @internal
  floatFromSlice(start4, end, isBigEndian) {
    return byteArrayToFloat(this.buffer, start4, end, isBigEndian);
  }
  // @internal
  intFromSlice(start4, end, isBigEndian, isSigned) {
    return byteArrayToInt(this.buffer, start4, end, isBigEndian, isSigned);
  }
  // @internal
  binaryFromSlice(start4, end) {
    return new _BitArray(this.buffer.slice(start4, end));
  }
  // @internal
  sliceAfter(index5) {
    return new _BitArray(this.buffer.slice(index5));
  }
};
function byteArrayToInt(byteArray, start4, end, isBigEndian, isSigned) {
  let value4 = 0;
  if (isBigEndian) {
    for (let i = start4; i < end; i++) {
      value4 = value4 * 256 + byteArray[i];
    }
  } else {
    for (let i = end - 1; i >= start4; i--) {
      value4 = value4 * 256 + byteArray[i];
    }
  }
  if (isSigned) {
    const byteSize = end - start4;
    const highBit = 2 ** (byteSize * 8 - 1);
    if (value4 >= highBit) {
      value4 -= highBit * 2;
    }
  }
  return value4;
}
function byteArrayToFloat(byteArray, start4, end, isBigEndian) {
  const view2 = new DataView(byteArray.buffer);
  const byteSize = end - start4;
  if (byteSize === 8) {
    return view2.getFloat64(start4, !isBigEndian);
  } else if (byteSize === 4) {
    return view2.getFloat32(start4, !isBigEndian);
  } else {
    const msg = `Sized floats must be 32-bit or 64-bit on JavaScript, got size of ${byteSize * 8} bits`;
    throw new globalThis.Error(msg);
  }
}
var Result = class _Result extends CustomType {
  // @internal
  static isResult(data) {
    return data instanceof _Result;
  }
};
var Ok = class extends Result {
  constructor(value4) {
    super();
    this[0] = value4;
  }
  // @internal
  isOk() {
    return true;
  }
};
var Error = class extends Result {
  constructor(detail) {
    super();
    this[0] = detail;
  }
  // @internal
  isOk() {
    return false;
  }
};
function isEqual(x, y) {
  let values = [x, y];
  while (values.length) {
    let a2 = values.pop();
    let b = values.pop();
    if (a2 === b)
      continue;
    if (!isObject(a2) || !isObject(b))
      return false;
    let unequal = !structurallyCompatibleObjects(a2, b) || unequalDates(a2, b) || unequalBuffers(a2, b) || unequalArrays(a2, b) || unequalMaps(a2, b) || unequalSets(a2, b) || unequalRegExps(a2, b);
    if (unequal)
      return false;
    const proto = Object.getPrototypeOf(a2);
    if (proto !== null && typeof proto.equals === "function") {
      try {
        if (a2.equals(b))
          continue;
        else
          return false;
      } catch {
      }
    }
    let [keys2, get3] = getters(a2);
    for (let k of keys2(a2)) {
      values.push(get3(a2, k), get3(b, k));
    }
  }
  return true;
}
function getters(object3) {
  if (object3 instanceof Map) {
    return [(x) => x.keys(), (x, y) => x.get(y)];
  } else {
    let extra = object3 instanceof globalThis.Error ? ["message"] : [];
    return [(x) => [...extra, ...Object.keys(x)], (x, y) => x[y]];
  }
}
function unequalDates(a2, b) {
  return a2 instanceof Date && (a2 > b || a2 < b);
}
function unequalBuffers(a2, b) {
  return a2.buffer instanceof ArrayBuffer && a2.BYTES_PER_ELEMENT && !(a2.byteLength === b.byteLength && a2.every((n, i) => n === b[i]));
}
function unequalArrays(a2, b) {
  return Array.isArray(a2) && a2.length !== b.length;
}
function unequalMaps(a2, b) {
  return a2 instanceof Map && a2.size !== b.size;
}
function unequalSets(a2, b) {
  return a2 instanceof Set && (a2.size != b.size || [...a2].some((e) => !b.has(e)));
}
function unequalRegExps(a2, b) {
  return a2 instanceof RegExp && (a2.source !== b.source || a2.flags !== b.flags);
}
function isObject(a2) {
  return typeof a2 === "object" && a2 !== null;
}
function structurallyCompatibleObjects(a2, b) {
  if (typeof a2 !== "object" && typeof b !== "object" && (!a2 || !b))
    return false;
  let nonstructural = [Promise, WeakSet, WeakMap, Function];
  if (nonstructural.some((c) => a2 instanceof c))
    return false;
  return a2.constructor === b.constructor;
}
function makeError(variant, module, line, fn, message, extra) {
  let error = new globalThis.Error(message);
  error.gleam_error = variant;
  error.module = module;
  error.line = line;
  error.fn = fn;
  for (let k in extra)
    error[k] = extra[k];
  return error;
}

// build/dev/javascript/gleam_stdlib/gleam/option.mjs
var Some2 = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var None2 = class extends CustomType {
};
function to_result(option, e) {
  if (option instanceof Some2) {
    let a2 = option[0];
    return new Ok(a2);
  } else {
    return new Error(e);
  }
}
function from_result(result) {
  if (result.isOk()) {
    let a2 = result[0];
    return new Some2(a2);
  } else {
    return new None2();
  }
}
function unwrap(option, default$) {
  if (option instanceof Some2) {
    let x = option[0];
    return x;
  } else {
    return default$;
  }
}
function map(option, fun) {
  if (option instanceof Some2) {
    let x = option[0];
    return new Some2(fun(x));
  } else {
    return new None2();
  }
}

// build/dev/javascript/gleam_stdlib/gleam/regex.mjs
var Match = class extends CustomType {
  constructor(content, submatches) {
    super();
    this.content = content;
    this.submatches = submatches;
  }
};
var CompileError = class extends CustomType {
  constructor(error, byte_index) {
    super();
    this.error = error;
    this.byte_index = byte_index;
  }
};
var Options = class extends CustomType {
  constructor(case_insensitive, multi_line) {
    super();
    this.case_insensitive = case_insensitive;
    this.multi_line = multi_line;
  }
};
function compile(pattern, options) {
  return compile_regex(pattern, options);
}
function scan(regex, string4) {
  return regex_scan(regex, string4);
}

// build/dev/javascript/gleam_stdlib/gleam/pair.mjs
function second(pair) {
  let a2 = pair[1];
  return a2;
}

// build/dev/javascript/gleam_stdlib/gleam/list.mjs
function do_reverse(loop$remaining, loop$accumulator) {
  while (true) {
    let remaining = loop$remaining;
    let accumulator = loop$accumulator;
    if (remaining.hasLength(0)) {
      return accumulator;
    } else {
      let item = remaining.head;
      let rest$1 = remaining.tail;
      loop$remaining = rest$1;
      loop$accumulator = prepend(item, accumulator);
    }
  }
}
function reverse(xs) {
  return do_reverse(xs, toList([]));
}
function first(list3) {
  if (list3.hasLength(0)) {
    return new Error(void 0);
  } else {
    let x = list3.head;
    return new Ok(x);
  }
}
function do_map(loop$list, loop$fun, loop$acc) {
  while (true) {
    let list3 = loop$list;
    let fun = loop$fun;
    let acc = loop$acc;
    if (list3.hasLength(0)) {
      return reverse(acc);
    } else {
      let x = list3.head;
      let xs = list3.tail;
      loop$list = xs;
      loop$fun = fun;
      loop$acc = prepend(fun(x), acc);
    }
  }
}
function map2(list3, fun) {
  return do_map(list3, fun, toList([]));
}
function do_try_map(loop$list, loop$fun, loop$acc) {
  while (true) {
    let list3 = loop$list;
    let fun = loop$fun;
    let acc = loop$acc;
    if (list3.hasLength(0)) {
      return new Ok(reverse(acc));
    } else {
      let x = list3.head;
      let xs = list3.tail;
      let $ = fun(x);
      if ($.isOk()) {
        let y = $[0];
        loop$list = xs;
        loop$fun = fun;
        loop$acc = prepend(y, acc);
      } else {
        let error = $[0];
        return new Error(error);
      }
    }
  }
}
function try_map(list3, fun) {
  return do_try_map(list3, fun, toList([]));
}
function do_append(loop$first, loop$second) {
  while (true) {
    let first3 = loop$first;
    let second2 = loop$second;
    if (first3.hasLength(0)) {
      return second2;
    } else {
      let item = first3.head;
      let rest$1 = first3.tail;
      loop$first = rest$1;
      loop$second = prepend(item, second2);
    }
  }
}
function append(first3, second2) {
  return do_append(reverse(first3), second2);
}
function fold(loop$list, loop$initial, loop$fun) {
  while (true) {
    let list3 = loop$list;
    let initial = loop$initial;
    let fun = loop$fun;
    if (list3.hasLength(0)) {
      return initial;
    } else {
      let x = list3.head;
      let rest$1 = list3.tail;
      loop$list = rest$1;
      loop$initial = fun(initial, x);
      loop$fun = fun;
    }
  }
}
function fold_right(list3, initial, fun) {
  if (list3.hasLength(0)) {
    return initial;
  } else {
    let x = list3.head;
    let rest$1 = list3.tail;
    return fun(fold_right(rest$1, initial, fun), x);
  }
}
function do_repeat(loop$a, loop$times, loop$acc) {
  while (true) {
    let a2 = loop$a;
    let times = loop$times;
    let acc = loop$acc;
    let $ = times <= 0;
    if ($) {
      return acc;
    } else {
      loop$a = a2;
      loop$times = times - 1;
      loop$acc = prepend(a2, acc);
    }
  }
}
function repeat(a2, times) {
  return do_repeat(a2, times, toList([]));
}
function key_set(list3, key, value4) {
  if (list3.hasLength(0)) {
    return toList([[key, value4]]);
  } else if (list3.atLeastLength(1) && isEqual(list3.head[0], key)) {
    let k = list3.head[0];
    let rest$1 = list3.tail;
    return prepend([key, value4], rest$1);
  } else {
    let first$1 = list3.head;
    let rest$1 = list3.tail;
    return prepend(first$1, key_set(rest$1, key, value4));
  }
}

// build/dev/javascript/gleam_stdlib/gleam/result.mjs
function map3(result, fun) {
  if (result.isOk()) {
    let x = result[0];
    return new Ok(fun(x));
  } else {
    let e = result[0];
    return new Error(e);
  }
}
function map_error(result, fun) {
  if (result.isOk()) {
    let x = result[0];
    return new Ok(x);
  } else {
    let error = result[0];
    return new Error(fun(error));
  }
}
function try$(result, fun) {
  if (result.isOk()) {
    let x = result[0];
    return fun(x);
  } else {
    let e = result[0];
    return new Error(e);
  }
}
function then$(result, fun) {
  return try$(result, fun);
}
function unwrap2(result, default$) {
  if (result.isOk()) {
    let v = result[0];
    return v;
  } else {
    return default$;
  }
}
function nil_error(result) {
  return map_error(result, (_) => {
    return void 0;
  });
}
function replace(result, value4) {
  if (result.isOk()) {
    return new Ok(value4);
  } else {
    let error = result[0];
    return new Error(error);
  }
}

// build/dev/javascript/gleam_stdlib/gleam/string_builder.mjs
function from_strings(strings) {
  return concat(strings);
}
function from_string(string4) {
  return identity(string4);
}
function to_string(builder) {
  return identity(builder);
}
function split2(iodata, pattern) {
  return split(iodata, pattern);
}

// build/dev/javascript/gleam_stdlib/gleam/string.mjs
function lowercase2(string4) {
  return lowercase(string4);
}
function starts_with2(string4, prefix) {
  return starts_with(string4, prefix);
}
function concat2(strings) {
  let _pipe = strings;
  let _pipe$1 = from_strings(_pipe);
  return to_string(_pipe$1);
}
function pop_grapheme2(string4) {
  return pop_grapheme(string4);
}
function split3(x, substring) {
  if (substring === "") {
    return graphemes(x);
  } else {
    let _pipe = x;
    let _pipe$1 = from_string(_pipe);
    let _pipe$2 = split2(_pipe$1, substring);
    return map2(_pipe$2, to_string);
  }
}

// build/dev/javascript/gleam_stdlib/gleam/dynamic.mjs
var DecodeError = class extends CustomType {
  constructor(expected, found, path) {
    super();
    this.expected = expected;
    this.found = found;
    this.path = path;
  }
};
function classify(data) {
  return classify_dynamic(data);
}
function int(data) {
  return decode_int(data);
}
function shallow_list(value4) {
  return decode_list(value4);
}
function optional(decode3) {
  return (value4) => {
    return decode_option(value4, decode3);
  };
}
function any(decoders) {
  return (data) => {
    if (decoders.hasLength(0)) {
      return new Error(
        toList([new DecodeError("another type", classify(data), toList([]))])
      );
    } else {
      let decoder = decoders.head;
      let decoders$1 = decoders.tail;
      let $ = decoder(data);
      if ($.isOk()) {
        let decoded = $[0];
        return new Ok(decoded);
      } else {
        return any(decoders$1)(data);
      }
    }
  };
}
function push_path(error, name3) {
  let name$1 = identity(name3);
  let decoder = any(
    toList([string, (x) => {
      return map3(int(x), to_string2);
    }])
  );
  let name$2 = (() => {
    let $ = decoder(name$1);
    if ($.isOk()) {
      let name$22 = $[0];
      return name$22;
    } else {
      let _pipe = toList(["<", classify(name$1), ">"]);
      let _pipe$1 = from_strings(_pipe);
      return to_string(_pipe$1);
    }
  })();
  return error.withFields({ path: prepend(name$2, error.path) });
}
function list(decoder_type) {
  return (dynamic) => {
    return try$(
      shallow_list(dynamic),
      (list3) => {
        let _pipe = list3;
        let _pipe$1 = try_map(_pipe, decoder_type);
        return map_errors(
          _pipe$1,
          (_capture) => {
            return push_path(_capture, "*");
          }
        );
      }
    );
  };
}
function map_errors(result, f) {
  return map_error(
    result,
    (_capture) => {
      return map2(_capture, f);
    }
  );
}
function string(data) {
  return decode_string(data);
}
function field(name3, inner_type) {
  return (value4) => {
    let missing_field_error = new DecodeError("field", "nothing", toList([]));
    return try$(
      decode_field(value4, name3),
      (maybe_inner) => {
        let _pipe = maybe_inner;
        let _pipe$1 = to_result(_pipe, toList([missing_field_error]));
        let _pipe$2 = try$(_pipe$1, inner_type);
        return map_errors(
          _pipe$2,
          (_capture) => {
            return push_path(_capture, name3);
          }
        );
      }
    );
  };
}

// build/dev/javascript/gleam_stdlib/dict.mjs
var referenceMap = /* @__PURE__ */ new WeakMap();
var tempDataView = new DataView(new ArrayBuffer(8));
var referenceUID = 0;
function hashByReference(o) {
  const known = referenceMap.get(o);
  if (known !== void 0) {
    return known;
  }
  const hash = referenceUID++;
  if (referenceUID === 2147483647) {
    referenceUID = 0;
  }
  referenceMap.set(o, hash);
  return hash;
}
function hashMerge(a2, b) {
  return a2 ^ b + 2654435769 + (a2 << 6) + (a2 >> 2) | 0;
}
function hashString(s) {
  let hash = 0;
  const len = s.length;
  for (let i = 0; i < len; i++) {
    hash = Math.imul(31, hash) + s.charCodeAt(i) | 0;
  }
  return hash;
}
function hashNumber(n) {
  tempDataView.setFloat64(0, n);
  const i = tempDataView.getInt32(0);
  const j = tempDataView.getInt32(4);
  return Math.imul(73244475, i >> 16 ^ i) ^ j;
}
function hashBigInt(n) {
  return hashString(n.toString());
}
function hashObject(o) {
  const proto = Object.getPrototypeOf(o);
  if (proto !== null && typeof proto.hashCode === "function") {
    try {
      const code = o.hashCode(o);
      if (typeof code === "number") {
        return code;
      }
    } catch {
    }
  }
  if (o instanceof Promise || o instanceof WeakSet || o instanceof WeakMap) {
    return hashByReference(o);
  }
  if (o instanceof Date) {
    return hashNumber(o.getTime());
  }
  let h = 0;
  if (o instanceof ArrayBuffer) {
    o = new Uint8Array(o);
  }
  if (Array.isArray(o) || o instanceof Uint8Array) {
    for (let i = 0; i < o.length; i++) {
      h = Math.imul(31, h) + getHash(o[i]) | 0;
    }
  } else if (o instanceof Set) {
    o.forEach((v) => {
      h = h + getHash(v) | 0;
    });
  } else if (o instanceof Map) {
    o.forEach((v, k) => {
      h = h + hashMerge(getHash(v), getHash(k)) | 0;
    });
  } else {
    const keys2 = Object.keys(o);
    for (let i = 0; i < keys2.length; i++) {
      const k = keys2[i];
      const v = o[k];
      h = h + hashMerge(getHash(v), hashString(k)) | 0;
    }
  }
  return h;
}
function getHash(u) {
  if (u === null)
    return 1108378658;
  if (u === void 0)
    return 1108378659;
  if (u === true)
    return 1108378657;
  if (u === false)
    return 1108378656;
  switch (typeof u) {
    case "number":
      return hashNumber(u);
    case "string":
      return hashString(u);
    case "bigint":
      return hashBigInt(u);
    case "object":
      return hashObject(u);
    case "symbol":
      return hashByReference(u);
    case "function":
      return hashByReference(u);
    default:
      return 0;
  }
}
var SHIFT = 5;
var BUCKET_SIZE = Math.pow(2, SHIFT);
var MASK = BUCKET_SIZE - 1;
var MAX_INDEX_NODE = BUCKET_SIZE / 2;
var MIN_ARRAY_NODE = BUCKET_SIZE / 4;
var ENTRY = 0;
var ARRAY_NODE = 1;
var INDEX_NODE = 2;
var COLLISION_NODE = 3;
var EMPTY = {
  type: INDEX_NODE,
  bitmap: 0,
  array: []
};
function mask(hash, shift) {
  return hash >>> shift & MASK;
}
function bitpos(hash, shift) {
  return 1 << mask(hash, shift);
}
function bitcount(x) {
  x -= x >> 1 & 1431655765;
  x = (x & 858993459) + (x >> 2 & 858993459);
  x = x + (x >> 4) & 252645135;
  x += x >> 8;
  x += x >> 16;
  return x & 127;
}
function index(bitmap, bit) {
  return bitcount(bitmap & bit - 1);
}
function cloneAndSet(arr, at2, val) {
  const len = arr.length;
  const out = new Array(len);
  for (let i = 0; i < len; ++i) {
    out[i] = arr[i];
  }
  out[at2] = val;
  return out;
}
function spliceIn(arr, at2, val) {
  const len = arr.length;
  const out = new Array(len + 1);
  let i = 0;
  let g = 0;
  while (i < at2) {
    out[g++] = arr[i++];
  }
  out[g++] = val;
  while (i < len) {
    out[g++] = arr[i++];
  }
  return out;
}
function spliceOut(arr, at2) {
  const len = arr.length;
  const out = new Array(len - 1);
  let i = 0;
  let g = 0;
  while (i < at2) {
    out[g++] = arr[i++];
  }
  ++i;
  while (i < len) {
    out[g++] = arr[i++];
  }
  return out;
}
function createNode(shift, key1, val1, key2hash, key2, val2) {
  const key1hash = getHash(key1);
  if (key1hash === key2hash) {
    return {
      type: COLLISION_NODE,
      hash: key1hash,
      array: [
        { type: ENTRY, k: key1, v: val1 },
        { type: ENTRY, k: key2, v: val2 }
      ]
    };
  }
  const addedLeaf = { val: false };
  return assoc(
    assocIndex(EMPTY, shift, key1hash, key1, val1, addedLeaf),
    shift,
    key2hash,
    key2,
    val2,
    addedLeaf
  );
}
function assoc(root2, shift, hash, key, val, addedLeaf) {
  switch (root2.type) {
    case ARRAY_NODE:
      return assocArray(root2, shift, hash, key, val, addedLeaf);
    case INDEX_NODE:
      return assocIndex(root2, shift, hash, key, val, addedLeaf);
    case COLLISION_NODE:
      return assocCollision(root2, shift, hash, key, val, addedLeaf);
  }
}
function assocArray(root2, shift, hash, key, val, addedLeaf) {
  const idx = mask(hash, shift);
  const node = root2.array[idx];
  if (node === void 0) {
    addedLeaf.val = true;
    return {
      type: ARRAY_NODE,
      size: root2.size + 1,
      array: cloneAndSet(root2.array, idx, { type: ENTRY, k: key, v: val })
    };
  }
  if (node.type === ENTRY) {
    if (isEqual(key, node.k)) {
      if (val === node.v) {
        return root2;
      }
      return {
        type: ARRAY_NODE,
        size: root2.size,
        array: cloneAndSet(root2.array, idx, {
          type: ENTRY,
          k: key,
          v: val
        })
      };
    }
    addedLeaf.val = true;
    return {
      type: ARRAY_NODE,
      size: root2.size,
      array: cloneAndSet(
        root2.array,
        idx,
        createNode(shift + SHIFT, node.k, node.v, hash, key, val)
      )
    };
  }
  const n = assoc(node, shift + SHIFT, hash, key, val, addedLeaf);
  if (n === node) {
    return root2;
  }
  return {
    type: ARRAY_NODE,
    size: root2.size,
    array: cloneAndSet(root2.array, idx, n)
  };
}
function assocIndex(root2, shift, hash, key, val, addedLeaf) {
  const bit = bitpos(hash, shift);
  const idx = index(root2.bitmap, bit);
  if ((root2.bitmap & bit) !== 0) {
    const node = root2.array[idx];
    if (node.type !== ENTRY) {
      const n = assoc(node, shift + SHIFT, hash, key, val, addedLeaf);
      if (n === node) {
        return root2;
      }
      return {
        type: INDEX_NODE,
        bitmap: root2.bitmap,
        array: cloneAndSet(root2.array, idx, n)
      };
    }
    const nodeKey = node.k;
    if (isEqual(key, nodeKey)) {
      if (val === node.v) {
        return root2;
      }
      return {
        type: INDEX_NODE,
        bitmap: root2.bitmap,
        array: cloneAndSet(root2.array, idx, {
          type: ENTRY,
          k: key,
          v: val
        })
      };
    }
    addedLeaf.val = true;
    return {
      type: INDEX_NODE,
      bitmap: root2.bitmap,
      array: cloneAndSet(
        root2.array,
        idx,
        createNode(shift + SHIFT, nodeKey, node.v, hash, key, val)
      )
    };
  } else {
    const n = root2.array.length;
    if (n >= MAX_INDEX_NODE) {
      const nodes = new Array(32);
      const jdx = mask(hash, shift);
      nodes[jdx] = assocIndex(EMPTY, shift + SHIFT, hash, key, val, addedLeaf);
      let j = 0;
      let bitmap = root2.bitmap;
      for (let i = 0; i < 32; i++) {
        if ((bitmap & 1) !== 0) {
          const node = root2.array[j++];
          nodes[i] = node;
        }
        bitmap = bitmap >>> 1;
      }
      return {
        type: ARRAY_NODE,
        size: n + 1,
        array: nodes
      };
    } else {
      const newArray = spliceIn(root2.array, idx, {
        type: ENTRY,
        k: key,
        v: val
      });
      addedLeaf.val = true;
      return {
        type: INDEX_NODE,
        bitmap: root2.bitmap | bit,
        array: newArray
      };
    }
  }
}
function assocCollision(root2, shift, hash, key, val, addedLeaf) {
  if (hash === root2.hash) {
    const idx = collisionIndexOf(root2, key);
    if (idx !== -1) {
      const entry = root2.array[idx];
      if (entry.v === val) {
        return root2;
      }
      return {
        type: COLLISION_NODE,
        hash,
        array: cloneAndSet(root2.array, idx, { type: ENTRY, k: key, v: val })
      };
    }
    const size = root2.array.length;
    addedLeaf.val = true;
    return {
      type: COLLISION_NODE,
      hash,
      array: cloneAndSet(root2.array, size, { type: ENTRY, k: key, v: val })
    };
  }
  return assoc(
    {
      type: INDEX_NODE,
      bitmap: bitpos(root2.hash, shift),
      array: [root2]
    },
    shift,
    hash,
    key,
    val,
    addedLeaf
  );
}
function collisionIndexOf(root2, key) {
  const size = root2.array.length;
  for (let i = 0; i < size; i++) {
    if (isEqual(key, root2.array[i].k)) {
      return i;
    }
  }
  return -1;
}
function find(root2, shift, hash, key) {
  switch (root2.type) {
    case ARRAY_NODE:
      return findArray(root2, shift, hash, key);
    case INDEX_NODE:
      return findIndex(root2, shift, hash, key);
    case COLLISION_NODE:
      return findCollision(root2, key);
  }
}
function findArray(root2, shift, hash, key) {
  const idx = mask(hash, shift);
  const node = root2.array[idx];
  if (node === void 0) {
    return void 0;
  }
  if (node.type !== ENTRY) {
    return find(node, shift + SHIFT, hash, key);
  }
  if (isEqual(key, node.k)) {
    return node;
  }
  return void 0;
}
function findIndex(root2, shift, hash, key) {
  const bit = bitpos(hash, shift);
  if ((root2.bitmap & bit) === 0) {
    return void 0;
  }
  const idx = index(root2.bitmap, bit);
  const node = root2.array[idx];
  if (node.type !== ENTRY) {
    return find(node, shift + SHIFT, hash, key);
  }
  if (isEqual(key, node.k)) {
    return node;
  }
  return void 0;
}
function findCollision(root2, key) {
  const idx = collisionIndexOf(root2, key);
  if (idx < 0) {
    return void 0;
  }
  return root2.array[idx];
}
function without(root2, shift, hash, key) {
  switch (root2.type) {
    case ARRAY_NODE:
      return withoutArray(root2, shift, hash, key);
    case INDEX_NODE:
      return withoutIndex(root2, shift, hash, key);
    case COLLISION_NODE:
      return withoutCollision(root2, key);
  }
}
function withoutArray(root2, shift, hash, key) {
  const idx = mask(hash, shift);
  const node = root2.array[idx];
  if (node === void 0) {
    return root2;
  }
  let n = void 0;
  if (node.type === ENTRY) {
    if (!isEqual(node.k, key)) {
      return root2;
    }
  } else {
    n = without(node, shift + SHIFT, hash, key);
    if (n === node) {
      return root2;
    }
  }
  if (n === void 0) {
    if (root2.size <= MIN_ARRAY_NODE) {
      const arr = root2.array;
      const out = new Array(root2.size - 1);
      let i = 0;
      let j = 0;
      let bitmap = 0;
      while (i < idx) {
        const nv = arr[i];
        if (nv !== void 0) {
          out[j] = nv;
          bitmap |= 1 << i;
          ++j;
        }
        ++i;
      }
      ++i;
      while (i < arr.length) {
        const nv = arr[i];
        if (nv !== void 0) {
          out[j] = nv;
          bitmap |= 1 << i;
          ++j;
        }
        ++i;
      }
      return {
        type: INDEX_NODE,
        bitmap,
        array: out
      };
    }
    return {
      type: ARRAY_NODE,
      size: root2.size - 1,
      array: cloneAndSet(root2.array, idx, n)
    };
  }
  return {
    type: ARRAY_NODE,
    size: root2.size,
    array: cloneAndSet(root2.array, idx, n)
  };
}
function withoutIndex(root2, shift, hash, key) {
  const bit = bitpos(hash, shift);
  if ((root2.bitmap & bit) === 0) {
    return root2;
  }
  const idx = index(root2.bitmap, bit);
  const node = root2.array[idx];
  if (node.type !== ENTRY) {
    const n = without(node, shift + SHIFT, hash, key);
    if (n === node) {
      return root2;
    }
    if (n !== void 0) {
      return {
        type: INDEX_NODE,
        bitmap: root2.bitmap,
        array: cloneAndSet(root2.array, idx, n)
      };
    }
    if (root2.bitmap === bit) {
      return void 0;
    }
    return {
      type: INDEX_NODE,
      bitmap: root2.bitmap ^ bit,
      array: spliceOut(root2.array, idx)
    };
  }
  if (isEqual(key, node.k)) {
    if (root2.bitmap === bit) {
      return void 0;
    }
    return {
      type: INDEX_NODE,
      bitmap: root2.bitmap ^ bit,
      array: spliceOut(root2.array, idx)
    };
  }
  return root2;
}
function withoutCollision(root2, key) {
  const idx = collisionIndexOf(root2, key);
  if (idx < 0) {
    return root2;
  }
  if (root2.array.length === 1) {
    return void 0;
  }
  return {
    type: COLLISION_NODE,
    hash: root2.hash,
    array: spliceOut(root2.array, idx)
  };
}
function forEach(root2, fn) {
  if (root2 === void 0) {
    return;
  }
  const items = root2.array;
  const size = items.length;
  for (let i = 0; i < size; i++) {
    const item = items[i];
    if (item === void 0) {
      continue;
    }
    if (item.type === ENTRY) {
      fn(item.v, item.k);
      continue;
    }
    forEach(item, fn);
  }
}
var Dict2 = class _Dict {
  /**
   * @template V
   * @param {Record<string,V>} o
   * @returns {Dict<string,V>}
   */
  static fromObject(o) {
    const keys2 = Object.keys(o);
    let m = _Dict.new();
    for (let i = 0; i < keys2.length; i++) {
      const k = keys2[i];
      m = m.set(k, o[k]);
    }
    return m;
  }
  /**
   * @template K,V
   * @param {Map<K,V>} o
   * @returns {Dict<K,V>}
   */
  static fromMap(o) {
    let m = _Dict.new();
    o.forEach((v, k) => {
      m = m.set(k, v);
    });
    return m;
  }
  static new() {
    return new _Dict(void 0, 0);
  }
  /**
   * @param {undefined | Node<K,V>} root
   * @param {number} size
   */
  constructor(root2, size) {
    this.root = root2;
    this.size = size;
  }
  /**
   * @template NotFound
   * @param {K} key
   * @param {NotFound} notFound
   * @returns {NotFound | V}
   */
  get(key, notFound) {
    if (this.root === void 0) {
      return notFound;
    }
    const found = find(this.root, 0, getHash(key), key);
    if (found === void 0) {
      return notFound;
    }
    return found.v;
  }
  /**
   * @param {K} key
   * @param {V} val
   * @returns {Dict<K,V>}
   */
  set(key, val) {
    const addedLeaf = { val: false };
    const root2 = this.root === void 0 ? EMPTY : this.root;
    const newRoot = assoc(root2, 0, getHash(key), key, val, addedLeaf);
    if (newRoot === this.root) {
      return this;
    }
    return new _Dict(newRoot, addedLeaf.val ? this.size + 1 : this.size);
  }
  /**
   * @param {K} key
   * @returns {Dict<K,V>}
   */
  delete(key) {
    if (this.root === void 0) {
      return this;
    }
    const newRoot = without(this.root, 0, getHash(key), key);
    if (newRoot === this.root) {
      return this;
    }
    if (newRoot === void 0) {
      return _Dict.new();
    }
    return new _Dict(newRoot, this.size - 1);
  }
  /**
   * @param {K} key
   * @returns {boolean}
   */
  has(key) {
    if (this.root === void 0) {
      return false;
    }
    return find(this.root, 0, getHash(key), key) !== void 0;
  }
  /**
   * @returns {[K,V][]}
   */
  entries() {
    if (this.root === void 0) {
      return [];
    }
    const result = [];
    this.forEach((v, k) => result.push([k, v]));
    return result;
  }
  /**
   *
   * @param {(val:V,key:K)=>void} fn
   */
  forEach(fn) {
    forEach(this.root, fn);
  }
  hashCode() {
    let h = 0;
    this.forEach((v, k) => {
      h = h + hashMerge(getHash(v), getHash(k)) | 0;
    });
    return h;
  }
  /**
   * @param {unknown} o
   * @returns {boolean}
   */
  equals(o) {
    if (!(o instanceof _Dict) || this.size !== o.size) {
      return false;
    }
    let equal = true;
    this.forEach((v, k) => {
      equal = equal && isEqual(o.get(k, !v), v);
    });
    return equal;
  }
};

// build/dev/javascript/gleam_stdlib/gleam_stdlib.mjs
var Nil = void 0;
var NOT_FOUND = {};
function identity(x) {
  return x;
}
function parse_int(value4) {
  if (/^[-+]?(\d+)$/.test(value4)) {
    return new Ok(parseInt(value4));
  } else {
    return new Error(Nil);
  }
}
function to_string3(term) {
  return term.toString();
}
function graphemes(string4) {
  const iterator = graphemes_iterator(string4);
  if (iterator) {
    return List.fromArray(Array.from(iterator).map((item) => item.segment));
  } else {
    return List.fromArray(string4.match(/./gsu));
  }
}
function graphemes_iterator(string4) {
  if (globalThis.Intl && Intl.Segmenter) {
    return new Intl.Segmenter().segment(string4)[Symbol.iterator]();
  }
}
function pop_grapheme(string4) {
  let first3;
  const iterator = graphemes_iterator(string4);
  if (iterator) {
    first3 = iterator.next().value?.segment;
  } else {
    first3 = string4.match(/./su)?.[0];
  }
  if (first3) {
    return new Ok([first3, string4.slice(first3.length)]);
  } else {
    return new Error(Nil);
  }
}
function lowercase(string4) {
  return string4.toLowerCase();
}
function split(xs, pattern) {
  return List.fromArray(xs.split(pattern));
}
function concat(xs) {
  let result = "";
  for (const x of xs) {
    result = result + x;
  }
  return result;
}
function starts_with(haystack, needle) {
  return haystack.startsWith(needle);
}
var unicode_whitespaces = [
  " ",
  // Space
  "	",
  // Horizontal tab
  "\n",
  // Line feed
  "\v",
  // Vertical tab
  "\f",
  // Form feed
  "\r",
  // Carriage return
  "\x85",
  // Next line
  "\u2028",
  // Line separator
  "\u2029"
  // Paragraph separator
].join("");
var left_trim_regex = new RegExp(`^([${unicode_whitespaces}]*)`, "g");
var right_trim_regex = new RegExp(`([${unicode_whitespaces}]*)$`, "g");
function compile_regex(pattern, options) {
  try {
    let flags = "gu";
    if (options.case_insensitive)
      flags += "i";
    if (options.multi_line)
      flags += "m";
    return new Ok(new RegExp(pattern, flags));
  } catch (error) {
    const number = (error.columnNumber || 0) | 0;
    return new Error(new CompileError(error.message, number));
  }
}
function regex_scan(regex, string4) {
  const matches = Array.from(string4.matchAll(regex)).map((match) => {
    const content = match[0];
    const submatches = [];
    for (let n = match.length - 1; n > 0; n--) {
      if (match[n]) {
        submatches[n - 1] = new Some2(match[n]);
        continue;
      }
      if (submatches.length > 0) {
        submatches[n - 1] = new None2();
      }
    }
    return new Match(content, List.fromArray(submatches));
  });
  return List.fromArray(matches);
}
function map_get2(map6, key) {
  const value4 = map6.get(key, NOT_FOUND);
  if (value4 === NOT_FOUND) {
    return new Error(Nil);
  }
  return new Ok(value4);
}
function classify_dynamic(data) {
  if (typeof data === "string") {
    return "String";
  } else if (typeof data === "boolean") {
    return "Bool";
  } else if (data instanceof Result) {
    return "Result";
  } else if (data instanceof List) {
    return "List";
  } else if (data instanceof BitArray) {
    return "BitArray";
  } else if (data instanceof Dict2) {
    return "Dict";
  } else if (Number.isInteger(data)) {
    return "Int";
  } else if (Array.isArray(data)) {
    return `Tuple of ${data.length} elements`;
  } else if (typeof data === "number") {
    return "Float";
  } else if (data === null) {
    return "Null";
  } else if (data === void 0) {
    return "Nil";
  } else {
    const type = typeof data;
    return type.charAt(0).toUpperCase() + type.slice(1);
  }
}
function decoder_error(expected, got) {
  return decoder_error_no_classify(expected, classify_dynamic(got));
}
function decoder_error_no_classify(expected, got) {
  return new Error(
    List.fromArray([new DecodeError(expected, got, List.fromArray([]))])
  );
}
function decode_string(data) {
  return typeof data === "string" ? new Ok(data) : decoder_error("String", data);
}
function decode_int(data) {
  return Number.isInteger(data) ? new Ok(data) : decoder_error("Int", data);
}
function decode_list(data) {
  if (Array.isArray(data)) {
    return new Ok(List.fromArray(data));
  }
  return data instanceof List ? new Ok(data) : decoder_error("List", data);
}
function decode_option(data, decoder) {
  if (data === null || data === void 0 || data instanceof None2)
    return new Ok(new None2());
  if (data instanceof Some2)
    data = data[0];
  const result = decoder(data);
  if (result.isOk()) {
    return new Ok(new Some2(result[0]));
  } else {
    return result;
  }
}
function decode_field(value4, name3) {
  const not_a_map_error = () => decoder_error("Dict", value4);
  if (value4 instanceof Dict2 || value4 instanceof WeakMap || value4 instanceof Map) {
    const entry = map_get2(value4, name3);
    return new Ok(entry.isOk() ? new Some2(entry[0]) : new None2());
  } else if (value4 === null) {
    return not_a_map_error();
  } else if (Object.getPrototypeOf(value4) == Object.prototype) {
    return try_get_field2(value4, name3, () => new Ok(new None2()));
  } else {
    return try_get_field2(value4, name3, not_a_map_error);
  }
}
function try_get_field2(value4, field3, or_else) {
  try {
    return field3 in value4 ? new Ok(new Some2(value4[field3])) : or_else();
  } catch {
    return or_else();
  }
}

// build/dev/javascript/gleam_stdlib/gleam/int.mjs
function parse(string4) {
  return parse_int(string4);
}
function to_string2(x) {
  return to_string3(x);
}

// build/dev/javascript/gleam_stdlib/gleam/uri.mjs
var Uri = class extends CustomType {
  constructor(scheme, userinfo, host, port, path, query, fragment) {
    super();
    this.scheme = scheme;
    this.userinfo = userinfo;
    this.host = host;
    this.port = port;
    this.path = path;
    this.query = query;
    this.fragment = fragment;
  }
};
function regex_submatches(pattern, string4) {
  let _pipe = pattern;
  let _pipe$1 = compile(_pipe, new Options(true, false));
  let _pipe$2 = nil_error(_pipe$1);
  let _pipe$3 = map3(
    _pipe$2,
    (_capture) => {
      return scan(_capture, string4);
    }
  );
  let _pipe$4 = try$(_pipe$3, first);
  let _pipe$5 = map3(_pipe$4, (m) => {
    return m.submatches;
  });
  return unwrap2(_pipe$5, toList([]));
}
function noneify_query(x) {
  if (x instanceof None2) {
    return new None2();
  } else {
    let x$1 = x[0];
    let $ = pop_grapheme2(x$1);
    if ($.isOk() && $[0][0] === "?") {
      let query = $[0][1];
      return new Some2(query);
    } else {
      return new None2();
    }
  }
}
function noneify_empty_string(x) {
  if (x instanceof Some2 && x[0] === "") {
    return new None2();
  } else if (x instanceof None2) {
    return new None2();
  } else {
    return x;
  }
}
function extra_required(loop$list, loop$remaining) {
  while (true) {
    let list3 = loop$list;
    let remaining = loop$remaining;
    if (remaining === 0) {
      return 0;
    } else if (list3.hasLength(0)) {
      return remaining;
    } else {
      let xs = list3.tail;
      loop$list = xs;
      loop$remaining = remaining - 1;
    }
  }
}
function pad_list(list3, size) {
  let _pipe = list3;
  return append(
    _pipe,
    repeat(new None2(), extra_required(list3, size))
  );
}
function split_authority(authority) {
  let $ = unwrap(authority, "");
  if ($ === "") {
    return [new None2(), new None2(), new None2()];
  } else if ($ === "//") {
    return [new None2(), new Some2(""), new None2()];
  } else {
    let authority$1 = $;
    let matches = (() => {
      let _pipe = "^(//)?((.*)@)?(\\[[a-zA-Z0-9:.]*\\]|[^:]*)(:(\\d*))?";
      let _pipe$1 = regex_submatches(_pipe, authority$1);
      return pad_list(_pipe$1, 6);
    })();
    if (matches.hasLength(6)) {
      let userinfo = matches.tail.tail.head;
      let host = matches.tail.tail.tail.head;
      let port = matches.tail.tail.tail.tail.tail.head;
      let userinfo$1 = noneify_empty_string(userinfo);
      let host$1 = noneify_empty_string(host);
      let port$1 = (() => {
        let _pipe = port;
        let _pipe$1 = unwrap(_pipe, "");
        let _pipe$2 = parse(_pipe$1);
        return from_result(_pipe$2);
      })();
      return [userinfo$1, host$1, port$1];
    } else {
      return [new None2(), new None2(), new None2()];
    }
  }
}
function do_parse(uri_string) {
  let pattern = "^(([a-z][a-z0-9\\+\\-\\.]*):)?(//([^/?#]*))?([^?#]*)(\\?([^#]*))?(#.*)?";
  let matches = (() => {
    let _pipe = pattern;
    let _pipe$1 = regex_submatches(_pipe, uri_string);
    return pad_list(_pipe$1, 8);
  })();
  let $ = (() => {
    if (matches.hasLength(8)) {
      let scheme2 = matches.tail.head;
      let authority_with_slashes = matches.tail.tail.head;
      let path2 = matches.tail.tail.tail.tail.head;
      let query_with_question_mark = matches.tail.tail.tail.tail.tail.head;
      let fragment2 = matches.tail.tail.tail.tail.tail.tail.tail.head;
      return [
        scheme2,
        authority_with_slashes,
        path2,
        query_with_question_mark,
        fragment2
      ];
    } else {
      return [new None2(), new None2(), new None2(), new None2(), new None2()];
    }
  })();
  let scheme = $[0];
  let authority = $[1];
  let path = $[2];
  let query = $[3];
  let fragment = $[4];
  let scheme$1 = noneify_empty_string(scheme);
  let path$1 = unwrap(path, "");
  let query$1 = noneify_query(query);
  let $1 = split_authority(authority);
  let userinfo = $1[0];
  let host = $1[1];
  let port = $1[2];
  let fragment$1 = (() => {
    let _pipe = fragment;
    let _pipe$1 = to_result(_pipe, void 0);
    let _pipe$2 = try$(_pipe$1, pop_grapheme2);
    let _pipe$3 = map3(_pipe$2, second);
    return from_result(_pipe$3);
  })();
  let scheme$2 = (() => {
    let _pipe = scheme$1;
    let _pipe$1 = noneify_empty_string(_pipe);
    return map(_pipe$1, lowercase2);
  })();
  return new Ok(
    new Uri(scheme$2, userinfo, host, port, path$1, query$1, fragment$1)
  );
}
function parse2(uri_string) {
  return do_parse(uri_string);
}
function do_remove_dot_segments(loop$input, loop$accumulator) {
  while (true) {
    let input2 = loop$input;
    let accumulator = loop$accumulator;
    if (input2.hasLength(0)) {
      return reverse(accumulator);
    } else {
      let segment = input2.head;
      let rest = input2.tail;
      let accumulator$1 = (() => {
        if (segment === "") {
          let accumulator$12 = accumulator;
          return accumulator$12;
        } else if (segment === ".") {
          let accumulator$12 = accumulator;
          return accumulator$12;
        } else if (segment === ".." && accumulator.hasLength(0)) {
          return toList([]);
        } else if (segment === ".." && accumulator.atLeastLength(1)) {
          let accumulator$12 = accumulator.tail;
          return accumulator$12;
        } else {
          let segment$1 = segment;
          let accumulator$12 = accumulator;
          return prepend(segment$1, accumulator$12);
        }
      })();
      loop$input = rest;
      loop$accumulator = accumulator$1;
    }
  }
}
function remove_dot_segments(input2) {
  return do_remove_dot_segments(input2, toList([]));
}
function path_segments(path) {
  return remove_dot_segments(split3(path, "/"));
}
function to_string4(uri) {
  let parts = (() => {
    let $ = uri.fragment;
    if ($ instanceof Some2) {
      let fragment = $[0];
      return toList(["#", fragment]);
    } else {
      return toList([]);
    }
  })();
  let parts$1 = (() => {
    let $ = uri.query;
    if ($ instanceof Some2) {
      let query = $[0];
      return prepend("?", prepend(query, parts));
    } else {
      return parts;
    }
  })();
  let parts$2 = prepend(uri.path, parts$1);
  let parts$3 = (() => {
    let $ = uri.host;
    let $1 = starts_with2(uri.path, "/");
    if ($ instanceof Some2 && !$1 && $[0] !== "") {
      let host = $[0];
      return prepend("/", parts$2);
    } else {
      return parts$2;
    }
  })();
  let parts$4 = (() => {
    let $ = uri.host;
    let $1 = uri.port;
    if ($ instanceof Some2 && $1 instanceof Some2) {
      let port = $1[0];
      return prepend(":", prepend(to_string2(port), parts$3));
    } else {
      return parts$3;
    }
  })();
  let parts$5 = (() => {
    let $ = uri.scheme;
    let $1 = uri.userinfo;
    let $2 = uri.host;
    if ($ instanceof Some2 && $1 instanceof Some2 && $2 instanceof Some2) {
      let s = $[0];
      let u = $1[0];
      let h = $2[0];
      return prepend(
        s,
        prepend(
          "://",
          prepend(u, prepend("@", prepend(h, parts$4)))
        )
      );
    } else if ($ instanceof Some2 && $1 instanceof None2 && $2 instanceof Some2) {
      let s = $[0];
      let h = $2[0];
      return prepend(s, prepend("://", prepend(h, parts$4)));
    } else if ($ instanceof Some2 && $1 instanceof Some2 && $2 instanceof None2) {
      let s = $[0];
      return prepend(s, prepend(":", parts$4));
    } else if ($ instanceof Some2 && $1 instanceof None2 && $2 instanceof None2) {
      let s = $[0];
      return prepend(s, prepend(":", parts$4));
    } else if ($ instanceof None2 && $1 instanceof None2 && $2 instanceof Some2) {
      let h = $2[0];
      return prepend("//", prepend(h, parts$4));
    } else {
      return parts$4;
    }
  })();
  return concat2(parts$5);
}

// build/dev/javascript/gleam_stdlib/gleam/bool.mjs
function guard(requirement, consequence, alternative) {
  if (requirement) {
    return consequence;
  } else {
    return alternative();
  }
}

// build/dev/javascript/gleam_json/gleam_json_ffi.mjs
function json_to_string(json) {
  return JSON.stringify(json);
}
function object(entries) {
  return Object.fromEntries(entries);
}
function identity2(x) {
  return x;
}
function do_null() {
  return null;
}
function decode(string4) {
  try {
    const result = JSON.parse(string4);
    return new Ok(result);
  } catch (err) {
    return new Error(getJsonDecodeError(err, string4));
  }
}
function getJsonDecodeError(stdErr, json) {
  if (isUnexpectedEndOfInput(stdErr))
    return new UnexpectedEndOfInput();
  return toUnexpectedByteError(stdErr, json);
}
function isUnexpectedEndOfInput(err) {
  const unexpectedEndOfInputRegex = /((unexpected (end|eof))|(end of data)|(unterminated string)|(json( parse error|\.parse)\: expected '(\:|\}|\])'))/i;
  return unexpectedEndOfInputRegex.test(err.message);
}
function toUnexpectedByteError(err, json) {
  let converters = [
    v8UnexpectedByteError,
    oldV8UnexpectedByteError,
    jsCoreUnexpectedByteError,
    spidermonkeyUnexpectedByteError
  ];
  for (let converter of converters) {
    let result = converter(err, json);
    if (result)
      return result;
  }
  return new UnexpectedByte("", 0);
}
function v8UnexpectedByteError(err) {
  const regex = /unexpected token '(.)', ".+" is not valid JSON/i;
  const match = regex.exec(err.message);
  if (!match)
    return null;
  const byte = toHex(match[1]);
  return new UnexpectedByte(byte, -1);
}
function oldV8UnexpectedByteError(err) {
  const regex = /unexpected token (.) in JSON at position (\d+)/i;
  const match = regex.exec(err.message);
  if (!match)
    return null;
  const byte = toHex(match[1]);
  const position = Number(match[2]);
  return new UnexpectedByte(byte, position);
}
function spidermonkeyUnexpectedByteError(err, json) {
  const regex = /(unexpected character|expected .*) at line (\d+) column (\d+)/i;
  const match = regex.exec(err.message);
  if (!match)
    return null;
  const line = Number(match[2]);
  const column = Number(match[3]);
  const position = getPositionFromMultiline(line, column, json);
  const byte = toHex(json[position]);
  return new UnexpectedByte(byte, position);
}
function jsCoreUnexpectedByteError(err) {
  const regex = /unexpected (identifier|token) "(.)"/i;
  const match = regex.exec(err.message);
  if (!match)
    return null;
  const byte = toHex(match[2]);
  return new UnexpectedByte(byte, 0);
}
function toHex(char) {
  return "0x" + char.charCodeAt(0).toString(16).toUpperCase();
}
function getPositionFromMultiline(line, column, string4) {
  if (line === 1)
    return column - 1;
  let currentLn = 1;
  let position = 0;
  string4.split("").find((char, idx) => {
    if (char === "\n")
      currentLn += 1;
    if (currentLn === line) {
      position = idx + column;
      return true;
    }
    return false;
  });
  return position;
}

// build/dev/javascript/gleam_json/gleam/json.mjs
var UnexpectedEndOfInput = class extends CustomType {
};
var UnexpectedByte = class extends CustomType {
  constructor(byte, position) {
    super();
    this.byte = byte;
    this.position = position;
  }
};
var UnexpectedFormat = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
function do_decode(json, decoder) {
  return then$(
    decode(json),
    (dynamic_value) => {
      let _pipe = decoder(dynamic_value);
      return map_error(
        _pipe,
        (var0) => {
          return new UnexpectedFormat(var0);
        }
      );
    }
  );
}
function decode2(json, decoder) {
  return do_decode(json, decoder);
}
function to_string6(json) {
  return json_to_string(json);
}
function string2(input2) {
  return identity2(input2);
}
function null$() {
  return do_null();
}
function nullable(input2, inner_type) {
  if (input2 instanceof Some2) {
    let value4 = input2[0];
    return inner_type(value4);
  } else {
    return null$();
  }
}
function object2(entries) {
  return object(entries);
}

// build/dev/javascript/lustre/lustre/effect.mjs
var Effect = class extends CustomType {
  constructor(all) {
    super();
    this.all = all;
  }
};
function from(effect) {
  return new Effect(toList([(dispatch, _) => {
    return effect(dispatch);
  }]));
}
function none() {
  return new Effect(toList([]));
}
function batch(effects) {
  return new Effect(
    fold(
      effects,
      toList([]),
      (b, _use1) => {
        let a2 = _use1.all;
        return append(b, a2);
      }
    )
  );
}

// build/dev/javascript/lustre/lustre/internals/vdom.mjs
var Text = class extends CustomType {
  constructor(content) {
    super();
    this.content = content;
  }
};
var Element = class extends CustomType {
  constructor(key, namespace, tag, attrs, children, self_closing, void$) {
    super();
    this.key = key;
    this.namespace = namespace;
    this.tag = tag;
    this.attrs = attrs;
    this.children = children;
    this.self_closing = self_closing;
    this.void = void$;
  }
};
var Attribute = class extends CustomType {
  constructor(x0, x1, as_property) {
    super();
    this[0] = x0;
    this[1] = x1;
    this.as_property = as_property;
  }
};
var Event = class extends CustomType {
  constructor(x0, x1) {
    super();
    this[0] = x0;
    this[1] = x1;
  }
};

// build/dev/javascript/lustre/lustre/attribute.mjs
function attribute(name3, value4) {
  return new Attribute(name3, identity(value4), false);
}
function property(name3, value4) {
  return new Attribute(name3, identity(value4), true);
}
function on(name3, handler) {
  return new Event("on" + name3, handler);
}
function class$(name3) {
  return attribute("class", name3);
}
function type_(name3) {
  return attribute("type", name3);
}
function value2(val) {
  return attribute("value", val);
}
function placeholder(text2) {
  return attribute("placeholder", text2);
}
function name2(name3) {
  return attribute("name", name3);
}
function required(is_required) {
  return property("required", is_required);
}
function max(val) {
  return attribute("max", val);
}
function min(val) {
  return attribute("min", val);
}
function href(uri) {
  return attribute("href", uri);
}
function target(target2) {
  return attribute("target", target2);
}

// build/dev/javascript/lustre/lustre/element.mjs
function element(tag, attrs, children) {
  if (tag === "area") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "base") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "br") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "col") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "embed") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "hr") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "img") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "input") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "link") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "meta") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "param") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "source") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "track") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else if (tag === "wbr") {
    return new Element("", "", tag, attrs, toList([]), false, true);
  } else {
    return new Element("", "", tag, attrs, children, false, false);
  }
}
function text(content) {
  return new Text(content);
}

// build/dev/javascript/lustre/lustre/internals/runtime.mjs
var Debug = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var Dispatch = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var Shutdown = class extends CustomType {
};
var ForceModel = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};

// build/dev/javascript/lustre/vdom.ffi.mjs
function morph(prev, next, dispatch, isComponent = false) {
  let out;
  let stack = [{ prev, next, parent: prev.parentNode }];
  while (stack.length) {
    let { prev: prev2, next: next2, parent } = stack.pop();
    if (next2.subtree !== void 0)
      next2 = next2.subtree();
    if (next2.content !== void 0) {
      if (!prev2) {
        const created = document.createTextNode(next2.content);
        parent.appendChild(created);
        out ??= created;
      } else if (prev2.nodeType === Node.TEXT_NODE) {
        if (prev2.textContent !== next2.content)
          prev2.textContent = next2.content;
        out ??= prev2;
      } else {
        const created = document.createTextNode(next2.content);
        parent.replaceChild(created, prev2);
        out ??= created;
      }
    } else if (next2.tag !== void 0) {
      const created = createElementNode({
        prev: prev2,
        next: next2,
        dispatch,
        stack,
        isComponent
      });
      if (!prev2) {
        parent.appendChild(created);
      } else if (prev2 !== created) {
        parent.replaceChild(created, prev2);
      }
      out ??= created;
    } else if (next2.elements !== void 0) {
      iterateElement(next2, (fragmentElement) => {
        stack.unshift({ prev: prev2, next: fragmentElement, parent });
        prev2 = prev2?.nextSibling;
      });
    } else if (next2.subtree !== void 0) {
      stack.push({ prev: prev2, next: next2, parent });
    }
  }
  return out;
}
function createElementNode({ prev, next, dispatch, stack }) {
  const namespace = next.namespace || "http://www.w3.org/1999/xhtml";
  const canMorph = prev && prev.nodeType === Node.ELEMENT_NODE && prev.localName === next.tag && prev.namespaceURI === (next.namespace || "http://www.w3.org/1999/xhtml");
  const el2 = canMorph ? prev : namespace ? document.createElementNS(namespace, next.tag) : document.createElement(next.tag);
  let handlersForEl;
  if (!registeredHandlers.has(el2)) {
    const emptyHandlers = /* @__PURE__ */ new Map();
    registeredHandlers.set(el2, emptyHandlers);
    handlersForEl = emptyHandlers;
  } else {
    handlersForEl = registeredHandlers.get(el2);
  }
  const prevHandlers = canMorph ? new Set(handlersForEl.keys()) : null;
  const prevAttributes = canMorph ? new Set(Array.from(prev.attributes, (a2) => a2.name)) : null;
  let className = null;
  let style = null;
  let innerHTML = null;
  for (const attr of next.attrs) {
    const name3 = attr[0];
    const value4 = attr[1];
    if (attr.as_property) {
      if (el2[name3] !== value4)
        el2[name3] = value4;
      if (canMorph)
        prevAttributes.delete(name3);
    } else if (name3.startsWith("on")) {
      const eventName = name3.slice(2);
      const callback = dispatch(value4);
      if (!handlersForEl.has(eventName)) {
        el2.addEventListener(eventName, lustreGenericEventHandler);
      }
      handlersForEl.set(eventName, callback);
      if (canMorph)
        prevHandlers.delete(eventName);
    } else if (name3.startsWith("data-lustre-on-")) {
      const eventName = name3.slice(15);
      const callback = dispatch(lustreServerEventHandler);
      if (!handlersForEl.has(eventName)) {
        el2.addEventListener(eventName, lustreGenericEventHandler);
      }
      handlersForEl.set(eventName, callback);
      el2.setAttribute(name3, value4);
    } else if (name3 === "class") {
      className = className === null ? value4 : className + " " + value4;
    } else if (name3 === "style") {
      style = style === null ? value4 : style + value4;
    } else if (name3 === "dangerous-unescaped-html") {
      innerHTML = value4;
    } else {
      if (el2.getAttribute(name3) !== value4)
        el2.setAttribute(name3, value4);
      if (name3 === "value" || name3 === "selected")
        el2[name3] = value4;
      if (canMorph)
        prevAttributes.delete(name3);
    }
  }
  if (className !== null) {
    el2.setAttribute("class", className);
    if (canMorph)
      prevAttributes.delete("class");
  }
  if (style !== null) {
    el2.setAttribute("style", style);
    if (canMorph)
      prevAttributes.delete("style");
  }
  if (canMorph) {
    for (const attr of prevAttributes) {
      el2.removeAttribute(attr);
    }
    for (const eventName of prevHandlers) {
      handlersForEl.delete(eventName);
      el2.removeEventListener(eventName, lustreGenericEventHandler);
    }
  }
  if (next.key !== void 0 && next.key !== "") {
    el2.setAttribute("data-lustre-key", next.key);
  } else if (innerHTML !== null) {
    el2.innerHTML = innerHTML;
    return el2;
  }
  let prevChild = el2.firstChild;
  let seenKeys = null;
  let keyedChildren = null;
  let incomingKeyedChildren = null;
  let firstChild = next.children[Symbol.iterator]().next().value;
  if (canMorph && firstChild !== void 0 && // Explicit checks are more verbose but truthy checks force a bunch of comparisons
  // we don't care about: it's never gonna be a number etc.
  firstChild.key !== void 0 && firstChild.key !== "") {
    seenKeys = /* @__PURE__ */ new Set();
    keyedChildren = getKeyedChildren(prev);
    incomingKeyedChildren = getKeyedChildren(next);
  }
  for (const child of next.children) {
    iterateElement(child, (currElement) => {
      if (currElement.key !== void 0 && seenKeys !== null) {
        prevChild = diffKeyedChild(
          prevChild,
          currElement,
          el2,
          stack,
          incomingKeyedChildren,
          keyedChildren,
          seenKeys
        );
      } else {
        stack.unshift({ prev: prevChild, next: currElement, parent: el2 });
        prevChild = prevChild?.nextSibling;
      }
    });
  }
  while (prevChild) {
    const next2 = prevChild.nextSibling;
    el2.removeChild(prevChild);
    prevChild = next2;
  }
  return el2;
}
var registeredHandlers = /* @__PURE__ */ new WeakMap();
function lustreGenericEventHandler(event2) {
  const target2 = event2.currentTarget;
  if (!registeredHandlers.has(target2)) {
    target2.removeEventListener(event2.type, lustreGenericEventHandler);
    return;
  }
  const handlersForEventTarget = registeredHandlers.get(target2);
  if (!handlersForEventTarget.has(event2.type)) {
    target2.removeEventListener(event2.type, lustreGenericEventHandler);
    return;
  }
  handlersForEventTarget.get(event2.type)(event2);
}
function lustreServerEventHandler(event2) {
  const el2 = event2.currentTarget;
  const tag = el2.getAttribute(`data-lustre-on-${event2.type}`);
  const data = JSON.parse(el2.getAttribute("data-lustre-data") || "{}");
  const include = JSON.parse(el2.getAttribute("data-lustre-include") || "[]");
  switch (event2.type) {
    case "input":
    case "change":
      include.push("target.value");
      break;
  }
  return {
    tag,
    data: include.reduce(
      (data2, property2) => {
        const path = property2.split(".");
        for (let i = 0, o = data2, e = event2; i < path.length; i++) {
          if (i === path.length - 1) {
            o[path[i]] = e[path[i]];
          } else {
            o[path[i]] ??= {};
            e = e[path[i]];
            o = o[path[i]];
          }
        }
        return data2;
      },
      { data }
    )
  };
}
function getKeyedChildren(el2) {
  const keyedChildren = /* @__PURE__ */ new Map();
  if (el2) {
    for (const child of el2.children) {
      iterateElement(child, (currElement) => {
        const key = currElement?.key || currElement?.getAttribute?.("data-lustre-key");
        if (key)
          keyedChildren.set(key, currElement);
      });
    }
  }
  return keyedChildren;
}
function diffKeyedChild(prevChild, child, el2, stack, incomingKeyedChildren, keyedChildren, seenKeys) {
  while (prevChild && !incomingKeyedChildren.has(prevChild.getAttribute("data-lustre-key"))) {
    const nextChild = prevChild.nextSibling;
    el2.removeChild(prevChild);
    prevChild = nextChild;
  }
  if (keyedChildren.size === 0) {
    iterateElement(child, (currChild) => {
      stack.unshift({ prev: prevChild, next: currChild, parent: el2 });
      prevChild = prevChild?.nextSibling;
    });
    return prevChild;
  }
  if (seenKeys.has(child.key)) {
    console.warn(`Duplicate key found in Lustre vnode: ${child.key}`);
    stack.unshift({ prev: null, next: child, parent: el2 });
    return prevChild;
  }
  seenKeys.add(child.key);
  const keyedChild = keyedChildren.get(child.key);
  if (!keyedChild && !prevChild) {
    stack.unshift({ prev: null, next: child, parent: el2 });
    return prevChild;
  }
  if (!keyedChild && prevChild !== null) {
    const placeholder2 = document.createTextNode("");
    el2.insertBefore(placeholder2, prevChild);
    stack.unshift({ prev: placeholder2, next: child, parent: el2 });
    return prevChild;
  }
  if (!keyedChild || keyedChild === prevChild) {
    stack.unshift({ prev: prevChild, next: child, parent: el2 });
    prevChild = prevChild?.nextSibling;
    return prevChild;
  }
  el2.insertBefore(keyedChild, prevChild);
  stack.unshift({ prev: keyedChild, next: child, parent: el2 });
  return prevChild;
}
function iterateElement(element2, processElement) {
  if (element2.elements !== void 0) {
    for (const currElement of element2.elements) {
      iterateElement(currElement, processElement);
    }
  } else if (element2.subtree !== void 0) {
    iterateElement(element2.subtree(), processElement);
  } else {
    processElement(element2);
  }
}

// build/dev/javascript/lustre/client-runtime.ffi.mjs
var LustreClientApplication2 = class _LustreClientApplication {
  #root = null;
  #queue = [];
  #effects = [];
  #didUpdate = false;
  #isComponent = false;
  #model = null;
  #update = null;
  #view = null;
  static start(flags, selector, init4, update2, view2) {
    if (!is_browser())
      return new Error(new NotABrowser());
    const root2 = selector instanceof HTMLElement ? selector : document.querySelector(selector);
    if (!root2)
      return new Error(new ElementNotFound(selector));
    const app = new _LustreClientApplication(init4(flags), update2, view2, root2);
    return new Ok((msg) => app.send(msg));
  }
  constructor([model, effects], update2, view2, root2 = document.body, isComponent = false) {
    this.#model = model;
    this.#update = update2;
    this.#view = view2;
    this.#root = root2;
    this.#effects = effects.all.toArray();
    this.#didUpdate = true;
    this.#isComponent = isComponent;
    window.requestAnimationFrame(() => this.#tick());
  }
  send(action) {
    switch (true) {
      case action instanceof Dispatch: {
        this.#queue.push(action[0]);
        this.#tick();
        return;
      }
      case action instanceof Shutdown: {
        this.#shutdown();
        return;
      }
      case action instanceof Debug: {
        this.#debug(action[0]);
        return;
      }
      default:
        return;
    }
  }
  emit(event2, data) {
    this.#root.dispatchEvent(
      new CustomEvent(event2, {
        bubbles: true,
        detail: data,
        composed: true
      })
    );
  }
  #tick() {
    this.#flush_queue();
    if (this.#didUpdate) {
      const vdom = this.#view(this.#model);
      const dispatch = (handler) => (e) => {
        const result = handler(e);
        if (result instanceof Ok) {
          this.send(new Dispatch(result[0]));
        }
      };
      this.#didUpdate = false;
      this.#root = morph(this.#root, vdom, dispatch, this.#isComponent);
    }
  }
  #flush_queue(iterations = 0) {
    while (this.#queue.length) {
      const [next, effects] = this.#update(this.#model, this.#queue.shift());
      this.#didUpdate ||= this.#model !== next;
      this.#model = next;
      this.#effects = this.#effects.concat(effects.all.toArray());
    }
    while (this.#effects.length) {
      this.#effects.shift()(
        (msg) => this.send(new Dispatch(msg)),
        (event2, data) => this.emit(event2, data)
      );
    }
    if (this.#queue.length) {
      if (iterations < 5) {
        this.#flush_queue(++iterations);
      } else {
        window.requestAnimationFrame(() => this.#tick());
      }
    }
  }
  #debug(action) {
    switch (true) {
      case action instanceof ForceModel: {
        const vdom = this.#view(action[0]);
        const dispatch = (handler) => (e) => {
          const result = handler(e);
          if (result instanceof Ok) {
            this.send(new Dispatch(result[0]));
          }
        };
        this.#queue = [];
        this.#effects = [];
        this.#didUpdate = false;
        this.#root = morph(this.#root, vdom, dispatch, this.#isComponent);
      }
    }
  }
  #shutdown() {
    this.#root.remove();
    this.#root = null;
    this.#model = null;
    this.#queue = [];
    this.#effects = [];
    this.#didUpdate = false;
    this.#update = () => {
    };
    this.#view = () => {
    };
  }
};
var start = (app, selector, flags) => LustreClientApplication2.start(
  flags,
  selector,
  app.init,
  app.update,
  app.view
);
var is_browser = () => globalThis.window && window.document;

// build/dev/javascript/lustre/lustre.mjs
var App = class extends CustomType {
  constructor(init4, update2, view2, on_attribute_change) {
    super();
    this.init = init4;
    this.update = update2;
    this.view = view2;
    this.on_attribute_change = on_attribute_change;
  }
};
var ElementNotFound = class extends CustomType {
  constructor(selector) {
    super();
    this.selector = selector;
  }
};
var NotABrowser = class extends CustomType {
};
function application(init4, update2, view2) {
  return new App(init4, update2, view2, new None2());
}
function start3(app, selector, flags) {
  return guard(
    !is_browser(),
    new Error(new NotABrowser()),
    () => {
      return start(app, selector, flags);
    }
  );
}

// build/dev/javascript/lustre/lustre/element/html.mjs
function h1(attrs, children) {
  return element("h1", attrs, children);
}
function h3(attrs, children) {
  return element("h3", attrs, children);
}
function nav(attrs, children) {
  return element("nav", attrs, children);
}
function dd(attrs, children) {
  return element("dd", attrs, children);
}
function div(attrs, children) {
  return element("div", attrs, children);
}
function dl(attrs, children) {
  return element("dl", attrs, children);
}
function dt(attrs, children) {
  return element("dt", attrs, children);
}
function hr(attrs) {
  return element("hr", attrs, toList([]));
}
function p(attrs, children) {
  return element("p", attrs, children);
}
function a(attrs, children) {
  return element("a", attrs, children);
}
function span(attrs, children) {
  return element("span", attrs, children);
}
function table(attrs, children) {
  return element("table", attrs, children);
}
function tbody(attrs, children) {
  return element("tbody", attrs, children);
}
function td(attrs, children) {
  return element("td", attrs, children);
}
function th(attrs, children) {
  return element("th", attrs, children);
}
function thead(attrs, children) {
  return element("thead", attrs, children);
}
function tr(attrs, children) {
  return element("tr", attrs, children);
}
function button(attrs, children) {
  return element("button", attrs, children);
}
function form(attrs, children) {
  return element("form", attrs, children);
}
function input(attrs) {
  return element("input", attrs, toList([]));
}
function label(attrs, children) {
  return element("label", attrs, children);
}

// build/dev/javascript/modem/modem.ffi.mjs
var defaults = {
  handle_external_links: false,
  handle_internal_links: true
};
var initial_location = globalThis.window && window?.location?.href;
var do_initial_uri = () => {
  if (!initial_location) {
    return new Error(void 0);
  } else {
    return new Ok(uri_from_url(new URL(initial_location)));
  }
};
var do_init = (dispatch, options = defaults) => {
  document.addEventListener("click", (event2) => {
    const a2 = find_anchor(event2.target);
    if (!a2)
      return;
    try {
      const url = new URL(a2.href);
      const uri = uri_from_url(url);
      const is_external = url.host !== window.location.host;
      if (!options.handle_external_links && is_external)
        return;
      if (!options.handle_internal_links && !is_external)
        return;
      event2.preventDefault();
      if (!is_external) {
        window.history.pushState({}, "", a2.href);
        window.requestAnimationFrame(() => {
          if (url.hash) {
            document.getElementById(url.hash.slice(1))?.scrollIntoView();
          }
        });
      }
      return dispatch(uri);
    } catch {
      return;
    }
  });
  window.addEventListener("popstate", (e) => {
    e.preventDefault();
    const url = new URL(window.location.href);
    const uri = uri_from_url(url);
    window.requestAnimationFrame(() => {
      if (url.hash) {
        document.getElementById(url.hash.slice(1))?.scrollIntoView();
      }
    });
    dispatch(uri);
  });
  window.addEventListener("modem-push", ({ detail }) => {
    dispatch(detail);
  });
  window.addEventListener("modem-replace", ({ detail }) => {
    dispatch(detail);
  });
};
var do_push = (uri) => {
  window.history.pushState({}, "", to_string4(uri));
  window.requestAnimationFrame(() => {
    if (uri.fragment[0]) {
      document.getElementById(uri.fragment[0])?.scrollIntoView();
    }
  });
  window.dispatchEvent(new CustomEvent("modem-push", { detail: uri }));
};
var find_anchor = (el2) => {
  if (!el2 || el2.tagName === "BODY") {
    return null;
  } else if (el2.tagName === "A") {
    return el2;
  } else {
    return find_anchor(el2.parentElement);
  }
};
var uri_from_url = (url) => {
  return new Uri(
    /* scheme   */
    url.protocol ? new Some2(url.protocol.slice(0, -1)) : new None2(),
    /* userinfo */
    new None2(),
    /* host     */
    url.hostname ? new Some2(url.hostname) : new None2(),
    /* port     */
    url.port ? new Some2(Number(url.port)) : new None2(),
    /* path     */
    url.pathname,
    /* query    */
    url.search ? new Some2(url.search.slice(1)) : new None2(),
    /* fragment */
    url.hash ? new Some2(url.hash.slice(1)) : new None2()
  );
};

// build/dev/javascript/modem/modem.mjs
function init2(handler) {
  return from(
    (dispatch) => {
      return guard(
        !is_browser(),
        void 0,
        () => {
          return do_init(
            (uri) => {
              let _pipe = uri;
              let _pipe$1 = handler(_pipe);
              return dispatch(_pipe$1);
            }
          );
        }
      );
    }
  );
}
var relative = /* @__PURE__ */ new Uri(
  /* @__PURE__ */ new None2(),
  /* @__PURE__ */ new None2(),
  /* @__PURE__ */ new None2(),
  /* @__PURE__ */ new None2(),
  "",
  /* @__PURE__ */ new None2(),
  /* @__PURE__ */ new None2()
);
function push(path, query, fragment) {
  return from(
    (_) => {
      return guard(
        !is_browser(),
        void 0,
        () => {
          return do_push(
            relative.withFields({ path, query, fragment })
          );
        }
      );
    }
  );
}

// build/dev/javascript/gleam_http/gleam/http.mjs
var Get = class extends CustomType {
};
var Post = class extends CustomType {
};
var Head = class extends CustomType {
};
var Put = class extends CustomType {
};
var Delete = class extends CustomType {
};
var Trace = class extends CustomType {
};
var Connect = class extends CustomType {
};
var Options2 = class extends CustomType {
};
var Patch = class extends CustomType {
};
var Http = class extends CustomType {
};
var Https = class extends CustomType {
};
function method_to_string(method) {
  if (method instanceof Connect) {
    return "connect";
  } else if (method instanceof Delete) {
    return "delete";
  } else if (method instanceof Get) {
    return "get";
  } else if (method instanceof Head) {
    return "head";
  } else if (method instanceof Options2) {
    return "options";
  } else if (method instanceof Patch) {
    return "patch";
  } else if (method instanceof Post) {
    return "post";
  } else if (method instanceof Put) {
    return "put";
  } else if (method instanceof Trace) {
    return "trace";
  } else {
    let s = method[0];
    return s;
  }
}
function scheme_to_string(scheme) {
  if (scheme instanceof Http) {
    return "http";
  } else {
    return "https";
  }
}
function scheme_from_string(scheme) {
  let $ = lowercase2(scheme);
  if ($ === "http") {
    return new Ok(new Http());
  } else if ($ === "https") {
    return new Ok(new Https());
  } else {
    return new Error(void 0);
  }
}

// build/dev/javascript/gleam_http/gleam/http/request.mjs
var Request = class extends CustomType {
  constructor(method, headers, body, scheme, host, port, path, query) {
    super();
    this.method = method;
    this.headers = headers;
    this.body = body;
    this.scheme = scheme;
    this.host = host;
    this.port = port;
    this.path = path;
    this.query = query;
  }
};
function to_uri(request) {
  return new Uri(
    new Some2(scheme_to_string(request.scheme)),
    new None2(),
    new Some2(request.host),
    request.port,
    request.path,
    request.query,
    new None2()
  );
}
function from_uri(uri) {
  return then$(
    (() => {
      let _pipe = uri.scheme;
      let _pipe$1 = unwrap(_pipe, "");
      return scheme_from_string(_pipe$1);
    })(),
    (scheme) => {
      return then$(
        (() => {
          let _pipe = uri.host;
          return to_result(_pipe, void 0);
        })(),
        (host) => {
          let req = new Request(
            new Get(),
            toList([]),
            "",
            scheme,
            host,
            uri.port,
            uri.path,
            uri.query
          );
          return new Ok(req);
        }
      );
    }
  );
}
function set_header(request, key, value4) {
  let headers = key_set(request.headers, lowercase2(key), value4);
  return request.withFields({ headers });
}
function set_body(req, body) {
  let method = req.method;
  let headers = req.headers;
  let scheme = req.scheme;
  let host = req.host;
  let port = req.port;
  let path = req.path;
  let query = req.query;
  return new Request(method, headers, body, scheme, host, port, path, query);
}
function set_method(req, method) {
  return req.withFields({ method });
}
function new$4() {
  return new Request(
    new Get(),
    toList([]),
    "",
    new Https(),
    "localhost",
    new None2(),
    "",
    new None2()
  );
}
function to(url) {
  let _pipe = url;
  let _pipe$1 = parse2(_pipe);
  return then$(_pipe$1, from_uri);
}

// build/dev/javascript/gleam_http/gleam/http/response.mjs
var Response = class extends CustomType {
  constructor(status, headers, body) {
    super();
    this.status = status;
    this.headers = headers;
    this.body = body;
  }
};

// build/dev/javascript/gleam_javascript/gleam_javascript_ffi.mjs
var PromiseLayer = class _PromiseLayer {
  constructor(promise) {
    this.promise = promise;
  }
  static wrap(value4) {
    return value4 instanceof Promise ? new _PromiseLayer(value4) : value4;
  }
  static unwrap(value4) {
    return value4 instanceof _PromiseLayer ? value4.promise : value4;
  }
};
function resolve(value4) {
  return Promise.resolve(PromiseLayer.wrap(value4));
}
function then_await(promise, fn) {
  return promise.then((value4) => fn(PromiseLayer.unwrap(value4)));
}
function map_promise(promise, fn) {
  return promise.then(
    (value4) => PromiseLayer.wrap(fn(PromiseLayer.unwrap(value4)))
  );
}
function rescue(promise, fn) {
  return promise.catch((error) => fn(error));
}

// build/dev/javascript/gleam_javascript/gleam/javascript/promise.mjs
function tap(promise, callback) {
  let _pipe = promise;
  return map_promise(
    _pipe,
    (a2) => {
      callback(a2);
      return a2;
    }
  );
}
function try_await(promise, callback) {
  let _pipe = promise;
  return then_await(
    _pipe,
    (result) => {
      if (result.isOk()) {
        let a2 = result[0];
        return callback(a2);
      } else {
        let e = result[0];
        return resolve(new Error(e));
      }
    }
  );
}

// build/dev/javascript/gleam_fetch/ffi.mjs
async function raw_send(request) {
  try {
    return new Ok(await fetch(request));
  } catch (error) {
    return new Error(new NetworkError(error.toString()));
  }
}
function from_fetch_response(response) {
  return new Response(
    response.status,
    List.fromArray([...response.headers]),
    response
  );
}
function to_fetch_request(request) {
  let url = to_string4(to_uri(request));
  let method = method_to_string(request.method).toUpperCase();
  let options = {
    headers: make_headers(request.headers),
    method
  };
  if (method !== "GET" && method !== "HEAD")
    options.body = request.body;
  return new globalThis.Request(url, options);
}
function make_headers(headersList) {
  let headers = new globalThis.Headers();
  for (let [k, v] of headersList)
    headers.append(k.toLowerCase(), v);
  return headers;
}
async function read_text_body(response) {
  let body;
  try {
    body = await response.body.text();
  } catch (error) {
    return new Error(new UnableToReadBody());
  }
  return new Ok(response.withFields({ body }));
}

// build/dev/javascript/gleam_fetch/gleam/fetch.mjs
var NetworkError = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var UnableToReadBody = class extends CustomType {
};
function send(request) {
  let _pipe = request;
  let _pipe$1 = to_fetch_request(_pipe);
  let _pipe$2 = raw_send(_pipe$1);
  return try_await(
    _pipe$2,
    (resp) => {
      return resolve(new Ok(from_fetch_response(resp)));
    }
  );
}

// build/dev/javascript/lustre_http/lustre_http.mjs
var BadUrl = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var InternalServerError = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var JsonError = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var NetworkError2 = class extends CustomType {
};
var NotFound = class extends CustomType {
};
var OtherError = class extends CustomType {
  constructor(x0, x1) {
    super();
    this[0] = x0;
    this[1] = x1;
  }
};
var Unauthorized = class extends CustomType {
};
var ExpectTextResponse = class extends CustomType {
  constructor(run) {
    super();
    this.run = run;
  }
};
function do_send(req, expect, dispatch) {
  let _pipe = send(req);
  let _pipe$1 = try_await(_pipe, read_text_body);
  let _pipe$2 = map_promise(
    _pipe$1,
    (response) => {
      if (response.isOk()) {
        let res = response[0];
        return expect.run(new Ok(res));
      } else {
        return expect.run(new Error(new NetworkError2()));
      }
    }
  );
  let _pipe$3 = rescue(
    _pipe$2,
    (_) => {
      return expect.run(new Error(new NetworkError2()));
    }
  );
  tap(_pipe$3, dispatch);
  return void 0;
}
function get2(url, expect) {
  return from(
    (dispatch) => {
      let $ = to(url);
      if ($.isOk()) {
        let req = $[0];
        return do_send(req, expect, dispatch);
      } else {
        return dispatch(expect.run(new Error(new BadUrl(url))));
      }
    }
  );
}
function post(url, body, expect) {
  return from(
    (dispatch) => {
      let $ = to(url);
      if ($.isOk()) {
        let req = $[0];
        let _pipe = req;
        let _pipe$1 = set_method(_pipe, new Post());
        let _pipe$2 = set_header(
          _pipe$1,
          "Content-Type",
          "application/json"
        );
        let _pipe$3 = set_body(_pipe$2, to_string6(body));
        return do_send(_pipe$3, expect, dispatch);
      } else {
        return dispatch(expect.run(new Error(new BadUrl(url))));
      }
    }
  );
}
function send2(req, expect) {
  return from((_capture) => {
    return do_send(req, expect, _capture);
  });
}
function response_to_result(response) {
  if (response instanceof Response && (200 <= response.status && response.status <= 299)) {
    let status = response.status;
    let body = response.body;
    return new Ok(body);
  } else if (response instanceof Response && response.status === 401) {
    return new Error(new Unauthorized());
  } else if (response instanceof Response && response.status === 404) {
    return new Error(new NotFound());
  } else if (response instanceof Response && response.status === 500) {
    let body = response.body;
    return new Error(new InternalServerError(body));
  } else {
    let code = response.status;
    let body = response.body;
    return new Error(new OtherError(code, body));
  }
}
function expect_anything(to_msg) {
  return new ExpectTextResponse(
    (response) => {
      let _pipe = response;
      let _pipe$1 = then$(_pipe, response_to_result);
      let _pipe$2 = replace(_pipe$1, void 0);
      return to_msg(_pipe$2);
    }
  );
}
function expect_json(decoder, to_msg) {
  return new ExpectTextResponse(
    (response) => {
      let _pipe = response;
      let _pipe$1 = then$(_pipe, response_to_result);
      let _pipe$2 = then$(
        _pipe$1,
        (body) => {
          let $ = decode2(body, decoder);
          if ($.isOk()) {
            let json = $[0];
            return new Ok(json);
          } else {
            let json_error = $[0];
            return new Error(new JsonError(json_error));
          }
        }
      );
      return to_msg(_pipe$2);
    }
  );
}

// build/dev/javascript/decode/decode_ffi.mjs
function index3(data, key) {
  const int4 = Number.isInteger(key);
  if (int4 && Array.isArray(data) || data && typeof data === "object" || Object.getPrototypeOf(data) === Object.prototype) {
    return new Ok(data[key]);
  }
  if (value instanceof Dict || value instanceof WeakMap || value instanceof Map) {
    const entry = map_get(value, name);
    return new Ok(entry.isOk() ? new Some(entry[0]) : new None());
  }
  if (Object.getPrototypeOf(value) == Object.prototype) {
    return try_get_field(value, name, () => new Ok(new None()));
  }
  return new Error(int4 ? "Indexable" : "Dict");
}

// build/dev/javascript/decode/decode.mjs
var Decoder = class extends CustomType {
  constructor(continuation) {
    super();
    this.continuation = continuation;
  }
};
function into(constructor) {
  return new Decoder((_) => {
    return new Ok(constructor);
  });
}
function parameter(body) {
  return body;
}
function from2(decoder, data) {
  return decoder.continuation(data);
}
var string3 = /* @__PURE__ */ new Decoder(string);
var int3 = /* @__PURE__ */ new Decoder(int);
function list2(item) {
  return new Decoder(list(item.continuation));
}
function optional2(item) {
  return new Decoder(optional(item.continuation));
}
function push_path2(errors, key) {
  let key$1 = identity(key);
  let decoder = any(
    toList([
      string,
      (x) => {
        return map3(int(x), to_string2);
      }
    ])
  );
  let key$2 = (() => {
    let $ = decoder(key$1);
    if ($.isOk()) {
      let key$22 = $[0];
      return key$22;
    } else {
      return "<" + classify(key$1) + ">";
    }
  })();
  return map2(
    errors,
    (error) => {
      return error.withFields({ path: prepend(key$2, error.path) });
    }
  );
}
function index4(key, inner, data) {
  let $ = index3(data, key);
  if ($.isOk()) {
    let data$1 = $[0];
    let $1 = inner(data$1);
    if ($1.isOk()) {
      let data$2 = $1[0];
      return new Ok(data$2);
    } else {
      let errors = $1[0];
      return new Error(push_path2(errors, key));
    }
  } else {
    let kind = $[0];
    return new Error(
      toList([new DecodeError(kind, classify(data), toList([]))])
    );
  }
}
function at(path, inner) {
  return new Decoder(
    (data) => {
      let decoder = fold_right(
        path,
        inner.continuation,
        (dyn_decoder, segment) => {
          return (_capture) => {
            return index4(segment, dyn_decoder, _capture);
          };
        }
      );
      return decoder(data);
    }
  );
}
function subfield(decoder, field_path, field_decoder) {
  return new Decoder(
    (data) => {
      let constructor = decoder.continuation(data);
      let data$1 = from2(at(field_path, field_decoder), data);
      if (constructor.isOk() && data$1.isOk()) {
        let constructor$1 = constructor[0];
        let data$2 = data$1[0];
        return new Ok(constructor$1(data$2));
      } else if (!constructor.isOk() && !data$1.isOk()) {
        let e1 = constructor[0];
        let e2 = data$1[0];
        return new Error(append(e1, e2));
      } else if (!data$1.isOk()) {
        let errors = data$1[0];
        return new Error(errors);
      } else {
        let errors = constructor[0];
        return new Error(errors);
      }
    }
  );
}
function field2(decoder, field_name, field_decoder) {
  return subfield(decoder, toList([field_name]), field_decoder);
}

// build/dev/javascript/shared/shared/auth_models.mjs
var LoginRequest = class extends CustomType {
  constructor(email, password) {
    super();
    this.email = email;
    this.password = password;
  }
};
function default_login_request() {
  return new LoginRequest("test@example.com", "password");
}
function login_request_encoder(data) {
  return object2(
    toList([
      ["email", string2(data.email)],
      ["password", string2(data.password)]
    ])
  );
}

// build/dev/javascript/shared/shared/id.mjs
var Id = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
function id_decoder() {
  let _pipe = into(parameter((id) => {
    return new Id(id);
  }));
  return field2(_pipe, "id", string3);
}
function id_value(id) {
  let value4 = id[0];
  return value4;
}

// build/dev/javascript/shared/shared/trip_models.mjs
var UserTrip = class extends CustomType {
  constructor(trip_id, destination, start_date, end_date, places_count) {
    super();
    this.trip_id = trip_id;
    this.destination = destination;
    this.start_date = start_date;
    this.end_date = end_date;
    this.places_count = places_count;
  }
};
var UserTrips = class extends CustomType {
  constructor(user_trips) {
    super();
    this.user_trips = user_trips;
  }
};
var UserTripPlace = class extends CustomType {
  constructor(trip_place_id, name3, date, google_maps_link) {
    super();
    this.trip_place_id = trip_place_id;
    this.name = name3;
    this.date = date;
    this.google_maps_link = google_maps_link;
  }
};
var UserTripPlaces = class extends CustomType {
  constructor(trip_id, destination, start_date, end_date, user_trip_places) {
    super();
    this.trip_id = trip_id;
    this.destination = destination;
    this.start_date = start_date;
    this.end_date = end_date;
    this.user_trip_places = user_trip_places;
  }
};
var CreateTripRequest = class extends CustomType {
  constructor(destination, start_date, end_date) {
    super();
    this.destination = destination;
    this.start_date = start_date;
    this.end_date = end_date;
  }
};
var CreateTripPlaceRequest = class extends CustomType {
  constructor(place, date, google_maps_link) {
    super();
    this.place = place;
    this.date = date;
    this.google_maps_link = google_maps_link;
  }
};
function user_trip_decoder() {
  let _pipe = into(
    parameter(
      (trip_id) => {
        return parameter(
          (destination) => {
            return parameter(
              (start_date) => {
                return parameter(
                  (end_date) => {
                    return parameter(
                      (places_count) => {
                        return new UserTrip(
                          trip_id,
                          destination,
                          start_date,
                          end_date,
                          places_count
                        );
                      }
                    );
                  }
                );
              }
            );
          }
        );
      }
    )
  );
  let _pipe$1 = field2(_pipe, "trip_id", string3);
  let _pipe$2 = field2(_pipe$1, "destination", string3);
  let _pipe$3 = field2(_pipe$2, "start_date", string3);
  let _pipe$4 = field2(_pipe$3, "end_date", string3);
  return field2(_pipe$4, "places_count", int3);
}
function default_user_trips() {
  return new UserTrips(toList([]));
}
function user_trips_decoder() {
  let _pipe = into(
    parameter((user_trips) => {
      return new UserTrips(user_trips);
    })
  );
  return field2(_pipe, "user_trips", list2(user_trip_decoder()));
}
function default_user_trip_places() {
  return new UserTripPlaces("", "", "", "", toList([]));
}
function user_trip_place_decoder() {
  let _pipe = into(
    parameter(
      (trip_place_id) => {
        return parameter(
          (name3) => {
            return parameter(
              (date) => {
                return parameter(
                  (google_maps_link) => {
                    return new UserTripPlace(
                      trip_place_id,
                      name3,
                      date,
                      google_maps_link
                    );
                  }
                );
              }
            );
          }
        );
      }
    )
  );
  let _pipe$1 = field2(_pipe, "trip_place_id", string3);
  let _pipe$2 = field2(_pipe$1, "name", string3);
  let _pipe$3 = field2(_pipe$2, "date", string3);
  return field2(
    _pipe$3,
    "google_maps_link",
    optional2(string3)
  );
}
function user_trip_places_decoder() {
  let _pipe = into(
    parameter(
      (trip_id) => {
        return parameter(
          (destination) => {
            return parameter(
              (start_date) => {
                return parameter(
                  (end_date) => {
                    return parameter(
                      (user_trip_places) => {
                        return new UserTripPlaces(
                          trip_id,
                          destination,
                          start_date,
                          end_date,
                          user_trip_places
                        );
                      }
                    );
                  }
                );
              }
            );
          }
        );
      }
    )
  );
  let _pipe$1 = field2(_pipe, "trip_id", string3);
  let _pipe$2 = field2(_pipe$1, "destination", string3);
  let _pipe$3 = field2(_pipe$2, "start_date", string3);
  let _pipe$4 = field2(_pipe$3, "end_date", string3);
  return field2(
    _pipe$4,
    "user_trip_places",
    list2(user_trip_place_decoder())
  );
}
function default_create_trip_request() {
  return new CreateTripRequest("", "", "");
}
function create_trip_request_encoder(data) {
  return object2(
    toList([
      ["destination", string2(data.destination)],
      ["start_date", string2(data.start_date)],
      ["end_date", string2(data.end_date)]
    ])
  );
}
function default_create_trip_place_request() {
  return new CreateTripPlaceRequest("", "", new None2());
}
function create_trip_place_request_encoder(data) {
  return object2(
    toList([
      ["place", string2(data.place)],
      ["date", string2(data.date)],
      ["google_maps_link", nullable(data.google_maps_link, string2)]
    ])
  );
}

// build/dev/javascript/frontend/frontend/routes.mjs
var Login = class extends CustomType {
};
var Signup = class extends CustomType {
};
var TripsDashboard = class extends CustomType {
};
var TripDetails = class extends CustomType {
  constructor(trip_id) {
    super();
    this.trip_id = trip_id;
  }
};
var TripPlaceCreate = class extends CustomType {
  constructor(trip_id) {
    super();
    this.trip_id = trip_id;
  }
};
var TripCreate = class extends CustomType {
};
var FourOFour = class extends CustomType {
};

// build/dev/javascript/frontend/frontend/events.mjs
var OnRouteChange = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var LoginPage = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var TripsDashboardPage = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var TripDetailsPage = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var TripCreatePage = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var TripPlaceCreatePage = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var AppModel = class extends CustomType {
  constructor(route, show_loading, login_request, trips_dashboard, trip_details, trip_create, trip_create_errors, trip_place_create, trip_place_create_errors) {
    super();
    this.route = route;
    this.show_loading = show_loading;
    this.login_request = login_request;
    this.trips_dashboard = trips_dashboard;
    this.trip_details = trip_details;
    this.trip_create = trip_create;
    this.trip_create_errors = trip_create_errors;
    this.trip_place_create = trip_place_create;
    this.trip_place_create_errors = trip_place_create_errors;
  }
};
var LoginPageUserUpdatedEmail = class extends CustomType {
  constructor(email) {
    super();
    this.email = email;
  }
};
var LoginPageUserUpdatedPassword = class extends CustomType {
  constructor(password) {
    super();
    this.password = password;
  }
};
var LoginPageUserClickedSubmit = class extends CustomType {
};
var LoginPageApiReturnedResponse = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var TripsDashboardPageUserClickedCreateTripButton = class extends CustomType {
};
var TripsDashboardPageApiReturnedTrips = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var TripDetailsPageApiReturnedTripDetails = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var TripDetailsPageUserClickedRemovePlace = class extends CustomType {
  constructor(trip_place_id) {
    super();
    this.trip_place_id = trip_place_id;
  }
};
var TripDetailsPageUserClickedCreatePlace = class extends CustomType {
  constructor(trip_place_id) {
    super();
    this.trip_place_id = trip_place_id;
  }
};
var TripCreatePageUserInputCreateTripRequest = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var TripCreatePageUserClickedCreateTrip = class extends CustomType {
};
var TripCreatePageApiReturnedResponse = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var TripPlaceCreatePageApiReturnedResponse = class extends CustomType {
  constructor(trip_id, x1) {
    super();
    this.trip_id = trip_id;
    this[1] = x1;
  }
};
var TripPlaceCreatePageUserInputCreateTripPlaceRequest = class extends CustomType {
  constructor(x0) {
    super();
    this[0] = x0;
  }
};
var TripPlaceCreatePageUserClickedSubmit = class extends CustomType {
  constructor(trip_id) {
    super();
    this.trip_id = trip_id;
  }
};
function default_app_model() {
  return new AppModel(
    new Login(),
    false,
    default_login_request(),
    default_user_trips(),
    default_user_trip_places(),
    default_create_trip_request(),
    "",
    default_create_trip_place_request(),
    ""
  );
}

// build/dev/javascript/lustre/lustre/event.mjs
function on2(name3, handler) {
  return on(name3, handler);
}
function on_click(msg) {
  return on2("click", (_) => {
    return new Ok(msg);
  });
}
function value3(event2) {
  let _pipe = event2;
  return field("target", field("value", string))(
    _pipe
  );
}
function on_input(msg) {
  return on2(
    "input",
    (event2) => {
      let _pipe = value3(event2);
      return map3(_pipe, msg);
    }
  );
}

// build/dev/javascript/frontend/frontend/pages/login_page.mjs
function login_view(app_model) {
  return div(
    toList([]),
    toList([
      h3(
        toList([class$("text-cursive")]),
        toList([text("Login")])
      ),
      div(
        toList([]),
        toList([
          label(toList([]), toList([text("Email")])),
          input(
            toList([
              on_input(
                (input2) => {
                  return new LoginPage(
                    new LoginPageUserUpdatedEmail(input2)
                  );
                }
              ),
              value2(app_model.login_request.email),
              name2("email"),
              type_("email")
            ])
          )
        ])
      ),
      div(
        toList([]),
        toList([
          label(toList([]), toList([text("Password")])),
          input(
            toList([
              on_input(
                (input2) => {
                  return new LoginPage(
                    new LoginPageUserUpdatedPassword(input2)
                  );
                }
              ),
              value2(app_model.login_request.password),
              name2("password"),
              type_("password")
            ])
          )
        ])
      ),
      button(
        toList([
          on_click(
            new LoginPage(new LoginPageUserClickedSubmit())
          )
        ]),
        toList([text("Submit")])
      )
    ])
  );
}
function handle_submit_login(login_request) {
  let url = "http://localhost:8080/api/login";
  let json = login_request_encoder(login_request);
  return post(
    url,
    json,
    expect_json(
      (response) => {
        let _pipe = id_decoder();
        return from2(_pipe, response);
      },
      (result) => {
        if (result.isOk()) {
          let user_id = result[0];
          return new LoginPage(
            new LoginPageApiReturnedResponse(user_id)
          );
        } else {
          return new OnRouteChange(new Login());
        }
      }
    )
  );
}
function handle_login_page_event(model, event2) {
  if (event2 instanceof LoginPageUserUpdatedEmail) {
    let email = event2.email;
    return [
      model.withFields({
        login_request: model.login_request.withFields({ email })
      }),
      none()
    ];
  } else if (event2 instanceof LoginPageUserUpdatedPassword) {
    let password = event2.password;
    return [
      model.withFields({
        login_request: model.login_request.withFields({ password })
      }),
      none()
    ];
  } else if (event2 instanceof LoginPageUserClickedSubmit) {
    return [
      model.withFields({ show_loading: true }),
      handle_submit_login(model.login_request)
    ];
  } else {
    return [
      model.withFields({ show_loading: false }),
      push("/dashboard", new None2(), new None2())
    ];
  }
}

// build/dev/javascript/frontend/frontend/pages/trip_create_page.mjs
function trip_create_view(app_model) {
  return div(
    toList([]),
    toList([
      h1(toList([]), toList([text("Create a New Trip")])),
      form(
        toList([]),
        toList([
          p(
            toList([]),
            toList([
              label(toList([]), toList([text("From")])),
              input(
                toList([
                  on_input(
                    (start_date) => {
                      return new TripCreatePage(
                        new TripCreatePageUserInputCreateTripRequest(
                          app_model.trip_create.withFields({
                            start_date
                          })
                        )
                      );
                    }
                  ),
                  name2("from"),
                  type_("date"),
                  required(true),
                  value2(app_model.trip_create.start_date)
                ])
              ),
              span(toList([class$("validity")]), toList([]))
            ])
          ),
          p(
            toList([]),
            toList([
              label(toList([]), toList([text("To")])),
              input(
                toList([
                  on_input(
                    (end_date) => {
                      return new TripCreatePage(
                        new TripCreatePageUserInputCreateTripRequest(
                          app_model.trip_create.withFields({ end_date })
                        )
                      );
                    }
                  ),
                  min(app_model.trip_create.start_date),
                  name2("to"),
                  type_("date"),
                  required(true),
                  value2(app_model.trip_create.end_date)
                ])
              ),
              span(toList([class$("validity")]), toList([]))
            ])
          ),
          p(
            toList([]),
            toList([
              label(toList([]), toList([text("Destination")])),
              input(
                toList([
                  on_input(
                    (destination) => {
                      return new TripCreatePage(
                        new TripCreatePageUserInputCreateTripRequest(
                          app_model.trip_create.withFields({
                            destination
                          })
                        )
                      );
                    }
                  ),
                  name2("destination"),
                  placeholder("Where are you going?"),
                  type_("text"),
                  required(true),
                  value2(app_model.trip_create.destination)
                ])
              ),
              span(toList([class$("validity")]), toList([]))
            ])
          )
        ])
      ),
      div(
        toList([]),
        toList([text(app_model.trip_create_errors)])
      ),
      button(
        toList([
          on_click(
            new TripCreatePage(
              new TripCreatePageUserClickedCreateTrip()
            )
          )
        ]),
        toList([text("Create Trip")])
      )
    ])
  );
}
function handle_create_trip(create_trip_request) {
  let url = "http://localhost:8080/api/trips";
  let json = create_trip_request_encoder(create_trip_request);
  return post(
    url,
    json,
    expect_json(
      (response) => {
        let _pipe = id_decoder();
        return from2(_pipe, response);
      },
      (result) => {
        return new TripCreatePage(
          new TripCreatePageApiReturnedResponse(result)
        );
      }
    )
  );
}
function handle_trip_create_page_event(model, event2) {
  if (event2 instanceof TripCreatePageUserInputCreateTripRequest) {
    let create_trip_request = event2[0];
    return [
      model.withFields({ trip_create: create_trip_request }),
      none()
    ];
  } else if (event2 instanceof TripCreatePageUserClickedCreateTrip) {
    return [model, handle_create_trip(model.trip_create)];
  } else {
    let response = event2[0];
    if (response.isOk()) {
      let trip_id = response[0];
      let trip_id$1 = id_value(trip_id);
      return [
        model.withFields({
          trip_create: default_create_trip_request(),
          trip_create_errors: ""
        }),
        push(
          "/trips/" + trip_id$1,
          new None2(),
          new None2()
        )
      ];
    } else {
      let e = response[0];
      if (e instanceof OtherError && e[0] === 400) {
        let error = e[1];
        return [model.withFields({ trip_create_errors: error }), none()];
      } else if (e instanceof OtherError && e[0] === 401) {
        return [
          model,
          push("/login", new None2(), new None2())
        ];
      } else {
        return [model, none()];
      }
    }
  }
}

// build/dev/javascript/frontend/frontend/pages/trip_details_page.mjs
function trip_details_view(app_model) {
  return div(
    toList([]),
    toList([
      h1(
        toList([]),
        toList([
          text("Trip to "),
          span(
            toList([class$("text-cursive")]),
            toList([text(app_model.trip_details.destination)])
          )
        ])
      ),
      div(
        toList([]),
        toList([
          dl(
            toList([]),
            toList([
              dt(toList([]), toList([text("Dates")])),
              dd(
                toList([]),
                toList([
                  text(
                    app_model.trip_details.start_date + " to " + app_model.trip_details.end_date
                  )
                ])
              )
            ])
          )
        ])
      ),
      button(
        toList([
          on_click(
            new TripDetailsPage(
              new TripDetailsPageUserClickedCreatePlace(
                app_model.trip_details.trip_id
              )
            )
          )
        ]),
        toList([
          text(
            (() => {
              let $ = app_model.trip_details.user_trip_places;
              if ($.hasLength(0)) {
                return "Add First Place";
              } else {
                return "Add More Places";
              }
            })()
          )
        ])
      ),
      table(
        toList([]),
        toList([
          thead(
            toList([]),
            toList([
              tr(
                toList([]),
                toList([
                  th(toList([]), toList([text("Place")])),
                  th(toList([]), toList([text("Date")])),
                  th(toList([]), toList([text("Maps Link")])),
                  th(toList([]), toList([text("Actions")]))
                ])
              )
            ])
          ),
          tbody(
            toList([]),
            (() => {
              let _pipe = app_model.trip_details.user_trip_places;
              return map2(
                _pipe,
                (place) => {
                  return tr(
                    toList([]),
                    toList([
                      td(toList([]), toList([text(place.name)])),
                      td(toList([]), toList([text(place.date)])),
                      td(
                        toList([]),
                        toList([
                          (() => {
                            let $ = place.google_maps_link;
                            if ($ instanceof Some2) {
                              let v = $[0];
                              return a(
                                toList([
                                  href(v),
                                  target("_blank")
                                ]),
                                toList([text(v)])
                              );
                            } else {
                              return text("");
                            }
                          })()
                        ])
                      ),
                      td(
                        toList([]),
                        toList([
                          button(
                            toList([
                              on_click(
                                new TripDetailsPage(
                                  new TripDetailsPageUserClickedRemovePlace(
                                    place.trip_place_id
                                  )
                                )
                              )
                            ]),
                            toList([text("Remove")])
                          )
                        ])
                      )
                    ])
                  );
                }
              );
            })()
          )
        ])
      )
    ])
  );
}
function delete_trip_place(trip_id, trip_place_id) {
  let url = "http://localhost:8080/api/trips/" + trip_id + "/places/" + trip_place_id;
  let req = (() => {
    let _pipe2 = url;
    let _pipe$12 = to(_pipe2);
    return unwrap2(_pipe$12, new$4());
  })();
  let _pipe = req;
  let _pipe$1 = set_method(_pipe, new Delete());
  return send2(
    _pipe$1,
    expect_anything(
      (result) => {
        if (result.isOk()) {
          return new OnRouteChange(new TripDetails(trip_id));
        } else {
          return new OnRouteChange(new Login());
        }
      }
    )
  );
}
function handle_trip_details_page_event(model, event2) {
  if (event2 instanceof TripDetailsPageApiReturnedTripDetails) {
    let user_trip_places = event2[0];
    return [
      model.withFields({ trip_details: user_trip_places }),
      none()
    ];
  } else if (event2 instanceof TripDetailsPageUserClickedRemovePlace) {
    let trip_place_id = event2.trip_place_id;
    return [model, delete_trip_place(model.trip_details.trip_id, trip_place_id)];
  } else {
    let trip_id = event2.trip_place_id;
    return [
      model,
      push(
        "/trips/" + trip_id + "/places/create",
        new None2(),
        new None2()
      )
    ];
  }
}
function load_trip_details(trip_id) {
  let url = "http://localhost:8080/api/trips/" + trip_id + "/places";
  return get2(
    url,
    expect_json(
      (response) => {
        let _pipe = user_trip_places_decoder();
        return from2(_pipe, response);
      },
      (result) => {
        if (result.isOk()) {
          let user_trip_places = result[0];
          return new TripDetailsPage(
            new TripDetailsPageApiReturnedTripDetails(user_trip_places)
          );
        } else {
          return new OnRouteChange(new Login());
        }
      }
    )
  );
}

// build/dev/javascript/frontend/frontend/web.mjs
function post2(url, json, response_decoder, to_msg) {
  return post(
    url,
    json,
    expect_json(response_decoder, to_msg)
  );
}

// build/dev/javascript/frontend/frontend/pages/trip_place_create_page.mjs
function trip_place_create_view(app_model, trip_id) {
  return div(
    toList([]),
    toList([
      h1(toList([]), toList([text("Add a Place")])),
      form(
        toList([]),
        toList([
          p(
            toList([]),
            toList([
              label(toList([]), toList([text("Place")])),
              input(
                toList([
                  on_input(
                    (place) => {
                      return new TripPlaceCreatePage(
                        new TripPlaceCreatePageUserInputCreateTripPlaceRequest(
                          app_model.trip_place_create.withFields({ place })
                        )
                      );
                    }
                  ),
                  name2("place"),
                  required(true),
                  placeholder("Name of place"),
                  value2(app_model.trip_place_create.place)
                ])
              ),
              span(toList([class$("validity")]), toList([]))
            ])
          ),
          p(
            toList([]),
            toList([
              label(toList([]), toList([text("Date")])),
              input(
                toList([
                  on_input(
                    (date) => {
                      return new TripPlaceCreatePage(
                        new TripPlaceCreatePageUserInputCreateTripPlaceRequest(
                          app_model.trip_place_create.withFields({ date })
                        )
                      );
                    }
                  ),
                  min(app_model.trip_details.start_date),
                  max(app_model.trip_details.end_date),
                  name2("date"),
                  type_("date"),
                  required(true),
                  value2(app_model.trip_place_create.date)
                ])
              ),
              span(toList([class$("validity")]), toList([]))
            ])
          ),
          p(
            toList([]),
            toList([
              label(
                toList([]),
                toList([text("Google Maps Link")])
              ),
              input(
                toList([
                  on_input(
                    (google_maps_link) => {
                      return new TripPlaceCreatePage(
                        new TripPlaceCreatePageUserInputCreateTripPlaceRequest(
                          app_model.trip_place_create.withFields({
                            google_maps_link: new Some2(google_maps_link)
                          })
                        )
                      );
                    }
                  ),
                  name2("google_maps_link"),
                  placeholder("https://..."),
                  type_("text"),
                  required(true),
                  value2(
                    (() => {
                      let $ = app_model.trip_place_create.google_maps_link;
                      if ($ instanceof Some2) {
                        let val = $[0];
                        return val;
                      } else {
                        return "";
                      }
                    })()
                  )
                ])
              ),
              span(toList([class$("validity")]), toList([]))
            ])
          )
        ])
      ),
      div(
        toList([]),
        toList([text(app_model.trip_create_errors)])
      ),
      button(
        toList([
          on_click(
            new TripPlaceCreatePage(
              new TripPlaceCreatePageUserClickedSubmit(trip_id)
            )
          )
        ]),
        toList([text("Create Place")])
      )
    ])
  );
}
function handle_trip_place_create_page_event(model, event2) {
  if (event2 instanceof TripPlaceCreatePageUserInputCreateTripPlaceRequest) {
    let create_trip_place_request = event2[0];
    return [
      model.withFields({ trip_place_create: create_trip_place_request }),
      none()
    ];
  } else if (event2 instanceof TripPlaceCreatePageApiReturnedResponse) {
    let trip_id = event2.trip_id;
    let response = event2[1];
    if (response.isOk()) {
      return [
        model.withFields({
          trip_place_create: default_create_trip_place_request()
        }),
        push("/trips/" + trip_id, new None2(), new None2())
      ];
    } else {
      return [model, none()];
    }
  } else {
    let trip_id = event2.trip_id;
    return [
      model,
      post2(
        "http://localhost:8080/api/trips/" + trip_id + "/places",
        create_trip_place_request_encoder(model.trip_place_create),
        (response) => {
          let _pipe = id_decoder();
          return from2(_pipe, response);
        },
        (decode_result2) => {
          return new TripPlaceCreatePage(
            new TripPlaceCreatePageApiReturnedResponse(
              trip_id,
              decode_result2
            )
          );
        }
      )
    ];
  }
}

// build/dev/javascript/frontend/frontend/pages/trips_dashboard_page.mjs
function trips_dashboard_view(app_model) {
  return div(
    toList([]),
    toList([
      h1(
        toList([]),
        toList([
          text("Planned"),
          span(
            toList([class$("text-cursive")]),
            toList([text(" Trips \u{1F334}")])
          )
        ])
      ),
      button(
        toList([
          on_click(
            new TripsDashboardPage(
              new TripsDashboardPageUserClickedCreateTripButton()
            )
          )
        ]),
        toList([
          text(
            (() => {
              let $ = app_model.trips_dashboard.user_trips;
              if ($.hasLength(0)) {
                return "Create Your First Trip";
              } else {
                return "Create New Trip";
              }
            })()
          )
        ])
      ),
      table(
        toList([]),
        toList([
          thead(
            toList([]),
            toList([
              tr(
                toList([]),
                toList([
                  th(toList([]), toList([text("Destination")])),
                  th(toList([]), toList([text("From")])),
                  th(toList([]), toList([text("Until")])),
                  th(
                    toList([]),
                    toList([text("Number of places")])
                  )
                ])
              )
            ])
          ),
          tbody(
            toList([]),
            (() => {
              let _pipe = app_model.trips_dashboard.user_trips;
              return map2(
                _pipe,
                (user_trip) => {
                  return tr(
                    toList([]),
                    toList([
                      td(
                        toList([]),
                        toList([
                          a(
                            toList([
                              href("trips/" + user_trip.trip_id)
                            ]),
                            toList([text(user_trip.destination)])
                          )
                        ])
                      ),
                      td(
                        toList([]),
                        toList([text(user_trip.start_date)])
                      ),
                      td(
                        toList([]),
                        toList([text(user_trip.end_date)])
                      ),
                      td(
                        toList([]),
                        toList([
                          text(to_string2(user_trip.places_count))
                        ])
                      )
                    ])
                  );
                }
              );
            })()
          )
        ])
      )
    ])
  );
}
function handle_trips_dashboard_page_event(model, event2) {
  if (event2 instanceof TripsDashboardPageUserClickedCreateTripButton) {
    return [
      model,
      push("/trips/create", new None2(), new None2())
    ];
  } else {
    let user_trips = event2[0];
    return [
      model.withFields({ trips_dashboard: user_trips, show_loading: false }),
      none()
    ];
  }
}
function load_trips_dashboard() {
  let url = "http://localhost:8080/api/trips";
  return get2(
    url,
    expect_json(
      (response) => {
        let _pipe = user_trips_decoder();
        return from2(_pipe, response);
      },
      (result) => {
        if (result.isOk()) {
          let user_trips = result[0];
          return new TripsDashboardPage(
            new TripsDashboardPageApiReturnedTrips(user_trips)
          );
        } else {
          return new OnRouteChange(new Login());
        }
      }
    )
  );
}

// build/dev/javascript/frontend/frontend.mjs
function path_to_route(path_segments2) {
  if (path_segments2.hasLength(1) && path_segments2.head === "login") {
    return new Login();
  } else if (path_segments2.hasLength(1) && path_segments2.head === "signup") {
    return new Signup();
  } else if (path_segments2.hasLength(1) && path_segments2.head === "dashboard") {
    return new TripsDashboard();
  } else if (path_segments2.hasLength(2) && path_segments2.head === "trips" && path_segments2.tail.head === "create") {
    return new TripCreate();
  } else if (path_segments2.hasLength(2) && path_segments2.head === "trips") {
    let trip_id = path_segments2.tail.head;
    return new TripDetails(trip_id);
  } else if (path_segments2.hasLength(4) && path_segments2.head === "trips" && path_segments2.tail.tail.head === "places" && path_segments2.tail.tail.tail.head === "create") {
    let trip_id = path_segments2.tail.head;
    return new TripPlaceCreate(trip_id);
  } else {
    return new FourOFour();
  }
}
function on_url_change(uri) {
  let route = (() => {
    let _pipe = uri.path;
    let _pipe$1 = path_segments(_pipe);
    return path_to_route(_pipe$1);
  })();
  return new OnRouteChange(route);
}
function init3(_) {
  let initial_uri = (() => {
    let $ = do_initial_uri();
    if ($.isOk()) {
      let uri = $[0];
      let _pipe = uri.path;
      let _pipe$1 = path_segments(_pipe);
      return path_to_route(_pipe$1);
    } else {
      return new Login();
    }
  })();
  return [
    default_app_model(),
    batch(
      toList([
        init2(on_url_change),
        from(
          (dispatch) => {
            return dispatch(new OnRouteChange(initial_uri));
          }
        )
      ])
    )
  ];
}
function update(model, msg) {
  if (msg instanceof OnRouteChange) {
    let route = msg[0];
    return [
      model.withFields({ route }),
      (() => {
        if (route instanceof TripsDashboard) {
          return load_trips_dashboard();
        } else if (route instanceof TripDetails) {
          let trip_id = route.trip_id;
          return load_trip_details(trip_id);
        } else {
          return none();
        }
      })()
    ];
  } else if (msg instanceof LoginPage) {
    let event2 = msg[0];
    return handle_login_page_event(model, event2);
  } else if (msg instanceof TripsDashboardPage) {
    let event2 = msg[0];
    return handle_trips_dashboard_page_event(model, event2);
  } else if (msg instanceof TripDetailsPage) {
    let event2 = msg[0];
    return handle_trip_details_page_event(model, event2);
  } else if (msg instanceof TripCreatePage) {
    let event2 = msg[0];
    return handle_trip_create_page_event(model, event2);
  } else {
    let event2 = msg[0];
    return handle_trip_place_create_page_event(
      model,
      event2
    );
  }
}
function view(app_model) {
  return div(
    toList([]),
    toList([
      nav(
        toList([]),
        toList([
          a(
            toList([href("/dashboard")]),
            toList([text("Trips")])
          )
        ])
      ),
      hr(toList([])),
      (() => {
        let $ = app_model.route;
        if ($ instanceof Login) {
          return login_view(app_model);
        } else if ($ instanceof Signup) {
          return h1(toList([]), toList([text("Signup")]));
        } else if ($ instanceof TripsDashboard) {
          return trips_dashboard_view(app_model);
        } else if ($ instanceof TripDetails) {
          return trip_details_view(app_model);
        } else if ($ instanceof TripCreate) {
          return trip_create_view(app_model);
        } else if ($ instanceof TripPlaceCreate) {
          let trip_id = $.trip_id;
          return trip_place_create_view(
            app_model,
            trip_id
          );
        } else {
          return h1(toList([]), toList([text("Not Found")]));
        }
      })(),
      (() => {
        let $ = app_model.show_loading;
        if ($) {
          return div(
            toList([class$("loading-overlay")]),
            toList([
              div(
                toList([class$("loading-screen")]),
                toList([
                  div(toList([class$("spinner")]), toList([])),
                  p(toList([]), toList([text("Loading...")]))
                ])
              )
            ])
          );
        } else {
          return div(
            toList([class$("loading-screen-placeholder")]),
            toList([])
          );
        }
      })()
    ])
  );
}
function main() {
  let app = application(init3, update, view);
  let $ = start3(app, "#app", void 0);
  if (!$.isOk()) {
    throw makeError(
      "assignment_no_match",
      "frontend",
      18,
      "main",
      "Assignment pattern did not match",
      { value: $ }
    );
  }
  return $;
}

// build/.lustre/entry.mjs
main();
