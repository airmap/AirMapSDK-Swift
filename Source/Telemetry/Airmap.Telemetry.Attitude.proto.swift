/// Generated by the Protocol Buffers 3.5.0 compiler.  DO NOT EDIT!
/// Protobuf-swift version: 4.0.0
/// Source file "attitude.proto"
/// Syntax "Proto3"

import Foundation
import ProtocolBuffers

public extension Airmap.Telemetry {
    public struct AttitudeRoot {
        public static let `default` = AttitudeRoot()
        public var extensionRegistry:ExtensionRegistry

        init() {
            extensionRegistry = ExtensionRegistry()
            registerAllExtensions(registry: extensionRegistry)
        }
        public func registerAllExtensions(registry: ExtensionRegistry) {
        }
    }

    final public class Attitude : GeneratedMessage {
        public typealias BuilderType = Airmap.Telemetry.Attitude.Builder

        public static func == (lhs: Airmap.Telemetry.Attitude, rhs: Airmap.Telemetry.Attitude) -> Bool {
            if lhs === rhs {
                return true
            }
            var fieldCheck:Bool = (lhs.hashValue == rhs.hashValue)
            fieldCheck = fieldCheck && (lhs.hasTimestamp == rhs.hasTimestamp) && (!lhs.hasTimestamp || lhs.timestamp == rhs.timestamp)
            fieldCheck = fieldCheck && (lhs.hasYaw == rhs.hasYaw) && (!lhs.hasYaw || lhs.yaw == rhs.yaw)
            fieldCheck = fieldCheck && (lhs.hasPitch == rhs.hasPitch) && (!lhs.hasPitch || lhs.pitch == rhs.pitch)
            fieldCheck = fieldCheck && (lhs.hasRoll == rhs.hasRoll) && (!lhs.hasRoll || lhs.roll == rhs.roll)
            fieldCheck = (fieldCheck && (lhs.unknownFields == rhs.unknownFields))
            return fieldCheck
        }

        /// UNIX time in Milliseconds
        public fileprivate(set) var timestamp:UInt64! = nil
        public fileprivate(set) var hasTimestamp:Bool = false

        /// Yaw angle measured from True North, { 0 <= x < 360 } degrees
        public fileprivate(set) var yaw:Float! = nil
        public fileprivate(set) var hasYaw:Bool = false

        /// Pitch angle, { -180 < x <= 180 } degrees
        public fileprivate(set) var pitch:Float! = nil
        public fileprivate(set) var hasPitch:Bool = false

        /// Roll angle, { -180 < x <= 180 } degrees
        public fileprivate(set) var roll:Float! = nil
        public fileprivate(set) var hasRoll:Bool = false

