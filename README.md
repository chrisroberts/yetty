## Yetty

With shelr.tv[1] now defunct, I wanted an easy way to spin out
my own to easily share terminal recordings. Yetty is a wrapper
around shelr[2] that removes some of the extra features it
provids. It also has a very simple web UI builtin that hooks into
an object store to persist dump files.

### Is it secure?

No, not at all. This is configuration based and user uploads are
simply prefixed within the bucket. But this is just a friendly
tool, so if bad things happen, maybe your friends aren't so friendly.

### Web UI?

Yep. It's a very simple sinatra application. It pulls information
directly from the object store. So not built for speed or scale.

### Private?

Kinda. Private pushes are simply not listed publicly. So you'll need
the direct link to access them (much like private gists).

### Configuration

Configuration is a JSON file. Locations checked in order of precedence:

* ./yetty
* ~/.yetty
* /etc/yetty/config.json

File contents:

```json
{
  "site": {
    "url": "http://localhost:4000"
  },
  "user": {
    "username": "YOUR_USERNAME",
    "storage": {
      "provider": "aws",
      "bucket": "my-yetty-bucket",
      "credentials": {
        "aws_access_key_id": "...",
        "aws_secret_access_key": "...",
        "aws_bucket_region": "..."
      }
    }
  }
}
```

The `credentials` section are the credentials expected
by miasma[3] based on the provider in use.

### Thanks!

A big thanks to @antono for the shelr[2] library. Also
to @jeromeetienne for the beautiful nyancat[4]

[1]: https://github.com/antono/shelr.tv "record you shell and publish it"
[2]: https://github.com/antono/shelr "Console screencasting tool"
[3]: https://github.com/chrisroberts/miasma "Cloud modeling library"
[4]: https://github.com/jeromeetienne/threex.nyancat "three.js extension to make nyancat"