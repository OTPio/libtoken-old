Pod::Spec.new do |spec|
    spec.name = 'libtoken'
    spec.version = '1.1.0'

    spec.license = { :type => 'MIT', :file => 'LICENSE' }
    spec.homepage = 'https://github.com/otpio/libtoken'
    spec.authors = { 'Mason Phillips' => 'math.matrix@icloud.com' }
    spec.summary = 'Token Library for OTP.io'

    spec.source = { :git => 'https://github.com/otpio/libtoken.git', :tag => spec.version.to_s }
    spec.swift_version = "5.0"

    spec.ios.deployment_target = '12.0'
    spec.source_files = 'Sources/libtoken/**/*.swift'

    spec.dependency 'FontAwesome.swift'
    spec.dependency 'SwiftBase32'

    #spec.watchos.deployment_target = '5.0'
    #spec.watchos.source_files = 'Source/watchos/*.swift'
end
