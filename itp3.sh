#!/bin/bash
cd ~/rails_projects/tl-blackjack-sinatra

tmux start-server

tmux new-session -d -s itp3 -n workspace
tmux new-window -t itp3:2 -n public
tmux new-window -t itp3:3 -n views
tmux new-window -t itp3:4 -n irb
tmux new-window -t itp3:5 -n thin
tmux new-window -t itp3:6 -n git

tmux send-keys -t itp3:2 "cd ~/rails_projects/tl-blackjack-sinatra/public; ls -la" C-m
tmux send-keys -t itp3:3 "cd ~/rails_projects/tl-blackjack-sinatra/views; ls -la" C-m
tmux send-keys -t itp3:4 "irb" C-m
tmux send-keys -t itp3:5 "shotgun main.rb" C-m
tmux send-keys -t itp3:6 "git status" C-m

tmux select-window -t itp3:6

tmux attach-session -t itp3