        required public init() {
            super.init()
        }
        override public func isInitialized() throws {
        }
        override public func writeTo(codedOutputStream: CodedOutputStream) throws {
            if hasTimestamp {
                try codedOutputStream.writeUInt64(fieldNumber: 1, value:timestamp)
            }
            if hasYaw {
                try codedOutputStream.writeFloat(fieldNumber: 2, value:yaw)
            }
            if hasPitch {
                try codedOutputStream.writeFloat(fieldNumber: 3, value:pitch)
            }
            if hasRoll {
                try codedOutputStream.writeFloat(fieldNumber: 4, value:roll)
            }
            try unknownFields.writeTo(codedOutputStream: codedOutputStream)
        }
        override public func serializedSize() -> Int32 {
            var serialize_size:Int32 = memoizedSerializedSize
            if serialize_size != -1 {
             return serialize_size
            }

            serialize_size = 0
            if hasTimestamp {
                serialize_size += timestamp.computeUInt64Size(fieldNumber: 1)
            }
            if hasYaw {
                serialize_size += yaw.computeFloatSize(fieldNumber: 2)
            }
            if hasPitch {
                serialize_size += pitch.computeFloatSize(fieldNumber: 3)
            }
            if hasRoll {
                serialize_size += roll.computeFloatSize(fieldNumber: 4)
            }
            serialize_size += unknownFields.serializedSize()
            memoizedSerializedSize = serialize_size
            return serialize_size
        }
        public class func getBuilder() -> Airmap.Telemetry.Attitude.Builder {
            return Airmap.Telemetry.Attitude.classBuilder() as! Airmap.Telemetry.Attitude.Builder
        }
        public func getBuilder() -> Airmap.Telemetry.Attitude.Builder {
            return classBuilder() as! Airmap.Telemetry.Attitude.Builder
        }
        override public class func classBuilder() -> ProtocolBuffersMessageBuilder {
            return Airmap.Telemetry.Attitude.Builder()
        }
        override public func classBuilder() -> ProtocolBuffersMessageBuilder {
            return Airmap.Telemetry.Attitude.Builder()
        }
        public func toBuilder() throws -> Airmap.Telemetry.Attitude.Builder {
            return try Airmap.Telemetry.Attitude.builderWithPrototype(prototype:self)
        }
        public class func builderWithPrototype(prototype:Airmap.Telemetry.Attitude) throws -> Airmap.Telemetry.Attitude.Builder {
            return try Airmap.Telemetry.Attitude.Builder().mergeFrom(other:prototype)
        }
        override public func encode() throws -> Dictionary<String,Any> {
            try isInitialized()
            var jsonMap:Dictionary<String,Any> = Dictionary<String,Any>()
            if hasTimestamp {
                jsonMap["timestamp"] = "\(timestamp!)"
            }
            if hasYaw {
                jsonMap["yaw"] = Float(yaw)
            }
            if hasPitch {
                jsonMap["pitch"] = Float(pitch)
            }
            if hasRoll {
                jsonMap["roll"] = Float(roll)
            }
            return jsonMap
        }
        override class public func decode(jsonMap:Dictionary<String,Any>) throws -> Airmap.Telemetry.Attitude {
            return try Airmap.Telemetry.Attitude.Builder.decodeToBuilder(jsonMap:jsonMap).build()
        }
        override class public func fromJSON(data:Data) throws -> Airmap.Telemetry.Attitude {
            return try Airmap.Telemetry.Attitude.Builder.fromJSONToBuilder(data:data).build()
        }
        override public func getDescription(indent:String) throws -> String {
            var output = ""
            if hasTimestamp {
                output += "\(indent) timestamp: \(timestamp) \n"
            }
            if hasYaw {
                output += "\(indent) yaw: \(yaw) \n"
            }
            if hasPitch {
                output += "\(indent) pitch: \(pitch) \n"
            }
            if hasRoll {
                output += "\(indent) roll: \(roll) \n"
            }
            output += unknownFields.getDescription(indent: indent)
            return output
        }
        override public var hashValue:Int {
            get {
                var hashCode:Int = 7
                if hasTimestamp {
                    hashCode = (hashCode &* 31) &+ timestamp.hashValue
                }
                if hasYaw {
                    hashCode = (hashCode &* 31) &+ yaw.hashValue
                }
                if hasPitch {
                    hashCode = (hashCode &* 31) &+ pitch.hashValue
                }
                if hasRoll {
                    hashCode = (hashCode &* 31) &+ roll.hashValue
                }
                hashCode = (hashCode &* 31) &+  unknownFields.hashValue
                return hashCode
            }
        }


        //Meta information declaration start

        override public class func className() -> String {
            return "Airmap.Telemetry.Attitude"
        }
        override public func className() -> String {
            return "Airmap.Telemetry.Attitude"
        }
        //Meta information declaration end

        final public class Builder : GeneratedMessageBuilder {
            fileprivate var builderResult:Airmap.Telemetry.Attitude = Airmap.Telemetry.Attitude()
            public func getMessage() -> Airmap.Telemetry.Attitude {
                return builderResult
            }

