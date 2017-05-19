# Other Topics

Here is a list of useful code snippets and other information about creating Data Connectors.

## Status code handling with Web.Contents

The [Web.Contents](https://msdn.microsoft.com/en-us/library/mt260892) function has some built in functionality for dealing with certain HTTP status codes. The default behavior can be overridden in your extension using the `ManualStatusHandling` field in the [options record](https://msdn.microsoft.com/library/mt260892#Anchor_1).

### Automatic retry

[Web.Contents](https://msdn.microsoft.com/en-us/library/mt260892.aspx) will automatically retry requests that fail with one of the following status codes:

| Code | Status                     |
|:-----|:---------------------------|
| 408  | Request Timeout            |
| 429  | Too Many Requests          |
| 503  | Service Unavailable        |
| 504  | Gateway Timeout            |
| 509  | Bandwidth Limit Exceeded   |

Requests will be retried up to 3 times before failing. The engine uses an exponential back-off algorithm to determine how long to wait until the next retry, unless the response contains a [`Retry-after`](https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.37) header. When the header is found, the engine will wait the specified number of seconds before the next retry. The minimum supported wait time is 0.5 seconds, and the maximum value is 120 seconds.

> **Note**: The `Retry-after` value must be in the `delta-seconds` format. The `HTTP-date` format is currently not supported. 

### Authentication exceptions

The following status codes will result in a credentials exception, causing an authentication prompt asking the user to provide credentials (or re-login in the cause of an expired OAuth token).

| Code | Status         |
|:-----|:---------------|
| 401  | Unauthorized   |
| 403  | Forbidden      |

> **Note:** Extensions are able to use the `ManualStatusHandling` option with status codes 401 and 403, which is not something that can be done in `Web.Contents` calls made outside of an extension context (i.e. directly from Power Query).

### Redirection

The follow status codes will result in an automatic redirect to the URI specified in the [`Location`](https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.30) header. A missing `Location` header will result in an error.

| Code | Status             |
|:-----|:-------------------|
| 300  | Multiple Choices   |
| 301  | Moved Permanently  |
| 302  | Found              |
| 303  | See Other          |
| 307  | Temporary Redirect |

> **Note:** Only status code 307 will keep a `POST` request method. All other redirect status codes will result in a switch to `GET`.