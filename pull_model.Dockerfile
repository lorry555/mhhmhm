#syntax = docker/dockerfile:1.4

FROM ollama/ollama:latest AS ollama
FROM babashka/babashka:latest

# just using as a client - never as a server
COPY --from=ollama /bin/ollama ./bin/ollama

COPY <<EOF pull_model.clj
(ns pull-model
  (:require [babashka.process :as process]
            [clojure.core.async :as async]
            [clojure.string :as str]))

;; LLM values with these prefixes are served by a hosted API, not Ollama (see load_llm in chains.py)
(def hosted-prefixes ["gpt-" "claude-" "gemini-" "bedrock:"])

(defn pull-model [url model]
  (println (format "pulling ollama model %s using %s" model url))

  ;; ----------------------------------------------------------------------
  ;; just call `ollama pull` here - create OLLAMA_HOST from OLLAMA_BASE_URL
  ;; ----------------------------------------------------------------------
  ;; TODO - this still doesn't show progress properly when run from docker compose

  (let [done (async/chan)]
    (async/go-loop [n 0]
      (let [[v _] (async/alts! [done (async/timeout 5000)])]
        (if (= :stop v) :stopped (do (println (format "... pulling model (%ss) - will take several minutes" (* n 10))) (recur (inc n))))))
    ;; :extra-env keeps HOME etc. - the ollama CLI panics without $HOME
    (process/shell {:extra-env {"OLLAMA_HOST" url} :out :inherit :err :inherit} (format "bash -c './bin/ollama show %s --modelfile > /dev/null || ./bin/ollama pull %s'" model model))
    (async/>!! done :stop)))

(try
  (let [llm (get (System/getenv) "LLM")
        embedding-model (get (System/getenv) "EMBEDDING_MODEL")
        url (get (System/getenv) "OLLAMA_BASE_URL")
        models (cond-> []
                 (and llm (not-any? #(str/starts-with? llm %) hosted-prefixes)) (conj llm)
                 (= embedding-model "ollama") (conj "nomic-embed-text"))]
    (if (and url (seq models))
      (doseq [model models] (pull-model url model))
      (println "OLLAMA models only pulled if OLLAMA_BASE_URL is set and LLM is an Ollama model or EMBEDDING_MODEL is ollama")))
  (catch Throwable _ (System/exit 1)))
EOF

ENTRYPOINT ["bb", "-f", "pull_model.clj"]

