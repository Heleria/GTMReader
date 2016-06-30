# GTMReader

## What it does

This tool reads JSON-values (in the format they have after conversion with https://github.com/Heleria/SwiftToGTMEncoder) from your Value Collections stored in Google Tag Manager, and converts them into any of the following types:
 - Arrays (can recursively contain anything on this list except CGSize)
 - Dictionaries (can recursively contain anything on this list except CGSize)
 - CGFloats
 - CGRects
 - CGSize (not supported inside arrays or dictionaries)
 - UIColor
 - All primitives

## Installation

Will be installable through CocoaPods in the future.

At the moment, download 'GTMReader.swift' and put it in your project.

## How to use

On app launch call 'setGTMContainer(TagManager:)', 'setGTMContainer(TagContainer:)' or 'GTMManager.sharedInstance.launchGTM(containerId:)'

Whenever you want a value either call '<STRING KEY OF VALUE>.gtm()' or 'value(<STRING KEY OF VALUE>)'. If the usage makes it clear what type of value is desired these generic methods will work. If the desired value is ambiguous you will instead have to call the explicit methods '<STRING KEY OF VALUE>.string, int, double, float, color, size, array or dictionary' or any of the functions with identical names (e.g. 'double(<STRING KEY OF VALUE>)'.)

## Author

Heleria, Jacob.R.Developer@gmail.com

## License

GTMReader is available under the MIT license. See the LICENSE file for more info.
