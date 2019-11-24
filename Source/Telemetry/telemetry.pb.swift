// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: telemetry.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that your are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

struct Telemetry_Position {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// UNIX time in Milliseconds
  var timestamp: UInt64 = 0

  /// The recorded latitude
  /// Decimal place requirement: 7 decimal places.
  var latitude: Double = 0

  /// The recorded longitude
  /// Decimal place requirement: 7 decimal places.
  var longitude: Double = 0

  /// Altitude above ground level, meters
  var altitudeAgl: Float = 0

  /// Altitude above mean sea level, meters (actually it is altitude of WGS84/GPS, the name msl is misleading)
  var altitudeMsl: Float = 0

  /// Horizontal Dilution of Precision, in meters
  var horizontalAccuracy: Float = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Telemetry_Attitude {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// UNIX time in Milliseconds
  var timestamp: UInt64 = 0

  /// Yaw angle measured from True North, { 0 <= x < 360 } degrees
  var yaw: Float = 0

  /// Pitch angle, { -180 < x <= 180 } degrees
  var pitch: Float = 0

  /// Roll angle, { -180 < x <= 180 } degrees
  var roll: Float = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Telemetry_Speed {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// UNIX time in Milliseconds
  var timestamp: UInt64 = 0

  /// Aircraft Speed in the x direction in meters per second using the North-East-Down (N-E-D) coordinate system
  var velocityX: Float = 0

  /// Aircraft Speed in the y direction in meters per second using the North-East-Down (N-E-D) coordinate system
  var velocityY: Float = 0

  /// Aircraft Speed in the z direction in meters per second using the North-East-Down (N-E-D) coordinate system
  var velocityZ: Float = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Telemetry_Barometer {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// UNIX time in Milliseconds
  var timestamp: UInt64 = 0

  /// Barometric pressure in hPa
  var pressure: Float = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "telemetry"

extension Telemetry_Position: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Position"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "timestamp"),
    2: .same(proto: "latitude"),
    3: .same(proto: "longitude"),
    4: .standard(proto: "altitude_agl"),
    5: .standard(proto: "altitude_msl"),
    6: .standard(proto: "horizontal_accuracy"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.timestamp)
      case 2: try decoder.decodeSingularDoubleField(value: &self.latitude)
      case 3: try decoder.decodeSingularDoubleField(value: &self.longitude)
      case 4: try decoder.decodeSingularFloatField(value: &self.altitudeAgl)
      case 5: try decoder.decodeSingularFloatField(value: &self.altitudeMsl)
      case 6: try decoder.decodeSingularFloatField(value: &self.horizontalAccuracy)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.timestamp != 0 {
      try visitor.visitSingularUInt64Field(value: self.timestamp, fieldNumber: 1)
    }
    if self.latitude != 0 {
      try visitor.visitSingularDoubleField(value: self.latitude, fieldNumber: 2)
    }
    if self.longitude != 0 {
      try visitor.visitSingularDoubleField(value: self.longitude, fieldNumber: 3)
    }
    if self.altitudeAgl != 0 {
      try visitor.visitSingularFloatField(value: self.altitudeAgl, fieldNumber: 4)
    }
    if self.altitudeMsl != 0 {
      try visitor.visitSingularFloatField(value: self.altitudeMsl, fieldNumber: 5)
    }
    if self.horizontalAccuracy != 0 {
      try visitor.visitSingularFloatField(value: self.horizontalAccuracy, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Telemetry_Position, rhs: Telemetry_Position) -> Bool {
    if lhs.timestamp != rhs.timestamp {return false}
    if lhs.latitude != rhs.latitude {return false}
    if lhs.longitude != rhs.longitude {return false}
    if lhs.altitudeAgl != rhs.altitudeAgl {return false}
    if lhs.altitudeMsl != rhs.altitudeMsl {return false}
    if lhs.horizontalAccuracy != rhs.horizontalAccuracy {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Telemetry_Attitude: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Attitude"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "timestamp"),
    2: .same(proto: "yaw"),
    3: .same(proto: "pitch"),
    4: .same(proto: "roll"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.timestamp)
      case 2: try decoder.decodeSingularFloatField(value: &self.yaw)
      case 3: try decoder.decodeSingularFloatField(value: &self.pitch)
      case 4: try decoder.decodeSingularFloatField(value: &self.roll)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.timestamp != 0 {
      try visitor.visitSingularUInt64Field(value: self.timestamp, fieldNumber: 1)
    }
    if self.yaw != 0 {
      try visitor.visitSingularFloatField(value: self.yaw, fieldNumber: 2)
    }
    if self.pitch != 0 {
      try visitor.visitSingularFloatField(value: self.pitch, fieldNumber: 3)
    }
    if self.roll != 0 {
      try visitor.visitSingularFloatField(value: self.roll, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Telemetry_Attitude, rhs: Telemetry_Attitude) -> Bool {
    if lhs.timestamp != rhs.timestamp {return false}
    if lhs.yaw != rhs.yaw {return false}
    if lhs.pitch != rhs.pitch {return false}
    if lhs.roll != rhs.roll {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Telemetry_Speed: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Speed"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "timestamp"),
    2: .standard(proto: "velocity_x"),
    3: .standard(proto: "velocity_y"),
    4: .standard(proto: "velocity_z"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.timestamp)
      case 2: try decoder.decodeSingularFloatField(value: &self.velocityX)
      case 3: try decoder.decodeSingularFloatField(value: &self.velocityY)
      case 4: try decoder.decodeSingularFloatField(value: &self.velocityZ)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.timestamp != 0 {
      try visitor.visitSingularUInt64Field(value: self.timestamp, fieldNumber: 1)
    }
    if self.velocityX != 0 {
      try visitor.visitSingularFloatField(value: self.velocityX, fieldNumber: 2)
    }
    if self.velocityY != 0 {
      try visitor.visitSingularFloatField(value: self.velocityY, fieldNumber: 3)
    }
    if self.velocityZ != 0 {
      try visitor.visitSingularFloatField(value: self.velocityZ, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Telemetry_Speed, rhs: Telemetry_Speed) -> Bool {
    if lhs.timestamp != rhs.timestamp {return false}
    if lhs.velocityX != rhs.velocityX {return false}
    if lhs.velocityY != rhs.velocityY {return false}
    if lhs.velocityZ != rhs.velocityZ {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Telemetry_Barometer: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Barometer"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "timestamp"),
    2: .same(proto: "pressure"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.timestamp)
      case 2: try decoder.decodeSingularFloatField(value: &self.pressure)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.timestamp != 0 {
      try visitor.visitSingularUInt64Field(value: self.timestamp, fieldNumber: 1)
    }
    if self.pressure != 0 {
      try visitor.visitSingularFloatField(value: self.pressure, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Telemetry_Barometer, rhs: Telemetry_Barometer) -> Bool {
    if lhs.timestamp != rhs.timestamp {return false}
    if lhs.pressure != rhs.pressure {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
