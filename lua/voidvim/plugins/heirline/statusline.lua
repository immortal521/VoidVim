local components = require("voidvim.plugins.heirline.components")

return {
  components.Mode,
  { provider = "%=" },
  components.Time,
}
