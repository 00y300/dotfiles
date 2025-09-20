return {
  -- Define the nvim-java plugin with configuration
  "nvim-java/nvim-java",
  ft = { "java" },
  config = function()
    -- Configure nvim-java
    require("java").setup({
      root_markers = {
        "settings.gradle",
        "settings.gradle.kts",
        "pom.xml",
        "build.gradle",
        "mvnw",
        "gradlew",
        "build.gradle.kts",
        ".git",
      },
      java_test = {
        enable = true,
      },
      java_debug_adapter = {
        enable = true,
      },
      spring_boot_tools = {
        enable = true,
      },
      jdk = {
        -- auto_install = true,
        auto_install = false,
      },
      notifications = {
        dap = false,
      },
      verification = {
        invalid_order = true,
        duplicate_setup_calls = true,
        invalid_mason_registry = false,
      },
    })
  end,
}
