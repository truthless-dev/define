# Define

Get definitions of English words from the command line

## Installation

### Homebrew

From the command line:

```shell
brew tap truthless-dev/formulae
brew install truthless-dev/formulae/define
```

In your Brewfile:

```ruby
tap "truthless-dev/formulae"
brew "truthless-dev/formulae/define"
```

Note that the fully qualified name `truthless-dev/formulae/define` is necessary.

### GitHub Releases

Download a compressed archive containing the executable from the project's [latest release page][gh-release-latest]. Extract it, and move it to a location available in your $PATH.

### Build from Source

Obtain an archive of the source code from the project's [latest release page][gh-release-latest]. Extract it, then run the following:

```shell
make
make install prefix=<prefix>
```

`Prefix` is the directory containing the `bin` directory where the binary will ultimately live (e.g., `~/.local/`. Depending on the location, you may need to run the install with `sudo`.

Note that this requires the Swift compiler and Swift Package manager to be installed on your system.

## Usage

Simply run `define <word>` to look up a word in the dictionary. For more options, run `define --help`.

## Dictionary Source

This program utilizes the [Free Dictionary API][free-dictionary-api] to obtain all of its definitions, phonetics, synonyms, and antonyms. All credit and thanks should be directed toward the owner of that generous project.

Users should please endeavor not to overwhelm that server with requests. If you need to check a dictionary so often, maybe you should buy a physical one to keep at your desk!

[free-dictionary-api]: https://dictionaryapi.dev/
[gh-release-latest]: https://github.com/truthless-dev/define/releases/latest
