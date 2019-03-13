import {{project.app.main}};

import snow.Snow;
import snow.types.Types.SnowConfig;

class SnowApp {

    public static var _host : {{project.app.main}};
    public static var _snow : Snow;

    public static function main () {

            //Create the runtime
        _snow = new Snow();
            //Create the app class, give it to the bootstrapper
        _host = new {{project.app.main}}();

        var _snow_config : SnowConfig = {
            has_loop : {{toString snow.config.has_loop}},
            config_path : '{{toString snow.config.config_path}}',
            app_package : '{{toString project.app.package}}'
        };

            //Start up
        _snow.init( _snow_config, _host );

    } //main

} //SnowApp
