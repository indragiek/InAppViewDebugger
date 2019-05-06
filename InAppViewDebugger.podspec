Pod::Spec.new do |spec|
  spec.name               = "InAppViewDebugger"
  spec.version            = "1.0.1"
  spec.summary            = "A UIView debugger (like Reveal or Xcode) that can be embedded in an app for on-device view debugging."
  spec.homepage           = "https://github.com/indragiek/InAppViewDebugger"
  spec.screenshots        = "https://raw.githubusercontent.com/indragiek/InAppViewDebugger/master/docs/img/main.png"
  spec.license            = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Indragie Karunaratne" => "i@indragie.com" }
  spec.social_media_url   = "https://twitter.com/indragie"
  spec.platform           = :ios, "11.0"
  spec.swift_version      = '4.2'
  spec.source             = { :git => "https://github.com/indragiek/InAppViewDebugger.git", :tag => "#{spec.version}" }
  spec.source_files       = "InAppViewDebugger/**/*.{h,m,swift}"
  spec.resources          = "InAppViewDebugger/**/*.xcassets"
end
