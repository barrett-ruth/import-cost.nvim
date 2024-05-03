# import-cost.nvim

Display the costs of javascript imports inside neovim with the power of
[import-cost](https://github.com/wix/import-cost/tree/master/packages/import-cost).

![preview](https://user-images.githubusercontent.com/62671086/210295248-916a8d81-22c9-432a-87fd-cf539879bf0c.png)

## Installation

1. Install regularly with your neovim package manager
    - *NOTE*: pnpm is not supported because [import-cost](https://github.com/wix/import-cost) does not.
3. Run `install.sh` with your node.js package manager to setup import-cost:

```sh
sh install.sh '<your-package-manager>'
```

For example, a config with [yarn](https://yarnpkg.com/) and [lazy.nvim](https://github.com/folke/lazy.nvim)
may look like the following:

```lua
require('lazy').setup {
    {
        'barrett-ruth/import-cost.nvim',
        build = 'sh install.sh yarn',
        -- if on windows
        -- build = 'pwsh install.ps1 yarn',
        config = true
    }
}
```

## Configuration

Configure via the setup function (or use the defaults with no arguments):

```lua
require('import-cost').setup(opts)
```

See `:h import-cost` for more information

## Known Issues

1. CommonJS support is particularly flaky - some packages work, some dont (this
   is by virtue of the [npm module](https://github.com/wix/import-cost/), and,
   thus, unavoidable)
2. Long wait times - once again, the npm module may take quite a while before
   fully parsing packages
3. [pnpm problems](https://github.com/barrett-ruth/import-cost.nvim/issues/5)

## Acknowledgements

1. [wix/import-cost](https://github.com/wix/import-cost/): provides the node
   backend that calculates the import costs
2. [import-cost](https://marketplace.visualstudio.com/items?itemName=wix.vscode-import-cost):
   the original VSCode plugin that started it all
3. [vim-import-cost](https://github.com/yardnsm/vim-import-cOst): inspired me to do it in neovim!
