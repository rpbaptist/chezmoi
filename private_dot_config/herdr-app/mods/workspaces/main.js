// Workspaces: repos and their worktrees with git, agent and GitHub pull request
// state, in the place of the Spaces list. One mod, four views by props().view:
// the list (default), its right-click "menu", the "new" worktree dialog and a "pr" pane.

import { View } from "gpui-kit";
import { props } from "herdr";
import { List } from "./list.js";
import { Menu } from "./menu.js";
import { New } from "./new.js";
import { Pr } from "./pr.js";

const VIEWS = { list: List, menu: Menu, new: New, pr: Pr };

export default class Workspaces extends View {
  init(p, cx) {
    this.view = new (VIEWS[props()?.view] ?? List)();
    this.view.init(p, cx);
  }

  render(cx) {
    return this.view.render(cx);
  }
}
