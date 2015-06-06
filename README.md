Where <a href="https://flattr.com/submit/auto?user_id=Tricertops&url=https%3A%2F%2Fgithub.com%2FiMartinKiss%2FWhere" target="_blank"><img src="https://api.flattr.com/button/flattr-badge-large.png" alt="Flattr this" title="Flattr this" border="0"></a>
=============================

Detect user’s location without Location Services. There are several ways to approximate user’s location and this little framework provides unified interface for all of them.

## Interface

There are two main methods on class `Where`:

  - `Where.amI` – where the user **currently** is.
  - `Where.isHome` – where the user is **from**.

Both of these return instance of `Where` class, which contains this info:

  - `source` – Value from enum with one of **6 sources**.
  - `timestamp` – How old this instance is.
  - `regionCode` – 2-letter **ISO** 3166 code (`US`, `GB`, `SK`, `JP`).
  - `regionName` – English name of the region.
  - `coordinate` – Accuracy **depends** on source, typically it’s the middle of region.

## Sources

  - **Locale** – Used to detect user’s residence, since that’s how you typically choose locale.
  - **Carrier** – Used to detect users’s residence, since carrier does’t change while roaming abroad.
  - **Cellular IP** – Similar to Carrier source, used to detect user’s residence.
  - **Wi-Fi IP** – When connected to Wi-Fi, external IP should tell us in which country is the user.
  - **Time Zone** – This is the **most important** source of location information. iOS uses Location Services when travelling to detect current time zone. This time zone is then available to apps and by checking `tz` database, we can get country and middle coordinate of the time zone.
  - **Location Services** – Finally, CoreLocation is integrated, but turned off by default. When enabled (see _Options_) it detect exact location, geocodes the region and then turns itself off.

To get latest instance for given source, call `+[Where forSource:]`

## Options

You can customize behavior of the framework by calling `+[Where detectWithOptions:]` and passing one or more of these options:

  - `UpdateContinuously` – In addition to providing location once, the framework **observes** all sources and updates the detected location until cancelled. Notification `WhereDidUpdateNotification` is posted every time any source is updated. This is **the default**.
  - `UseInternet` – Enables use of **Cellular IP** and **Wi-Fi IP** sources
  - `UseLocationServices` – Enables use of CoreLocation, implies `UseInternet`, because it needs geocoding.
  - `AskForPermission` – In addition to `UseLocationServices` (which it implies) also asks the user for permission to use CoreLocation. If you don’t pass this option, you have to gain permission yourself.
  
To turn off continuous updates or usage of internet, use option `None`.

#### Debugging

You can simulate user’s location by using `-WhereDebug` launch argument with ISO or time zone value.


## Additions

Framework uses categories on `NSLocale` and `NSTimeZone` with some generaly useful methods:

  - **Canonize** region ISO codes to 2-letter uppercase form.
  - Lookup **coordinates** for region or time zone.
  - Get all time zones for given **region**.

---
The MIT License (MIT)  
Copyright © 2015 Martin Kiss
