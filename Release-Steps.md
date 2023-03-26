# Release Steps

1. Determine the new release number, like `1.6.4`.

2. In `Sources > Info.plist`, update `Bundle version string` with the new release number.

3. In `ScrollingContentViewController.podspec`, update `s.version` with the new release number.

4. Verify that the Cocoapods spec file is valid:
```
pod lib lint
```

5. Commit the updated release number and Cocopods spec file:
``` 
git add -A && git commit -m "Release 1.6.4"
git push
```

6. Create a tag for the new release. For consistency, **do not** prefix tags with 'v'.
```
git tag '1.6.4'
git push --tags
```

7. Submit the new release to the Cocoapods specs repo: 
```
pod trunk push ScrollingContentViewController.podspec
```

If that doesn't work, first follow the steps at https://guides.cocoapods.org/making/getting-setup-with-trunk.html
using the email address in `ScrollingContentViewController.podspec` to register the local device with the Cocoapods trunk.
```
pod trunk register drew@retroactivefiasco.com 'Drew Olbrich' --description='MacBook Pro' 
```

8. Draft a new release on GitHub at https://github.com/drewolbrich/ScrollingContentViewController/releases

9. For the new release, use the release number 1.6.4 as the title and prefix each item in the description with bullets, indicated by '*'.

10. Leave **Set as the latest release** checked and click **Publish**.
