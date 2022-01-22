# Uncomment the next line to define a global platform for your project
platform :ios, '15'

target 'ReduxMovieDB' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Redux pods
  pod 'ReSwift'
  pod 'ReSwiftThunk'

  # Reactive pods
  pod 'CombineCocoa'
  pod 'CombineKeyboard'

  # Networking pods
  pod 'Nuke'

  # Diffing pods
  pod 'DifferenceKit/UIKitExtension'

  target 'ReduxMovieDBTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
