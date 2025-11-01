#
# Be sure to run `pod lib lint dimplugins-objc.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name                  = 'DIMPlugins'
    s.version               = '1.0.6'
    s.summary               = 'Decentralized Instant Messaging Plugins'
    s.description           = <<-DESC
            Decentralized Instant Messaging (Objective-C Plugins)
                              DESC
    s.homepage              = 'https://github.com/dimchat/plugins-objc'
    s.license               = { :type => 'MIT', :file => 'LICENSE' }
    s.author                = { 'Albert Moky' => 'albert.moky@gmail.com' }
    s.source                = { :git => 'https://github.com/dimchat/plugins-objc.git', :tag => s.version.to_s }
    # s.platform            = :ios, "12.0"
    s.ios.deployment_target = '12.0'

    s.source_files          = 'Classes', 'DIMPlugins/DIMPlugins/*.h', 'Classes/**/*.{h,inc,m,mm,c,cpp}'
    # s.exclude_files       = 'DIMPlugins/Classes/Exclude'
    s.public_header_files   = 'DIMPlugins/DIMPlugins/*.h', 'Classes/*.h', 'Classes/crypto/*.h', 'Classes/data/*.h', 'Classes/mkm/*.h', 'Classes/dkd/*.h', 'Classes/extends/*.h'

    s.frameworks            = 'Security'
    # s.requires_arc        = true

    s.dependency 'DIMCore', '~> 1.0.6'
    s.dependency 'DaoKeDao', '~> 1.0.6'
    s.dependency 'MingKeMing', '~> 1.0.6'
end
