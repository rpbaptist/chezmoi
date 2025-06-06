return {
  "monaqa/dial.nvim",
  opts = {
    groups = {
      default = {
        require("dial.augend").constant.alias.bool,
        require("dial.augend").integer.alias.decimal_int,
      },
    },
  },
}
