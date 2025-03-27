extension String {
  package func lowerCamelCased() -> String {
    var prefix = prefix(while: \.isUppercase)
    if prefix.count > 1 { prefix = prefix.dropLast() }
    return prefix.lowercased() + dropFirst(prefix.count)
  }

  // This implementation is very basic but could be expanded to support more cases:
  // https://github.com/rails/rails/blob/main/activesupport/lib/active_support/inflections.rb
  package func pluralized() -> String {
    var bytes = self[...].utf8
    guard !bytes.isEmpty else { return self }

    switch bytes.removeLast() {
    case UInt8(ascii: "h"):
      switch bytes.last {
      case UInt8(ascii: "c"), UInt8(ascii: "s"):
        return "\(self)es"
      default:
        break
      }

    case UInt8(ascii: "s"):
      return "\(self)es"

    case UInt8(ascii: "y"):
      return "\(dropLast())ies"

    default:
      break
    }

    return "\(self)s"
  }
}
