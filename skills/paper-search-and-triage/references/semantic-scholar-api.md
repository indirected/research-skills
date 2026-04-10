# Semantic Scholar API Reference

The Semantic Scholar Academic Graph API is the primary search backend for the paper-search-and-triage
skill. This document covers the endpoints, parameters, rate limits, and field definitions used in
the workflow.

API documentation (external): https://api.semanticscholar.org/api-docs/

---

## Base URL

```
https://api.semanticscholar.org/graph/v1/
```

No authentication is required for read operations at low volume. An API key raises rate limits
significantly (see Rate Limits below).

---

## Endpoint: Paper Search

```
GET https://api.semanticscholar.org/graph/v1/paper/search
```

### Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `query` | string (required) | Full-text search query. URL-encode spaces as `+`. Supports boolean operators: `AND`, `OR`, `NOT`. |
| `fields` | string | Comma-separated list of fields to return (see Fields section below). |
| `limit` | integer | Number of results per page. Maximum: 100. Default: 10. Use 20-50 for triage runs. |
| `offset` | integer | Pagination offset. Default: 0. Increment by `limit` to get next page. |
| `publicationDateOrYear` | string | Filter by date range: `YYYY-MM-DD:YYYY-MM-DD` or `YYYY:YYYY` for year range. Example: `2023-01-01:2026-04-02` |
| `venue` | string | Filter to specific venue name. Use carefully — venue names are inconsistent. |
| `fieldsOfStudy` | string | Comma-separated fields: `Computer Science`, `Mathematics`, etc. |
| `openAccessPdf` | (flag) | If present, filter to papers with open-access PDFs. Useful for synthesis skill. |

### Required Fields for This Workflow

Always request these fields (comma-separated in the `fields` parameter):

```
paperId,title,authors,year,venue,citationCount,openAccessPdf,abstract,externalIds,publicationTypes,referenceCount
```

Field descriptions:
- `paperId` — Semantic Scholar internal ID (40-char hex). Use as fallback `arxiv_id`.
- `title` — Full paper title string.
- `authors` — Array of `{authorId, name}` objects. Extract `.name` from each.
- `year` — Integer publication year.
- `venue` — String venue name (may be null; fall back to `publicationVenue.name`).
- `citationCount` — Integer. Use to identify influential papers (score boost if > 50).
- `openAccessPdf` — Object `{url, status}` or null. `.url` is the direct PDF link.
- `abstract` — Full abstract string (may be null for some papers).
- `externalIds` — Object containing `ArXiv`, `DOI`, `ACL`, `MAG`, etc. keys.
- `publicationTypes` — Array of strings: `JournalArticle`, `Conference`, `Book`, `Review`, etc.
- `referenceCount` — Integer. Papers with many references are often survey-like.

### Optional Fields (add as needed)

```
tldr,citations,references,authors.affiliations,publicationVenue
```

- `tldr` — AI-generated one-sentence summary. Useful as `abstract_snippet` fallback.
- `publicationVenue` — Object `{id, name, type, url}`. More reliable than `venue` string.

---

## Rate Limits

| Authentication | Rate Limit | Notes |
|---|---|---|
| No API key | 100 requests / 5 minutes | ~1 request per 3 seconds sustained |
| With API key (free) | 1 request / second | Apply at semanticscholar.org/product/api |
| With API key (partner) | Higher | Contact Semantic Scholar |

### Handling Rate Limit Errors

Response code `429 Too Many Requests` means rate limit exceeded. The response includes a
`Retry-After` header (seconds to wait). Strategy:

1. After receiving 429, wait the number of seconds in `Retry-After` (or 60 seconds if header absent).
2. Retry the same request.
3. If 429 persists after 3 retries, skip that query and note it in the triage report.

For the triage workflow (5-8 queries × 20 results each = 5-8 requests), the unauthenticated limit
is rarely hit if you spread queries over 30+ seconds total.

---

## Example curl Commands

### Basic keyword search (last 2 years, 20 results):
```bash
curl "https://api.semanticscholar.org/graph/v1/paper/search?query=LLM+automated+vulnerability+repair&fields=paperId,title,authors,year,venue,citationCount,openAccessPdf,abstract,externalIds&limit=20&publicationDateOrYear=2024-01-01:2026-04-02"
```

### With API key header:
```bash
curl -H "x-api-key: YOUR_API_KEY" \
  "https://api.semanticscholar.org/graph/v1/paper/search?query=automated+program+repair+security&fields=paperId,title,authors,year,venue,citationCount,openAccessPdf,abstract,externalIds&limit=50"
```

