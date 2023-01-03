# import-cost.nvim

Display the costs of javascript imports inside neovim with the power of
[import-cost](https://github.com/wix/import-cost/tree/master/packages/import-cost).

![preview](https://user-images.githubusercontent.com/62671086/210295248-916a8d81-22c9-432a-87fd-cf539879bf0c.png)

## Installation

1. Install regularly with your neovim package manager
2. Run `install.sh` with your node.js package manager to setup import-cost:

```sh
sh install.sh '<your-package-manager>'
```

For example, a config with [yarn](https://yarnpkg.com/) and [lazy.nvim](https://github.com/folke/lazy.nvim)
may look like the following:

```lua
require('lazy').setup {
    {
        'barrett-ruth/import-cost.nvim',
        build = 'sh install.sh yarn'
    }
}
```

## Configuration

Configure via the setup function (or use the defaults with no arguments):

```lua
require('import-cost').setup(opts)
```

See `:h import-cost` for more information

## TODO

1. CommonJS support

## Acknowledgements

1. [wix/import-cost](https://github.com/wix/import-cost/): provides the node
   backend that calculates the import costs
2. [import-cost](https://marketplace.visualstudio.com/items?itemName=wix.vscode-import-cost):
   the original VSCode plugin that started it all
3. [vim-import-cost](https://github.com/yardnsm/vim-import-cOst): inspired me to do it in neovim!