            required override public init () {
                super.init()
            }
            /// UNIX time in Milliseconds
            public var timestamp:UInt64 {
                get {
                    return builderResult.timestamp
                }
                set (value) {
                    builderResult.hasTimestamp = true
                    builderResult.timestamp = value
                }
            }
            public var hasTimestamp:Bool {
                get {
                    return builderResult.hasTimestamp
                }
            }
            @discardableResult
            public func setTimestamp(_ value:UInt64) -> Airmap.Telemetry.Attitude.Builder {
                self.timestamp = value
                return self
            }
            @discardableResult
            public func clearTimestamp() -> Airmap.Telemetry.Attitude.Builder{
                builderResult.hasTimestamp = false
                builderResult.timestamp = nil
                return self
            }
            /// Yaw angle measured from True North, { 0 <= x < 360 } degrees
            public var yaw:Float {
                get {
                    return builderResult.yaw
                }
                set (value) {
                    builderResult.hasYaw = true
                    builderResult.yaw = value
                }
            }
            public var hasYaw:Bool {
                get {
                    return builderResult.hasYaw
                }
            }
            @discardableResult
            public func setYaw(_ value:Float) -> Airmap.Telemetry.Attitude.Builder {
                self.yaw = value
                return self
            }
            @discardableResult
            public func clearYaw() -> Airmap.Telemetry.Attitude.Builder{
                builderResult.hasYaw = false
                builderResult.yaw = nil
                return self
            }
            /// Pitch angle, { -180 < x <= 180 } degrees
            public var pitch:Float {
                get {
                    return builderResult.pitch
                }
                set (value) {
                    builderResult.hasPitch = true
                    builderResult.pitch = value
                }
            }
            public var hasPitch:Bool {
                get {
                    return builderResult.hasPitch
                }
            }
            @discardableResult
            public func setPitch(_ value:Float) -> Airmap.Telemetry.Attitude.Builder {
                self.pitch = value
                return self
            }
            @discardableResult
            public func clearPitch() -> Airmap.Telemetry.Attitude.Builder{
                builderResult.hasPitch = false
                builderResult.pitch = nil
                return self
            }
            /// Roll angle, { -180 < x <= 180 } degrees
            public var roll:Float {
                get {
                    return builderResult.roll
                }
                set (value) {
                    builderResult.hasRoll = true
                    builderResult.roll = value
                }
            }
            public var hasRoll:Bool {
                get {
                    return builderResult.hasRoll
                }
            }
            @discardableResult
            public func setRoll(_ value:Float) -> Airmap.Telemetry.Attitude.Builder {
                self.roll = value
                return self
            }
            @discardableResult
            public func clearRoll() -> Airmap.Telemetry.Attitude.Builder{
                builderResult.hasRoll = false
                builderResult.roll = nil
                return self
            }
            override public var internalGetResult:GeneratedMessage {
                get {
                    return builderResult
                }
            }
            @discardableResult
            override public func clear() -> Airmap.Telemetry.Attitude.Builder {
                builderResult = Airmap.Telemetry.Attitude()
                return self
            }
            override public func clone() throws -> Airmap.Telemetry.Attitude.Builder {
                return try Airmap.Telemetry.Attitude.builderWithPrototype(prototype:builderResult)
            }
            override public func build() throws -> Airmap.Telemetry.Attitude {
                try checkInitialized()
                return buildPartial()
            }
            public func buildPartial() -> Airmap.Telemetry.Attitude {
                let returnMe:Airmap.Telemetry.Attitude = builderResult
                return returnMe
            }
            @discardableResult
            public func mergeFrom(other:Airmap.Telemetry.Attitude) throws -> Airmap.Telemetry.Attitude.Builder {
                if other == Airmap.Telemetry.Attitude() {
                    return self
                }
                if other.hasTimestamp {
                    timestamp = other.timestamp
                }
                if other.hasYaw {
                    yaw = other.yaw
                }
                if other.hasPitch {
                    pitch = other.pitch
                }
                if other.hasRoll {
                    roll = other.roll
                }
                try merge(unknownField: other.unknownFields)
                return self
            }
            @discardableResult
            override public func mergeFrom(codedInputStream: CodedInputStream) throws -> Airmap.Telemetry.Attitude.Builder {
                return try mergeFrom(codedInputStream: codedInputStream, extensionRegistry:ExtensionRegistry())
            }
            @discardableResult
            override public func mergeFrom(codedInputStream: CodedInputStream, extensionRegistry:ExtensionRegistry) throws -> Airmap.Telemetry.Attitude.Builder {
                let unknownFieldsBuilder:UnknownFieldSet.Builder = try UnknownFieldSet.builderWithUnknownFields(copyFrom:self.unknownFields)
                while (true) {
                    let protobufTag = try codedInputStream.readTag()
                    switch protobufTag {
                    case 0: 
                        self.unknownFields = try unknownFieldsBuilder.build()
                        return self

                    case 8:
                        timestamp = try codedInputStream.readUInt64()

                    case 21:
                        yaw = try codedInputStream.readFloat()

                    case 29:
                        pitch = try codedInputStream.readFloat()

                    case 37:
                        roll = try codedInputStream.readFloat()

                    default:
                        if (!(try parse(codedInputStream:codedInputStream, unknownFields:unknownFieldsBuilder, extensionRegistry:extensionRegistry, tag:protobufTag))) {
                            unknownFields = try unknownFieldsBuilder.build()
                            return self
                        }
                    }
                }
            }
            class override public func decodeToBuilder(jsonMap:Dictionary<String,Any>) throws -> Airmap.Telemetry.Attitude.Builder {
                let resultDecodedBuilder = Airmap.Telemetry.Attitude.Builder()
                if let jsonValueTimestamp = jsonMap["timestamp"] as? String {
                    resultDecodedBuilder.timestamp = UInt64(jsonValueTimestamp)!
                } else if let jsonValueTimestamp = jsonMap["timestamp"] as? UInt {
                    resultDecodedBuilder.timestamp = UInt64(jsonValueTimestamp)
                }
                if let jsonValueYaw = jsonMap["yaw"] as? Float {
                    resultDecodedBuilder.yaw = Float(jsonValueYaw)
                } else if let jsonValueYaw = jsonMap["yaw"] as? String {
                    resultDecodedBuilder.yaw = Float(jsonValueYaw)!
                }
                if let jsonValuePitch = jsonMap["pitch"] as? Float {
                    resultDecodedBuilder.pitch = Float(jsonValuePitch)
                } else if let jsonValuePitch = jsonMap["pitch"] as? String {
                    resultDecodedBuilder.pitch = Float(jsonValuePitch)!
                }
                if let jsonValueRoll = jsonMap["roll"] as? Float {
                    resultDecodedBuilder.roll = Float(jsonValueRoll)
                } else if let jsonValueRoll = jsonMap["roll"] as? String {
                    resultDecodedBuilder.roll = Float(jsonValueRoll)!
                }
                return resultDecodedBuilder
            }
            override class public func fromJSONToBuilder(data:Data) throws -> Airmap.Telemetry.Attitude.Builder {
                let jsonData = try JSONSerialization.jsonObject(with:data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                guard let jsDataCast = jsonData as? Dictionary<String,Any> else {
                  throw ProtocolBuffersError.invalidProtocolBuffer("Invalid JSON data")
                }
                return try Airmap.Telemetry.Attitude.Builder.decodeToBuilder(jsonMap:jsDataCast)
            }
        }

    }

}
extension Airmap.Telemetry.Attitude: GeneratedMessageProtocol {
    public class func parseArrayDelimitedFrom(inputStream: InputStream) throws -> Array<Airmap.Telemetry.Attitude> {
        var mergedArray = Array<Airmap.Telemetry.Attitude>()
        while let value = try parseDelimitedFrom(inputStream: inputStream) {
          mergedArray.append(value)
        }
        return mergedArray
    }
    public class func parseDelimitedFrom(inputStream: InputStream) throws -> Airmap.Telemetry.Attitude? {
        return try Airmap.Telemetry.Attitude.Builder().mergeDelimitedFrom(inputStream: inputStream)?.build()
    }
    public class func parseFrom(data: Data) throws -> Airmap.Telemetry.Attitude {
        return try Airmap.Telemetry.Attitude.Builder().mergeFrom(data: data, extensionRegistry:Airmap.Telemetry.AttitudeRoot.default.extensionRegistry).build()
    }
    public class func parseFrom(data: Data, extensionRegistry:ExtensionRegistry) throws -> Airmap.Telemetry.Attitude {
        return try Airmap.Telemetry.Attitude.Builder().mergeFrom(data: data, extensionRegistry:extensionRegistry).build()
    }
    public class func parseFrom(inputStream: InputStream) throws -> Airmap.Telemetry.Attitude {
        return try Airmap.Telemetry.Attitude.Builder().mergeFrom(inputStream: inputStream).build()
    }
    public class func parseFrom(inputStream: InputStream, extensionRegistry:ExtensionRegistry) throws -> Airmap.Telemetry.Attitude {
        return try Airmap.Telemetry.Attitude.Builder().mergeFrom(inputStream: inputStream, extensionRegistry:extensionRegistry).build()
    }
    public class func parseFrom(codedInputStream: CodedInputStream) throws -> Airmap.Telemetry.Attitude {
        return try Airmap.Telemetry.Attitude.Builder().mergeFrom(codedInputStream: codedInputStream).build()
    }
    public class func parseFrom(codedInputStream: CodedInputStream, extensionRegistry:ExtensionRegistry) throws -> Airmap.Telemetry.Attitude {
        return try Airmap.Telemetry.Attitude.Builder().mergeFrom(codedInputStream: codedInputStream, extensionRegistry:extensionRegistry).build()
    }
    public subscript(key: String) -> Any? {
        switch key {
        case "timestamp": return self.timestamp
        case "yaw": return self.yaw
        case "pitch": return self.pitch
        case "roll": return self.roll
        default: return nil
        }
    }
}
extension Airmap.Telemetry.Attitude.Builder: GeneratedMessageBuilderProtocol {
    public typealias GeneratedMessageType = Airmap.Telemetry.Attitude
    public subscript(key: String) -> Any? {
        get { 
            switch key {
            case "timestamp": return self.timestamp
            case "yaw": return self.yaw
            case "pitch": return self.pitch
            case "roll": return self.roll
            default: return nil
            }
        }
        set (newSubscriptValue) { 
            switch key {
            case "timestamp":
                guard let newSubscriptValue = newSubscriptValue as? UInt64 else {
                    return
                }
                self.timestamp = newSubscriptValue
            case "yaw":
                guard let newSubscriptValue = newSubscriptValue as? Float else {
                    return
                }
                self.yaw = newSubscriptValue
            case "pitch":
                guard let newSubscriptValue = newSubscriptValue as? Float else {
                    return
                }
                self.pitch = newSubscriptValue
            case "roll":
                guard let newSubscriptValue = newSubscriptValue as? Float else {
                    return
                }
                self.roll = newSubscriptValue
            default: return
            }
        }
    }
}

// @@protoc_insertion_point(global_scope)