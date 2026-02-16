
const context = require.context("./controllers", true, /controller\.js$/)
window.Stimulus.load(window.definitionsFromContext(context))

