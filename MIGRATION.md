# Migrating from verions 2.x to 3.x

AirMap is updating its identity provider and authentication mechanisms to be OIDC-compliant (https://openid.net/connect/). This will incur some breaking changes in version 3 of the AirMap SDK for Swift. While these changes are minimal, there are a few things you will need to update if you are using any of the authentication features of the AirMap SDK.

### Configuration

The format of the `airmap.config.json` configuration file has changed. Please visit the AirMap Developer Portal (https://dashboard.airmap.com/developer) and download an updated configuration file.

### Refresh Tokens

The AirMapSDK no longer requires developers to manually refresh access tokens after they expire. The SDK now automatically handles refreshing access tokens so long as the refresh token has not been invalidated by the user. As a consequence, the `AirMap.refreshAuthToken()` method has been removed.

### Anonymous Login

`AirMap.performAnonymousLogin()` will no longer return `Result<AirMapToken>`. It will now return `Result<Void>` which can be checked for any errors before performing any other interactions with the SDK that require user authentication.

### Handling The Login Redirect (iOS < 10)

If you support any OS versions that preceded iOS 10.0 (non-inclusive) you will need to register a callback url scheme to handle the authentication redirect back into your app.

In the Info.plist file add a new URL. Go to MyProject → Info → URL Types and click the +. This URL scheme should be the same as your *lower cased* bundle identifier. For example, if your bundle id is `com.MyCompany.MyApp`, the url scheme should be `com.mycompany.myapp`.

```
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool { if AirMap.resumeLogin(with: url) { return true } return false }
```

### Logout

`AirMap.logout()` now takes a completion handler and will return `Result<Void>`.

```
  AirMap.logout(completion: { (result) in
    switch result {
    case .value:
      // Do something on success 
    case .error(let error):
      // Do something on error
    }
  })
```

### Checking Auth State

To check the user's authentication state, check the public property `AirMap.isAuthorized`.

### Native Authentication

Additionally, it is now possible to use any OAuth2 OIDC-conformant client to connect directly to the AirMap identity provider service at auth.airmap.com.

# Getting Support

You can get support from AirMap via the following channels:
- Our developer workspace on [Slack](https://join.slack.com/t/airmap-developers/shared_invite/enQtNTA4MzU0MTM2MjI0LWYwYTM5MjUxNWNhZTQwYmYxODJmMjFiODAyNzZlZTRkOTY2MjUwMzQ1NThlZjczY2FjMDQ2YzgxZDcxNTY2ZGQ)
- Our developer guides and references at https://developers.airmap.com/
