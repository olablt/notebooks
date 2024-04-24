
tmux send-keys -t trendline.0 C-c;
tmux send-keys -t trendline.0 C-l;
tmux send-keys -t trendline.0 "tmux clear-history" ENTER
# tmux send-keys -t trendline.0 "go run ./apps/06-subscribe/" ENTER
# tmux send-keys -t trendline.0 "go run ./apps/07-strategy/" ENTER
# tmux send-keys -t trendline.0 "go run ./apps/08-donchian2/" ENTER
# tmux send-keys -t trendline.0 "python3 walkforward.py" ENTER
tmux send-keys -t trendline.0 "python3 trendline_break_dataset.py" ENTER
# tmux send-keys -t trendline.0 "python3 test.py" ENTER
