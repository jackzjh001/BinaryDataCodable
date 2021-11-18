import Foundation
import Darwin

public protocol BinaryDataEncodable{ }

public protocol BinaryDataDecodable{ }

public typealias BinaryDataCodable = BinaryDataDecodable & BinaryDataEncodable

public extension Data{
	mutating func encodeBinary(object: BinaryDataEncodable...){
		object.forEach{ $0.encode(into: &self) }
	}
	mutating func decodeBinary<Content: BinaryDataDecodable>(object: inout Content){
		object = .decode(from: &self)
	}
	mutating func decodeBinary<Content: BinaryDataDecodable>(object: inout Content?){
		object = .decode(from: &self)
	}
	mutating func decodeBinary<Content: BinaryDataDecodable>(object: inout Content, count: Int? = nil) where Content: RangeReplaceableCollection, Content.Element: BinaryDataDecodable{
		object = .decode(from: &self, count: count)
	}
	func peekBinary<Content: BinaryDataDecodable>(object: inout Content){
		object = .peek(from: self)
	}
	mutating func padBinary(count: Int = 1){
		encodeBinary(object: [UInt8](repeating: 0, count: count))
	}
	mutating func skipBinary(count: Int = 1){
		self.removeFirst(count)
	}
}

public extension BinaryDataEncodable{
	func encode(into data: inout Data) {
		withUnsafeBytes(of: self){ ptr in
			data.append(ptr.bindMemory(to: Self.self))
		}
	}
}

public extension BinaryDataDecodable{
	static func decode(from data: inout Data) -> Self {
		return data[data.indices.lowerBound..<data.indices.lowerBound + MemoryLayout<Self>.size].withUnsafeBytes{ ptr in
			defer{
				data.removeFirst(ptr.count)
			}
			return ptr.bindMemory(to: Self.self)[0]
		}
	}
	static func peek(from data: Data) -> Self {
		return data[data.indices.lowerBound..<data.indices.lowerBound + MemoryLayout<Self>.size].withUnsafeBytes{ ptr in
			return ptr.bindMemory(to: Self.self)[0]
		}
	}
}

public extension BinaryDataDecodable where Self: RangeReplaceableCollection, Element: BinaryDataDecodable{
	static func decode(from data: inout Data, count: Int? = nil) -> Self {
		return (count != nil ? data[data.indices.lowerBound..<data.indices.lowerBound + MemoryLayout<Element>.size * count!] : data).withUnsafeBytes{ ptr in
			defer{
				data.removeFirst(ptr.count)
				
			}
			return ptr.bindMemory(to: Element.self).reduce(into: Self()){
				$0.append($1)
			}
		}
	}
}

extension Int8: BinaryDataCodable{ }
extension UInt8: BinaryDataCodable{ }

extension Int16: BinaryDataCodable{ }
extension UInt16: BinaryDataCodable{ }

extension Int32: BinaryDataCodable{ }
extension UInt32: BinaryDataCodable{ }

extension Int64: BinaryDataCodable{ }
extension UInt64: BinaryDataCodable{ }

extension Float32: BinaryDataCodable{ }
extension Float64: BinaryDataCodable{ }

extension Bool: BinaryDataCodable{ }

extension UUID: BinaryDataCodable{ }

extension Array: BinaryDataCodable where Element: BinaryDataCodable{
	func encode(into data: inout Data) {
		self.withUnsafeBufferPointer{
			data.append($0)
		}
	}
}
