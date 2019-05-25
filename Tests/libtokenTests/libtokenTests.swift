import XCTest
@testable import libtoken

final class libtokenTests: XCTestCase {
    func testExample() {
        let turl: URL = URL(string: "otpauth://totp/abcd:efgh?secret=bh4j24w7lyawyiaxrrnk652kbjmbjk37ojd2z5t5lo33hcvlebeb3fpi&algorithm=SHA1&digits=6&period=30")!
        let hurl: URL = URL(string: "otpauth://hotp/abcd:efgh?secret=m44twveuayfl2w3akznffdgzlcbfv36x4fx2ipi6w3d4dqbmopyqgat5&algorithm=SHA256&digits=6&period=30&counter=0")!
        let totp = try! Token(from: turl)
        let hotp = try! Token(from: hurl)
        print(totp)
        print("Code: \(totp.password(format: true)) (\(totp.timeRemaining(reversed: true))s remaining)")
        print(hotp)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
