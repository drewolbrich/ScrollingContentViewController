# Release Steps

1. Determine the new release number, like `1.7.0` and search and replace the previous version number with it in this file.

2. Verify that the tests pass:
```
xcodebuild test -scheme ScrollingContentViewControllerTests -sdk iphonesimulator16.4 -destination "OS=16.4,name=iPhone 14"
```

3. In `Sources > Info.plist`, update `Bundle version string` with the new release number.

4. In `ScrollingContentViewController.podspec`, update `s.version` with the new release number.

5. Verify that the Swift package file is valid:
```
swift package describe
```

6. Verify that the Cocoapods spec file is valid:
```
pod lib lint
```

7. Commit the updated release number and Cocopods spec file:
``` 
git add -A && git commit -m "Release 1.7.0"
git push
```

8. Create a tag for the new release. For consistency, **do not** prefix tags with 'v'.
```
git tag '1.7.0'
git push --tags
```

9. Submit the new release to the Cocoapods specs repo:
```
pod trunk push ScrollingContentViewController.podspec
```

If that doesn't work, first follow the steps at https://guides.cocoapods.org/making/getting-setup-with-trunk.html
using the email address in `ScrollingContentViewController.podspec` to register the local device with the Cocoapods trunk.
```
pod trunk register drew@retroactivefiasco.com 'Drew Olbrich' --description='MacBook Pro' 
```

10. Draft a new release on GitHub at https://github.com/drewolbrich/ScrollingContentViewController/releases

11. For the new release, use the release number 1.7.0 as the title and prefix each item in the description with bullets, indicated by '*'.

12. Leave **Set as the latest release** checked and click **Publish**.
