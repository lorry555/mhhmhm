# GenAI Stack
The GenAI Stack will get you started building your own GenAI application in no time.
The demo applications can serve as inspiration or as a starting point.
Learn more about the details in the [technical blog post](https://neo4j.com/developer-blog/genai-app-how-to-build/).

# Configure

Create a `.env` file from the environment template file `env.example`

Available variables:
| Variable Name          | Default value                      | Description                                                             |
|------------------------|------------------------------------|-------------------------------------------------------------------------|
| OLLAMA_BASE_URL        | http://host.docker.internal:11434  | REQUIRED - URL to Ollama LLM API                                        |   
| NEO4J_URI              | neo4j://database:7687              | REQUIRED - URL to Neo4j database                                        |
| NEO4J_USERNAME         | neo4j                              | REQUIRED - Username for Neo4j database                                  |
| NEO4J_PASSWORD         | password                           | REQUIRED - Password for Neo4j database                                  |
| LLM                    | llama3.2                           | REQUIRED - Any Ollama model tag, or a hosted model name: `gpt-...` (OpenAI), `claude-...` (Anthropic), `gemini-...` (Google) or `bedrock:<model id>` (AWS Bedrock) |
| EMBEDDING_MODEL        | sentence_transformer               | REQUIRED - Can be sentence_transformer, openai, aws, ollama or google-genai |
| AWS_ACCESS_KEY_ID      |                                    | REQUIRED - Only if LLM=bedrock:... or EMBEDDING_MODEL=aws               |
| AWS_SECRET_ACCESS_KEY  |                                    | REQUIRED - Only if LLM=bedrock:... or EMBEDDING_MODEL=aws               |
| AWS_DEFAULT_REGION     |                                    | REQUIRED - Only if LLM=bedrock:... or EMBEDDING_MODEL=aws               |
| OPENAI_API_KEY         |                                    | REQUIRED - Only if LLM=gpt-... or EMBEDDING_MODEL=openai                |
| ANTHROPIC_API_KEY      |                                    | REQUIRED - Only if LLM=claude-...                                       |
| GOOGLE_API_KEY         |                                    | REQUIRED - Only if LLM=gemini-... or EMBEDDING_MODEL=google-genai       |
| LANGCHAIN_ENDPOINT     | "https://api.smith.langchain.com"  | OPTIONAL - URL to Langchain Smith API                                   |
| LANGCHAIN_TRACING_V2   | false                              | OPTIONAL - Enable Langchain tracing v2                                  |
| LANGCHAIN_PROJECT      |                                    | OPTIONAL - Langchain project name                                       |
| LANGCHAIN_API_KEY      |                                    | OPTIONAL - Langchain API key                                            |

## LLM Configuration
MacOS and Linux users can use any LLM that's available via Ollama. Check the "tags" section under the model page you want to use on https://ollama.com/library and write the tag for the value of the environment variable `LLM=` in the `.env` file.

All platforms can use hosted models instead (bring your own API key). The start of the `LLM` value picks the provider:

| `LLM` value | Provider | Example |
|---|---|---|
| `gpt-...` | OpenAI (`OPENAI_API_KEY`) | `LLM=gpt-6-luna` |
| `claude-...` | Anthropic (`ANTHROPIC_API_KEY`) | `LLM=claude-opus-5-5` |
| `gemini-...` | Google Gemini (`GOOGLE_API_KEY`) | `LLM=gemini-3.7-flash` |
| `bedrock:<model id>` | AWS Bedrock (`AWS_*` variables) | `LLM=bedrock:us.anthropic.claude-opus-5-5` |
| anything else | Ollama model tag | `LLM=llama3.2` |

**MacOS**
Install [Ollama](https://ollama.com) on MacOS and start it before running `docker compose up` using `ollama serve` in a separate terminal.

**Linux**
No need to install Ollama manually, it will run in a container as
part of the stack when running with the Linux profile: run `docker compose --profile linux up`.
Make sure to set the `OLLAMA_BASE_URL=http://llm:11434` in the `.env` file when using Ollama docker container.

To use the Linux-GPU profile: run `docker compose --profile linux-gpu up`. Also change `OLLAMA_BASE_URL=http://llm-gpu:11434` in the `.env` file.

**Windows**
Ollama now supports Windows. Install [Ollama](https://ollama.com) on Windows and start it before running `docker compose up` using `ollama serve` in a separate terminal. Alternatively, Windows users can use one of the hosted models from the table above.

## Embedding model
`EMBEDDING_MODEL` picks the model used to embed questions, answers and PDF chunks:

| `EMBEDDING_MODEL` | Model | Dimensions |
|---|---|---|
| `sentence_transformer` | `all-MiniLM-L6-v2`, runs locally | 384 |
| `ollama` | `nomic-embed-text` (pulled automatically) | 768 |
| `openai` | `text-embedding-3-small` | 1536 |
| `aws` | `amazon.titan-embed-text-v2:0` | 1024 |
| `google-genai` | `gemini-embedding-2` | 768 |

Stored embeddings only work with the model that created them. If you switch `EMBEDDING_MODEL`, or upgrade from an older version of this stack, delete the `data/` folder (or the `stackoverflow`, `top_answers` and `pdf_bot` vector indexes) and import your data again.

# Develop

> [!WARNING]
> There is a performance issue that impacts python applications in the `4.24.x` releases of Docker Desktop. Please upgrade to the latest release before using this stack.

**To start everything**
```
docker compose up
```
If changes to build scripts have been made, **rebuild**.
```
docker compose up --build
```

To enter **watch mode** (auto rebuild on file changes).
First start everything, then in new terminal:
```
docker compose watch
```

**Shutdown**
If health check fails or containers don't start up as expected, shutdown
completely to start up again.
```
docker compose down
```

# Applications

Here's what's in this repo:

| Name | Main files | Compose name | URLs | Description |
|---|---|---|---|---|
| Support Bot | `bot.py` | `bot` | http://localhost:8501 | Main usecase. Fullstack Python application. |
| Stack Overflow Loader | `loader.py` | `loader` | http://localhost:8502 | Load SO data into the database (create vector embeddings etc). Fullstack Python application. |
| PDF Reader | `pdf_bot.py` | `pdf_bot` | http://localhost:8503 | Read local PDF and ask it questions. Fullstack Python application. |
| Standalone Bot API | `api.py` | `api` | http://localhost:8504 | Standalone HTTP API streaming (SSE) + non-streaming endpoints Python. |
| Standalone Bot UI | `front-end/` | `front-end` | http://localhost:8505 | Standalone client that uses the Standalone Bot API to interact with the model. JavaScript (Svelte) front-end. |

The database can be explored at http://localhost:7474.

## App 1 - Support Agent Bot

UI: http://localhost:8501
DB client: http://localhost:7474

- answer support question based on recent entries
- provide summarized answers with sources
- demonstrate difference between
    - RAG Disabled (pure LLM response)
    - RAG Enabled (vector + knowledge graph context)
- allow to generate a high quality support ticket for the current conversation based on the style of highly rated questions in the database.

![](.github/media/app1-rag-selector.png)
*(Chat input + RAG mode selector)*

|  |  |
|---|---|
| ![](.github/media/app1-generate.png) | ![](.github/media/app1-ticket.png) |
| *(CTA to auto generate support ticket draft)* | *(UI of the auto generated support ticket draft)* |

---

##  App 2 - Loader

UI: http://localhost:8502
DB client: http://localhost:7474

- import recent Stack Overflow data for certain tags into a KG
- embed questions and answers and store them in vector index
- UI: choose tags, run import, see progress, some stats of data in the database
- Load high ranked questions (regardless of tags) to support the ticket generation feature of App 1.




|  |  |
|---|---|
| ![](.github/media/app2-ui-1.png) | ![](.github/media/app2-model.png) |

## App 3 Question / Answer with a local PDF
UI: http://localhost:8503  
DB client: http://localhost:7474

This application lets you load a local PDF into text
chunks and embed it into Neo4j so you can ask questions about
its contents and have the LLM answer them using vector similarity
search.

![](.github/media/app3-ui.png)

## App 4 Standalone HTTP API
Endpoints: 
  - http://localhost:8504/query?text=hello&rag=false (non streaming)
  - http://localhost:8504/query-stream?text=hello&rag=false (SSE streaming)

Example cURL command:
```bash
curl http://localhost:8504/query-stream\?text\=minimal%20hello%20world%20in%20python\&rag\=false
```

Exposes the functionality to answer questions in the same way as App 1 above. Uses
same code and prompts.

## App 5 Static front-end
UI: http://localhost:8505

This application has the same features as App 1, but is built separate from
the back-end code using modern best practices (Vite, Svelte, Tailwind).  
The auto-reload on changes are instant using the Docker watch `sync` config.  
![](.github/media/app5-ui.png)
