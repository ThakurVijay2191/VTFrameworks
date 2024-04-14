Pod::Spec.new do |spec|

spec.name         = "VTFrameworks"
spec.version      = "1.0.1"
spec.summary      = "This is VTFrameworks in which you can find all helping methods and components for your project."
spec.description  = "This is the place where you can get any helpful component or library and can integrate in your project without any difficulty and in a simple way.."

spec.homepage     = "https://github.com/ThakurVijay2191/VTFrameworks"
spec.license      = "MIT"
spec.author             = { "Thakur Vijay" => "105584645+ThakurVijay2191@users.noreply.github.com" }
spec.platform     = :ios, "15.0"

spec.source       = { :git => "https://github.com/ThakurVijay2191/VTFrameworks.git", :tag => spec.version.to_s }

spec.source_files  = "VTFrameworks/**/*.{swift}"
spec.swift_versions = "5.0"
end
