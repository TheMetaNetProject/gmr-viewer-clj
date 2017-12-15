(defproject gmr-viewer "0.1.3-SNAPSHOT"
  :description "A Viewer for the GMR database."
  :url "http://localhost:3000"
  
  ;:bootclasspath true
  
  :dependencies [[org.clojure/clojure "1.6.0"]
                 [lib-noir "0.9.9"]
                 [ring-server "0.4.0"]
                 [selmer "0.8.2"]
                 [com.taoensso/timbre "3.4.0"]
                 [com.taoensso/tower "3.0.2"]
                 [markdown-clj "0.9.66"]
                 [environ "1.0.0"]
                 [im.chit/cronj "1.4.3"]
                 [noir-exception "0.2.5"]
                 [prone "0.8.2"]
                 [com.ashafa/clutch "0.4.0"]
                 ;[org.clojure/clojurescript "0.0-3297"]
                 [hiccup "1.0.5"]
                 [cheshire "5.5.0"]
                 [clj-jade "0.1.7"]
                 [ring.middleware.logger "0.5.0"]
                 [clojurewerkz/elastisch "2.1.0"]]
  
  :bower {:directory "resources/public/js/lib"}
  :bower-dependencies [[angular "~1.2.x"]
                       [angular-mocks "~1.2.x"]
                       [bootstrap "~3.3.1"]
                       [angular-route "~1.2.x"]
                       [angular-resource "~1.2.x"]
                       ;[angular-animate "~1.2.x"]
                       [jquery "~2.1.1"]
                       [lodash "~2.4.1"]
                       [d3 "~3.4.11"]
                       [angular-busy "~4.0.x"]]
  
  :repl-options {:init-ns gmr-viewer.repl}
  
  :jvm-opts ["-server"]
  
  :main ^:skip-aot gmr-viewer.repl
  
  :plugins [[lein-ring "0.9.4"]
            [lein-environ "1.0.0"]
            [lein-ancient "0.6.7"]
            [lein-npm "0.5.0"]
            [lein-bower "0.5.2"]
            [lein-gorilla "0.3.4"]]
  
  :ring {:handler gmr-viewer.handler/app
         :init    gmr-viewer.handler/init
         :destroy gmr-viewer.handler/destroy}
  
  :profiles {:uberjar {:aot :all}
             :production {:ring {:open-browser? false
                                 :stacktraces?  false
                                 :auto-reload?  false}}
             :dev {:ring {:open-browser? false
                          :stacktraces?  true
                          :auto-reload?  true}
                   :dependencies [[ring-mock "0.1.5"]
                                  [ring/ring-devel "1.3.2"]
                                  [pjstadig/humane-test-output "0.7.0"]]
                   :injections [(require 'pjstadig.humane-test-output)
                                (pjstadig.humane-test-output/activate!)]
                   :env {:dev true
                         :port "3000"}}})
