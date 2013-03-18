# Whisper: Clean [![Build Status](https://travis-ci.org/killdream/whisper-clean.png)](https://travis-ci.org/killdream/whisper-clean)

Removes build artifacts and backup files from a project.


### Example

Define a list of patterns that should be cleaned up in your `.whisper` file.

```js
module.exports = function(whisper) {
  whisper.configure({
    clean: { files: ['build', '*.orig']
           , ignore: ['node_modules']
           }
  })

  require('whisper-clean')(whisper)
}
```

Invoke `whisper clean` on your project to remove those files.

```bash
whisper clean
```


### Installing

Just grab it from NPM:

    $ npm install whisper-clean


### Licence

MIT/X11. ie.: do whatever you want.

[es5-shim]: https://github.com/kriskowal/es5-shim
