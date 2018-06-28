#
# Be sure to run `pod lib lint RMHttp.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name         = 'RMHttp'
    s.version      = '1.3'
    s.summary      = 'Lightweight RESTful library for iOS and watchOS'

    s.homepage         = 'https://github.com/rogermolas/RMHttp'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'rogermolas' => 'contact@rogermolas.com' }
    s.source           = { :git => 'https://github.com/rogermolas/RMHttp.git', :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/roger_molas'

    s.ios.deployment_target = '10.0'

    s.source_files = 'RMHttp/Classes/*.swift'
end
