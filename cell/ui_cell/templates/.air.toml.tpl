root = "."
tmp_dir = "air"

[build]
  args_bin = ["serve"]
  bin = "./air/main"
  cmd = "go build -o ./air/main ."
  delay = 1000
  exclude_dir = ["assets", "air", "vendor", "testdata", "api/gen", "temp", "redis_cache", "ui/public/static"]
  exclude_file = []
  exclude_regex = ["_test.go", "_templ.go"]
  exclude_unchanged = false
  follow_symlink = false
  full_bin = ""
  include_dir = []
  include_ext = ["go", "templ",  "proto", "ts", "tsx"]
  include_file = []
  kill_delay = "0s"
  log = "build-errors.log"
  poll = false
  poll_interval = 0
  post_cmd = []
  pre_cmd = ["make build-ui"]
  rerun = false
  rerun_delay = 500
  send_interrupt = false
  stop_on_error = false

[color]
  app = ""
  build = "yellow"
  main = "magenta"
  runner = "green"
  watcher = "cyan"

[log]
  main_only = false
  time = false

[misc]
  clean_on_exit = false

[screen]
  clear_on_rebuild = false
  keep_scroll = true