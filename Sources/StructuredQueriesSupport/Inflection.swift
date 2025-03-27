extension String {
  package func lowerCamelCased() -> String {
    var prefix = prefix(while: \.isUppercase)
    if prefix.count > 1 { prefix = prefix.dropLast() }
    return prefix.lowercased() + dropFirst(prefix.count)
  }

  package func pluralized() -> String {
    var bytes = self[...].utf8
    guard !bytes.isEmpty else { return self }

    switch bytes.removeLast() {
    case UInt8(ascii: "h"):
      guard !bytes.isEmpty else { break }

      switch bytes.removeLast() {
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
