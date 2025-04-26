{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-vscode-remote.remote-ssh
      vscodevim.vim
      github.copilot
      eamodio.gitlens
      donjayamanne.githistory
      emroussel.atomize-atom-one-dark-theme
      vscode-icons-team.vscode-icons
      oderwat.indent-rainbow
      alefragnani.bookmarks
      kamikillerto.vscode-colorize
      esbenp.prettier-vscode
    ];

    userSettings = {
      "workbench.colorTheme" = "One Dark Pro"; # By binaryify
      "workbench.sideBar.location" = "right";
      "workbench.iconTheme" = "vscode-icons";
      "editor.formatOnSave" = true;

      "[typescript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      # NOTE:  More options
      "chat.agent.enabled" = true;

      # NOTE: VSCode Vim
      "vim.leader" = " ";
      "vim.useSystemClipboard" = false;
      "vim.normalModeKeyBindingsNonRecursive" = [
        {
          "before" = ["<leader>" "/"];
          "commands" = ["editor.action.commentLine"];
        }
        {
          "before" = ["<leader>" "h"];
          "commands" = [":noh"];
        }
        {
          "before" = ["<leader>" "w"];
          "commands" = [":w"];
        }
        # {
        #   "before" = ["<leader>" "d"];
        #   "after" = ["\"" "_" "d"];
        # },
        {
          # This focuses the hover window
          "before" = ["K"];
          "commands" = ["editor.debug.action.showDebugHover"];
        }
        # {
        #   "before" = ["K"];
        #   "commands" = ["editor.action.showHover"];
        # },
        {
          "before" = ["g" "r"];
          "commands" = ["editor.action.goToReferences"];
        }
        # MOVE LINES
        {
          "before" = ["alt+j"];
          "commands" = ["editor.action.moveLinesDownAction"];
        }
        {
          "before" = ["alt+k"];
          "commands" = ["editor.action.moveLinesUpAction"];
        }
        # QUICK OPEN
        {
          "before" = ["<leader>" "f" "f"];
          "commands" = ["workbench.action.quickOpen"];
          #  "when" = "inFilesPicker && inQuickOpen" }]
        }
        {
          "before" = ["<leader>" "f" "w"];
          "commands" = ["livegrep.search"];
        }
        # BUFFER COMMANDS
        {
          "before" = ["<leader>" "b" "h"];
          "commands" = ["workbench.action.closeEditorsToTheLeft"];
        }
        {
          "before" = ["<leader>" "b" "l"];
          "commands" = ["workbench.action.closeEditorsToTheRight"];
        }
        {
          "before" = ["<leader>" "b" "b"];
          "commands" = ["bookmarks.toggle"];
          "when" = ["editorTextFocus"];
        }
        # CODE ACTIONS
        {
          "before" = ["<leader>" "l" "a"];
          "commands" = ["editor.action.quickFix"];
        }
        {
          "before" = ["<leader>" "j"];
          "commands" = ["workbench.action.togglePanel"];
        }
        # DEBUG
        {
          "before" = ["<leader>" "d" "t"];
          "commands" = ["editor.debug.action.toggleBreakpoint"];
          "when" = ["debuggersAvailable, editorTextFocus"];
        }
        # {
        #   "before" = ["<leader>" "t"];
        #   "commands" = ["workbench.action.togglePanel"];
        # }
        # FILE TREE
        # {
        #   "before" = ["<leader>" "e"];
        #   "commands" = ["workbench.view.explorer"];
        #   # "when" = "viewContainer.workbench.view.explorer.enabled";
        # }
        {
          "before" = ["<leader>" "e"];
          "commands" = ["workbench.action.toggleSidebarVisibility"];
        }
        # CLOSE TAB
        {
          "before" = ["<leader>" "c"];
          "commands" = ["workbench.action.closeActiveEditor"];
        }
        # NAVIGATE TABS
        {
          # Navigate to the next tab
          "before" = ["<S-l>"];
          "commands" = ["workbench.action.nextEditor"];
        }

        {
          # Navigate to the previous tab
          "before" = ["<S-h>"];
          "commands" = ["workbench.action.previousEditor"];
        }
        # GIT
        {
          "before" = ["<leader>" "g" "l"];
          "commands" = ["gitlens.toggleFileBlame"];
        }
        # WHICH KEY
        {
          "before" = ["<space>"];
          "commands" = ["whichkey.show"];
        }
      ];
      "vim.visualModeKeyBindingsNonRecursive" = [
        {
          "before" = ["<leader>" "/"];
          "commands" = ["editor.action.commentLine"];
        }
        {
          "before" = ["<leader>" "d"];
          "after" = ["\"" "_" "d"];
        }
        {
          "before" = ["<leader>" "c"];
          "after" = ["\"" "_" "c"];
        }
        {
          "before" = [">"];
          "after" = [">" "g" "v"];
        }
        {
          "before" = ["<"];
          "after" = ["<" "g" "v"];
        }
        # MOVE LINES
        {
          "before" = ["<alt+j>"];
          "commands" = ["editor.action.moveLinesDownAction"];
        }
        {
          "before" = ["<alt+k>"];
          "commands" = ["editor.action.moveLinesUpAction"];
        }
        # WHICH KEY
        {
          "before" = ["<space>"];
          "commands" = ["whichkey.show"];
        }
      ];
      "vim.handleKeys" = {
        "<C-b>" = false;
        "<C-j>" = false;
      };
      # NOTE: End of VSCode Vim
    };

    keybindings = [
      {
        "key" = "ctrl+`";
        "command" = "workbench.action.terminal.focus";
      }
      {
        "key" = "ctrl+`";
        "command" = "workbench.action.focusActiveEditorGroup";
        "when" = "terminalFocus";
      }
      {
        "key" = "h";
        "command" = "editor.action.scrollLeftHover";
        "when" = "editorHoverFocused";
      }
      {
        "key" = "j";
        "command" = "editor.action.scrollDownHover";
        "when" = "editorHoverFocused";
      }
      {
        "key" = "k";
        "command" = "editor.action.scrollUpHover";
        "when" = "editorHoverFocused";
      }
      {
        "key" = "l";
        "command" = "editor.action.scrollRightHover";
        "when" = "editorHoverFocused";
      }
      {
        "key" = "alt+j";
        "command" = "vim.remap";
        "when" = "inputFocus && vim.mode == 'Normal' || vim.mode == 'Visual'";
        "args" = {
          "after" = ["alt+j"];
        };
      }
      {
        "key" = "alt+k";
        "command" = "vim.remap";
        "when" = "inputFocus && vim.mode == 'Normal' || vim.mode == 'Visual'";
        "args" = {
          "after" = ["alt+k"];
        };
      }
      {
        "key" = "tab";
        "command" = "selectNextSuggestion";
        "when" = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus";
      }
      {
        "key" = "shift+tab";
        "command" = "selectPrevSuggestion";
        "when" = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus";
      }
      {
        "key" = "ctrl+enter";
        "command" = "mdb.runAllPlaygroundBlocks";
        "when" = "mdb.isPlayground";
      }
      {
        "key" = "ctrl+alt+r";
        "command" = "-mdb.runAllPlaygroundBlocks";
        "when" = "mdb.isPlayground";
      }
      {
        "key" = "ctrl+j";
        "command" = "workbench.action.togglePanel";
        "when" = "terminalFocus";
      }
      # TERMINAL
      {
        "key" = "ctrl+t";
        "command" = "workbench.action.terminal.focus";
        "when" = "editorTextFocus";
      }
      {
        "key" = "ctrl+l";
        "command" = "workbench.action.previousEditor";
        "when" = "terminalFocus";
      }
    ];
  };
}
