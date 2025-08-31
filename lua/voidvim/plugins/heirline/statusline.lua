local components = require("voidvim.plugins.heirline.components")

return {
  components.Mode,
  components.Git,
  { provider = "%=" },
  components.Time,
}
