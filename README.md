# Vim ErbLint

The **Vim ErbLint** plugin for [Shopify/erb-lint](https://github.com/shopify/erb-lint)

## Requirements

 [Shopify/erb-lint](https://github.com/shopify/erb-lint)
 Install Shopify/erb-lint with `gem install erb_lint`

## Installation

Obtain a copy of this plugin and place in your Vim plugin directory.

Using with plugin manager 'dein' is available.
Example of 'dein_lazy.toml'
```
[[plugins]]
repo = 'tkatsu/vim-erblint'
on_ft = ['eruby']
if = 1
hook_source = '''
    autocmd BufWritePost *.erb ErbLint
'''
```

## Usage

You can use the `:ErbLint` command to run erblint and display the results.

You can also use the `:ErbLint` command together with 'erblint' options.
For example, `:ErbLint --autocorrect`, `:ErbLint --enable-linters space_indentation` and so on.

Using with 'scrooloose/Syntastic' is NOT available.

## License

The Vim ErbLint plugin is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT).

## Thank
  Special thanks to Mr. Yuta Nagamiya who is author of [vim-rubocop]( https://github.com/ngmy/vim-rubocop)
