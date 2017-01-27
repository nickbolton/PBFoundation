Pod::Spec.new do |s|
  s.name      = 'PBFoundation'
  s.version   = '0.1.0'
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  s.summary   = 'PBFoundation is a collection of useful Mac and iOS utilities.'
  s.homepage  = 'https://github.com/nickbolton/PBFoundation'
  s.requires_arc = true 
  s.subspec 'no-arc' do |sna|
    sna.platform = :osx, '10.8'
    sna.requires_arc = false
    sna.osx.source_files = 'Mac-NonArc/**/*.{h,m}'
  end

  s.author    = { 'nickbolton' => 'nick@deucent.com' }             
  s.source    = { :git => 'https://github.com/nickbolton/PBFoundation.git',
                  :branch => 'emitters-breakout'}
  s.osx.source_files  = '*.{h,m}', 'Shared', 'Shared/**/*.{h,m}', 'Mac', 'Mac/**/*.{h,m}'
  s.ios.source_files  = '*.{h,m}', 'Shared', 'Shared/**/*.{h,m}', 'iOS', 'iOS/**/*.{h,m}'
  s.ios.resources = 'iOS/ListView/PBListCell.xib', 'iOS/ListView/PBTitleCell.xib'
  s.prefix_header_contents = <<-EOS
#ifdef __OBJC__
#import "PBFoundation.h"
#endif
  EOS
  s.osx.frameworks    = 'Cocoa', 'QuartzCore', 'Carbon', 'CoreServices', 'QuickLook'
  s.license   = {
    :type => 'MIT',
    :text => <<-LICENSE
              Copyright (C) 2011-2013, Pixelbleed LLC

              Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

              The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

              THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    LICENSE
  }

end