### Search with open-access PDF filter:
```bash
curl "https://api.semanticscholar.org/graph/v1/paper/search?query=LLM+patch+generation+C+vulnerability&fields=paperId,title,authors,year,venue,citationCount,openAccessPdf,abstract,externalIds&openAccessPdf&limit=20"
```

### Paginate to second page:
```bash
curl "https://api.semanticscholar.org/graph/v1/paper/search?query=LLM+vulnerability+repair&fields=paperId,title,authors,year,venue,citationCount,openAccessPdf,abstract,externalIds&limit=20&offset=20"
```

### Fetch a single paper by arXiv ID:
```bash
curl "https://api.semanticscholar.org/graph/v1/paper/arXiv:2403.18471?fields=paperId,title,authors,year,venue,citationCount,openAccessPdf,abstract,externalIds"
```

---

## Example Response Structure

```json
{
  "total": 1432,
  "offset": 0,
  "next": 20,
  "data": [
    {
      "paperId": "a3f2e1b4c5d6...",
      "title": "LLM-Driven Automated Repair of Memory Safety Vulnerabilities",
      "authors": [
        {"authorId": "1234567", "name": "Wang, Peng"},
        {"authorId": "2345678", "name": "Chen, Yifei"},
        {"authorId": "3456789", "name": "Liu, Junfeng"}
      ],
      "year": 2024,
      "venue": "CCS",
      "citationCount": 23,
      "openAccessPdf": {
        "url": "https://arxiv.org/pdf/2403.18471",
        "status": "GREEN"
      },
      "abstract": "We present a framework for automated repair of...",
      "externalIds": {
        "ArXiv": "2403.18471",
        "DOI": "10.1145/3576915.3623208",
        "ACL": null,
        "MAG": "987654321"
      }
    }
  ]
}
```

---

## Field Extraction Logic (Pseudocode)

```python
def extract_paper(s2_result):
    ext_ids = s2_result.get("externalIds", {}) or {}
    arxiv_id = ext_ids.get("ArXiv") or f"s2:{s2_result['paperId']}"
    
    authors_list = s2_result.get("authors", [])
    if len(authors_list) <= 3:
        authors_str = " ; ".join(a["name"] for a in authors_list)
    else:
        authors_str = " ; ".join(a["name"] for a in authors_list[:3]) + " et al."
    
    venue = (s2_result.get("venue") or 
             (s2_result.get("publicationVenue") or {}).get("name") or 
             "Unknown")
    if s2_result.get("year"):
        venue = f"{venue} {s2_result['year']}" if str(s2_result['year']) not in venue else venue
    
    abstract = s2_result.get("abstract") or ""
    snippet = (abstract[:297] + "...") if len(abstract) > 300 else abstract
    snippet = snippet.replace("\n", " ").replace("\r", " ")
    
    pdf = s2_result.get("openAccessPdf") or {}
    url = (pdf.get("url") or 
           (f"https://arxiv.org/abs/{ext_ids['ArXiv']}" if ext_ids.get("ArXiv") else None) or
           f"https://www.semanticscholar.org/paper/{s2_result['paperId']}")
    
    doi = ext_ids.get("DOI") or ""
    
    return {
        "arxiv_id": arxiv_id,
        "title": s2_result["title"],
        "authors": authors_str,
        "year": s2_result.get("year", ""),
        "venue": venue,
        "abstract_snippet": snippet,
        "url": url,
        "doi": doi,
        "citation_count": s2_result.get("citationCount", 0)
    }
```

---

## Recommended Query Set for AutoPatch Domain

Run these queries in sequence (each as a separate API call):

```
1. LLM automated vulnerability repair
2. automated program repair security vulnerability
3. large language model patch generation security
4. neural automated program repair C C++
5. LLM code security benchmark evaluation
6. fuzzing vulnerability detection machine learning
7. CVE automated fix generation neural
8. software vulnerability localization neural network
```

After running all 8, check for duplicates across result sets (same `paperId` may appear in
multiple queries — deduplicate before adding to CSV).

---

## Alternative: Semantic Scholar Bulk Download

For large-scale sweeps (e.g., all papers from a specific venue), Semantic Scholar offers a bulk
data download via S3. This is rarely needed for the triage workflow but is documented at:
https://api.semanticscholar.org/api-docs/#tag/Paper-Data

For the standard weekly triage workflow, the search endpoint above is sufficient.
