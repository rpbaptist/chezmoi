return {
	"afewyards/codereview.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = { "CodeReview" },
	opts = {
    picker = "snacks",
    open_in_tab = false,
    ai = {
      review_level = "suggestion"
    },
  },
}
