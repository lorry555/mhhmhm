class BaseLogger:
    def __init__(self) -> None:
        self.info = print


def token_text(token) -> str:
    # Most models stream str tokens, but some (e.g. Claude with thinking) stream lists of content blocks
    if isinstance(token, str):
        return token
    return "".join(
        block if isinstance(block, str) else block.get("text", "")
        for block in token
        if isinstance(block, str) or block.get("type") == "text"
    )


def extract_title_and_question(input_string):
    lines = input_string.strip().split("\n")

    title = ""
    question = ""
    is_question = False  # flag to know if we are inside a "Question" block

    for line in lines:
        if line.startswith("Title:"):
            title = line.split("Title: ", 1)[1].strip()
        elif line.startswith("Question:"):
            question = line.split("Question: ", 1)[1].strip()
            is_question = (
                True  # set the flag to True once we encounter a "Question:" line
            )
        elif is_question:
            # if the line does not start with "Question:" but we are inside a "Question" block,
            # then it is a continuation of the question
            question += "\n" + line.strip()

    return title, question


def create_vector_index(driver, dimension: int) -> None:
    index_query = """
    CREATE VECTOR INDEX stackoverflow IF NOT EXISTS FOR (m:Question) ON m.embedding
    OPTIONS {indexConfig: {`vector.dimensions`: $dimension, `vector.similarity_function`: 'cosine'}}
    """
    driver.query(index_query, {"dimension": dimension})
    index_query = """
    CREATE VECTOR INDEX top_answers IF NOT EXISTS FOR (m:Answer) ON m.embedding
    OPTIONS {indexConfig: {`vector.dimensions`: $dimension, `vector.similarity_function`: 'cosine'}}
    """
    driver.query(index_query, {"dimension": dimension})


def create_constraints(driver):
    driver.query(
        "CREATE CONSTRAINT question_id IF NOT EXISTS FOR (q:Question) REQUIRE (q.id) IS UNIQUE"
    )
    driver.query(
        "CREATE CONSTRAINT answer_id IF NOT EXISTS FOR (a:Answer) REQUIRE (a.id) IS UNIQUE"
    )
    driver.query(
        "CREATE CONSTRAINT user_id IF NOT EXISTS FOR (u:User) REQUIRE (u.id) IS UNIQUE"
    )
    driver.query(
        "CREATE CONSTRAINT tag_name IF NOT EXISTS FOR (t:Tag) REQUIRE (t.name) IS UNIQUE"
    )
