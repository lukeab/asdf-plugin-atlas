<div align="center">

# asdf-plugin-atlas [![Build](https://github.com/lukeab/asdf-plugin-atlas/actions/workflows/build.yml/badge.svg)](https://github.com/lukeab/asdf-plugin-atlas/actions/workflows/build.yml) [![Lint](https://github.com/lukeab/asdf-plugin-atlas/actions/workflows/lint.yml/badge.svg)](https://github.com/lukeab/asdf-plugin-atlas/actions/workflows/lint.yml)

[atlas](https://atlasgo.io/getting-started) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`: generic POSIX utilities.


# Install

Plugin:

```shell
asdf plugin add atlas
# or
asdf plugin add atlas https://github.com/lukeab/asdf-plugin-atlas.git
```

atlas:

```shell
# Show all installable versions
asdf list-all atlas

# Install specific version
asdf install atlas latest

# Set a version globally (on your ~/.tool-versions file)
asdf global atlas latest

# Now atlas commands are available
atlas version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/lukeab/asdf-plugin-atlas/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Luke Ashe-Browne](https://github.com/lukeab/)
