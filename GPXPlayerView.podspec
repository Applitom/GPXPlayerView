Pod::Spec.new do |s|


  s.name         = "GPXPlayerView"
  s.version      = "0.0.1"
  s.summary      = "iOS GPX File player view"

  s.description  = <<-DESC
                      An iOS GPX File player view
                   DESC

  s.homepage     = "http://applitom.com"

  s.license      = "MIT"

  s.author             = { "Tomer Shalom" => "applitom@gmail.com" }
  s.social_media_url   = "http://twitter.com/applitom"

  s.platform     = :ios

  s.source       = { :git => "http://github.com/applitom/GPXPlayerView.git", :tag => "#{s.version}" }
  s.source_files = "GPXPlayerView/*.swift","GpxKit/GpxKit/*.swift"
  s.framework  = "Foundation"
  
  s.dependency "SWXMLHash", '~> 4'
  s.dependency "RxSwift", '~> 4'
  
end
