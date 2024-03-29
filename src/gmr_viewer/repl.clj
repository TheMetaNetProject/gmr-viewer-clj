(ns gmr-viewer.repl
  (:use gmr-viewer.handler
        ring.server.standalone
        [ring.middleware file-info file]
        [taoensso.timbre :as timbre]
        [environ.core :refer [env]]))

(defonce server (atom nil))

(defn get-handler []
  ;; #'app expands to (var app) so that when we reload our code,
  ;; the server is forced to re-resolve the symbol in the var
  ;; rather than having its own copy. When the root binding
  ;; changes, the server picks it up without having to restart.
  (-> #'app
      ;; Makes static assets in $PROJECT_DIR/resources/public/ available.
      (wrap-file "resources")
      ;; Content-Type, Content-Length, and Last Modified headers for files in body
      (wrap-file-info)))

(defn parse-port [port]
  (Integer/parseInt (or port (env :port) "3000")))

(defn start-server
  "used for starting the server in development mode from REPL"
  [& [port]]
  (println (format "port: %s" port))
  (let [port (parse-port port)]
    (reset! server
            (serve (get-handler)
                   {:port port
                    :init init
                    :open-browser? false
                    :auto-reload? true
                    :auto-refresh? true
                    :destroy destroy
                    :join? false}))
    (println (str "You can view the site at http://localhost:" port))))

(defn stop-server []
  (.stop @server)
  (reset! server nil))

(defn -main [& [port]]
  (.addShutdownHook (Runtime/getRuntime) (Thread. stop-server))
  (start-server port))