module Rails
  class Initializer
    def load_plugin_with_desert(directory)
      return if Desert::Manager.plugin_exists?(directory)
      plugin = Desert::Manager.register_plugin(directory) do
        load_plugin_without_desert(directory)
      end
      warn "WARNING: MIGRATIONS NOT UP TO DATE: #{plugin.name}" unless plugin.up_to_date?
      # TODO: Can we use Initializer::Configuration#default_load_paths to do this?
      Dependencies.load_paths << plugin.models_path
      Dependencies.load_paths << plugin.controllers_path
      Dependencies.load_paths << plugin.helpers_path
      configuration.controller_paths << plugin.controllers_path
    end
    alias_method_chain :load_plugin, :desert

    def require_plugin(plugin_name)
      find_plugins(configuration.plugin_paths).sort.each do |path|
        return load_plugin(path) if File.basename(path) == plugin_name
      end
      raise "Plugin '#{plugin_name}' does not exist"
    end
  end
end