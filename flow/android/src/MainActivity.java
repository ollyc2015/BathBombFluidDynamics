package {{project.app.package}};


public class MainActivity extends org.snowkit.snow.SnowActivity {

    // 1. Override this file using flow,

            // i.e
            /*
                if: {
                  android: {
                    build: {
                      files: {
                        activity : {
                            path:"src/custom/MainActivity.java => project/src/MainActivity.java",
                            template:'project'
                        }
                      }
                    }
                  }
                }
            */

    // 2. Add custom Android Java here.

} //MainActivity

