"""
Import Java basics course from markdown lecture notes into smart-learning-system.

Usage:
  cd E:/smart-learning-system/agent
  .venv/Scripts/python scripts/import_java_course.py

Steps:
  1. Login as admin to get JWT
  2. Create "Java基础入门" course (if not exists)
  3. Parse 9 markdown files, split by ## sections
  4. POST each section as a knowledge point
  5. Re-ingest ChromaDB + BM25
"""
import os, re, sys, json, urllib.request, urllib.error, asyncio, logging

BASE_DIR = r"E:\javatestragsql\java\01阶段：java基础入门\Java基础班讲义"
BACKEND = "http://127.0.0.1:9090/api"
AGENT_SRC = "E:/smart-learning-system/agent/src"

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
logger = logging.getLogger(__name__)


def api_request(method, path, body=None, token=None):
    """Make JSON API request to backend."""
    url = f"{BACKEND}{path}"
    data = json.dumps(body).encode("utf-8") if body else None
    headers = {"Content-Type": "application/json; charset=utf-8"}
    if token:
        headers["Authorization"] = f"Bearer {token}"

    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        logger.error("HTTP %d %s: %s", e.code, path, body[:300])
        raise


def login():
    """Login as admin, return JWT token."""
    resp = api_request("POST", "/auth/login", {
        "username": "admin",
        "password": "admin123",
    })
    token = resp["data"]["token"]
    logger.info("Logged in as admin, token=%s...", token[:20])
    return token


def create_course(token):
    """Create Java course, return course ID. Skips if already exists."""
    # Check if course exists
    resp = api_request("GET", "/courses", token=token)
    for c in resp.get("data", []):
        if c["name"] == "Java基础入门":
            logger.info("Course already exists: id=%d", c["id"])
            return c["id"]

    resp = api_request("POST", "/courses", {
        "name": "Java基础入门",
        "description": "Java基础班全套讲义，涵盖Java入门、数据类型、流程控制、数组、方法、面向对象、常用API、综合项目",
        "category": "Java",
    }, token=token)
    course_id = resp["data"]["id"]
    logger.info("Created course: id=%d", course_id)
    return course_id


def parse_markdown_sections(filepath):
    """Parse a markdown file, splitting into sections by ## headings.

    Returns list of (section_title, section_content) pairs.
    The content includes everything from the ## heading to the next ## or EOF.
    """
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # Remove the # day title line (keep it for context)
    main_title = ""
    m = re.match(r"^# (.+)$", content, re.MULTILINE)
    if m:
        main_title = m.group(1).strip()

    # Split by ## headings
    sections = []
    # Find all ## heading positions
    pattern = re.compile(r"^## (.+)$", re.MULTILINE)
    matches = list(pattern.finditer(content))

    for i, m in enumerate(matches):
        title = m.group(1).strip()
        start = m.end() + 1  # after the heading line
        end = matches[i + 1].start() if i + 1 < len(matches) else len(content)
        body = content[start:end].strip()

        if body:
            sections.append((title, body))

    return main_title, sections


def import_knowledge_points(token, course_id, day_name, sections):
    """POST knowledge points to backend. Returns count created."""
    created = 0
    for idx, (title, content) in enumerate(sections):
        # First 120 chars as description
        desc = content[:120].replace("\n", " ").strip()
        payload = {
            "name": title,
            "description": desc,
            "learningContent": f"## {title}\n\n{content}",
            "courseId": course_id,
            "level": 0,
        }
        try:
            resp = api_request("POST", "/knowledge-graph/nodes", payload, token=token)
            logger.info("  [%s] %s → id=%d", day_name, title[:50], resp["data"]["id"])
            created += 1
        except urllib.error.HTTPError:
            logger.warning("  [%s] FAILED: %s", day_name, title[:50])
    return created


def main():
    token = login()
    course_id = create_course(token)

    # Process all 9 day directories
    total = 0
    day_dirs = sorted([
        d for d in os.listdir(BASE_DIR)
        if os.path.isdir(os.path.join(BASE_DIR, d))
    ])

    for day_dir in day_dirs:
        day_path = os.path.join(BASE_DIR, day_dir)
        md_files = [f for f in os.listdir(day_path) if f.endswith(".md")]
        if not md_files:
            continue

        md_path = os.path.join(day_path, md_files[0])
        day_short = day_dir.replace("day0", "day").split("-")[0]
        main_title, sections = parse_markdown_sections(md_path)
        logger.info("Processing %s: %d sections", day_dir, len(sections))
        created = import_knowledge_points(token, course_id, day_short, sections)
        total += created

    logger.info("Done! Created %d knowledge points total.", total)

    # Re-ingest agent
    logger.info("Re-ingesting agent knowledge base...")
    sys.path.insert(0, AGENT_SRC)
    os.chdir(os.path.dirname(AGENT_SRC))

    async def reingest():
        from rag_service import ingest_knowledge_points
        count = await ingest_knowledge_points()
        logger.info("Agent re-ingested: %d chunks", count)

    asyncio.run(reingest())


if __name__ == "__main__":
    main()
